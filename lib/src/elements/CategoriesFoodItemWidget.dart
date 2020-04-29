import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/category_with_foods.dart';
import 'FoodItemWidget.dart';

class CategoriesFoodItemWidget extends StatelessWidget {
  final String heroTag;
  final CategoryWithFoods categoryWithFoods;

  const CategoriesFoodItemWidget({Key key, this.categoryWithFoods, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return categoryWithFoods.foods.length > 0 ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
            SizedBox(height: 10,),
            Padding(padding: EdgeInsets.only(left: 20,right: 20),child:
             Text(
               categoryWithFoods.name,
               overflow: TextOverflow.ellipsis,
               maxLines: 2,
               style: Theme.of(context).textTheme.display1,
             ),),
            SizedBox(height: 20,),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: categoryWithFoods.foods.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return FoodItemWidget(
                  heroTag: 'details_featured_food',
                  food: categoryWithFoods.foods
                      .elementAt(index),
                );
              },
            ),
          ],
        ):Container();
  }
}
