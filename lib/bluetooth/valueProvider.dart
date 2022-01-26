import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class valueProvider with ChangeNotifier {
  double? value1;
  // double? value2;
  // double? bat;
  // int? frp;
  // double? vfrp;
  // int? pfrp;
  // double? pvfrp;
  double _battery = 0;
  double _frp = 0;
  double _vfrp = 0;
  double _pfrp = 0;
  double _pvfrp = 0;
  double _speed = 0;
  double _tspeed = 0;

  double get speed => _speed;
  double get tspeed => _tspeed;
  double get battery => _battery;
  double get frp => _frp;
  double get vfrp => _vfrp;
  double get pfrp => _pfrp;
  double get pvfrp => _pvfrp;
  set speed(double value) {
    _speed = value;
    notifyListeners();
  }
  set stpeed(double value) {
    _tspeed = value;
    notifyListeners();
  }

  set battery(double value) {
    _battery = value;
    notifyListeners();
  }

  set frp(double value) {
    _frp = value;
    notifyListeners();
  }

  set vfrp(double value) {
    _vfrp = value;
    notifyListeners();
  }

  set pfrp(double value) {
    _pfrp = value;
    notifyListeners();
  }

  set pvfrp(double value) {
    _pvfrp = value;
    notifyListeners();
  }
  // notifyListeners();

  // สร้างฟังก์ชันการนับ counter
  // increment(value1PRO) {
  //   value1 = value1PRO;

  //   notifyListeners();
  // }
}
