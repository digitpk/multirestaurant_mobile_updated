import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/pages/splash_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/cart_controller.dart';
import 'package:food_delivery_app/src/elements/CartItemWidget.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/EmptyCartWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
    as settingRepo;
import 'package:food_delivery_app/src/repository/user_repository.dart'
    as userRepo;
import 'package:location_permissions/location_permissions.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:io' show Platform;

class CartWidget extends StatefulWidget {
  RouteArgument routeArgument;

  CartWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  CartController _con;
  bool isLoading = false;

  _CartWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }
  void checkoutAlert(String message) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: S.of(context).checkout,
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).alert_ok,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  void minOrderAlert(double minOrderPrice) {
    Alert(
      context: context,
      type: AlertType.info,
      title: S.of(context).alert_title_min_order,
      desc: S.of(context).alert_message_min_order(minOrderPrice,SplashScreen
          .appSetting.defaultCurrency),
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).alert_ok,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }
  void locationEnableAlert() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: S.of(context).alert_location_service_title,
      desc: S.of(context).alert_location_service_message,
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).alert_location_service_btn,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            //LocationPermissions().openAppSettings();
            AppSettings.openLocationSettings();
          },
          width: 120,
        )
      ],
    ).show();
  }

  void checkLocationPermission() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    print('geolocationStatus.value:${geolocationStatus.value}');
    if (geolocationStatus.value != 2) {
      requestLocationPermission();
    } else {
      ServiceStatus serviceStatus =
          await LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == ServiceStatus.enabled) {
        goToDeliveryAddress();
      } else {
        locationEnableAlert();
      }
    }
  }

  Future<bool> requestLocationPermission() async {
    return _requestPermission();
  }

  Future<bool> _requestPermission() async {
    print('_requestPermission');
    var result = await LocationPermissions().requestPermissions();
    if (result == PermissionStatus.granted) {
      ServiceStatus serviceStatus =
          await LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == ServiceStatus.enabled) {
        goToDeliveryAddress();
      } else {
        locationEnableAlert();
      }
      return true;
    } else {
      print('PermissionStatus not granted');
      //if (Platform.isIOS) {
      ServiceStatus serviceStatus =
          await LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == ServiceStatus.disabled) {
        locationEnableAlert();
      } else {
        Alert(
          context: context,
          type: AlertType.warning,
          title: S.of(context).alert_location_service_permission_title,
          desc: S.of(context).alert_location_service_permission_message,
          buttons: [
            DialogButton(
              child: Text(
                S.of(context).alert_location_service_btn,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                LocationPermissions().openAppSettings();
              },
              width: 120,
            )
          ],
        ).show();
      }
      //}
    }
    return false;
  }

  void goToDeliveryAddress() {
    List<Map> params = _con.carts.map((element) => element.toMap()).toList();
    String orderItams = json.encode(params);
    print('orderItams:$orderItams');
    print('_con.total:${_con.total}');
    userRepo.setOrderJsonArray(orderItams);
    userRepo.setOrderAmount(_con.total.toString());
    Navigator.of(context).pushNamed('/DeliveryAddresses',
        arguments: new RouteArgument(param: [
          _con.carts,
          _con.total,
          settingRepo.setting.value.defaultTax
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              /*if (widget.routeArgument.param == '/Food') {
                Navigator.of(context).pushReplacementNamed('/Food',
                    arguments: RouteArgument(id: widget.routeArgument.id));
              } else {
                Navigator.of(context)
                    .pushReplacementNamed('/Pages', arguments: 2);
              }*/
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(context)
                .textTheme
                .title
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _con.refreshCarts,
          child: _con.carts.isEmpty
              ? EmptyCartWidget()
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 150),
                      padding: EdgeInsets.only(bottom: 15),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 0),
                                leading: Icon(
                                  Icons.shopping_cart,
                                  color: Theme.of(context).hintColor,
                                ),
                                title: Text(
                                  S.of(context).shopping_cart,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.display1,
                                ),
                                subtitle: Text(
                                  S
                                      .of(context)
                                      .verify_your_quantity_and_click_checkout,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ),
                            ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: _con.carts.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 15);
                              },
                              itemBuilder: (context, index) {
                                return CartItemWidget(
                                  cart: _con.carts.elementAt(index),
                                  heroTag: 'cart',
                                  increment: () {
                                    _con.incrementQuantity(
                                        _con.carts.elementAt(index));
                                  },
                                  decrement: () {
                                    _con.decrementQuantity(
                                        _con.carts.elementAt(index));
                                  },
                                  onDismissed: () {
                                    _con.removeFromCart(
                                        _con.carts.elementAt(index));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
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
                                      style:
                                          Theme.of(context).textTheme.subhead)
                                ],
                              ),
                              SizedBox(height: 5),
                              /*Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      S.of(context).delivery_fee,
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                  Helper.getPrice(_con.carts[0].food.restaurant.deliveryFee, context,
                                      style: Theme.of(context).textTheme.subhead)
                                ],
                              ),*/
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${S.of(context).delivery_fee}',
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                  Helper.getPrice(
                                      settingRepo.setting.value.defaultTax,
                                      context,
                                      style:
                                          Theme.of(context).textTheme.subhead)
                                ],
                              ),
                              SizedBox(height: 10),
                              isLoading
                                  ? CircularLoadingWidget(
                                      height: 50,
                                    )
                                  : Stack(
                                      fit: StackFit.loose,
                                      alignment: AlignmentDirectional.centerEnd,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          child: FlatButton(
                                            onPressed: () {
//                                        Navigator.of(context).pushNamed('/PaymentMethod',
//                                            arguments:
//                                                new RouteArgument(param: [_con.carts, _con.total, setting.defaultTax]));
                                              /* Navigator.of(context).pushNamed('/DeliveryAddresses',
                                            arguments: new RouteArgument(
                                                param: [_con.carts, _con.total, setting.value.defaultTax]));*/
                                              if (_con.subTotal >=
                                                  _con.carts
                                                      .elementAt(0)
                                                      .food
                                                      .restaurant
                                                      .minOrderPrice) {
                                                setState(() {
                                                  isLoading = true;
                                                  settingRepo
                                                      .initSettings()
                                                      .then((setting) {
                                                    print('called checkout');
                                                    setState(() {
                                                      isLoading = false;
                                                      if (setting
                                                              .checkoutAlertEnabled ==
                                                          '1') {
                                                        checkoutAlert(setting
                                                            .checkoutAlertMessage);
                                                      } else {
                                                        checkLocationPermission();
                                                      }
                                                    });
                                                  });
                                                });
                                              } else {
                                                minOrderAlert(_con.carts
                                                    .elementAt(0)
                                                    .food
                                                    .restaurant
                                                    .minOrderPrice);
                                              }
                                            },
                                            padding: EdgeInsets.symmetric(
                                                vertical: 14),
                                            color:
                                                Theme.of(context).accentColor,
                                            shape: StadiumBorder(),
                                            child: Text(
                                              S.of(context).checkout,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Helper.getPrice(
                                            _con.total,
                                            context,
                                            style: Theme.of(context)
                                                .textTheme
                                                .display1
                                                .merge(TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                          ),
                                        )
                                      ],
                                    ),
                              //SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
