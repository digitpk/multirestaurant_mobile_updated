import 'package:flutter/cupertino.dart';

class Setting {
  String appName = "";
  double defaultTax;
  String defaultCurrency;
  bool currencyRight = false;
  bool payPalEnabled = true;
  bool stripeEnabled = true;
  String mainColor;
  String mainDarkColor;
  String secondColor;
  String secondDarkColor;
  String accentColor;
  String accentDarkColor;
  String scaffoldDarkColor;
  String scaffoldColor;
  String googleMapsKey;
  ValueNotifier<Locale> mobileLanguage = new ValueNotifier(Locale('en', ''));
  String appVersion;
  bool enableVersion = true;
  String checkoutAlertEnabled = "0";
  String checkoutAlertMessage = "";
  String messageClose = "";
  String town_area_message = "";
  String town_area_distance = "0";
  double town_area_lat = 0.0;
  double town_area_long = 0.0;
  Setting();

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    appName = jsonMap['app_name'] ?? null;
    mainColor = jsonMap['main_color'] ?? null;
    mainDarkColor = jsonMap['main_dark_color'] ?? '';
    secondColor = jsonMap['second_color'] ?? '';
    secondDarkColor = jsonMap['second_dark_color'] ?? '';
    accentColor = jsonMap['accent_color'] ?? '';
    accentDarkColor = jsonMap['accent_dark_color'] ?? '';
    scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
    scaffoldColor = jsonMap['scaffold_color'] ?? '';
    googleMapsKey = jsonMap['google_maps_key'] ?? null;
    mobileLanguage.value = Locale(jsonMap['mobile_language'] ?? "en", '');
    appVersion = jsonMap['app_version'] ?? '';
    enableVersion = jsonMap['enable_version'] == null ? false : true;
    defaultTax = double.tryParse(jsonMap['default_tax']) ?? 0.0;
    defaultCurrency = jsonMap['default_currency'] ?? '';
    currencyRight = jsonMap['currency_right'] == null ? false : true;
    payPalEnabled = jsonMap['enable_paypal'] == null ? false : true;
    stripeEnabled = jsonMap['enable_stripe'] == null ? false : true;
    town_area_lat = double.parse(jsonMap['town_area_lat']) ?? 0.0;
    town_area_long = double.parse(jsonMap['town_area_long']) ?? 0.0;
    town_area_distance = jsonMap['town_area_distance'] ?? '0';
    town_area_message = jsonMap['town_area_message'] ?? '';
    defaultCurrency = jsonMap['default_currency'] ?? '';
    checkoutAlertEnabled = jsonMap['block_checkout'] ?? '0';
    checkoutAlertMessage = jsonMap['block_checkout_msg'] ?? '';
    messageClose = jsonMap['message_close'] ?? '';
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["app_name"] = appName;
    map["app_version"] = appVersion;
    map["default_tax"] = defaultTax;
    map["default_currency"] = defaultCurrency;
    map["currency_right"] = currencyRight;
    map["enable_paypal"] = payPalEnabled;
    map["enable_stripe"] = stripeEnabled;
    map["mobile_language"] = mobileLanguage.value.languageCode;
    map["block_checkout"] = checkoutAlertEnabled;
    map["block_checkout_msg"] = checkoutAlertMessage;
    return map;
  }
}
