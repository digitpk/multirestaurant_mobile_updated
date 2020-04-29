class ResOpeningHours {
  String week;
  String start_hours;
  String start_minutes;
  String end_hours;
  String end_minutes;
  String is_open;

  ResOpeningHours();

  ResOpeningHours.fromJSON(Map<String, dynamic> jsonMap)
      : week = jsonMap['week'].toString(),
        start_hours = jsonMap['start_time'].toString(),
        start_minutes = jsonMap['start_minutes'].toString(),
        end_hours = jsonMap['end_time'].toString(),
        end_minutes = jsonMap['end_minutes'].toString(),
        is_open = jsonMap['is_open'].toString();
  Map<String, dynamic> toMap() {
    return {
      'week': week,
      'start_hours': start_hours,
      'start_minutes': start_minutes,
      'end_hours': end_hours,
      'end_minutes': end_minutes,
      'is_open': is_open,
    };
  }
}
