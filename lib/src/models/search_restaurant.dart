import 'package:food_delivery_app/src/models/media.dart';

class SearchRestaurant {
  String id;
  String name;
  String type;
  String description;
  Media image;
  String latitude;
  String longitude;
  String rate;
  SearchRestaurant();

  SearchRestaurant.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'],
        type = jsonMap['type'],
        latitude = jsonMap['latitude'] !=null ? jsonMap['latitude']:"0",
        longitude = jsonMap['longitude'] !=null ? jsonMap['longitude']:"0",
        rate = jsonMap['rate'] !=null ?jsonMap['rate'] : '1.0',
        image = jsonMap['media'] != null ? Media.fromJSON(jsonMap['media'][0]) : null,
        description = jsonMap['description'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'rate': rate,
      'description': description,
      'image': image.url,
    };
  }
}
