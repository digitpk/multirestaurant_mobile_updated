import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/address.dart';
import 'package:food_delivery_app/src/models/credit_card.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart' as userRepo;
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<User> currentUser = new ValueNotifier(User());
Address deliveryAddress = new Address();

Future<User> login(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}login';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    try {
      currentUser.value = User.fromJSON(json.decode(response.body)['data']);
    } catch (e) {}
  }
  if (currentUser.value.apiToken == null) {
    currentUser.value.message = jsonDecode(response.body)['message'];
  }
  return currentUser.value;
}

Future<User> register(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}register';
  print('register:$url');
  print('register params:${user.toMap()}');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  print('response.statusCode:${response.statusCode}');
  if (response.statusCode == 200) {
    print('currentUser:${currentUser.value.toMap()}');
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  }else {
    currentUser.value.message = jsonDecode(response.body)['message'];
    print('currentUser error:${currentUser.value.message}');
  }
  return currentUser.value;
}

Future<bool> resetPassword(User user) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    print(json.decode(response.body)['data']);
    return true;
  } else {
    return false;
  }
}

Future<User> update(User user) async {
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}users/${currentUser.value.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  setCurrentUser(response.body);
  currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=is_default&sortedBy=desc';
  print(url);
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Address.fromJSON(data);
  });
}

Future<Address> addAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}delivery_addresses?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> updateAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> removeDeliveryAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<void> logout() async {
  currentUser.value = new User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
}

void setCurrentUser(jsonString) async {
  if (json.decode(jsonString)['data'] != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(json.decode(jsonString)['data']));
  }
}

Future<User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
//  prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = User.fromJSON(json.decode(await prefs.get('current_user')));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  currentUser.notifyListeners();
  return currentUser.value;
}
Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}
Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = new CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard = CreditCard.fromJSON(json.decode(await prefs.get('credit_card')));
  }
  return _creditCard;
}
void setUserEmail(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String getEmail = await prefs.get('user_email');
  if(email != getEmail)
  {
    setCreditCard(CreditCard());
  }
  await prefs.setString('user_email', email);
}
Future<String> getUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = await prefs.get('user_email');
  print('user_email:$email');
  return email;
}
void setOrderAmount(String amount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('Set OrderAmount:$amount');
  await prefs.setString('order_amount', amount);
}
Future<String> getOrderAmount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String amount = await prefs.get('order_amount');
  print('Get OrderAmount:$amount');
  return amount;
}
Future<String> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String code = await prefs.get('language_code');
  print('language_code:$code');
  return code;
}
void setLanguage(String code) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('language_code:$code');
  await prefs.setString('language_code', code);
}
void setResCat(String resCatId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('Set resCat:$resCatId');
  await prefs.setString('resCatId', resCatId);
}
Future<String> getResCat() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String resCatId = await prefs.get('resCatId');
  print('get resCat:$resCatId');
  return resCatId;
}
void setOrderJsonArray(String jsonArray) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('Set order_json_array:$jsonArray');
  await prefs.setString('order_json_array', jsonArray);
}
Future<String> getOrderJsonArray() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String jsonArray = await prefs.get('order_json_array');
  print('Get order_json_array:$jsonArray');
  return jsonArray;
}
Future<http.Response> isUserExist(user) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}user_exists?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  return response;
}
