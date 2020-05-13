import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/elements/CardsCarouselWidget.dart';
import 'package:food_delivery_app/src/elements/CaregoriesCarouselWidget.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/FoodsCarouselWidget.dart';
import 'package:food_delivery_app/src/elements/GridWidget.dart';
import 'package:food_delivery_app/src/elements/SearchBarWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartButtonWidget.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart'
    as settingsRepo;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:location_permissions/location_permissions.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  int _current = 0;
  LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  List<T> returnMap<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
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
          width: 150,
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
      goToLocationService();
    }
  }

  Future<bool> requestLocationPermission() async {
    return _requestPermission();
  }

  void goToLocationService() async {
    ServiceStatus serviceStatus =
        await LocationPermissions().checkServiceStatus();
    print('serviceStatus:$serviceStatus');
    if (serviceStatus == ServiceStatus.enabled) {
      Geolocator()
          .getCurrentPosition(desiredAccuracy: desiredAccuracy)
          .then((position) async {
        if (position != null) {
          print('new lat:${position.latitude}');
          print('new long:${position.longitude}');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('currentLat', position.latitude);
          await prefs.setDouble('currentLon', position.longitude);
          location.LocationData locationData = location.LocationData.fromMap(
              {"latitude": position.latitude, "longitude": position.longitude});
          _con.listenForTopRestaurants(locationData);
        } else {
          print('position null');
        }
      });
    } else {
      locationEnableAlert();
    }
  }

  Future<bool> _requestPermission() async {
    print('_requestPermission');
    var result = await LocationPermissions().requestPermissions();
    if (result == PermissionStatus.granted) {
      goToLocationService();
      return true;
    } else {
      print('PermissionStatus not granted');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              value.appName ?? S.of(context).home,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
//        title: Text(
//          settingsRepo.setting?.value.appName ?? S.of(context).home,
//          style: Theme.of(context).textTheme.title.merge(TextStyle(letterSpacing: 1.3)),
//        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(),
              ),
              SizedBox(height: 10,),
        _con.setting.announcement.isNotEmpty ?Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).focusColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 5)),
            ],
          ),
          child:
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(_con.setting.announcement,textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display1.merge(TextStyle(color:Theme.of(context).primaryColor)),
            ),
          ),
        ): Container(),
              SizedBox(height: 10),
              _con.bannerList.isEmpty
                  ? Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        CircularLoadingWidget(height: 150)
                      ],
                    )
                  : Column(children: [
                      CarouselSlider(
                        viewportFraction: 1.0,
                        items: returnMap<Widget>(
                          _con.bannerList,
                          (index, i) {
                            return Container(
                              margin: EdgeInsets.all(5.0),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: Stack(children: <Widget>[
                                  GestureDetector(
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          width: 1000.0,
                                          placeholder: (context, url) =>
                                              Container(),
                                          imageUrl: i),
                                      /*Image.network(i,
                                          fit: BoxFit.cover, width: 1000.0),*/
                                      onTap: () {
                                        print('onTap:$index');
                                        print(
                                            'onTapType_id:${_con.bannerAppList[index].type_id}');
                                        print(
                                            'onTapRedirectUrl:${_con.bannerAppList[index].redirect_url}');

                                        if (_con.bannerAppList[index].type_id ==
                                            '1') {
                                          //Restaurant
                                          Navigator.of(context)
                                              .pushNamed('/Details',
                                                  arguments: RouteArgument(
                                                    id: _con
                                                        .bannerAppList[index]
                                                        .redirect_url,
                                                    heroTag: "",
                                                  ));
                                        } else if (_con
                                                .bannerAppList[index].type_id ==
                                            '2') {
                                          //Category
                                          Navigator.of(context).pushNamed(
                                              '/Category',
                                              arguments: RouteArgument(
                                                  id: _con.bannerAppList[index]
                                                      .redirect_url));
                                        } else if (_con
                                                .bannerAppList[index].type_id ==
                                            '3') {
                                          //Food
                                          Navigator.of(context).pushNamed(
                                              '/Food',
                                              arguments: RouteArgument(
                                                  id: _con.bannerAppList[index]
                                                      .redirect_url,
                                                  heroTag: ""));
                                        } else if (_con
                                                .bannerAppList[index].type_id ==
                                            '4') {
                                          //Custom URL
                                          Navigator.of(context).pushNamed(
                                              '/Web',
                                              arguments: RouteArgument(
                                                  id: _con.bannerAppList[index]
                                                      .redirect_url));
                                        }
                                      }),
                                ]),
                              ),
                            );
                          },
                        ).toList(),
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 2.0,
                        onPageChanged: (index) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: returnMap<Widget>(
                          _con.bannerList,
                          (index, url) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
                                      ? Color.fromRGBO(0, 0, 0, 0.9)
                                      : Color.fromRGBO(0, 0, 0, 0.4)),
                            );
                          },
                        ),
                      ),
                    ]),
              Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 20, right: 20, bottom: 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.stars,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).top_restaurants,
                        style: Theme.of(context).textTheme.display1,
                      ),
                      subtitle: Text(
                        S.of(context).ordered_by_nearby_first,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () {
                          print('currentLocation Tap');
                          checkLocationPermission();
                        },
                        child: ImageIcon(
                          AssetImage("assets/img/current_location.png"),
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CardsCarouselWidget(
                  restaurantsList: _con.topRestaurants,
                  heroTag: 'home_top_restaurants'),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                leading: Icon(
                  Icons.trending_up,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).trending_this_week,
                  style: Theme.of(context).textTheme.display1,
                ),
                subtitle: Text(
                  S.of(context).double_click_on_the_food_to_add_it_to_the,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(fontSize: 11)),
                ),
              ),
              FoodsCarouselWidget(
                  foodsList: _con.trendingFoods, heroTag: 'home_food_carousel'),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.category,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).food_categories,
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
              CategoriesCarouselWidget(
                categories: _con.categories,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).most_popular,
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridWidget(
                  restaurantsList: _con.topRestaurants,
                  heroTag: 'home_restaurants',
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                  leading: Icon(
                    Icons.recent_actors,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).recent_reviews,
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ReviewsListWidget(reviewsList: _con.recentReviews),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
