import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart' as repository;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String otp;
  String verificationId;
  bool isVerified = false;

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      print(_deviceToken);
      user.deviceToken = _deviceToken;
    });
  }

  void login() async {
    if (loginFormKey.currentState.validate()) {
      if ((user.phone != null && user.phone.trim().length > 0) &&
          ((user.email != null && user.email.trim().length > 0) ||
              (user.password != null && user.password.trim().length > 0))) {
        showErrorAndGoBack(S.current.enter_email_or_phone, false);
      } else if (!isVerified &&
          (user.phone != null && user.phone.trim() != "") &&
          (user.email == null || user.email.trim() == "")) {
        sendOTP();
      } else {
        addCountryCode();
        repository.login(user).then((value) {
          //print(value.apiToken);
          if (value != null && value.apiToken != null) {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(S.current.welcome + value.name),
            ));
            //Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
            repository.setUserEmail(user.email);
            goToDashboard();
          } else {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(S.current.wrong_email_or_password),
            ));
          }
        });
      }
    }
  }

  void register() async {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.welcome + value.name),
          ));
          //Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
          goToDashboard();
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.wrong_email_or_password),
          ));
        }
      });
    }
  }
  void goToDashboard() {
    /*Navigator.of(scaffoldKey.currentContext)
        .pushReplacementNamed('/ResCategories');*/
    Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
  }
  void resetPassword() {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.current.login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.error_verify_email_settings),
          ));
        }
      });
    }
  }
  void sendOTP() async {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();

      addCountryCode();

      var response = await repository.isUserExist(user);

      if ((this.user.isForLogin && response.statusCode != 200) ||
          !this.user.isForLogin && response.statusCode == 200) {
        showErrorAndGoBack(json.decode(response.body)['message'], false);
      } else {
        final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
          this.verificationId = verId;
          Navigator.of(scaffoldKey.currentContext).pushNamed('/OTP',
              arguments: RouteArgument(
                  id: verificationId, heroTag: null, param: user));
        };
        try {
          await _auth.verifyPhoneNumber(
              phoneNumber: user.phone,
              // PHONE NUMBER TO SEND OTP
              codeAutoRetrievalTimeout: (String verId) {
                //Starts the phone number verification process for the given phone number.
                //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
                this.verificationId = verId;
              },
              // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
              codeSent: smsOTPSent,
              timeout: const Duration(seconds: 60),
              verificationCompleted: (AuthCredential phoneAuthCredential) {
                onVerified();
              },
              verificationFailed: (AuthException exception) {
                showErrorAndGoBack(exception.message, false);
              });
        } catch (e) {
          showErrorAndGoBack(e.message, false);
        }
      }
    }
  }

  verify() async {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: this.otp,
      );
      FirebaseAuth.instance.signInWithCredential(credential).then((user) {
        onVerified();
      }).catchError((error) {
        showErrorAndGoBack(error.message, true);
      });
    }
  }

  showErrorAndGoBack(error, shouldGoBack) {
    showDialog(
        context: scaffoldKey.currentContext,
        builder: (context) => AlertDialog(
          title: Text(S.current.request_failed),
          content: Text(error),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                otp = "";
                verificationId = "";
                isVerified = false;
                Navigator.of(context).pop();
                if (shouldGoBack) Navigator.of(context).pop();
              },
            ),
          ],
        ).build(context));
  }
  void onVerified() {
    isVerified = true;
    if (user.isForLogin) {
      login();
    } else {
      register();
    }
  }

  void addCountryCode() {
    if (this.user.phone != null && this.user.phone != "") {
      var code = "+972";
      this.user.phone =
          (this.user.phone.contains(code) ? "" : code) + this.user.phone;
    }
  }
}
