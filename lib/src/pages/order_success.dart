import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/checkout_controller.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/order_json_array_item.dart';
import 'package:food_delivery_app/src/models/payment.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
    as settingRepo;
import 'package:food_delivery_app/src/repository/user_repository.dart'
    as userRepo;
import 'package:food_delivery_app/src/repository/yaadpay_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class OrderSuccessWidget extends StatefulWidget {
  RouteArgument routeArgument;

  OrderSuccessWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _OrderSuccessWidgetState createState() => _OrderSuccessWidgetState();
}

class _OrderSuccessWidgetState extends StateMVC<OrderSuccessWidget> {
  CheckoutController _con;
  String amount = "0";
  String heshDesc = "";
  String orderId = "12345678910";

  _OrderSuccessWidgetState() : super(CheckoutController()) {
    _con = controller;
  }

  @override
  void initState() {
    // route param contains the payment method
    _con.payment = new Payment(widget.routeArgument.param);
    if (widget.routeArgument.param == "Pay with Token") {
      getOrderAmount();
    } else {
      _con.listenForCarts(withAddOrder: true);
    }

    super.initState();
  }

  void getOrderAmount() async {
    Future<String> future = userRepo.getOrderAmount();
    future.then((orderAmount) {
      amount = orderAmount; //for live
      print('OrderAmount:$orderAmount');
      getOrderJsonArray();
    });
  }

  void getOrderJsonArray() async {
    Future<String> future = userRepo.getOrderJsonArray();
    future.then((jsonArray) {
      print('OrderjsonArray:$jsonArray');
      List<dynamic> decodedJSON;
      try {
        decodedJSON = json.decode(jsonArray) as List<dynamic>;
        print('decodedJSON:$decodedJSON');
        for (int i = 0; i < decodedJSON.length; i++) {
          String formateOrderYaadPay = "";
          OrderJsonArrayItem orderJsonArrayItem =
              OrderJsonArrayItem.fromJSON(decodedJSON[i]);
          print('FoodName:${orderJsonArrayItem.food_name}');
          formateOrderYaadPay =
              "%5B0~${orderJsonArrayItem.food_name}~${orderJsonArrayItem.quantity}~${orderJsonArrayItem.food_price_extra}%5D";
          heshDesc = "$heshDesc$formateOrderYaadPay";
        }
        String deliveryFee = "";
        deliveryFee =
            "%5B0~Delivery fee~1~${settingRepo.setting.value.defaultTax}%5D";
        heshDesc = "$heshDesc$deliveryFee";
        print('heshDesc:$heshDesc');

        userRepo.getCreditCard().then((creditCard) async {
          final Stream<String> stream = await submitTokenToSoftProtocol(creditCard,orderId,amount,heshDesc);
          stream.listen((String response) async {
            print('submitToken Response:$response');
            List<String> splitUrl = response.split("&");
            String tranId = "";
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

            }
            if (transactionStatus == 0) {
              _con.listenForCarts(withAddOrder: true);
            } else {
              //transaction failed
            }
          });
        });
      } on FormatException catch (e) {
        print("The provided string is not valid JSON addCart:$e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              //Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed('/Pages', arguments: 3);
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).confirmation,
            style: Theme.of(context)
                .textTheme
                .title
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: _con.carts.isEmpty
            ? CircularLoadingWidget(height: 500)
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    alignment: AlignmentDirectional.center,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Colors.green.withOpacity(1),
                                        Colors.green.withOpacity(0.2),
                                      ])),
                              child: _con.loading
                                  ? Padding(
                                      padding: EdgeInsets.all(55),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor),
                                      ),
                                    )
                                  : Icon(
                                      Icons.check,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      size: 90,
                                    ),
                            ),
                            Positioned(
                              right: -30,
                              bottom: -50,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(150),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -20,
                              top: -50,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(150),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Opacity(
                          opacity: 0.4,
                          child: Text(
                            S
                                .of(context)
                                .your_order_has_been_successfully_submitted,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .display2
                                .merge(TextStyle(fontWeight: FontWeight.w300)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      //height: 255,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.15),
                                offset: Offset(0, -2),
                                blurRadius: 5.0)
                          ]),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).subtotal,
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                                Helper.getPrice(_con.subTotal, context,
                                    style: Theme.of(context).textTheme.subhead)
                              ],
                            ),
                            SizedBox(height: 3),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).delivery_fee,
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
//                                Helper.getPrice(_con.carts[0].food.restaurant.deliveryFee, context,
                                Helper.getPrice(
                                    settingRepo.setting.value.defaultTax,
                                    context,
                                    style: Theme.of(context).textTheme.subhead)
                              ],
                            ),
                            /*SizedBox(height: 3),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "${S.of(context).tax} (${setting.value.defaultTax}%)",
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                                Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subhead)
                              ],
                            ),*/
                            Divider(height: 30),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).total,
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                ),
                                Helper.getPrice(_con.total, context,
                                    style: Theme.of(context).textTheme.title)
                              ],
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed('/Pages', arguments: 3);
                                },
                                padding: EdgeInsets.symmetric(vertical: 14),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Text(
                                  S.of(context).my_orders,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            //SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ));
  }
}
