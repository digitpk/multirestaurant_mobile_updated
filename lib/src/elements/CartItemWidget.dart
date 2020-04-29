import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/cart.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/pages/splash_screen.dart';

class CartItemWidget extends StatefulWidget {
  String heroTag;
  Cart cart;
  VoidCallback increment;
  VoidCallback decrement;
  VoidCallback onDismissed;

  CartItemWidget({Key key, this.cart, this.heroTag, this.increment, this.decrement, this.onDismissed})
      : super(key: key);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.cart.id),
      onDismissed: (direction) {
        setState(() {
          widget.onDismissed();
        });
      },
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        focusColor: Theme.of(context).accentColor,
        highlightColor: Theme.of(context).primaryColor,
        onTap: () {
          Navigator.of(context)
              .pushNamed('/Food', arguments: RouteArgument(id: widget.cart.food.id, heroTag: widget.heroTag));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.9),
            boxShadow: [
              BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
            ],
          ),
          child:
          Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: CachedNetworkImage(
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                    imageUrl: widget.cart.food.image.thumb,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      height: 90,
                      width: 90,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(width: 15),
                Flexible(
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.cart.food.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.subhead,
                                ),
                                Helper.getPrice(widget.cart.food.price,context,
                                    style: Theme.of(context).textTheme.display2),
                                Wrap(
                                  children: List.generate(
                                      widget.cart.extras.length, (index) {
                                    return Text(
                                      widget.cart.extras.elementAt(index).name +
                                          '(' +
                                          SplashScreen
                                              .appSetting.defaultCurrency +
                                          widget.cart.extras
                                              .elementAt(index)
                                              .extraPivot
                                              .extra_price
                                              .toString() +
                                          '*' +
                                          widget.cart.extras
                                              .elementAt(index)
                                              .extraPivot
                                              .extra_qty
                                              .toString() +
                                          ')' +
                                          ', ',
                                      style: Theme.of(context).textTheme.caption,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            widget.increment();
                                          });
                                        },
                                        iconSize: 20,
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        icon: Icon(Icons.add_circle_outline),
                                        color: Theme.of(context).hintColor,
                                      ),
                                      Text(widget.cart.quantity.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            widget.decrement();
                                          });
                                        },
                                        iconSize: 20,
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        icon: Icon(Icons.remove_circle_outline),
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      widget.onDismissed();
                                    },
                                    iconSize: 27,
                                    padding: EdgeInsets.symmetric(horizontal: 1),
                                    icon: Icon(Icons.delete),
                                    color: Theme.of(context).hintColor,
                                  ),
                                ],
                              ),
//                      Helper.getPrice(widget.cart.food.price, style: Theme.of(context).textTheme.display1),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            /*Row(
              children: <Widget>[
                Helper.getPrice(widget.cart.food.priceWithExtra,context,
                    style: Theme.of(context).textTheme.display1),
              ],
            ),*/
          ],),
        ),
      ),
    );
  }
}
