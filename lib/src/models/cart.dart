import 'package:food_delivery_app/src/models/extra.dart';
import 'package:food_delivery_app/src/models/food.dart';

class Cart {
  String id;
  Food food;
  double quantity;
  List<Extra> extras;
  String userId;

  Cart();

  Cart.fromJSON(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'].toString();
    quantity = jsonMap['quantity'] != null ? jsonMap['quantity'].toDouble() : 0.0;
    food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : new Food();
    extras = jsonMap['extras'] != null
        ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList()
        : [];
    food.priceWithExtra = getFoodPriceWithExtra();
  }
  double getFoodPriceWithExtra() {
    double result = food.price;
    if (extras.isNotEmpty) {
      extras.forEach((Extra extra) {
        double extraPrice = extra.extraPivot.extra_price != null ? extra.extraPivot.extra_price : 0;
        double extraQty = extra.extraPivot.extra_qty != null ? extra.extraPivot.extra_qty : 0;
        result += extraPrice * extraQty;
      });
    }
    return result;
  }
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["quantity"] = quantity;
    map["food_id"] = food.id;
    map["food_name"] = food.name;
    map["food_price"] = food.price;
    map["food_price_extra"] = food.priceWithExtra;
    map["user_id"] = userId;
//    map["extras"] = extras.map((element) => element.id).toList();
    map["extras"] = extras.map((element) => element.toMap()).toList();
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }
}
