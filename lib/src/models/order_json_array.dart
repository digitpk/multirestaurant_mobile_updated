import 'package:food_delivery_app/src/models/order_json_array_item.dart';

class OrderJsonArray {
  List<OrderJsonArrayItem> list;

  OrderJsonArray();
  OrderJsonArray.fromJSON(Map<String, dynamic> jsonMap) {
    list = jsonMap['list'] != null
        ? List.from(jsonMap['list']).map((element) => OrderJsonArrayItem.fromJSON(element)).toList()
        : [];
  }
}
