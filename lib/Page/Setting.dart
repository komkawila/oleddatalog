import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app_com/bluetooth/valueProvider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert' show utf8;
import 'dart:math' as math;

class SettingPage extends StatefulWidget {
  final BluetoothCharacteristic? characteristicTX;
  final BluetoothCharacteristic? characteristicRX;
  const SettingPage(
      {Key? key, required this.characteristicTX, this.characteristicRX})
      : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  late TooltipBehavior _tooltipBehavior;
  bool showFRT = false;
  bool showVFRP = false;
  bool showSPEED = false;
  bool? isrunning;
  late int count;
  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true, duration:800,);
    count = 0;
    isrunning = false;
    chartData = getChartData();
    Timer.periodic(const Duration(milliseconds: 800), updateDataSource);
    super.initState();
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Container(
                height: 250, width: 500, child: getAddRemoveSeriesChart()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                  onPressed: () {
                    setState(() {
                      isrunning = true;
                    });
                  },
                  child: const Text(
                    'start',
                    style: TextStyle(
                        backgroundColor: Colors.green, color: Colors.white),
                  )),
              FlatButton(
                onPressed: () {
                  setState(() {
                    isrunning = false;
                  });
                },
                child: const Text(
                  'stop',
                  style: TextStyle(
                      backgroundColor: Colors.red, color: Colors.white),
                ),
              ),
              Text(' ${context.watch<valueProvider>().frp}'),
              // Text('   valueBle  === > ${valueBle}'),
              Text('chartData.length ${chartData.length}'),
              FlatButton(
                onPressed: () {
                  setState(() {
                    chartData.clear();
                    count = 0;
                  });
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                      backgroundColor: Colors.yellow, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void getdataBle() {
    if (widget.characteristicTX != null) {
      widget.characteristicTX!.value.listen((data) {
        final command = _dataParser(data).toString();
        print('data page7 ========= > ${command}');
        if (command.contains('frp1=')) {
          final start = 'frp1=';
          final end = '#';

          final startIndex = command.indexOf(start);
          final endIndex = command.indexOf(end);
          final result =
              command.substring(startIndex + start.length, endIndex).trim();
          // context.read<valueProvider>().frp = double.parse(result);

          print('Data ------------> frp = ${result}');
          setState(() {
            // valueBle = result;
          });
          // _getChartData(result);
        }
      });
    }
    // var provider = Provider.of<valueProvider>(context, listen: false);
    // var frp = provider.frp;
    // print('DATA FRP ----------- > ${frp}');
  }

  SfCartesianChart getAddRemoveSeriesChart() {
    return SfCartesianChart(
        series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            dataSource: chartData,
            color: const Color.fromRGBO(192, 108, 132, 1),
            xValueMapper: (LiveData sales, _) => sales.count,
            yValueMapper: (LiveData sales, _) => sales.speed,
            markerSettings: const MarkerSettings(isVisible: true),
            enableTooltip: true,
          ),
        ],
        primaryXAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 3,
            title: AxisTitle(text: 'Time (seconds)')),
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true),
        tooltipBehavior: _tooltipBehavior,
        primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            title: AxisTitle(text: 'Internet speed (Mbps)')));
  }

  ///Get the random data point
  int _getRandomInt(int min, int max) {
    final Random _random = Random();
    return min + _random.nextInt(max - min);
  }

  // int time = 0;
  // void updateDataSource(Timer timer) {
  //   if (isrunning == true) {
  //     chartData.add(LiveData(time++, (math.Random().nextInt(60) + 30)));
  //     if (chartData.length == 2) {
  //       chartData.removeAt(0);
  //       _chartSeriesController.updateDataSource(
  //           addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  //     } else {
  //       _chartSeriesController.updateDataSource(
  //           addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  //     }

  //     _chartSeriesController.updateDataSource(
  //         addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  //   } else {
  //     return;
  //   }
  // }

  void updateDataSource(Timer timer) {
    if (isrunning == true) {
      chartData.add(LiveData(count, (math.Random().nextInt(60) + 30)));
      //   if (chartData.length == 2) {
      //     chartData.removeAt(0);
      //     _chartSeriesController.updateDataSource(
      //         addedDataIndex: chartData.length - 1, removedDataIndex: 0);
      //   } else {
      //     _chartSeriesController.updateDataSource(
      //         addedDataIndex: chartData.length - 1, removedDataIndex: 0);
      //   }

      //   _chartSeriesController.updateDataSource(
      //       addedDataIndex: chartData.length - 1, removedDataIndex: 0);
      // } else {
      //   return;
      // }

      count = count + 1;
    }
  }

  List<LiveData> getChartData() {
    return <LiveData>[];
  }

  @override
  void dispose() {
    chartData.clear();
    super.dispose();
  }
}

class LiveData {
  LiveData(this.count, this.speed);
  final int count;
  final num speed;
}
