// ignore_for_file: file_names, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_com/Page/DATALOG.dart';
import 'package:flutter_app_com/Page/Setting.dart';
import 'package:flutter_app_com/bluetooth/settingble.dart';
import 'package:flutter_app_com/bluetooth/valueProvider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  final BluetoothCharacteristic? characteristicRX;
  final BluetoothCharacteristic? characteristicTX;
  const Home(
      {Key? key,
      required this.characteristicRX,
      required this.characteristicTX})
      : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothCharacteristic? characteristic;
  double _volumeValue = 0;
  double speed = 0;
  int frp = 0;
  int vfrp = 0;
  var random = new Random();
  double _min = 0;
  double _max = 100;
  int mode = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();

    if (characteristic != null) {
      characteristic = widget.characteristicRX;
    }
    mode = 0;
  }

  // void onVolumeChanged() {
  //   if (mode == 0) {
  //     setState(() {
  //       _volumeValue = context.watch<valueProvider>().battery;
  //     });
  //   } else if (mode == 1) {
  //     setState(() {
  //       _volumeValue = context.watch<valueProvider>().frp;
  //     });
  //   } else if (mode == 2) {
  //     setState(() {
  //       _volumeValue = context.watch<valueProvider>().vfrp;
  //     });
  //   }
  // }

  Future<Null> checkPermission() async {
    bool locationService;
    LocationPermission locationPermission;
    BluetoothCharacteristic? characteristic;
    locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      print('Service Location Open');

      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Localtion Service ปิดอยู่ ?'),
              content: Text('กรุณาเปิด Localtion Service'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    exit(0);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Find LatLang
          findSpeed();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Localtion Service ปิดอยู่ ?'),
              content: Text('กรุณาเปิด Localtion Service'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    exit(0);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Find LatLng
          findSpeed();
        }
      }
    } else {
      print('Service Location Close');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Localtion Service ปิดอยู่ ?'),
          content: Text('กรุณาเปิด Localtion Service'),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                exit(0);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Null?> findSpeed() async {
    print('Find findSpeed');
    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      print('locationSettings :android ');
      locationSettings = AndroidSettings(
        // accuracy: LocationAccuracy.best,
        // distanceFilter: 2,
        // forceLocationManager: false,
        intervalDuration: const Duration(milliseconds: 500),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      print('locationSettings orter');
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      var speedInMps = position.speed; // this is your speed
      // print('speedInMps = $speedInMps');
      context.read<valueProvider>().speed = speedInMps;
      setState(() {
        speed = double.parse('${speedInMps}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;

    // Timer.periodic(new Duration(seconds: 8), (timer) {
    //   setState(() {
    //     speed = random.nextInt(150) + 1;
    //     frp = random.nextInt(250) + 1;
    //     vfrp = random.nextInt(250) + 1;
    //   });
    // });

    Widget _buildChild() {
      if (mode == 0) {
        return SfRadialGauge(
          axes: [
            RadialAxis(
              startAngle: 110,
              endAngle: 10,
              minimum: 0,
              maximum: 15,
              interval: 2,
              pointers: [
                NeedlePointer(
                    needleStartWidth: 1,
                    needleEndWidth: 5,
                    // value: context
                    //     .watch<valueProvider>()
                    //     .battery,
                    value: _volumeValue =
                        context.watch<valueProvider>().battery,
                    enableAnimation: true,
                    tailStyle:
                        TailStyle(width: 5, length: 0.15, color: Colors.white),
                    needleColor: Colors.white),
                RangePointer(
                    value: 15,
                    width: 0.5,
                    gradient: SweepGradient(colors: const <Color>[
                      Color(0xFFBBC05),
                      Color(0xFFBBC05),
                    ], stops: <double>[
                      0.0,
                      0.75
                    ]),
                    sizeUnit: GaugeSizeUnit.factor)
              ],
              axisLabelStyle: GaugeTextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times'),
              showAxisLine: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.1,
              ),
              annotations: [
                GaugeAnnotation(
                    widget: Container(
                        child: Text('${(speed * 3.7).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ))),
                    angle: 60,
                    positionFactor: 0.7),
              ],
            ),
          ],
        );
      } else if (mode == 1) {
        return SfRadialGauge(
          axes: [
            RadialAxis(
              startAngle: 110,
              endAngle: 10,
              minimum: 0,
              maximum: 250,
              interval: 20,
              pointers: [
                NeedlePointer(
                    needleStartWidth: 1,
                    needleEndWidth: 5,
                    // value: context
                    //     .watch<valueProvider>()
                    //     .battery,
                    value: _volumeValue = context.watch<valueProvider>().frp,
                    enableAnimation: true,
                    tailStyle:
                        TailStyle(width: 5, length: 0.15, color: Colors.white),
                    needleColor: Colors.white),
                RangePointer(
                    value: 250,
                    width: 0.5,
                    gradient: SweepGradient(colors: const <Color>[
                      Color(0xFFBBC05),
                      Color(0xFFBBC05),
                    ], stops: <double>[
                      0.0,
                      0.75
                    ]),
                    sizeUnit: GaugeSizeUnit.factor)
              ],
              axisLabelStyle: GaugeTextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times'),
              showAxisLine: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.1,
              ),
              annotations: [
                GaugeAnnotation(
                    widget: Container(
                        child: Text('${(speed * 3.7).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ))),
                    angle: 60,
                    positionFactor: 0.7),
              ],
            ),
          ],
        );
      } else {
        return SfRadialGauge(
          axes: [
            RadialAxis(
              startAngle: 110,
              endAngle: 10,
              minimum: 0,
              maximum: 5,
              interval: 1,
              pointers: [
                NeedlePointer(
                    needleStartWidth: 1,
                    needleEndWidth: 5,
                    // value: context
                    //     .watch<valueProvider>()
                    //     .battery,
                    value: _volumeValue = context.watch<valueProvider>().vfrp,
                    enableAnimation: true,
                    tailStyle:
                        TailStyle(width: 5, length: 0.15, color: Colors.white),
                    needleColor: Colors.white),
                RangePointer(
                    value: 5,
                    width: 0.5,
                    gradient: SweepGradient(colors: const <Color>[
                      Color(0xFFBBC05),
                      Color(0xFFBBC05),
                    ], stops: <double>[
                      0.0,
                      0.75
                    ]),
                    sizeUnit: GaugeSizeUnit.factor)
              ],
              axisLabelStyle: GaugeTextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times'),
              showAxisLine: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.1,
              ),
              annotations: [
                GaugeAnnotation(
                    widget: Container(
                        child: Text('${(speed * 3.7).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ))),
                    angle: 60,
                    positionFactor: 0.7),
              ],
            ),
          ],
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg-main.jpg'),
              fit: BoxFit.cover),
        ),
        child: Row(
          children: [
            Container(
              width: size / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/logopng.png'),
                        iconSize: 50,
                        onPressed: () {},
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: new Container(
                            height: size / 2.3,
                            child: _buildChild(),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: size / 2,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            child: IconButton(
                              icon: Image.asset('assets/images/clear.png'),
                              iconSize: 50,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('AT+CLEAR'));
                                }
                                print('claer ======= > ');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: size / 2,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        iconSize: 40,
                        icon: Image.asset('assets/images/ble-logo.png'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingBle()));
                        },
                      )
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                              // ignore: prefer_const_literals_to_create_immutables
                              text: TextSpan(children: [
                            // Consumer<valueProvider>(
                            //   builder: (_, value, __) => Text(
                            //     'value1: ${_value1.value1}',
                            //     style: TextStyle(color: Colors.yellow),
                            //   ),
                            // ),
                            // TextSpan(
                            //     text: 'BATTERY',
                            //     style: GoogleFonts.sriracha(
                            //         color: Colors.orangeAccent,
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold)),

                            TextSpan(
                                text: 'BATTERY',
                                style: GoogleFonts.sriracha(
                                    color: Colors.orangeAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),

                            TextSpan(
                                text:
                                    ' ${context.watch<valueProvider>().battery} ',
                                style: GoogleFonts.sriracha(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: 'V',
                                style: GoogleFonts.sriracha(
                                    color: Colors.orangeAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ])),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: 'PEAK FRP',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      '   ${context.watch<valueProvider>().pfrp}   ',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: 'mpa',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ])),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: 'PEAK VFRP',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      '   ${context.watch<valueProvider>().pvfrp}  ',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: 'V',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ])),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: 'TOP SPEED ',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      '   ${context.watch<valueProvider>().tspeed}  ',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: 'km/h',
                                  style: GoogleFonts.sriracha(
                                      color: Colors.orangeAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ])),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Consumer<valueProvider>(
                  //   builder: (_, value, __) => Text(
                  //     'BATARY: ${_value1.battery}',
                  //     style: TextStyle(color: Colors.yellow),
                  //   ),
                  // ),
                  // Text(
                  //   "${context.watch<valueProvider>().battery}",
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  FlatButton(
                    onPressed: () {
                      if (widget.characteristicTX != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DATALOG(
                                      characteristicTX: widget.characteristicTX,
                                      characteristicRX: widget.characteristicRX,
                                    )));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DATALOG(
                                      characteristicTX: null,
                                      characteristicRX: null,
                                    )));
                      }
                      // print('DATALOG');
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => DATALOG()));
                    },
                    child: Text(
                      'DATALOG',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    ),
                  ),
                  Text(
                    'Mode = ${mode}',
                    style: TextStyle(color: Colors.white, fontSize: 5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Text(
                              'MODE',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.orangeAccent),
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/batt.png'),
                              iconSize: 40,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('RY1#'));
                                }
                                print('claer ======= > ');
                                setState(() {
                                  _min = 0;
                                  _max = 150;
                                  mode = 0;
                                });
                              },
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/frp.png'),
                              iconSize: 55,
                              onPressed: () {
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('RY2#'));
                                }

                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => SettingPage()));
                                setState(() {
                                  mode = 1;
                                });
                              },
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/vfrp.png'),
                              iconSize: 50,
                              onPressed: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => SettingPage()));
                                if (widget.characteristicRX != null) {
                                  widget.characteristicRX!
                                      .write(utf8.encode('RY3#'));
                                }
                                setState(() {
                                  mode = 2;
                                });
                              },
                            ),
                            IconButton(
                              icon: Image.asset(
                                  'assets/images/setting-logo3.png'),
                              iconSize: 40,
                              onPressed: () {
                                if (widget.characteristicTX != null) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingPage(
                                                characteristicTX:
                                                    widget.characteristicTX,
                                              )));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingPage(
                                                characteristicTX: null,
                                              )));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
