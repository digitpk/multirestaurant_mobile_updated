import 'dart:convert';
import 'dart:io';

import 'package:food_delivery_app/src/controllers/home_controller.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/favorite.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/review.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart' as userRepo;
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<Stream<Food>> getTrendingFoods(String resCatId) async {
  User _user = await userRepo.getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods?${_apiToken}&limit=6&res_category_id=$resCatId';
  print('getTrendingFoods:$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Food.fromJSON(data);
  });
}

Future<Stream<Food>> getFood(String foodId) async {
  User _user = await userRepo.getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}foods/$foodId?${_apiToken}with=nutrition;restaurant;category;extras;foodReviews;foodReviews.user';
  print('getFoodUrl:$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .map((data) => Food.fromJSON(data));
}

Future<Stream<Food>> getFoodsByCategory(categoryId) async {
  User _user = await userRepo.getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}foods?${_apiToken}categoryid=$categoryId&res_category_id=${HomeController.resCatIdRefresh}';
  print('getFoodsByCategory:$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Food.fromJSON(data);
  });
}

Future<Stream<Favorite>> isFavoriteFood(String foodId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites/exist?${_apiToken}food_id=$foodId&user_id=${_user.id}';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getObjectData(data))
      .map((data) => Favorite.fromJSON(data));
}

Future<Stream<Favorite>> getFavorites() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites?${_apiToken}with=food;user;extras&search=user_id:${_user.id}&searchFields=user_id:=';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) => Favorite.fromJSON(data));
}

Future<Favorite> addFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  favorite.userId = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(favorite.toMap()),
  );
  return Favorite.fromJSON(json.decode(response.body)['data']);
}

Future<Favorite> removeFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites/${favorite.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Favorite.fromJSON(json.decode(response.body)['data']);
}

Future<Stream<Food>> getFoodsOfRestaurant(String restaurantId) async {
  User _user = await userRepo.getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}foods?${_apiToken}&restaurant_id=$restaurantId&res_category_id=${HomeController.resCatIdRefresh}';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Food.fromJSON(data);
  });
}
Future<Stream<Food>> getTrendingFoodsOfRestaurant(String restaurantId) async {
  User _user = await userRepo.getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  // TODO Trending foods only
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}foods?${_apiToken}&limit=6&restaurant_id=$restaurantId';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Food.fromJSON(data);
  });
}

Future<Stream<Food>> getFeaturedFoodsOfRestaurant(String restaurantId) async {
  User _user = await userRepo.getCurrentUser();
  final String _apiToken = 'api_token=${_user.apiToken}';
  // TODO Featured foods only
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}foods?${_apiToken}&restaurant_id=$restaurantId&res_category_id=${HomeController.resCatIdRefresh}';
  print('getFeaturedFoodsOfRestaurant:$url');
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Food.fromJSON(data);
  });
}

Future<Review> addFoodReview(Review review, Food food) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}food_reviews';
  final client = new http.Client();
  review.user = userRepo.currentUser.value;
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(review.ofFoodToMap(food)),
  );
  if (response.statusCode == 200) {
    review = Review.fromJSON(json.decode(response.body)['data']);
  }
  return review;
}
