import 'package:food_delivery_app/src/models/media.dart';
import 'package:food_delivery_app/src/models/res_opening_hours.dart';
import 'package:intl/intl.dart';

class Restaurant {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  String latitude;
  String longitude;
  double distance;
  bool resOpeningStatus;
  List<ResOpeningHours> res_opening_hours;

  Restaurant();

  Restaurant.fromJSON(Map<String, dynamic> jsonMap)
  {
    id = jsonMap['id'].toString();
    name = jsonMap['name'];
    image = jsonMap['media'] != null
        ? Media.fromJSON(jsonMap['media'][0])
        : null;
    res_opening_hours = jsonMap.containsKey('res_opening_hours') ? jsonMap['res_opening_hours'] != null
        ? List.from(jsonMap['res_opening_hours'])
        .map((element) => ResOpeningHours.fromJSON(element))
        .toList()
        : []:[];
    rate = jsonMap['rate'] ?? '0';
    address = jsonMap['address'];
    description = jsonMap['description'];
    phone = jsonMap['phone'];
    mobile = jsonMap['mobile'];
    information = jsonMap['information'];
    latitude = jsonMap['latitude'];
    longitude = jsonMap['longitude'];
    distance = jsonMap['distance'] != null
        ? double.parse(jsonMap['distance'].toString())
        : 0.0;
    resOpeningStatus = jsonMap.containsKey('res_opening_hours') ? getResOpeningStatus(jsonMap['res_opening_hours'] != null
        ? List.from(jsonMap['res_opening_hours'])
        .map((element) => ResOpeningHours.fromJSON(element))
        .toList()
        : false):false;
  }
  bool getResOpeningStatus(List<ResOpeningHours> resOpeningHoursList)
  {
    //print('resOpeningHoursList:${resOpeningHoursList.length}');
    bool resOpeningStatus = false;
    if (resOpeningHoursList.isNotEmpty) {
      DateTime date = DateTime.now();
      String currentWeekOfDay = DateFormat('EEEE').format(date);
      //print('currentWeekOfDay:$currentWeekOfDay');
      for (int i = 0; i < resOpeningHoursList.length; i++) {
        ResOpeningHours resOpeningHours = resOpeningHoursList[i];
        if (currentWeekOfDay == resOpeningHours.week) {
          //print('resOpeningHours.is_open:${resOpeningHours.is_open}');
          if (resOpeningHours.is_open == "1") {
            //print('ResOpeningHours:${resOpeningHours.toMap()}');
            final currentTime = DateTime.now();
            final startTime = DateTime(
                currentTime.year,
                currentTime.month,
                currentTime.day,
                int.parse(resOpeningHours.start_hours),
                int.parse(resOpeningHours.start_minutes),
                0);
            final endTime = DateTime(
                currentTime.year,
                currentTime.month,
                currentTime.day,
                int.parse(resOpeningHours.end_hours),
                int.parse(resOpeningHours.end_minutes),
                0);

            //print('startTime:$startTime');
            //print('endTime:$endTime');
            if (currentTime.isAfter(startTime) &&
                currentTime.isBefore(endTime)) {
              // do something
              resOpeningStatus = true;
            }
          }
          break;
        }
      }
    }
    return resOpeningStatus;
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
    };
  }
}
