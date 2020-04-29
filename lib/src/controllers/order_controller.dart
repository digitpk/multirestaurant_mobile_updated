import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/order.dart';
import 'package:food_delivery_app/src/repository/order_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class OrderController extends ControllerMVC {
  List<Order> orders = <Order>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isDataEmpty = false;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForOrders();
  }

  void listenForOrders({String message}) async {
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {
      if(orders.length == 0) {
        setState(() {
          isDataEmpty = true;
        });
      }
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.current.order_refreshed_successfuly);
  }
}
