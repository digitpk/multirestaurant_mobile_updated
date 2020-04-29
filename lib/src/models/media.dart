class Media {
  String id;
  String name;
  String url;
  String thumb;
  String icon;
  String size;

  Media() {
    url = "";
    thumb = "";
    icon = "";
  }

  Media.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'],
        url = jsonMap['url'],
        thumb = jsonMap['thumb'],
        icon = jsonMap['icon'],
        size = jsonMap['formated_size'];

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
