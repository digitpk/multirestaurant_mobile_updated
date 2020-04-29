import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;
import 'package:food_delivery_app/src/repository/user_repository.dart' as userRepo;
import 'package:mvc_pattern/mvc_pattern.dart';

class Controller extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  Controller() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    settingRepo.initSettings().then((setting) {
      setState(() {
        settingRepo.setting.value = setting;
      });
    });
    settingRepo.setCurrentLocation().then((locationData) {
      setState(() {
        settingRepo.locationData = locationData;
      });
    });
    userRepo.getCurrentUser().then((user) {
      setState(() {
        userRepo.currentUser.value = user;
      });
    });
  }
}
