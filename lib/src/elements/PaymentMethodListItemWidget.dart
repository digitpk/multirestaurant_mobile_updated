import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/credit_card.dart';
import 'package:food_delivery_app/src/models/payment_method.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart'
    as userRepo;
import 'package:rflutter_alert/rflutter_alert.dart';

// ignore: must_be_immutable
class PaymentMethodListItemWidget extends StatelessWidget {
  String heroTag;
  PaymentMethod paymentMethod;
  BuildContext context;

  PaymentMethodListItemWidget({Key key, this.paymentMethod}) : super(key: key);

  void payAlert(CreditCard creditCard) {
    Alert(
      context: context,
      type: AlertType.none,
      title: S.of(context).pay_alert_title,
      desc: S.of(context).pay_alert_message(creditCard.number),
      style: AlertStyle(
          titleStyle: Theme.of(context)
              .textTheme
              .display1
              .merge(TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          descStyle: Theme.of(context)
              .textTheme
              .caption
              .merge(TextStyle(fontSize: 20, fontWeight: FontWeight.w200))),
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).alert_yes,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacementNamed('/PayWithToken',
                arguments: new RouteArgument(param: 'Pay with Token'));
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            S.of(context).alert_no,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
            goToPayment();
          },
          width: 50,
        ),
      ],
    ).show();
  }

  void goToPayment() {
    Navigator.of(context).pushNamed(this.paymentMethod.route);
    print(this.paymentMethod.name);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if (this.paymentMethod.name == "Pay With CreditCard") {
          userRepo.getCreditCard().then((creditCard) {
            print('creditCard:${creditCard.toMap()}');
            print('creditCard.token:${creditCard.token}');
            if (creditCard.token.toString() == 'null') {
              goToPayment();
            } else {
              payAlert(creditCard);
            }
          });
        } else {
          goToPayment();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(
                    image: AssetImage(paymentMethod.logo), fit: BoxFit.fill),
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
                          paymentMethod.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subhead,
                        ),
                        Text(
                          paymentMethod.description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).focusColor,
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
