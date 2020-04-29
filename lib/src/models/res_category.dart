class ResCategory {
  String id;
  String name;
  String description;
  String image;
  ResCategory();

  ResCategory.fromJSON(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'] != null ? jsonMap['id'].toString() : null;
    name = jsonMap['name'] != null ? jsonMap['name'].toString() : null;
    description = jsonMap['description'] != null ? jsonMap['description'].toString() : null;
    image = jsonMap['media'][0]['thumb'];

  }
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["description"] = description;
    map["image"] = image;
    return map;
  }
}
