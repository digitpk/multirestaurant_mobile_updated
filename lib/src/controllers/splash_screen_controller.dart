import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/splash_screen.dart';
import 'package:food_delivery_app/src/repository/category_repository.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;
import 'package:mvc_pattern/mvc_pattern.dart';

class SplashScreenController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<ResCategory> resCategories = <ResCategory>[];
  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  @override
  void initState() {
    settingRepo.initSettings().then((setting) async{
      final Stream<ResCategory> stream = await getResCategories();
      stream.listen((ResCategory _category) {
        resCategories.add(_category);
      }, onError: (a) {
        print('onError');
      }, onDone: () {
        print('Categories lenght:${resCategories.length}');
        setState(() {
          settingRepo.setting.value = setting;
          SplashScreen.appSetting = setting;
        });
        loadData();
      });
    });

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("splash screen onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("splash screen onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print(" splash screen  onResume: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );

    super.initState();
  }
  void loadData() {
    Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/ResCategories',
        arguments: RouteArgument(param: resCategories));
  }
  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }
    print("splash screen myBackgroundMessageHandler");
  }
}
