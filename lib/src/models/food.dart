import 'package:food_delivery_app/src/models/category.dart';
import 'package:food_delivery_app/src/models/extra.dart';
import 'package:food_delivery_app/src/models/media.dart';
import 'package:food_delivery_app/src/models/nutrition.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/review.dart';

class Food {
  String id;
  String name;
  double price;
  double priceWithExtra;
  double discountPrice;
  Media image;
  String description;
  String ingredients;
  String weight;
  bool featured;
  Restaurant restaurant;
  Category category;
  List<Extra> extras;
  List<Review> foodReviews;
  List<Nutrition> nutritions;

  Food();

  Food.fromJSON(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'].toString();
    name = jsonMap['name'];
    price = double.parse(jsonMap['price'].toString());
    discountPrice = jsonMap['discount_price'] != null ? double.parse(jsonMap['discount_price'].toString()) : null;
    description = jsonMap['description'];
    ingredients = jsonMap['ingredients'];
    weight = jsonMap['weight'].toString();
    featured = jsonMap['featured'] ?? false;
    restaurant = jsonMap['restaurant'] != null ? Restaurant.fromJSON(jsonMap['restaurant']) : null;
    category = jsonMap['category'] != null ? Category.fromJSON(jsonMap['category']) : null;
    image = jsonMap['media'] != null ? Media.fromJSON(jsonMap['media'][0]) : null;
    extras = jsonMap['extras'] != null
        ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList()
        : [];
    nutritions = jsonMap['nutrition'] != null
        ? List.from(jsonMap['nutrition']).map((element) => Nutrition.fromJSON(element)).toList()
        : [];
    foodReviews = jsonMap['food_reviews'] != null
        ? List.from(jsonMap['food_reviews']).map((element) => Review.fromJSON(element)).toList()
        : [];
    priceWithExtra = 0;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["discountPrice"] = discountPrice;
    map["description"] = description;
    map["ingredients"] = ingredients;
    map["weight"] = weight;
    map["foodReviews"] = foodReviews;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }
}
