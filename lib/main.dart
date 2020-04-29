import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/route_generator.dart';
import 'package:food_delivery_app/src/controllers/controller.dart';
import 'package:food_delivery_app/src/helpers/app_config.dart' as config;
import 'package:food_delivery_app/src/models/setting.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  runApp(MyApp());
}

class MyApp extends AppMVC {
  // This widget is the root of your application.
//  /// Supply 'the Controller' for this application.
/*
Fonts:
      - ExtraLight -  200
      - Light - 300
      - Regular - 400
      - SemiBold - 600
      - Bold - 700
      - ExtraBold - 800
 */
  MyApp({Key key}) : super(con: Controller(), key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) {
          /*if (brightness == Brightness.light) {
            return ThemeData(
              fontFamily: 'Assistant',
              primaryColor: Colors.white,
              brightness: brightness,
              accentColor: config.Colors().mainColor(1),
              focusColor: config.Colors().accentColor(1),
              hintColor: config.Colors().secondColor(1),
              textTheme: TextTheme(
                headline: TextStyle(fontSize: 20.0, color: config.Colors().secondColor(1)),
                display1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
                display2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
                display3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1)),
                display4: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w300, color: config.Colors().secondColor(1)),
                subhead: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: config.Colors().secondColor(1)),
                title: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: config.Colors().mainColor(1)),
                body1: TextStyle(fontSize: 12.0, color: config.Colors().secondColor(1)),
                body2: TextStyle(fontSize: 14.0, color: config.Colors().secondColor(1)),
                caption: TextStyle(fontSize: 12.0, color: config.Colors().accentColor(1)),
              ),
            );
          } else {
            return ThemeData(
              fontFamily: 'Assistant',
              primaryColor: Color(0xFF252525),
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color(0xFF2C2C2C),
              accentColor: config.Colors().mainDarkColor(1),
              hintColor: config.Colors().secondDarkColor(1),
              focusColor: config.Colors().accentDarkColor(1),
              textTheme: TextTheme(
                headline: TextStyle(fontSize: 20.0, color: config.Colors().secondDarkColor(1)),
                display1:
                    TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
                display2:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
                display3:
                    TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1)),
                display4:
                    TextStyle(fontSize: 22.0, fontWeight: FontWeight.w300, color: config.Colors().secondDarkColor(1)),
                subhead:
                    TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: config.Colors().secondDarkColor(1)),
                title: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: config.Colors().mainDarkColor(1)),
                body1: TextStyle(fontSize: 12.0, color: config.Colors().secondDarkColor(1)),
                body2: TextStyle(fontSize: 14.0, color: config.Colors().secondDarkColor(1)),
                caption: TextStyle(fontSize: 12.0, color: config.Colors().secondDarkColor(0.6)),
              ),
            );
          }*/
          if (brightness == Brightness.light) {
            return ThemeData(
              fontFamily: 'Assistant',
              primaryColor: Colors.white,
              brightness: brightness,
              accentColor: config.Colors().mainColor(1),
              focusColor: config.Colors().accentColor(1),
              hintColor: config.Colors().secondColor(1),
              textTheme: TextTheme(
                headline: TextStyle(fontSize: 21.0, color: config.Colors().secondColor(1)),
                display1: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w800, color: config.Colors().secondColor(1)),
                display2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: config.Colors().secondColor(1)),
                display3: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1)),
                display4: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1)),
                title: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w800, color: config.Colors().mainColor(1)),
                subhead: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
                body1: TextStyle(fontSize: 13.0, color: config.Colors().secondColor(1)),
                body2: TextStyle(fontSize: 15.0, color: config.Colors().secondColor(1)),
                caption: TextStyle(fontSize: 13.0, color: config.Colors().accentColor(1)),
              ),
            );
          } else {
            return ThemeData(
              fontFamily: 'Assistant',
              primaryColor: Color(0xFF252525),
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color(0xFF2C2C2C),
              accentColor: config.Colors().mainDarkColor(1),
              hintColor: config.Colors().secondDarkColor(1),
              focusColor: config.Colors().accentDarkColor(1),
              textTheme: TextTheme(
                headline: TextStyle(fontSize: 21.0, color: config.Colors().secondDarkColor(1)),
                display1: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w800, color: config.Colors().secondDarkColor(1)),
                display2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: config.Colors().secondDarkColor(1)),
                display3: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1)),
                display4: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1)),
                title: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w800, color: config.Colors().mainDarkColor(1)),
                subhead: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
                body1: TextStyle(fontSize: 13.0, color: config.Colors().secondDarkColor(1)),
                body2: TextStyle(fontSize: 15.0, color: config.Colors().secondDarkColor(1)),
                caption: TextStyle(fontSize: 13.0, color: config.Colors().secondDarkColor(0.6)),
              ),
            );
          }
        },
        themedWidgetBuilder: (context, theme) {
          return ValueListenableBuilder(
              valueListenable: settingRepo.locale,
              builder: (context, Locale value, _) {
                print(value);
                return MaterialApp(
                  title: 'Flutter Multi-Restaurants',
                  initialRoute: '/Splash',
                  onGenerateRoute: RouteGenerator.generateRoute,
                  debugShowCheckedModeBanner: false,
                  locale: value,
                  localizationsDelegates: [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  localeListResolutionCallback: S.delegate.listResolution(fallback: const Locale('he', '')),
                  navigatorObservers: [
                    FirebaseAnalyticsObserver(analytics: analytics),
                  ],
                  theme: theme,
                );
              });
        });
  }
}
