import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/address.dart' as model;
import 'package:food_delivery_app/src/repository/user_repository.dart' as userRepo;
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class DeliveryAddressesController extends ControllerMVC {
  List<model.Address> addresses = <model.Address>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  DeliveryAddressesController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getCurrentLocation();
  }
  void addCurrentLocation(double latitude, double longitude) async
  {
    print('locationData.latitude:${latitude}');
    print('locationData.longitude:${longitude}');
    final coordinates = new Coordinates(latitude, longitude);
    var addressesByLatLong = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addressesByLatLong.first;
    print("featureName:${first.featureName} /addressLine : ${first.addressLine}");
    model.Address address = new model.Address();
    address.id = "0";
    address.isDefault = false;
    address.description = S.of(context).current_location;
    address.address = "${first.addressLine}";
    address.latitude = latitude.toString();
    address.longitude = longitude.toString();
    print('address.latitude:${address.latitude}');
    print('address.longitude:${address.longitude}');
    setState(() {
      addresses.insert(0,address);
    });
  }
  void getCurrentLocation() async {
    GeolocationStatus geolocationStatus =
    await Geolocator().checkGeolocationPermissionStatus();
    print('geolocationStatus.value:${geolocationStatus.value}');
    if (geolocationStatus.value == 2) {
      //for granted
      print('permission granted');
      Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high)
          .then((position) async {
        if (position != null) {
          addCurrentLocation(position.latitude,position.longitude);
        } else {
          print('last position null');
          Geolocator()
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
              .then((position) async {
            if (position != null) {
              addCurrentLocation(position.latitude,position.longitude);
            }
          });
        }
      });
    }
    listenForAddresses();
  }
  void listenForAddresses({String message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
      setState(() {
        addresses.add(_address);
      });
    }, onError: (a) {
      print(a);
      /*scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));*/
    }, onDone: () {
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshAddresses() async {
    addresses.clear();
    listenForAddresses(message: S.current.addresses_refreshed_successfuly);
  }

  void addAddress(model.Address address) {
    userRepo.addAddress(address).then((value) {
      setState(() {
        this.addresses.add(value);
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.new_address_added_successfully),
      ));
    });
  }

  void chooseDeliveryAddress(model.Address address) {
    userRepo.deliveryAddress = address;
  }

  void updateAddress(model.Address address) {
//    if (address.isDefault) {
//      this.addresses.map((model.Address _address) {
//        setState(() {
//          _address.isDefault = false;
//        });
//      });
//    }
    userRepo.updateAddress(address).then((value) {
      //setState(() {});
//      scaffoldKey.currentState.showSnackBar(SnackBar(
//        content: Text(S.current.the_address_updated_successfully),
//      ));
      setState(() {});
      addresses.clear();
      listenForAddresses(message: S.current.the_address_updated_successfully);
    });
  }

  void removeDeliveryAddress(model.Address address) async {
    userRepo.removeDeliveryAddress(address).then((value) {
      setState(() {
        this.addresses.remove(address);
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Delivery Address removed successfully"),
      ));
    });
  }
}
