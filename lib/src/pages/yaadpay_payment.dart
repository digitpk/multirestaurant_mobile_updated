import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:food_delivery_app/src/models/credit_card.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/yaadpay_controller.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart' as userRepo;
import 'package:food_delivery_app/src/repository/yaadpay_repository.dart';

class YaadPayPaymentWidget extends StatefulWidget {
  RouteArgument routeArgument;
  YaadPayPaymentWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _YaadPayPaymentWidgetState createState() => _YaadPayPaymentWidgetState();
}

class _YaadPayPaymentWidgetState extends StateMVC<YaadPayPaymentWidget> {
  YaadPayController _con;
  bool isIos = false;
  _YaadPayPaymentWidgetState() : super(YaadPayController()) {
    _con = controller;
  }
  void goToOrderSuccessPage()
  {
    Navigator.of(context).pushReplacementNamed(
        '/YaadPayCreditCard',
        arguments: new RouteArgument(
            param: 'Credit Card (YaasPay Gateway)'));
  }
  void saveCreditCardToken(String transactionId) async
  {
    setState(() {
      _con.url = "";
    });
    final Stream<String> stream =
        await getTokenSavingCreditCard(transactionId,_con.orderId);
    stream.listen((String response) async{
      print('getToken Response:$response');
      String token = "";
      String ccMonth = "";
      String ccYear = "";
      List<String> splitUrl = response.split("&");
      for (var i = 0; i < splitUrl.length; i++) {
        String splitItem = splitUrl[i];
        if (splitItem.startsWith("Token")) {
          List<String> splitValue = splitItem.split("=");
          token = splitValue[1];
          print("token:$token");
        }
        if (splitItem.startsWith("Tokef")) {
          List<String> splitValue = splitItem.split("=");
          String ccDate = splitValue[1];
          print("ccDate:$ccDate");
          for (var i = 0; i < ccDate.length; i++) {
            if(i < 2)
            {
              ccYear = ccYear + ccDate[i];
            }else{
              ccMonth = ccMonth + ccDate[i];
            }
          }
        }
      }
      userRepo.getCreditCard().then((creditCard){
        creditCard.token = token;
        creditCard.expYear = ccYear;
        creditCard.expMonth = ccMonth;
        userRepo.setCreditCard(creditCard);
        goToOrderSuccessPage();
      });
    });
  }
  void savingCardAlert(String cardLast4Digit,String transactionId) {
    Alert(
      context: context,
      type: AlertType.none,
      title: S.of(context).saving_card_alert_title,
      desc: S.of(context).saving_card_alert_message("XXXX-XXXX-XXXX-$cardLast4Digit"),
      style: AlertStyle(
          titleStyle: Theme.of(context)
              .textTheme
              .display1
              .merge(TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          descStyle: Theme.of(context)
              .textTheme
              .caption
              .merge(TextStyle(fontSize: 20, fontWeight: FontWeight.w200))),
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).alert_yes,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
            CreditCard creditCard = CreditCard();
            creditCard.number = "XXXX-XXXX-XXXX-$cardLast4Digit";
            userRepo.setCreditCard(creditCard);
            saveCreditCardToken(transactionId);
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            S.of(context).alert_no,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
            goToOrderSuccessPage();
          },
          width: 50,
        ),
      ],
    ).show();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).yaadpay_payment,
          style: Theme.of(context)
              .textTheme
              .title
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: _con.url.isEmpty
          ? CircularLoadingWidget(height: 300)
          : Stack(
              children: <Widget>[
                InAppWebView(
                  initialUrl: _con.url,
                  initialHeaders: {},
                  initialOptions: {},//for version 1.2.2
                  /*initialOptions: InAppWebViewWidgetOptions(
                    inAppWebViewOptions: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),*/
                  onWebViewCreated: (InAppWebViewController controller) {
                    _con.webView = controller;
                  },
                  onLoadStop: (InAppWebViewController controller, String url){
                    setState(() {
                      _con.url = url;
                      print('web return url: ${_con.url}');
                      if (_con.url.startsWith(
                          "https://icom.yaad.net/yaadpay/tmp/apitest/yaadsuccesspagedemo.htm")) {
                        List<String> splitUrl1 = _con.url.split("?");
                        List<String> splitUrl = splitUrl1[1].split("&");
                        String transactionId = "";
                        String last4Digit = "";
                        int transactionStatus = -1;
                        for (var i = 0; i < splitUrl.length; i++) {
                          String splitItem = splitUrl[i];
                          if (splitItem.startsWith("CCode")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionStatus = int.parse(splitValue[1]);
                            print("transactionStatus:$transactionStatus");
                          }
                          if (splitItem.startsWith("Id")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionId = splitValue[1];
                            print("transactionId:$transactionId");
                          }
                          if (splitItem.startsWith("L4digit")) {
                            List<String> splitValue = splitItem.split("=");
                            last4Digit = splitValue[1];
                            print("transactionId:$last4Digit");
                          }
                        }

                        if (transactionStatus == 0) {
                          /*Navigator.of(context).pushReplacementNamed(
                              '/YaadPayCreditCard',
                              arguments: new RouteArgument(
                                  param: 'Credit Card (YaasPay Gateway)'));*/
                          savingCardAlert(last4Digit,transactionId);
                        } else {
                          //transaction failed
                        }
                      }
                      //for live return url
                      if (_con.url.startsWith(
                          "https://icom.yaad.net/p3/?action=thankYouPage")) {
                        List<String> splitUrl1 = _con.url.split("?");
                        List<String> splitUrl = splitUrl1[1].split("&");
                        String tranId = "";
                        String last4Digit = "";
                        int transactionStatus = -1;
                        for (var i = 0; i < splitUrl.length; i++) {
                          String splitItem = splitUrl[i];
                          if (splitItem.startsWith("CCode")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionStatus = int.parse(splitValue[1]);
                            print("transactionStatus:$transactionStatus");
                          }
                          if (splitItem.startsWith("Id")) {
                            List<String> splitValue = splitItem.split("=");
                            tranId = splitValue[1];
                            print("transactionId:$tranId");
                          }
                          if (splitItem.startsWith("L4digit")) {
                            List<String> splitValue = splitItem.split("=");
                            last4Digit = splitValue[1];
                            print("transactionId:$last4Digit");
                          }
                        }
                        if (transactionStatus == 0) {
                          /*Navigator.of(context).pushReplacementNamed(
                              '/YaadPayCreditCard',
                              arguments: new RouteArgument(
                                  param: 'Credit Card (YaasPay Gateway)'));*/
                          savingCardAlert(last4Digit,tranId);
                        } else {
                          //transaction failed
                        }
                      }
                    });
                  },
                  /*onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      _con.url = url;
                      print('web return url: ${_con.url}');
                      if (_con.url.startsWith(
                          "https://icom.yaad.net/yaadpay/tmp/apitest/yaadsuccesspagedemo.htm")) {
                        List<String> splitUrl1 = _con.url.split("?");
                        List<String> splitUrl = splitUrl1[1].split("&");
                        String transactionId = "";
                        int transactionStatus = -1;
                        for (var i = 0; i < splitUrl.length; i++) {
                          String splitItem = splitUrl[i];
                          if (splitItem.startsWith("Id")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionId = splitValue[1];
                            print("transactionId:$transactionId");
                          }
                          if (splitItem.startsWith("CCode")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionStatus = int.parse(splitValue[1]);
                            print("transactionStatus:$transactionStatus");
                          }
                        }
                        if (transactionStatus == 0) {
                          Navigator.of(context).pushReplacementNamed(
                              '/YaadPayCreditCard',
                              arguments: new RouteArgument(
                                  param: 'Credit Card (YaasPay Gateway)'));
                        } else {
                          //transaction failed
                        }
                      }
                      //for live return url
                      if (_con.url.startsWith(
                          "https://icom.yaad.net/p3/?action=thankYouPage")) {
                        List<String> splitUrl1 = _con.url.split("?");
                        List<String> splitUrl = splitUrl1[1].split("&");
                        String transactionId = "";
                        int transactionStatus = -1;
                        for (var i = 0; i < splitUrl.length; i++) {
                          String splitItem = splitUrl[i];
                          if (splitItem.startsWith("Id")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionId = splitValue[1];
                            print("transactionId:$transactionId");
                          }
                          if (splitItem.startsWith("CCode")) {
                            List<String> splitValue = splitItem.split("=");
                            transactionStatus = int.parse(splitValue[1]);
                            print("transactionStatus:$transactionStatus");
                          }
                        }
                        if (transactionStatus == 0) {
                          Navigator.of(context).pushReplacementNamed(
                              '/YaadPayCreditCard',
                              arguments: new RouteArgument(
                                  param: 'Credit Card (YaasPay Gateway)'));
                        } else {
                          //transaction failed
                        }
                      }
                    });
                    //for testing return url

                  },*/
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      _con.progress = progress / 100;
                    });
                  },
                ),

                _con.progress < 1
                    ? SizedBox(
                        height: 3,
                        child: LinearProgressIndicator(
                          value: _con.progress,
                          backgroundColor:
                              Theme.of(context).accentColor.withOpacity(0.2),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
    );
  }
}
