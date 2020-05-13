import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:food_delivery_app/src/models/category_with_foods.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/gallery.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/review.dart';
import 'package:food_delivery_app/src/repository/category_repository.dart';
import 'package:food_delivery_app/src/repository/food_repository.dart';
import 'package:food_delivery_app/src/repository/gallery_repository.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;
import 'package:rflutter_alert/rflutter_alert.dart';

class RestaurantController extends ControllerMVC {
  Restaurant restaurant;
  List<Gallery> galleries = <Gallery>[];
  List<Food> foods = <Food>[];
  List<Food> trendingFoods = <Food>[];
  List<Food> featuredFoods = <Food>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  List<Category> categories = <Category>[];
  List<CategoryWithFoods> categoriesWithFoods = <CategoryWithFoods>[];
  bool isOpeningRestaurantStatus = false;
  RestaurantController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForRestaurant({String id, String message}) async {
    final Stream<Restaurant> stream = await getRestaurant(id);
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurant = _restaurant);
    }, onError: (a) {
      print(a);
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {
      print('listenForRestaurant Done');
      if(restaurant !=null) {
        Helper.getResOpeningStatus(restaurant.res_opening_hours).then((
            resOpeningStatus) {
          setState(() {
            isOpeningRestaurantStatus = resOpeningStatus;
          });
          if(!resOpeningStatus)
          {
            settingRepo.initSettings().then((setting) {
              closeRestaurantAlert(setting.messageClose);
            });
          }
        });
      }
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }
  void closeRestaurantAlert(String message) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "",
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
  void listenForGalleries(String idRestaurant) async {
    final Stream<Gallery> stream = await getGalleries(idRestaurant);
    stream.listen((Gallery _gallery) {
      setState(() => galleries.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForRestaurantReviews({String id, String message}) async {
    final Stream<Review> stream = await getRestaurantReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => foods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForTrendingFoods(String idRestaurant) async {
    final Stream<Food> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => featuredFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }
  void listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {}, onDone: () {});
  }
  void listenForCategoriesWithFoods(String id) async {
    final Stream<CategoryWithFoods> stream = await getCategoriesWithFoods(id);
    stream.listen((CategoryWithFoods _category) {
      setState(() => categoriesWithFoods.add(_category));
    }, onError: (a) {}, onDone: () {
      print('categoriesWithFoodsList:${categoriesWithFoods.length}');
    });
  }
  Future<void> refreshRestaurant() async {
    var _id = restaurant.id;
    restaurant = new Restaurant();
    galleries.clear();
    reviews.clear();
    featuredFoods.clear();
    listenForRestaurant(id: _id, message: S.current.restaurant_refreshed_successfuly);
    listenForRestaurantReviews(id: _id);
    listenForCategories();
    listenForGalleries(_id);
    listenForFeaturedFoods(_id);
  }
}
