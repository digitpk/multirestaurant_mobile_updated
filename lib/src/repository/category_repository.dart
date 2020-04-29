import 'dart:convert';

import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:food_delivery_app/src/models/category_with_foods.dart';
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<Stream<ResCategory>> getResCategories() async {
  User _user = await getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}res_categories?$_apiToken';
  print('get ResCategories :$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  Stream<ResCategory> resCategoryStream = streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) => ResCategory.fromJSON(data));
  return resCategoryStream;
}
Future<Stream<Category>> getCategories() async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}categories';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) => Category.fromJSON(data));
}
Future<Stream<CategoryWithFoods>>  getCategoriesWithFoods() async {
  User _user = await getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}foodswithcategories?$_apiToken&res_category_id=${HomeController.resCatIdRefresh}';
  print('getCategoriesWithFoods :$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) => CategoryWithFoods.fromJSON(data));
}
Future<Stream<Category>> getCategory(String id) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}categories/$id';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .map((data) => Category.fromJSON(data));
}
