import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart' as userRepo;
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;

// ignore: must_be_immutable
class ResCatListItemWidget extends StatelessWidget {
  String heroTag;
  ResCategory resCategory;

  ResCatListItemWidget({Key key, this.heroTag, this.resCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        userRepo.getResCat().then((resCatId){
          userRepo.setResCat(resCategory.id);
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + resCategory.id,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: NetworkImage(resCategory.image), fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          resCategory.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.display3.merge(TextStyle(fontSize: 20)),
                        ),
                        Text(
                          '${Helper.skipHtml(resCategory.description)}',
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.display4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
