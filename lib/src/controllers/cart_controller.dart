import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/cart.dart';
import 'package:food_delivery_app/src/repository/cart_repository.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;
import 'package:mvc_pattern/mvc_pattern.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];

  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);

    }, onDone: () {
      calculateSubtotal();
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      /*scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    });
  }

  Future<void> refreshCarts() async {
    listenForCarts();
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      setState(() {
        this.carts.remove(_cart);
        refreshCarts();
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_food_was_removed_from_your_cart(_cart.food.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    carts.forEach((cart) {
//      subTotal += cart.quantity * cart.food.price;
      subTotal += (cart.quantity * cart.food.priceWithExtra);
    });

    //deliveryFee = carts[0].food.restaurant.deliveryFee;
    //taxAmount = (subTotal + deliveryFee) * settingRepo.setting.value.defaultTax / 100;
    //total = subTotal + taxAmount + deliveryFee;
    total = subTotal + settingRepo.setting.value.defaultTax;
    setState(() {});
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }
}
