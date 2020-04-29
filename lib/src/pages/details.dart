import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:food_delivery_app/src/elements/ReviewsListWidget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/restaurant_controller.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/FoodItemWidget.dart';
import 'package:food_delivery_app/src/elements/GalleryCarouselWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartFloatButtonWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart'
as locationPermission;
import 'package:food_delivery_app/src/repository/settings_repository.dart'
as settingRepo;
import 'dart:io' show Platform;
import 'package:food_delivery_app/src/helpers/app_config.dart' as appConfig;

class DetailsWidget extends StatefulWidget {
  RouteArgument routeArgument;

  DetailsWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends StateMVC<DetailsWidget> {
  RestaurantController _con;
  LocationData currentLocation;

  _DetailsWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForRestaurant(id: widget.routeArgument.id);
    _con.listenForGalleries(widget.routeArgument.id);
    _con.listenForRestaurantReviews(id: widget.routeArgument.id);
    _con.listenForFeaturedFoods(widget.routeArgument.id);
    super.initState();
  }
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
                  _con.restaurant.latitude +
                  "," +
                  _con.restaurant.longitude +
                  "&travelmode=driving&dir_action=navigate"),
          package: 'com.google.android.apps.maps');
      intent.launch();
    } else {
      String url = "https://www.google.com/maps/dir/?api=1&origin=" +
          "${currentLocation.latitude},${currentLocation.longitude}" +
          "&destination=" +
          _con.restaurant.latitude +
          "," +
          _con.restaurant.longitude +
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
    return Scaffold(
        key: _con.scaffoldKey,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed('/Menu', arguments: new RouteArgument(id: widget.routeArgument.id));
          },
          isExtended: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: Icon(Icons.restaurant),
          label: Text(S.of(context).menu),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: RefreshIndicator(
          onRefresh: _con.refreshRestaurant,
          child: _con.restaurant == null
              ? CircularLoadingWidget(height: 500)
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomScrollView(
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
                              tag: widget.routeArgument.heroTag + _con.restaurant.id,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _con.restaurant.image.url,
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
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10, top: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child:
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _con.restaurant.name,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            maxLines: 2,
                                            style: Theme.of(context)
                                                .textTheme
                                                .display2,
                                          ),
                                          _con.isOpeningRestaurantStatus ? Chip(
                                            backgroundColor: appConfig.Colors().greenColor(1),
                                            shape: StadiumBorder(),
                                            padding: EdgeInsets.all(5),
                                            label: Text(S.of(context).open,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2
                                                    .merge(TextStyle(
                                                    color:appConfig.Colors().scaffoldColor(1)))),
                                          ) : Chip(
                                            backgroundColor: appConfig.Colors().grayColor(1),
                                            shape: StadiumBorder(),
                                            padding: EdgeInsets.all(5),
                                            label: Text(S.of(context).close,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2
                                                    .merge(TextStyle(
                                                    color: appConfig.Colors().scaffoldDarkColor(1)))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32,
                                      child: Chip(
                                        padding: EdgeInsets.all(0),
                                        label: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(_con.restaurant.rate,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2
                                                    .merge(TextStyle(color: Theme.of(context).primaryColor))),
                                            Icon(
                                              Icons.star_border,
                                              color: Theme.of(context).primaryColor,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                child: Html(
                                  data: _con.restaurant.description,
                                  defaultTextStyle: Theme.of(context).textTheme.body1.merge(TextStyle(fontSize: 14)),
                                ),
                              ),
                              ImageThumbCarouselWidget(galleriesList: _con.galleries),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.stars,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).information,
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Helper.applyHtml(context, _con.restaurant.information),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _con.restaurant.address,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          /*Navigator.of(context)
                                              .pushNamed('/Map', arguments: new RouteArgument(param: _con.restaurant));*/
                                          checkLocationPermission();
                                        },
                                        child: Icon(
                                          Icons.directions,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '${_con.restaurant.phone} \n${_con.restaurant.mobile}',
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          launch("tel:${_con.restaurant.mobile}");
                                        },
                                        child: Icon(
                                          Icons.call,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _con.featuredFoods.isEmpty
                                  ? SizedBox(height: 0)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.restaurant,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          S.of(context).featured_foods,
                                          style: Theme.of(context).textTheme.display1,
                                        ),
                                      ),
                                    ),
                              _con.featuredFoods.isEmpty
                                  ? SizedBox(height: 0)
                                  : ListView.separated(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: _con.featuredFoods.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 10);
                                      },
                                      itemBuilder: (context, index) {
                                        return FoodItemWidget(
                                          heroTag: 'details_featured_food',
                                          food: _con.featuredFoods.elementAt(index),
                                        );
                                      },
                                    ),
                              _con.reviews.isEmpty ? Padding(
                                padding: EdgeInsets.all(5),
                                child: SizedBox(
                                  height: 80,
                                ),
                              ) : SizedBox(height: 20,),
                              _con.reviews.isEmpty
                                  ? SizedBox(height: 5)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.recent_actors,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          S.of(context).what_they_say,
                                          style: Theme.of(context).textTheme.display1,
                                        ),
                                      ),
                                    ),
                              _con.reviews.isEmpty
                                  ? SizedBox(height: 5)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: ReviewsListWidget(reviewsList: _con.reviews),
                                    ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: SizedBox(
                                  height: 80,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 32,
                      right: 20,
                      child: ShoppingCartFloatButtonWidget(
                        iconColor: Theme.of(context).primaryColor,
                        labelColor: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
        ));
  }
}
