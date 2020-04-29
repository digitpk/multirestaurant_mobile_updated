import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;

class App {
  BuildContext _context;
  double _height;
  double _width;
  double _heightPadding;
  double _widthPadding;

  App(_context) {
    this._context = _context;
    MediaQueryData _queryData = MediaQuery.of(this._context);
    _height = _queryData.size.height / 100.0;
    _width = _queryData.size.width / 100.0;
    _heightPadding = _height - ((_queryData.padding.top + _queryData.padding.bottom) / 100.0);
    _widthPadding = _width - (_queryData.padding.left + _queryData.padding.right) / 100.0;
  }

  double appHeight(double v) {
    return _height * v;
  }

  double appWidth(double v) {
    return _width * v;
  }

  double appVerticalPadding(double v) {
    return _heightPadding * v;
  }

  double appHorizontalPadding(double v) {
//    int.parse(settingRepo.setting.mainColor.replaceAll("#", "0xFF"));
    return _widthPadding * v;
  }
}

class Colors {
//  Color _mainColor = Color(0xFFFF4E6A);
//  Color _mainDarkColor = Color(0xFFea5c44);
//  Color _secondColor = Color(0xFF344968);
//  Color _secondDarkColor = Color(0xFFccccdd);
//  Color _accentColor = Color(0xFF8C98A8);
//  Color _accentDarkColor = Color(0xFF9999aa);
//  Color _scaffoldDarkColor = Color(0xFF2C2C2C);
//  Color _scaffoldColor = Color(0xFFFAFAFA);
  Color _greenColor = Color(0xFF388e3c);
  Color _grayColor = Color(0xFF9e9e9e);
  Color mainColor(double opacity) {
    try {
      return Color(int.parse(settingRepo.setting.value.mainColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }

  Color secondColor(double opacity) {
    try {
      return Color(int.parse(settingRepo.setting.value.secondColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }

  Color accentColor(double opacity) {
    try {
      return Color(int.parse(settingRepo.setting.value.accentColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }

  Color mainDarkColor(double opacity) {
    try {
      return Color(int.parse(settingRepo.setting.value.mainDarkColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }

  Color secondDarkColor(double opacity) {
    try {
      return Color(int.parse(settingRepo.setting.value.secondDarkColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }

  Color accentDarkColor(double opacity) {
    try {
      return Color(int.parse(settingRepo.setting.value.accentDarkColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }

  Color scaffoldColor(double opacity) {
    // TODO test if brightness is dark or not
    try {
      return Color(int.parse(settingRepo.setting.value.scaffoldColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }
  Color scaffoldDarkColor(double opacity) {
    // TODO test if brightness is dark or not
    try {
      return Color(int.parse(settingRepo.setting.value.scaffoldDarkColor.replaceAll("#", "0xFF"))).withOpacity(opacity);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity);
    }
  }
  Color grayColor(double opacity) {
    return this._grayColor.withOpacity(opacity);
  }
  Color greenColor(double opacity) {
    return this._greenColor.withOpacity(opacity);
  }
}
/*
class Colors {
//  Color _mainColor = Color(0xFFFF4E6A);
  Color _mainColor = Color(0xFFea5c44);
  Color _mainDarkColor = Color(0xFFea5c44);
  Color _secondColor = Color(0xFF344968);
  Color _secondDarkColor = Color(0xFFccccdd);
  Color _accentColor = Color(0xFF8C98A8);
  Color _accentDarkColor = Color(0xFF9999aa);
  Color _scaffoldDarkColor = Color(0xFF2C2C2C);
  Color _scaffoldColor = Color(0xFFFAFAFA);
  Color _greenColor = Color(0xFF388e3c);
  Color _grayColor = Color(0xFF9e9e9e);

  Color mainColor(double opacity) {
    return this._mainColor.withOpacity(opacity);
  }

  Color secondColor(double opacity) {
    return this._secondColor.withOpacity(opacity);
  }

  Color accentColor(double opacity) {
    return this._accentColor.withOpacity(opacity);
  }

  Color mainDarkColor(double opacity) {
    return this._mainDarkColor.withOpacity(opacity);
  }

  Color secondDarkColor(double opacity) {
    return this._secondDarkColor.withOpacity(opacity);
  }

  Color accentDarkColor(double opacity) {
    return this._accentDarkColor.withOpacity(opacity);
  }
  Color grayColor(double opacity) {
    return this._grayColor.withOpacity(opacity);
  }
  Color greenColor(double opacity) {
    return this._greenColor.withOpacity(opacity);
  }
  Color scaffoldDarkColor(double opacity) {
    return this._scaffoldDarkColor.withOpacity(opacity);
  }

  Color scaffoldColor(double opacity) {
    // TODO test if brightness is dark or not
    return _scaffoldColor.withOpacity(opacity);
  }
}*/