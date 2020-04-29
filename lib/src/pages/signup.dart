import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/user_controller.dart';
import 'package:food_delivery_app/src/elements/BlockButtonWidget.dart';
import 'package:food_delivery_app/src/helpers/app_config.dart' as config;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController _con;
  bool _isChecked = false;

  _SignUpWidgetState() : super(UserController()) {
    _con = controller;
    _con.user.isForLogin = false;
  }
  void goToTermsOfService() async {
    String url = "http://hyperurl.co/diny";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                  S.of(context).lets_start_with_register,
                  style: Theme.of(context).textTheme.display3.merge(TextStyle(color: Theme.of(context).primaryColor)),
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
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (input) => _con.user.name = input,
                        validator: (input) => input.length < 3 ? S.of(context).should_be_more_than_3_letters : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).full_name,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: S.of(context).john_doe,
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => _con.user.email = input,
                        validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).email,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'johndoe@gmail.com',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        obscureText: _con.hidePassword,
                        onSaved: (input) => _con.user.password = input,
                        validator: (input) => input.length < 6 ? S.of(context).should_be_more_than_6_letters : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).password,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).accentColor),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con.hidePassword = !_con.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_con.hidePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        onSaved: (input) => _con.user.phone = input,
                        validator: (input) => input.trim().length < 6
                            ? S.of(context).not_a_valid_phone
                            : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).phone,
                          labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '+972 626 219 765',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.phone,
                              color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(children: <Widget>[
                        Checkbox(value: _isChecked,
                          onChanged: (isChecked){
                            setState((){
                              _isChecked = isChecked;
                            });
                          },),
                        InkWell(child:
                        Text.rich(
                          TextSpan(
                            text: S.of(context).i_agree_txt,
                            style: Theme.of(context)
                                .textTheme
                                .display4
                                .merge(TextStyle(fontSize: 17,color: Theme.of(context).accentColor)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: S.of(context).terms_of_service_txt,
                                  style: Theme.of(context)
                                      .textTheme
                                      .display4
                                      .merge(TextStyle(fontSize: 17,decoration:TextDecoration.underline,color: Theme.of(context).accentColor))),
                              // can add more TextSpans here...
                            ],
                          ),
                        ),
                          /*Text(S.of(context).terms_of_service_txt,style: Theme.of(context)
                            .textTheme
                            .display4
                            .merge(TextStyle(color: Theme.of(context).accentColor)),),*/
                          onTap: (){
                            goToTermsOfService();
                          },
                        )
                      ],),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context).register,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          _con.register();
                        },
                      ),
                      SizedBox(height: 25),
//                      FlatButton(
//                        onPressed: () {
//                          Navigator.of(context).pushNamed('/MobileVerification');
//                        },
//                        padding: EdgeInsets.symmetric(vertical: 14),
//                        color: Theme.of(context).accentColor.withOpacity(0.1),
//                        shape: StadiumBorder(),
//                        child: Text(
//                          'Register with Google',
//                          textAlign: TextAlign.start,
//                          style: TextStyle(
//                            color: Theme.of(context).accentColor,
//                          ),
//                        ),
//                      ),
                    ],
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
}
