import 'dart:async';
import 'dart:math' as math;
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_app_com/bluetooth/valueProvider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/src/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DATALOG extends StatefulWidget {
  final BluetoothCharacteristic? characteristicTX;
  final BluetoothCharacteristic? characteristicRX;
  const DATALOG(
      {Key? key,
      required this.characteristicTX,
      required this.characteristicRX})
      : super(key: key);

  @override
  _DATALOGState createState() => _DATALOGState();
}

class _DATALOGState extends State<DATALOG> {
  TooltipBehavior? _tooltipBehavior;
  ZoomPanBehavior? _zoomPanBehavior;

  late int count;
  Timer? timer;
  bool? isrunning;
  bool showFRT = true;
  bool showVFRP = true;
  bool showSPEED = true;
  int valueFRT = 0;
  int valueVFRP = 0;
  List<_ChartData>? chartData;
  ChartSeriesController? _chartSeriesController;
  double _minY = 0;
  double _maxY = 250;
  double speed = 0;
  @override
  void initState() {
    _tooltipBehavior =
        TooltipBehavior(enable: true, activationMode: ActivationMode.singleTap);
    setState(() {
      isrunning = false;
    });
    count = 0;
    chartData = <_ChartData>[
      _ChartData(0, 0, 0),
    ];

    // timer =
    //     Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
    getdataBle();
    // timer =
    //     Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/datalog-page/bg.jpg'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FRP DATALOGGER',
                    style: TextStyle(color: Colors.amber, fontSize: 30),
                  ),
                  Text(
                    '${context.watch<valueProvider>().battery}  V',
                    style: TextStyle(color: Colors.amber, fontSize: 30),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   height: 230,
                //   width: 200,
                //   child: Column(
                //     children: [
                //       TextButton(
                //           onPressed: () {},
                //           child: Text(
                //             'EN/DIS ${isrunning}',
                //             style: TextStyle(
                //                 fontSize: 20,
                //                 color: isrunning == true
                //                     ? Colors.red
                //                     : Colors.yellow),
                //           )),
                //       TextButton(
                //           onPressed: () {
                //             setState(() {
                //               showFRT = !showFRT;
                //             });
                //           },
                //           child: const Text(
                //             'FRP',
                //             style: TextStyle(fontSize: 20),
                //           )),
                //       TextButton(
                //           onPressed: () {
                //             setState(() {
                //               showVFRP = !showVFRP;
                //             });
                //           },
                //           child: const Text(
                //             'VFRP',
                //             style: TextStyle(fontSize: 20),
                //           )),
                //       TextButton(
                //           onPressed: () {
                //             setState(() {
                //               showSPEED = !showSPEED;
                //             });
                //           },
                //           child: Text(
                //             'SPEED',
                //             style: TextStyle(fontSize: 20),
                //           )),
                //     ],
                //   ),
                // ),
                Center(
                  child: Container(
                    height: 240,
                    width: 500,
                    color: Colors.grey,
                    // child: SfCartesianChart(
                    //   plotAreaBorderWidth: 0,
                    //   primaryXAxis: NumericAxis(
                    //     majorGridLines: const MajorGridLines(width: 0),
                    //     autoScrollingDelta: 50,
                    //   ),
                    //   primaryYAxis: NumericAxis(
                    //       axisLine: const AxisLine(width: 0),
                    //       majorTickLines: const MajorTickLines(size: 0)),
                    //   zoomPanBehavior: ZoomPanBehavior(
                    //       enablePinching: true,
                    //       zoomMode: ZoomMode.x,
                    //       enablePanning: true),
                    //   tooltipBehavior: TooltipBehavior(enable: true),
                    //   series: _getDefaultLineSeries(),
                    // ),
                    child: _buildLiveLineChart(),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon:
                          Image.asset('assets/images/datalog-page/bt-play.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          isrunning = true;
                          print(
                              'is ======= > Play ===== isrunning ==== ${isrunning}');
                          // getdataBle();
                        });
                      },
                    ),
                    IconButton(
                      icon:
                          Image.asset('assets/images/datalog-page/bt-stop.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          isrunning = false;
                          print(
                              'is ======= > Stop  isrunning ==== ${isrunning}');
                          // getdataBle();
                        });
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/images/clear.png'),
                      iconSize: 50,
                      onPressed: () {
                        chartData!.clear();
                        print('is ======= > clear ');

                        setState(() {
                          isrunning = true;
                          count = 0;
                          // chartData = <_ChartData>[
                          //   _ChartData(0, 0, 0),
                          // ];
                        });
                        // getdataBle();
                      },
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       ' Frp = ${context.watch<valueProvider>().frp}',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //     Text(
                //       ' showFRT (${showFRT})',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //     Text(
                //       ' showVFRP (${showVFRP})',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //     Text(
                //       ' showSPEED (${showSPEED})',
                //       style: TextStyle(color: Colors.yellow),
                //     ),
                //   ],
                // ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'EXIT',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          )),
                    ),
                    Text(
                      'SPEED === > ${speed}',
                      style: TextStyle(color: Colors.pink),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }
  double newMap(int x, int inMin, int inMax, int outMin, int outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
  void getdataBle() {
    if (widget.characteristicTX != null) {
      widget.characteristicTX!.value.listen((data) {
        var provider = Provider.of<valueProvider>(context, listen: false);
        setState(() {
          speed = provider.speed;
        });
        final command = _dataParser(data).toString();
        print('data  ========= > ${command}');
        final len = command.indexOf("=");
        // #IN2=5.00$"
        if (command.contains('IN2=')) {
         
          final resultfrp1 =
              command.substring(len + 1, command.length - 1).trim();
          var valueFRT2 = double.parse(resultfrp1) * 100;
          var valueFRT3 = valueFRT2.toInt() ;
          valueFRT = newMap(valueFRT3,0,500,0,100).toInt();
          // setState(() {});
           print('######### KUY ===> ${resultfrp1}');
          print('Data ------------> frp = ${valueFRT}');
          // setState(() {
          //   valueBle = resultfrp1;
          // });
          // _getChartData(result);
          // _updateDataSource(resultfrp1);
          if (isrunning == true) {
            if (resultfrp1 != null && count != 1000) {
              _updateDataSource();
              setState(() {});
            }
          }
        }
      });
    }
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
        legend: Legend(overflowMode: LegendItemOverflowMode.wrap),
        plotAreaBorderWidth: 0,
        primaryXAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          autoScrollingDelta: 50,
          interval: 10,
          minimum: 0,
        ),
        primaryYAxis: NumericAxis(
            minimum: _minY,
            maximum: _maxY,
            interval: 50,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0)),
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true),
        tooltipBehavior: _tooltipBehavior,
        series: <LineSeries<_ChartData, int>>[
          LineSeries<_ChartData, int>(
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
              name: 'FRT',
              dataSource: chartData!,
              color: Colors.greenAccent,
              xValueMapper: (_ChartData sales, _) => sales.x,
              yValueMapper: (_ChartData sales, _) => sales.y,
              animationDuration: 0,
              markerSettings: const MarkerSettings(isVisible: true)),
          LineSeries<_ChartData, int>(
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
              name: 'SPEED',
              dataSource: chartData!,
              color: Colors.red,
              xValueMapper: (_ChartData sales, _) => sales.x,
              yValueMapper: (_ChartData sales, _) => sales.y2,
              animationDuration: 0,
              markerSettings: const MarkerSettings(isVisible: true))
        ]);
  }

  ///Continously updating the data source based on timer
  void _updateDataSource() {
    if (isrunning == true) {
      chartData!.add(_ChartData(count, valueFRT, (speed * 3.5).toInt()));
      // // chartData!.removeAt(0);
      // if (chartData!.length == 1) {
      //   chartData!.removeAt(0);
      //   _chartSeriesController?.updateDataSource(
      //     addedDataIndexes: <int>[chartData!.length - 1],
      //     removedDataIndexes: <int>[0],
      //   );
      // } else {
      //   _chartSeriesController?.updateDataSource(
      //     addedDataIndexes: <int>[chartData!.length - 1],
      //   );
      // }

      count = count + 1;
    }
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min);
  }

  @override
  void dispose() {
    chartData!.clear();
    _chartSeriesController = null;
    super.dispose();
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2);
  final int x;
  final int y;
  final int y2;
}
