import 'package:food_delivery_app/src/models/media.dart';

import 'extra_pivot.dart';

class Extra {
  String id;
  String name;
  double price;
  double totalPrice;
  double qty = 1.0;
  Media image;
  String description;
  bool checked;
  ExtraPivot extraPivot;
  Extra();

  Extra.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'],
        price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : null,
        description = jsonMap['description'],
        extraPivot = jsonMap['pivot'] != null ? ExtraPivot.fromJSON(jsonMap['pivot']) : null,
        checked = false,
        image = jsonMap['media'] != null ? Media.fromJSON(jsonMap['media'][0]) : null;

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["extra_id"] = id;
    map["extra_price"] = price;
    map["extra_qty"] = qty;
    return map;
  }
}
