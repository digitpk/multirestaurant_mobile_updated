import 'package:food_delivery_app/src/models/banner_media.dart';

class AppBanner {
  String redirect_url ;
  String type_id;
  String type;
  BannerMedia image;
  AppBanner();

  AppBanner.fromJSON(Map<String, dynamic> jsonMap)
      : type_id = jsonMap['type_id'].toString(),
        redirect_url = jsonMap['redirect_url'],
        type = jsonMap['type'],
        image = jsonMap['media'] != null ? BannerMedia.fromJSON(jsonMap['media'][0]) : null;

  Map<String, dynamic> toMap() {
    return {
      'type_id': type_id,
      'type': type,
      'redirect_url': redirect_url,
      'image': image.url,
    };
  }
}
