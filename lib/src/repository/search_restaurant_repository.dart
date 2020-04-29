import 'dart:convert';

import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/search_restaurant.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

Future<Stream<SearchRestaurant>> searchRestaurants(String search, LocationData location,String resCatId) async {
  User _user = await getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String _searchParam = 'search=$search';
  final String _locationParam =
      'myLon=${location.longitude}&myLat=${location.latitude}&areaLon=${location.longitude}&areaLat=${location.latitude}';
  final String _orderLimitParam = 'orderBy=area&limit=5';
  final String _resCatIdParam = 'res_category_id=$resCatId';

  final String url =
      '${GlobalConfiguration().getString('api_base_url')}restaurants?$_apiToken&$_searchParam&$_locationParam&$_orderLimitParam&$_resCatIdParam';
  print('searchApi:$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        return SearchRestaurant.fromJSON(data);
  });
}
