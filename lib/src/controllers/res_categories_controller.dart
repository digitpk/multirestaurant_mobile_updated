import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/repository/category_repository.dart';

class ResCategoriesController extends ControllerMVC {
  List<ResCategory> resCategories = <ResCategory>[];

  ResCategoriesController() {
    //listenForResCategories();
  }

  void listenForResCategories() async {
    final Stream<ResCategory> stream = await getResCategories();
    stream.listen((ResCategory _category) {
      setState(() => resCategories.add(_category));
    }, onError: (a) {
      print('onError');
    }, onDone: () {
      print('Categories lenght:${resCategories.length}');
    });
  }
}
