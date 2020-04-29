import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/order.dart';
import 'package:food_delivery_app/src/models/order_status.dart';
import 'package:food_delivery_app/src/models/review.dart';
import 'package:food_delivery_app/src/repository/food_repository.dart' as foodRepo;
import 'package:food_delivery_app/src/repository/order_repository.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart' as restaurantRepo;
import 'package:mvc_pattern/mvc_pattern.dart';

class ReviewsController extends ControllerMVC {
  Review restaurantReview;
  List<Review> foodsReviews = [];
  Order order;
  List<Food> foodsOfOrder = [];
  List<OrderStatus> orderStatus = <OrderStatus>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  ReviewsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.restaurantReview = new Review.init("0");
  }

  void listenForOrder({String orderId, String message}) async {
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen((Order _order) {
      setState(() {
        order = _order;
        foodsReviews = List.generate(order.foodOrders.length, (_) => new Review.init("0"));
      });
    }, onError: (a) {
      print(a);
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {
      getFoodsOfOrder();
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void addFoodReview(Review _review, Food _food) async {
    foodRepo.addFoodReview(_review, _food).then((value) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_food_has_been_rated_successfully),
      ));
    });
  }

  void addRestaurantReview(Review _review) async {
    restaurantRepo.addRestaurantReview(_review, this.order.foodOrders[0].food.restaurant).then((value) {
      refreshOrder();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_restaurant_has_been_rated_successfully),
      ));
    });
  }

  Future<void> refreshOrder() async {
    listenForOrder(orderId: order.id, message: S.current.reviews_refreshed_successfully);
  }

  void getFoodsOfOrder() {
    this.order.foodOrders.forEach((_foodOrder) {
      if (!foodsOfOrder.contains(_foodOrder.food)) {
        foodsOfOrder.add(_foodOrder.food);
      }
    });
  }
}
