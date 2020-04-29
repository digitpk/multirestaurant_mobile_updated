import 'dart:convert';
import 'package:food_delivery_app/src/models/credit_card.dart';
import 'package:http/http.dart' as http;
import 'package:food_delivery_app/constants.dart' as Constants;
import 'package:food_delivery_app/src/controllers/yaadpay_controller.dart';

Future<Stream<String>> getSignature(String url) async {
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder);
}

Future<Stream<String>> getTokenSavingCreditCard(
    String transId, String orderId) async {
  final client = new http.Client();
  //field1=name,field2=email,field3=orderId
  String url =
      "https://icom.yaad.net/p/?action=getToken&Masof=${Constants.YAADPAY_MASOF}&PassP=${Constants.YAADPAY_PASS}&TransId=$transId"
      "&Fild1=Israeli&Fild2=demo&Fild3=$orderId";
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder);
}

Future<Stream<String>> submitTokenToSoftProtocol(CreditCard creditCard,
    String orderId, String amount, String heshDesc) async {
  final client = new http.Client();
  /*String url = "https://icom.yaad.net/p3/?action=soft&Masof=${Constants.YAADPAY_MASOF}&PassP=${Constants.YAADPAY_PASS}"
      "&Amount=$amount&CC=${creditCard.token}&Tmonth=${creditCard.expMonth}&Tyear=${creditCard.expYear}&Coin=1"
      "&Info=&Order=$orderId&Tash=2&UserId=${Constants.YAADPAY_USERID}&ClientLName=Israeli&ClientName=Israel"
      "&cell=050555555555&phone=098610338&city=netanya&email=test@yaad.net&street=levanon+3&zip=42361&J5=False&MoreData=True&Postpone=False"
      "&Pritim=True&SendHesh=True&heshDesc=$heshDesc&sendemail=True&UTF8=True&UTF8out=True&Fild1=freepram&Fild2=freepram"
      "&Fild3=freepram&Token=True";*/
  String url =
      "https://icom.yaad.net/p3/?action=soft&Masof=${Constants.YAADPAY_MASOF}&PassP=${Constants.YAADPAY_PASS}&Amount=$amount"
      "&CC=${creditCard.token}&Tmonth=${creditCard.expMonth}&Tyear=${creditCard.expYear}&Coin=1&Info='test-api'&Order=$orderId&Tash=1"
      "&UserId=${Constants.YAADPAY_USERID}&ClientLName=&ClientName=AppUser&cell=&phone=&city=&email=&street=&zip=&J5=False&MoreData=True"
      "&Postpone=False&Pritim=True&SendHesh=True"
      "&heshDesc=$heshDesc&sendemail=True&UTF8=True&UTF8out=True&Fild1=freepram&Fild2=freepram&Fild3=freepram&Token=True";

  print('Soft Protocol url:$url');
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder);
}
