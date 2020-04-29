import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/user.dart';

class Review {
  String id;
  String review;
  String rate;
  User user;

  Review();
  Review.init(this.rate);

  Review.fromJSON(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'].toString();
    review = jsonMap['review'];
    rate = jsonMap['rate'].toString() ?? '0';
    user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : null;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["review"] = review;
    map["rate"] = rate;
    map["user_id"] = user?.id;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }

  Map ofRestaurantToMap(Restaurant restaurant) {
    var map = this.toMap();
    map["restaurant_id"] = restaurant.id;
    return map;
  }

  Map ofFoodToMap(Food food) {
    var map = this.toMap();
    map["food_id"] = food.id;
    return map;
  }
}
