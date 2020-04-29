class OrderJsonArrayItem {
  String food_id;
  String food_name;
  String food_price;
  String food_price_extra;
  String quantity;
  OrderJsonArrayItem();
  OrderJsonArrayItem.fromJSON(Map<String, dynamic> jsonMap) {
    food_id = jsonMap['food_id'].toString();
    food_name = jsonMap['food_name'];
    food_price = jsonMap['food_price'].toString();
    food_price_extra = jsonMap['food_price_extra'].toString();
    quantity = jsonMap['quantity'].toString();
  }
}
