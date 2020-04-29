import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/app_banner.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/offer.dart';
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/review.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/splash_screen.dart';
import 'package:food_delivery_app/src/repository/category_repository.dart';
import 'package:food_delivery_app/src/repository/food_repository.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart'
as userRepo;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:package_info/package_info.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends ControllerMVC {
  List<ResCategory> resCategories = <ResCategory>[];
  List<Category> categories = <Category>[];
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];
  List<String> bannerList = <String>[];
  List<AppBanner> bannerAppList = <AppBanner>[];
  List<Offer> OfferData = <Offer>[];
  String resCatId  = "0";
  location.LocationData locationData;
  static String resCatIdRefresh = "0";
  LocationAccuracy desiredAccuracy = LocationAccuracy.best;
  HomeController() {
    userRepo.getResCat().then((resCatId) {
      if (resCatId != null) {
        this.resCatId = resCatId;
        getLatLong();
      }
    });
  }
  void getAllDashboard() {
    print('id:$resCatId');
    resCatIdRefresh = resCatId;
    getAppVersion();
    listenForBanner();
    listenForCategories();
    listenForTrendingFoods();
    if (SplashScreen.isFirstTime) {
      SplashScreen.isFirstTime = false;
      listenForOffers();
    }
    listenForTopRestaurants();
  }
  void getLatLong() async {
    Geolocator()
        .getLastKnownPosition(desiredAccuracy: desiredAccuracy)
        .then((position) async {
      if (position != null) {
        print('last new lat:${position.latitude}');
        print('last new long:${position.longitude}');
        locationData = location.LocationData.fromMap({"latitude": position.latitude, "longitude":position.longitude});
        getAllDashboard();
      } else {
        print('last position null');
        Geolocator()
            .getCurrentPosition(desiredAccuracy: desiredAccuracy)
            .then((position) async {
          if (position != null) {
            print('new lat:${position.latitude}');
            print('new long:${position.longitude}');
            locationData = location.LocationData.fromMap({"latitude": position.latitude, "longitude":position.longitude});
            getAllDashboard();
          } else {
            print('position null');
          }
        });
      }
    });
  }
  void getAppVersion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String packageVersion = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      print('packageName:$packageName');
      print('appName:$appName');
      print('version:$packageVersion');
      print('buildNumber:$buildNumber');
      getCurrentSettings().then((setting) {
        print('compareTo:${packageVersion.compareTo(setting.appVersion)}');
        if (packageVersion.compareTo(setting.appVersion) < 0) {
          appVersionAlert();
        }
      });
    });
  }

  void appVersionAlert() {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
      ),
      type: AlertType.warning,
      title: S.of(context).alert_update_app_version_title,
      desc: S.of(context).alert_update_app_version_message,
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).update_btn,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            /*Navigator.of(context).pushNamed('/Web',
                arguments: RouteArgument(id: "http://hyperurl.co/diny"));*/
            goToExternalBrowser();
          },
          width: 120,
        )
      ],
    ).show();
  }

  void goToExternalBrowser() async {
    String url = "http://hyperurl.co/diny";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void offerAlert(Offer offer) {
    Alert(
      context: context,
      type: AlertType.none,
      title: offer.title,
      desc: Helper.skipHtml(offer.description),
      style: AlertStyle(
          titleStyle: Theme.of(context)
              .textTheme
              .display1
              .merge(TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          descStyle: Theme.of(context)
              .textTheme
              .caption
              .merge(TextStyle(fontSize: 20, fontWeight: FontWeight.w200))),
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).go_to_offer,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pop(context);

            print('offerType_id:${offer.type_id}');
            print('offerRedirectUrl:${offer.redirect_url}');

            if (offer.type_id == '1') {
              //Restaurant
              Navigator.of(context).pushNamed('/Details',
                  arguments: RouteArgument(
                    id: offer.redirect_url,
                    heroTag: "",
                  ));
            } else if (offer.type_id == '2') {
              //Category
              Navigator.of(context).pushNamed('/Category',
                  arguments: RouteArgument(id: offer.redirect_url));
            } else if (offer.type_id == '3') {
              //Food
              Navigator.of(context).pushNamed('/Food',
                  arguments:
                  RouteArgument(id: offer.redirect_url, heroTag: ""));
            } else if (offer.type_id == '4') {
              //Custom URL
              Navigator.of(context).pushNamed('/Web',
                  arguments: RouteArgument(id: offer.redirect_url));
            }
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            S.of(context).alert_ok,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 50,
        ),
      ],
    ).show();
  }

  void listenForOffers() async {
    final Stream<Offer> stream = await getOffer();
    stream.listen(
            (Offer offer) {
          setState(() => OfferData.add(offer));
        },
        onError: (a) {},
        onDone: () {
          print('offerlenght:${OfferData.length}');
          if (OfferData.isNotEmpty) {
            for (int i = 0; i < OfferData.length; i++) {
              if (OfferData[i].is_active == '1') {
                offerAlert(OfferData[i]);
                break;
              }
            }
          }
        });
  }

  void listenForBanner() async {
    bannerAppList.clear();
    bannerList.clear();
    final Stream<AppBanner> stream = await getBanner(resCatIdRefresh);
    stream.listen((AppBanner _banner) {
      print('getbanner:${_banner.toMap().toString()}');
      setState(() => bannerAppList.add(_banner));
    }, onError: (a) {
      print('onError listenForBanner():${a.toString()}');
    }, onDone: () {
      for (int i = 0; i < bannerAppList.length; i++) {
        setState(() {
          bannerList.add(bannerAppList[i].image.url);
        });
      }

      print('onDone listenForBanner()');
      print('Banner List:${bannerList.length}');
    });
  }
  void listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForTopRestaurants() async {
    getCurrentLocation().then((location.LocationData _locationData) async {
      final Stream<Restaurant> stream = await getNearRestaurants(_locationData, _locationData, resCatIdRefresh);
      stream.listen((Restaurant _restaurant) {
        setState(() => topRestaurants.add(_restaurant));
      }, onError: (a) {
        print('listenForTopRestaurants Error:${a.toString()}');
      }, onDone: () {
        print('listenForTopRestaurants Done:${topRestaurants.length}');
      });
    });
  }

  void listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForTrendingFoods() async {
    final Stream<Food> stream = await getTrendingFoods(resCatIdRefresh);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> refreshHome() async {
    categories = <Category>[];
    topRestaurants = <Restaurant>[];
    recentReviews = <Review>[];
    trendingFoods = <Food>[];
    listenForCategories();
    listenForTopRestaurants();
    listenForTrendingFoods();
  }
}
