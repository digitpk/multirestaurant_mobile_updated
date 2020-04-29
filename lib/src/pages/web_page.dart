import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';

class WebPageWidget extends StatefulWidget {
  RouteArgument routeArgument;

  WebPageWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _WebPageWidgetState createState() => _WebPageWidgetState();
}

class _WebPageWidgetState extends StateMVC<WebPageWidget> {
  double web_progress = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).web_page_title,
          style: Theme.of(context)
              .textTheme
              .title
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: widget.routeArgument.id.isEmpty
          ? CircularLoadingWidget(height: 300)
          : Stack(
              children: <Widget>[
                InAppWebView(
                  initialUrl: widget.routeArgument.id,
                  initialHeaders: {},
                  initialOptions: {},//for version 1.2.2
                  /*initialOptions: InAppWebViewWidgetOptions(
                    inAppWebViewOptions: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),*/
                  onWebViewCreated: (InAppWebViewController controller) {

                  },
                  onLoadStop: (InAppWebViewController controller, String url){

                  },

                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      web_progress = progress / 100;
                    });
                  },
                ),

                web_progress < 1
                    ? SizedBox(
                        height: 3,
                        child: LinearProgressIndicator(
                          value: web_progress,
                          backgroundColor:
                              Theme.of(context).accentColor.withOpacity(0.2),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
    );
  }
}
