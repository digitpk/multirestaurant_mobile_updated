import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/search_restaurant.dart';
import 'package:food_delivery_app/src/repository/search_repository.dart';
import 'package:food_delivery_app/src/repository/search_restaurant_repository.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart'
as userRepo;
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SearchController extends ControllerMVC {
  List<SearchRestaurant> restaurants = <SearchRestaurant>[];
  List<SearchRestaurant> recent_search_restaurants = <SearchRestaurant>[];
  String resCatIdRefresh = "0";

  SearchController() {
    print('SearchController');
    userRepo.getResCat().then((resCatId) {
      if (resCatId != null) {
        resCatIdRefresh = resCatId;
        listenForRecentSearchRestaurants();
      }
    });
  }

  void listenForRestaurants(String search) async {
    restaurants.clear();
    await getCurrentLocation().then((_locationData) async {
      final Stream<SearchRestaurant> stream =
      await searchRestaurants(search, _locationData, resCatIdRefresh);
      setState(() {
        restaurants.clear();
      });
      stream.listen((SearchRestaurant _restaurant) {
        print('searchitem $search:${_restaurant.toMap().toString()}');
        setState(() {
          restaurants.add(_restaurant);
        });
      }, onError: (a) {
        print('onError SearchRestaurantCardWidget');
      }, onDone: () {
        print('onDone SearchRestaurantCardWidget: ${restaurants.length}');
        if (restaurants.length == 0) {
          saveSearch('');
          setState(() {
            restaurants.clear();
          });
        } else {
          saveSearch(search);
        }
      });
    });
  }

  void searchAlert() {
    Alert(
      context: context,
      type: AlertType.info,
      title: S.of(context).search,
      desc: S.of(context).empty_data,
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

  void listenForRecentSearchRestaurants() async {
    await getRecentSearch().then((search) async {
      print('recentSearchText:$search');
      if (search != null && search != '') {
        LocationData _locationData = await getCurrentLocation();
        final Stream<SearchRestaurant> stream =
        await searchRestaurants(search, _locationData, resCatIdRefresh);
        stream.listen((SearchRestaurant _restaurant) {
          setState(() => recent_search_restaurants.add(_restaurant));
        }, onError: (a) {
          print('onError RecentSearchRestaurantCardWidget');
        }, onDone: () {
          print('onDone RecentSearchRestaurantCardWidget');
        });
      }
    });
  }

  void saveSearch(String search) {
    setRecentSearch(search);
  }
}