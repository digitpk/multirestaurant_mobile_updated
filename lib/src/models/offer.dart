class Offer {
  String title ;
  String description ;
  String redirect_url ;
  String type_id;
  String type;
  String is_active;

  Offer();

  Offer.fromJSON(Map<String, dynamic> jsonMap)
      : title = jsonMap['title'],
        type_id = jsonMap['type_id'].toString(),
        redirect_url = jsonMap['redirect_url'],
        type = jsonMap['type'],
        description = jsonMap['description'],
        is_active = jsonMap['is_active'].toString();
}
