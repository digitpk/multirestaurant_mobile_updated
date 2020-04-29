import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/cart_controller.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ShoppingCartButtonWidget extends StatefulWidget {
  const ShoppingCartButtonWidget({
    this.iconColor,
    this.labelColor,
    Key key,
  }) : super(key: key);

  final Color iconColor;
  final Color labelColor;

  @override
  _ShoppingCartButtonWidgetState createState() => _ShoppingCartButtonWidgetState();
}

class _ShoppingCartButtonWidgetState extends StateMVC<ShoppingCartButtonWidget> {
  CartController _con;

  _ShoppingCartButtonWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(width: 10,),
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/ResCategories');
          },
          child:
          ImageIcon(AssetImage("assets/img/res_cat.png"),color: this.widget.iconColor,size: 28,),
        ),
        SizedBox(width: 10,),
        InkWell(
          onTap: () {
            if (currentUser.value.apiToken != null) {
              Navigator.of(context).pushNamed('/Cart', arguments: RouteArgument(param: '/Pages', id: '2'));
            } else {
              Navigator.of(context).pushNamed('/Login');
            }
          },
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: <Widget>[
              Icon(
                Icons.shopping_cart,
                color: this.widget.iconColor,
                size: 28,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  _con.cartCount.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption.merge(
                    TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 9),
                  ),
                ),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: this.widget.labelColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                constraints: BoxConstraints(
                    minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
              ),
            ],
          ),
        ),
        SizedBox(width: 10,),
      ],
    );
  }
}
