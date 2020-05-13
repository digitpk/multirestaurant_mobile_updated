import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/src/helpers/app_config.dart' as config;
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/user_controller.dart';
import 'package:food_delivery_app/src/elements/BlockButtonWidget.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';

class OTPWidget extends StatefulWidget {
  RouteArgument routeArgument;

  OTPWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _OTPWidgetState createState() => _OTPWidgetState();
}

class _OTPWidgetState extends StateMVC<OTPWidget> {
  UserController _con;

  _OTPWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.user = widget.routeArgument.param;
    _con.verificationId = widget.routeArgument.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(29.5),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(29.5),
                child: Text(
                  S.of(context).one_time_password,
                  style: Theme.of(context)
                      .textTheme
                      .display3
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getRespectiveFields(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/Login');
                },
                textColor: Theme.of(context).hintColor,
                child: Text(S.of(context).i_have_account_back_to_login),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getRespectiveFields() {
    var widgets = <Widget>[];
    widgets.addAll(<Widget>[
      TextFormField(
        keyboardType: TextInputType.number,
        onSaved: (input) => _con.otp = input,
        validator: (input) =>
            input.length < 6 ? S.of(context).enter_valid_otp : null,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: S.of(context).otp,
          labelStyle: TextStyle(color: Theme.of(context).accentColor),
          contentPadding: EdgeInsets.all(12),
          hintText: S.of(context).otp,
          hintStyle:
              TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
          prefixIcon:
              Icon(Icons.person_outline, color: Theme.of(context).accentColor),
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).focusColor.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).focusColor.withOpacity(0.5))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).focusColor.withOpacity(0.2))),
        ),
      ),
      SizedBox(height: 30),
      _con.isLoading
          ? CircularLoadingWidget(
        height: 50,
      )
          : BlockButtonWidget(
        text: Text(
          S.of(context).verify,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        color: Theme.of(context).accentColor,
        onPressed: () {
          _con.loginFormKey.currentState.save();
          _con.verify();
        },
      ),
      SizedBox(height: 30),
      BlockButtonWidget(
        text: Text(
          S.of(context).back,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        color: Theme.of(context).accentColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ]);
    return widgets;
  }
}
