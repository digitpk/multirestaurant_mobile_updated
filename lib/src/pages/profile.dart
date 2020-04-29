import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/profile_controller.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/OrderItemWidget.dart';
import 'package:food_delivery_app/src/elements/PermissionDeniedWidget.dart';
import 'package:food_delivery_app/src/elements/ProfileAvatarWidget.dart';
import 'package:food_delivery_app/src/elements/ProfileSettingsDialog.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartButtonWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  ProfileWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  ProfileController _con;

  _ProfileWidgetState() : super(ProfileController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).primaryColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).profile,
          style: Theme.of(context)
              .textTheme
              .title
              .merge(TextStyle(letterSpacing: 1.3, color: Theme.of(context).primaryColor)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).primaryColor, labelColor: Theme.of(context).hintColor),
        ],
      ),
      key: _con.scaffoldKey,
      body: currentUser.value.apiToken == null
          ? PermissionDeniedWidget()
          : SingleChildScrollView(
//              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: <Widget>[
                  ProfileAvatarWidget(user: currentUser.value),
                  /*ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).about,
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      currentUser.value?.bio ?? "",
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),*/
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.15),
                            offset: Offset(0, 3),
                            blurRadius: 10)
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                            S.of(context).profile_settings,
                            style: Theme.of(context).textTheme.body2,
                          ),
                          trailing: ButtonTheme(
                            padding: EdgeInsets.all(0),
                            minWidth: 50.0,
                            height: 25.0,
                            child: ProfileSettingsDialog(
                              user: currentUser.value,
                              onChanged: () {
                                _con.update(currentUser.value);
                                //setState(() {});
                              },
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).full_name,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Text(
                            currentUser.value.name,
                            style: TextStyle(color: Theme.of(context).focusColor),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).email,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Text(
                            currentUser.value.email,
                            style: TextStyle(color: Theme.of(context).focusColor),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).phone,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Text(
                            currentUser.value.phone == null ? "": currentUser.value.phone,
                            style: TextStyle(color: Theme.of(context).focusColor),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).address,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Text(
                            Helper.limitString(currentUser.value.address),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(color: Theme.of(context).focusColor),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          dense: true,
                          title: Text(
                            S.of(context).about,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Text(
                            Helper.limitString(currentUser.value.bio),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(color: Theme.of(context).focusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.shopping_basket,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).recent_orders,
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                  _con.recentOrders.isEmpty
                      ? CircularLoadingWidget(height: 200)
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount: _con.recentOrders.length,
                          itemBuilder: (context, index) {
                            return Theme(
                              data: theme,
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(
                                            '${S.of(context).order_id}: #${_con.recentOrders.elementAt(index).id}')),
                                    Text(
                                      '${_con.recentOrders.elementAt(index).orderStatus.status}',
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                                children:
                                    List.generate(_con.recentOrders.elementAt(index).foodOrders.length, (indexFood) {
                                  return OrderItemWidget(
                                      heroTag: 'recent_orders',
                                      order: _con.recentOrders.elementAt(index),
                                      foodOrder: _con.recentOrders.elementAt(index).foodOrders.elementAt(indexFood));
                                }),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
