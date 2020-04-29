import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/food_controller.dart';
import 'package:food_delivery_app/src/elements/AddToCartAlertDialog.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/ExtraItemWidget.dart';
import 'package:food_delivery_app/src/elements/ReviewsListWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartFloatButtonWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/models/setting.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as Platform;
import 'package:app_settings/app_settings.dart' as appSetting;
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
as settingRepo;
// ignore: must_be_immutable
class FoodWidget extends StatefulWidget {
  RouteArgument routeArgument;

  FoodWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _FoodWidgetState createState() {
    return _FoodWidgetState();
  }
}

class _FoodWidgetState extends StateMVC<FoodWidget> {
  FoodController _con;
  Setting setting;
  _FoodWidgetState() : super(FoodController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForFood(foodId: widget.routeArgument.id);
    _con.listenForFavorite(foodId: widget.routeArgument.id);
    _con.listenForCart();
    super.initState();
  }
  void permissionGranted() {
    LocationPermissions().checkServiceStatus().then((locationServiceStatus) {
      print('serviceStatus:$locationServiceStatus');
      if (locationServiceStatus == ServiceStatus.enabled) {
        goToCheckOutTownArea();
      } else {
        locationEnableAlert();
      }
    });
  }

  void checkLocationPermission() async {
    Geolocator()
        .checkGeolocationPermissionStatus()
        .then((geolocationStatus) async {
      print('geolocationStatus.value:${geolocationStatus.value}');
      //if (geolocationStatus.value != 2) {
      LocationPermissions().requestPermissions().then((result) async {
        if (result == PermissionStatus.granted) {
          print('PermissionStatus granted');
          permissionGranted();
        } else {
          print('PermissionStatus not granted');
          waitingForGrantPermission();
        }
      });
      //}
    });
  }

  Future<Timer> waitingForGrantPermission() async {
    return new Timer(Duration(seconds: 5), onWaitingForGrantPermission);
  }

  onWaitingForGrantPermission() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      print('call onWaitingForGrantPermission');
      LocationPermissions().requestPermissions().then((result) async {
        if (result == PermissionStatus.granted) {
          print('PermissionStatus.granted');
          permissionGranted();
        } else {
          waitingForGrantPermission();
        }
      });
    });
  }

  Future<Timer> waitingForServiceEnableLocation() async {
    return new Timer(Duration(seconds: 5), onWaitingForServiceEnableLocation);
  }

  onWaitingForServiceEnableLocation() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      print('call onWaitingForServiceEnableLocation');
      LocationPermissions().checkServiceStatus().then((locationServiceStatus) {
        print('serviceStatus:$locationServiceStatus');
        if (locationServiceStatus == ServiceStatus.enabled) {
          goToCheckOutTownArea();
        } else {
          waitingForServiceEnableLocation();
        }
      });
    });
  }

  void locationEnableAlert() {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
      ),
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
            waitingForServiceEnableLocation();
            //LocationPermissions().openAppSettings();
            appSetting.AppSettings.openLocationSettings();
          },
          width: 120,
        )
      ],
    ).show();
  }

  void goToCheckOutTownArea() {
    checkAppIsOutOfTownArea();
  }

  void checkLatLongWithTown(double newLatitude, double newLongitude) {
    settingRepo.getCurrentSettings().then((setting) async {
      if (setting != null) {
        this.setting = setting;
        print('setting lat:${setting.town_area_lat}');
        print('setting long:${setting.town_area_long}');
        double distance = await Geolocator().distanceBetween(
            setting.town_area_lat,
            setting.town_area_long,
            newLatitude,
            newLongitude);
        distance = distance / 1000;
        print('distance:$distance');
        print('setting.town_area_distance:${setting.town_area_distance}');
        if (distance > double.parse(setting.town_area_distance)) {
          outOfTownAreaAlert();
        } else {
          if (_con.isSameRestaurants(_con.food)) {
            _con.addToCart(_con.food);
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AddToCartAlertDialogWidget(
                    oldFood: _con.cart?.food,
                    newFood: _con.food,
                    onPressed: (food, {reset: true}) {
                      return _con.addToCart(_con.food, reset: true);
                    });
              },
            );
          }
        }
      } else {
        print('settingData null');
      }
    });
  }
  void outOfTownAreaAlert() {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
      ),
      type: AlertType.warning,
      title: "",
      desc: setting.town_area_message,
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
  void checkAppIsOutOfTownArea() async {
    Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) async {
      if (position != null) {
        print('last new lat:${position.latitude}');
        print('last new long:${position.longitude}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('currentLat', position.latitude);
        await prefs.setDouble('currentLon', position.longitude);
        checkLatLongWithTown(position.latitude, position.longitude);
      } else {
        print('last position null');
        Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((position) async {
          if (position != null) {
            print('new lat:${position.latitude}');
            print('new long:${position.longitude}');
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('currentLat', position.latitude);
            await prefs.setDouble('currentLon', position.longitude);
            checkLatLongWithTown(position.latitude, position.longitude);
          }
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: _con.food == null
          ? CircularLoadingWidget(height: 500)
          : RefreshIndicator(
              onRefresh: _con.refreshFood,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    margin: _con.isEnableAddToCart
                        ? EdgeInsets.only(bottom: 120) : EdgeInsets.only(bottom: 0),
                    padding: _con.isEnableAddToCart
                        ? EdgeInsets.only(bottom: 15) : EdgeInsets.only(bottom: 0),
                    child: CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                          expandedHeight: 300,
                          elevation: 0,
                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Hero(
                              tag: widget.routeArgument.heroTag ?? '' + _con.food.id,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _con.food.image.url,
                                placeholder: (context, url) => Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Wrap(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _con.food.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.display2,
                                          ),
                                          Text(
                                            _con.food.restaurant.name,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: Theme.of(context).textTheme.body1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Helper.getPrice(
                                            _con.food.price,
                                            context,
                                            style: Theme.of(context).textTheme.display3,
                                          ),
                                          Text(
                                            _con.food.weight + S.of(context).g,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: Theme.of(context).textTheme.body1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 40),
                                Text(Helper.skipHtml(_con.food.description)),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  leading: Icon(
                                    Icons.add_circle,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).extras,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                  subtitle: Text(
                                    S.of(context).select_extras_to_add_them_on_the_food,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),
                                ListView.separated(
                                  padding: EdgeInsets.all(0),
                                  itemBuilder: (context, index) {
                                    return ExtraItemWidget(
                                      extra: _con.food.extras.elementAt(index),
                                      onChanged: _con.calculateTotal,
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 20);
                                  },
                                  itemCount: _con.food.extras.length,
                                  primary: false,
                                  shrinkWrap: true,
                                ),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  leading: Icon(
                                    Icons.donut_small,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).ingredients,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ),
                                Helper.applyHtml(context, _con.food.ingredients, style: TextStyle(fontSize: 12)),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  leading: Icon(
                                    Icons.local_activity,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).nutrition,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(_con.food.nutritions.length, (index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context).focusColor.withOpacity(0.2),
                                                offset: Offset(0, 2),
                                                blurRadius: 6.0)
                                          ]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(_con.food.nutritions.elementAt(index).name,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.caption),
                                          Text(_con.food.nutritions.elementAt(index).quantity.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.headline),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                _con.food.foodReviews.length > 0 ? ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  leading: Icon(
                                    Icons.recent_actors,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).reviews,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ):Container(),
                                _con.food.foodReviews.length > 0 ? ReviewsListWidget(
                                  reviewsList: _con.food.foodReviews,
                                ):Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _con.isEnableAddToCart
                      ? Positioned(
                    top: 32,
                    right: 20,
                    child: _con.loadCart
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: RefreshProgressIndicator(),
                          )
                        : ShoppingCartFloatButtonWidget(
                            iconColor: Theme.of(context).primaryColor,
                            labelColor: Theme.of(context).hintColor,
                            food: _con.food,
                          ),
                  ): Container(height: 0,),
                  _con.isEnableAddToCart
                      ? Positioned(
                    bottom: 0,
                    child: Container(
                      height: 140,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).focusColor.withOpacity(0.15),
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
                                    S.of(context).quantity,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () {
                                        _con.decrementQuantity();
                                      },
                                      iconSize: 30,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      icon: Icon(Icons.remove_circle_outline),
                                      color: Theme.of(context).hintColor,
                                    ),
                                    Text(_con.quantity.toString(), style: Theme.of(context).textTheme.subhead),
                                    IconButton(
                                      onPressed: () {
                                        _con.incrementQuantity();
                                      },
                                      iconSize: 30,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      icon: Icon(Icons.add_circle_outline),
                                      color: Theme.of(context).hintColor,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _con.favorite?.id != null
                                      ? OutlineButton(
                                          onPressed: () {
                                            _con.removeFromFavorite(_con.favorite);
                                          },
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          color: Theme.of(context).primaryColor,
                                          shape: StadiumBorder(),
                                          borderSide: BorderSide(color: Theme.of(context).accentColor),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Theme.of(context).accentColor,
                                          ))
                                      : FlatButton(
                                          onPressed: () {
                                            if (currentUser.value.apiToken == null) {
                                              Navigator.of(context).pushNamed("/Login");
                                            } else {
                                              _con.addToFavorite(_con.food);
                                            }
                                          },
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          color: Theme.of(context).accentColor,
                                          shape: StadiumBorder(),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Theme.of(context).primaryColor,
                                          )),
                                ),
                                SizedBox(width: 10),
                                Stack(
                                  fit: StackFit.loose,
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width - 110,
                                      child: FlatButton(
                                        onPressed: () {
                                          if (currentUser.value.apiToken == null) {
                                            Navigator.of(context).pushNamed("/Login");
                                          } else {
                                            checkLocationPermission();
                                          }
                                        },
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        color: Theme.of(context).accentColor,
                                        shape: StadiumBorder(),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                            S.of(context).add_to_cart,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(color: Theme.of(context).primaryColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Helper.getPrice(
                                        _con.total,
                                        context,
                                        style: Theme.of(context)
                                            .textTheme
                                            .display1
                                            .merge(TextStyle(color: Theme.of(context).primaryColor)),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ): Container(height: 0,)
                ],
              ),
            ),
    );
  }
}
