import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/food_order.dart';
import 'package:food_delivery_app/src/models/res_opening_hours.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

class Helper {
  // for mapping data retrieved form json array
  static getData(Map<String, dynamic> data) {
    return data['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool) ?? false;
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  static Future<Marker> getMarker(Map<String, dynamic> res) async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/img/marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(res['id']),
        icon: BitmapDescriptor.fromBytes(markerIcon),
//        onTap: () {
//          //print(res.name);
//        },
        anchor: Offset(0.5, 0.5),
        infoWindow: InfoWindow(
            title: res['name'],
            snippet: res['distance'].toStringAsFixed(2) + ' mi',
            onTap: () {
              print('infowi tap');
            }),
        position: LatLng(double.parse(res['latitude']), double.parse(res['longitude'])));

    return marker;
  }

  static Future<Marker> getMyPositionMarker(double latitude, double longitude) async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/img/my_marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(Random().nextInt(100).toString()),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        anchor: Offset(0.5, 0.5),
        position: LatLng(latitude, longitude));

    return marker;
  }

  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
    }));
    return list;
  }

//  static Future<List> getPriceWithCurrency(double myPrice) async {
//    final Setting _settings = await getCurrentSettings();
//    List result = [];
//    if (myPrice != null) {
//      result.add('${myPrice.toStringAsFixed(2)}');
//      if (_settings.currencyRight) {
//        return '${myPrice.toStringAsFixed(2)} ' + _settings.defaultCurrency;
//      } else {
//        return _settings.defaultCurrency + ' ${myPrice.toStringAsFixed(2)}';
//      }
//    }
//    if (_settings.currencyRight) {
//      return '0.00 ' + _settings.defaultCurrency;
//    } else {
//      return _settings.defaultCurrency + ' 0.00';
//    }
//  }

  static Widget getPrice(double myPrice, BuildContext context, {TextStyle style}) {
    if (style != null) {
      style = style.merge(TextStyle(fontSize: style.fontSize + 2));
    }
    try {
      return RichText(
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        text: setting.value?.currencyRight != null && setting.value?.currencyRight == false
            ? TextSpan(
          text: setting.value?.defaultCurrency,
          style: style ?? Theme.of(context).textTheme.subhead,
          children: <TextSpan>[
            TextSpan(text: myPrice.toStringAsFixed(2) ?? '', style: style ?? Theme.of(context).textTheme.subhead),
          ],
        )
            : TextSpan(
          text: myPrice.toStringAsFixed(2) ?? '',
          style: style ?? Theme.of(context).textTheme.subhead,
          children: <TextSpan>[
            TextSpan(
                text: setting.value?.defaultCurrency,
                style: TextStyle(
                    fontWeight: FontWeight.w400, fontSize: style != null ? style.fontSize - 4 : Theme.of(context).textTheme.subhead.fontSize - 4)),
          ],
        ),
      );
    } catch (e) {
      return Text('');
    }
  }
  static double getTotalOrderPrice(FoodOrder foodOrder, double tax) {
    double total = foodOrder.price * foodOrder.quantity;
    foodOrder.extras.forEach((extra) {
      total += extra.price != null ? extra.price : 0;
    });
    //total += deliveryFee;
    //total += tax * total / 100;
    total = tax + total;
    return total;
  }

  static String getDistance(double distance) {
    print('before convert distance:$distance');
    distance = distance * 1.60934 * 1.60934;
    print('after convert distance:$distance');
    return distance.toStringAsFixed(2) + " km";
  }

  static String skipHtml(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  static Html applyHtml(context, String html, {TextStyle style}) {
    return Html(
      blockSpacing: 0,
      data: html,
      defaultTextStyle: style ?? Theme.of(context).textTheme.body2.merge(TextStyle(fontSize: 14)),
      useRichText: false,
      customRender: (node, children) {
        if (node is dom.Element) {
          switch (node.localName) {
            case "br":
              return SizedBox(
                height: 0,
              );
            case "p":
              return Padding(
                padding: EdgeInsets.only(top: 0, bottom: 0),
                child: Container(
                  width: double.infinity,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.start,
                    children: children,
                  ),
                ),
              );
          }
        }
        return null;
      },
    );
  }

  static String limitString(String text, {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) + (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number != null && number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static String trans(String text) {
    switch (text) {
      case "App\\Notifications\\StatusChangedOrder":
        return S.current.order_status_changed;
      case "App\\Notifications\\NewOrder":
        return S.current.new_order_from_client;
      default:
        return "";
    }
  }
  static Future<bool> getResOpeningStatus(
      List<ResOpeningHours> resOpeningHoursList) async {
    print('getResOpeningStatus');
    bool resOpeningStatus = false;
    if (resOpeningHoursList.isNotEmpty) {
      DateTime date = DateTime.now();
      String currentWeekOfDay = DateFormat('EEEE').format(date);
      print('currentWeekOfDay:$currentWeekOfDay');
      for (int i = 0; i < resOpeningHoursList.length; i++) {
        ResOpeningHours resOpeningHours = resOpeningHoursList[i];
        if (currentWeekOfDay == resOpeningHours.week) {
          if (resOpeningHours.is_open == "1") {
            print('ResOpeningHours:${resOpeningHours.toMap()}');
            final currentTime = DateTime.now();
            final startTime = DateTime(
                currentTime.year,
                currentTime.month,
                currentTime.day,
                int.parse(resOpeningHours.start_hours),
                int.parse(resOpeningHours.start_minutes),
                0);
            final endTime = DateTime(
                currentTime.year,
                currentTime.month,
                currentTime.day,
                int.parse(resOpeningHours.end_hours),
                int.parse(resOpeningHours.end_minutes),
                0);

            print('startTime:$startTime');
            print('endTime:$endTime');
            if (currentTime.isAfter(startTime) &&
                currentTime.isBefore(endTime)) {
              // do something
              resOpeningStatus = true;
            }
          }
          break;
        }
      }
    }
    print('resOpeningStatus:$resOpeningStatus');
    return resOpeningStatus;
  }
  static String getRandomAvatar(){
    List<String> listOfAvatar = List();
    listOfAvatar.add("assets/img/avatar_1.png");
    listOfAvatar.add("assets/img/avatar_2.png");
    listOfAvatar.add("assets/img/avatar_3.png");
    listOfAvatar.add("assets/img/avatar_4.png");
    listOfAvatar.add("assets/img/avatar_5.png");
    listOfAvatar.add("assets/img/avatar_6.png");
    listOfAvatar.add("assets/img/avatar_7.png");
    listOfAvatar.add("assets/img/avatar_8.png");
    listOfAvatar.add("assets/img/avatar_9.png");
    listOfAvatar.add("assets/img/avatar_10.png");
    listOfAvatar.add("assets/img/avatar_11.png");
    listOfAvatar.add("assets/img/avatar_12.png");
    listOfAvatar.add("assets/img/avatar_13.png");
    listOfAvatar.add("assets/img/avatar_14.png");
    listOfAvatar.add("assets/img/avatar_15.png");
    listOfAvatar.add("assets/img/avatar_16.png");
    listOfAvatar.add("assets/img/avatar_17.png");
    int min = 0;
    int max = 16;
    Random rnd = new Random();
    int randomNumber = min + rnd.nextInt(max - min);
    print('random Number:$randomNumber');
    return listOfAvatar[randomNumber];
  }
}
