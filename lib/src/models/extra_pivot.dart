class ExtraPivot {
  String cart_id;
  String extra_id;
  double extra_qty;
  double extra_price;

  ExtraPivot();

  ExtraPivot.fromJSON(Map<String, dynamic> jsonMap)
      : cart_id = jsonMap.containsKey('cart_id') ? jsonMap['cart_id'].toString() : "0",
        extra_id = jsonMap['extra_id'].toString(),
        extra_qty = jsonMap.containsKey('extra_qty') ? double.parse(jsonMap['extra_qty'].toString()) : 0,
        extra_price = jsonMap.containsKey('extra_price') ? double.parse(jsonMap['extra_price'].toString()) : 0;
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["extra_id"] = extra_id;
    map["extra_price"] = extra_price;
    map["extra_qty"] = extra_qty;
    return map;
  }
}
