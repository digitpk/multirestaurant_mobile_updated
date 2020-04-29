import 'food.dart';

class CategoryWithFoods {
  String id;
  String name;
  String image;
  List<Food> foods = <Food>[];

  CategoryWithFoods();

  CategoryWithFoods.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'],
        image = jsonMap['media'][0]['url'],
        foods = jsonMap['foods'] != null
            ? List.from(jsonMap['foods']).map((element) => Food.fromJSON(element)).toList()
            : null;
}
