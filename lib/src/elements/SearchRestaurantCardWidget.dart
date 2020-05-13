import 'package:android_intent/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/search_restaurant.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
    as settingRepo;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart'
    as locationPermission;

class SearchRestaurantCardWidget extends StatelessWidget {
  SearchRestaurant restaurant;
  String heroTag;
  LocationData currentLocation;
  BuildContext context;

  SearchRestaurantCardWidget({Key key, this.restaurant, this.heroTag}) : super(key: key);

  void getCurrentLocation() async {
    try {
      currentLocation = await settingRepo.getCurrentLocation();
      goToMapExplore();
    } on Exception catch (e) {
      print('Permission denied:${e}');
    }
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
      locationPermission.ServiceStatus serviceStatus =
          await locationPermission.LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == locationPermission.ServiceStatus.enabled) {
        getCurrentLocation();
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
    var result =
        await locationPermission.LocationPermissions().requestPermissions();
    if (result == locationPermission.PermissionStatus.granted) {
      locationPermission.ServiceStatus serviceStatus =
          await locationPermission.LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == locationPermission.ServiceStatus.enabled) {
        getCurrentLocation();
      } else {
        locationEnableAlert();
      }
      return true;
    } else {
      print('PermissionStatus not granted');
      //if (Platform.isIOS) {
      locationPermission.ServiceStatus serviceStatus =
          await locationPermission.LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == locationPermission.ServiceStatus.disabled) {
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
                locationPermission.LocationPermissions().openAppSettings();
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

  void goToMapExplore() async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(
              "https://www.google.com/maps/dir/?api=1&origin=" +
                  "${currentLocation.latitude},${currentLocation.longitude}" +
                  "&destination=" +
                  restaurant.latitude +
                  "," +
                  restaurant.longitude +
                  "&travelmode=driving&dir_action=navigate"),
          package: 'com.google.android.apps.maps');
      intent.launch();
    } else {
      String url = "https://www.google.com/maps/dir/?api=1&origin=" +
          "${currentLocation.latitude},${currentLocation.longitude}" +
          "&destination=" +
          restaurant.latitude +
          "," +
          restaurant.longitude +
          "&travelmode=driving&dir_action=navigate";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('SearchRestaurantCardWidget :${restaurant.toMap()}');
    this.context = context;
    return Container(
      width: 292,
      margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Image of the card
          Hero(
            tag: this.heroTag + restaurant.id,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: CachedNetworkImage(
                height: 150,
                fit: BoxFit.cover,
                imageUrl: restaurant.image.url,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                  height: 150,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        restaurant.name,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      /*Text(
                        Helper.skipHtml(restaurant.description),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.caption,
                      ),*/
                      SizedBox(height: 5),
                      /*Row(
                        children:
                            Helper.getStarsList(double.parse(restaurant.rate)),
                      ),*/
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          //Navigator.of(context).pushNamed('/Map', arguments: new RouteArgument(param: restaurant));
                          checkLocationPermission();
                        },
                        child: Icon(Icons.directions,
                            color: Theme.of(context).primaryColor),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      Text(
                        Helper.getDistance(0.0),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
