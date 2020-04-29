import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:food_delivery_app/constants.dart' as Constants;
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/order_json_array_item.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
    as settingRepo;
import 'package:food_delivery_app/src/repository/user_repository.dart'
    as userRepo;
import 'package:food_delivery_app/src/repository/yaadpay_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class YaadPayController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  InAppWebViewController webView;
  String url = "";
  double progress = 10;
  String amount = "0";
  String heshDesc = "";
  String orderId = "12345678910";

  //heshDesc=[0~Item 1~1~8][0~Item 2~2~1]
  String orderItems = "";

  YaadPayController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    heshDesc = "";
    amount = "0";
    getOrderAmount();
  }

  void getOrderAmount() async {
    Future<String> future = userRepo.getOrderAmount();
    future.then((orderAmount) {
      amount = orderAmount; //for live
//      this.amount = "10";// for testing
      print('OrderAmount:$orderAmount');
      //getSignatureFromYaadPayApi();
      getOrderJsonArray();
    });
  }

  void getOrderJsonArray() async {
    Future<String> future = userRepo.getOrderJsonArray();
    future.then((jsonArray) {
      print('OrderjsonArray:$jsonArray');
      List<dynamic> decodedJSON = null;
      try {
        decodedJSON = json.decode(jsonArray) as List<dynamic>;
        print('decodedJSON:$decodedJSON');
        for (int i = 0; i < decodedJSON.length; i++) {
          String formateOrderYaadPay = "";
          OrderJsonArrayItem orderJsonArrayItem =
              OrderJsonArrayItem.fromJSON(decodedJSON[i]);
          print('FoodName:${orderJsonArrayItem.food_name}');
//          formateOrderYaadPay = "[0~${orderJsonArrayItem.food_name}~${orderJsonArrayItem.quantity}~${orderJsonArrayItem.food_price}]";
          formateOrderYaadPay =
              "[0~${orderJsonArrayItem.food_name}~${orderJsonArrayItem.quantity}~${orderJsonArrayItem.food_price_extra}]";
          heshDesc = "$heshDesc$formateOrderYaadPay";
        }
        String deliveryFee = "";
        deliveryFee = "[0~Delivery fee~1~${settingRepo.setting.value.defaultTax}]";
        heshDesc = "$heshDesc$deliveryFee";
        print('heshDesc:$heshDesc');
        getSignatureFromYaadPayApi();
      } on FormatException catch (e) {
        print("The provided string is not valid JSON addCart:$e");
      }
    });
  }

  void getSignatureFromYaadPayApi() async {
    /*String url =
        'https://icom.yaad.net/p3/?action=APISign&What=SIGN&KEY=${Constants.YAADPAY_KEY}&PassP=${Constants.YAADPAY_PASS}&Masof=${Constants.YAADPAY_MASOF}'
        '&Order=$orderId&Info=&Amount=${amount}&UTF8=True&UTF8out=True&UserId=${Constants.YAADPAY_USERID}&ClientName=Israel&ClientLName=Isareli&street=levanon+3'
        '&city=netanya&zip=42361&phone=098610338&cell=050555555555&email=test@yaad.net&Tash=2&FixTash=False&ShowEngTashText=False&Coin=1&Postpone=False'
        '&J5=False&Sign=True&MoreData=True&sendemail=True&SendHesh=True&heshDesc=$heshDesc]&Pritim=True&PageLang=HEB&tmp=${Constants.YAADPAY_TMP}';*/
    String url ="https://icom.yaad.net/p3/?action=APISign&What=SIGN&KEY=${Constants.YAADPAY_KEY}&PassP=${Constants.YAADPAY_PASS}&Masof=${Constants.YAADPAY_MASOF}"
        "&Order=$orderId&Info=&Amount=$amount&UTF8=True&UTF8out=True&UserId=&ClientName=AppUser&ClientLName=&street=&city=&zip=&phone=&cell=&email=&Tash=1&FixTash=False&ShowEngTashText=False&Coin=1&Postpone=False&J5=False&Sign=True&MoreData=True&sendemail=True&SendHesh=True"
        "&heshDesc=$heshDesc&Pritim=True&PageLang=HEB&tmp=${Constants.YAADPAY_TMP}";
    print('ApiSign:$url');
    final Stream<String> stream = await getSignature(url);
    stream.listen((String response) {
      print('Signature Response:$response');
      String signature = "";
      String heshDesc = "";
      List<String> splitUrl = response.split("&");
      for (var i = 0; i < splitUrl.length; i++) {
        String splitItem = splitUrl[i];
        if (splitItem.startsWith("signature")) {
          List<String> splitValue = splitItem.split("=");
          signature = splitValue[1];
          print("signature:$signature");
        }
        if (splitItem.startsWith("heshDesc")) {
          List<String> splitValue = splitItem.split("=");
          heshDesc = splitValue[1];
          print("heshDesc:$heshDesc");
        }
      }
      setState(() {
        /*this.url =
            'https://icom.yaad.net/p3/?action=pay&Amount=${amount}&ClientLName=Isareli&ClientName=Israel&Coin=1&FixTash=False&Info=&J5=False'
                '&Masof=${Constants.YAADPAY_MASOF}&MoreData=True&Order=$orderId&PageLang=HEB&Postpone=False&Pritim=True&SendHesh=True'
                '&ShowEngTashText=False&Sign=True&Tash=2&UTF8=True&UTF8out=True&UserId=${Constants.YAADPAY_USERID}&action=pay&cell=050555555555&city=netanya'
                '&email=test%40yaad.net&heshDesc=$heshDesc&phone=098610338&sendemail=True&street=levanon%203&tmp=${Constants.YAADPAY_TMP}'
                '&zip=42361&signature=$signature';*/
        this.url = "https://icom.yaad.net/p3/?action=pay&Amount=$amount&ClientLName=&ClientName=AppUser&Coin=1&FixTash=False&Info=&J5=False"
            "&Masof=${Constants.YAADPAY_MASOF}&MoreData=True&Order=$orderId&PageLang=HEB&Postpone=False&Pritim=True&SendHesh=True&ShowEngTashText=False&Sign=True&Tash=1&UTF8=True&UTF8out=True&UserId=&action=pay&cell=&city=&email="
            "&heshDesc=$heshDesc&phone=&sendemail=True&street=&tmp=${Constants.YAADPAY_TMP}&zip=&signature=$signature";
        print("Payment url:${this.url}");
        //webView.loadUrl(this.url);
      });
    }, onError: (a) {
      print(a);
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {});
  }
}
