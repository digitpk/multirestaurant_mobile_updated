import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/delivery_addresses_controller.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/DeliveryAddressDialog.dart';
import 'package:food_delivery_app/src/elements/DeliveryAddressesItemWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartButtonWidget.dart';
import 'package:food_delivery_app/src/models/address.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DeliveryAddressesWidget extends StatefulWidget {
  RouteArgument routeArgument;

  DeliveryAddressesWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryAddressesWidgetState createState() =>
      _DeliveryAddressesWidgetState();
}

class _DeliveryAddressesWidgetState extends StateMVC<DeliveryAddressesWidget> {
  DeliveryAddressesController _con;

  _DeliveryAddressesWidgetState() : super(DeliveryAddressesController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.isLoadingData = true;
  }

  void saveAddressAlert(Address address) {
    address.description = "";
    Alert(
      context: context,
      type: AlertType.info,
      title: S.of(context).alert_title_save_address,
      desc: S.of(context).alert_message_save_address,
      buttons: [
        DialogButton(
          child: Text(
            S.of(context).alert_yes,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            DeliveryAddressDialog(
              context: context,
              address: address,
              onChanged: (Address _address) {
                _con.addAddress(_address);
              },
              isForCurrentLocation: true
            );
          },
          width: 120,
        ),
        DialogButton(
          child: Text(
            S.of(context).alert_no,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/PaymentMethod');
          },
          width: 120,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_addresses,
          style: Theme.of(context)
              .textTheme
              .title
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            DeliveryAddressDialog(
              context: context,
              address: new Address(),
              onChanged: (Address _address) {
                _con.addAddress(_address);
              },
              isForCurrentLocation: false
            );
          },
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          )),
      body: RefreshIndicator(
        onRefresh: _con.refreshAddresses,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.map,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).delivery_addresses,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  subtitle: Text(
                    S
                        .of(context)
                        .long_press_to_edit_item_swipe_item_to_delete_it,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              _con.isLoadingData
                  ? CircularLoadingWidget(height: 250)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.addresses.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return DeliveryAddressesItemWidget(
                          address: _con.addresses.elementAt(index),
                          onPressed: (Address _address) {
                            _con.chooseDeliveryAddress(_address);
                            if (index != 0) {
                              Navigator.of(context).pushNamed('/PaymentMethod');
                            } else {
                              saveAddressAlert(_address);
                            }
                          },
                          onLongPress: (Address _address) {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (Address _address) {
                                _con.updateAddress(_address);
                              },
                              isForCurrentLocation: false
                            );
                          },
                          onDismissed: (Address _address) {
                            _con.removeDeliveryAddress(_address);
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
