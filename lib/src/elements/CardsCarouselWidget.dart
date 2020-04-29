import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'CardWidget.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;

class CardsCarouselWidget extends StatefulWidget {
  List<Restaurant> restaurantsList;
  String heroTag;

  CardsCarouselWidget({Key key, this.restaurantsList, this.heroTag}) : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.restaurantsList.isEmpty
        ? CircularLoadingWidget(height: 288)
        : Container(
            height: 288,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.restaurantsList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    /*if (widget.restaurantsList
                        .elementAt(index)
                        .resOpeningStatus) {*/
                      Navigator.of(context).pushNamed('/Details',
                          arguments: RouteArgument(
                            id: widget.restaurantsList.elementAt(index).id,
                            heroTag: widget.heroTag,
                          ));
                   /* } else {
                      settingRepo.initSettings().then((setting) {
                        setState(() {
                          closeRestaurantAlert(setting.messageClose);
                        });
                      });
                    }*/
                  },
                  child: CardWidget(restaurant: widget.restaurantsList.elementAt(index), heroTag: widget.heroTag),
                );
              },
            ),
          );
  }
}
