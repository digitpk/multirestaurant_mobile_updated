import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/splash_screen_controller.dart';
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/models/setting.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart'
as userRepo;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
as settingRepo;

class SplashScreen extends StatefulWidget {
  static bool isFirstTime = true;
  static Setting appSetting;
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;
  bool isOutOfTownArea = false;
  List<ResCategory> resCategories = <ResCategory>[];
  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    Future<String> future = userRepo.getLanguage();
    future.then((language_code) {
      if (language_code != null) {
        settingRepo.locale.value = new Locale(language_code, '');
        settingRepo.locale.notifyListeners();
      } else {
        settingRepo.locale.value = new Locale('he', '');
        settingRepo.locale.notifyListeners();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/logo.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              isOutOfTownArea ?  Text(
                S.of(context).multirestaurants,
                style: Theme.of(context).textTheme.display1.merge(
                    TextStyle(
                        color:
                        Theme.of(context).scaffoldBackgroundColor)),
              ): Container(),
              isOutOfTownArea ? Container() : SizedBox(height: 50),
              isOutOfTownArea
                  ? Container()
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).hintColor),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
