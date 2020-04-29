import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/cart.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/repository/cart_repository.dart';
import 'package:food_delivery_app/src/repository/category_repository.dart';
import 'package:food_delivery_app/src/repository/food_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class CategoryController extends ControllerMVC {
  List<Food> foods = <Food>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  Category category;
  bool loadCart = false;
  Cart cart;

  CategoryController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForFoodsByCategory({String id, String message}) async {
    final Stream<Food> stream = await getFoodsByCategory(id);
    stream.listen((Food _food) {
      setState(() {
        foods.add(_food);
      });
    }, onError: (a) {
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCategory({String id, String message}) async {
    final Stream<Category> stream = await getCategory(id);
    stream.listen((Category _category) {
      setState(() => category = _category);
    }, onError: (a) {
      print(a);
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ))*/
    }, onDone: () {
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cart = _cart;
    });
  }

  bool isSameRestaurants(Food food) {
    if (cart != null) {
      return cart.food?.restaurant?.id == food.restaurant.id;
    }
    return true;
  }

  void addToCart(Food food, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });
    var _cart = new Cart();
    _cart.food = food;
    _cart.extras = [];
    _cart.quantity = 1;
    addCart(_cart, reset).then((value) {
      setState(() {
        this.loadCart = false;
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('This food was added to cart'),
      ));
    });
  }

  Future<void> refreshCategory() async {
    foods.clear();
    category = new Category();
    listenForFoodsByCategory(message: S.current.category_refreshed_successfuly);
    listenForCategory(message: S.current.category_refreshed_successfuly);
  }
}
