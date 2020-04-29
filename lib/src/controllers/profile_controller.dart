import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/order.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/repository/order_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart' as repository;

class ProfileController extends ControllerMVC {
  List<Order> recentOrders = [];
  GlobalKey<ScaffoldState> scaffoldKey;

  ProfileController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForRecentOrders();
  }
  void update(User user) async {
    repository.update(user).then((value) {
      setState(() {
        //this.favorite = value;
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.profile_settings_updated_successfully),
      ));
    });
  }
  void listenForRecentOrders({String message}) async {
    final Stream<Order> stream = await getRecentOrders();
    stream.listen((Order _order) {
      setState(() {
        recentOrders.add(_order);
      });
    }, onError: (a) {
      print(a);
      /*scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshProfile() async {
    recentOrders.clear();
    listenForRecentOrders(message: S.current.orders_refreshed_successfuly);
  }
}
