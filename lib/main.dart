import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_com/Page/Home.dart';
import 'package:flutter_app_com/bluetooth/valueProvider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider<valueProvider>(
          create: (_) => valueProvider(),
        ),
      ], child: MyApp()),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.srirachaTextTheme(
          Theme.of(context)
              .textTheme, // ถ้าไม่ใส่ มันจะตั้งค่า Default ทุกอย่างตาม ThemeData.light().textTheme
        ),
        primaryTextTheme: GoogleFonts.srirachaTextTheme(
          Theme.of(context)
              .primaryTextTheme, // ถ้าไม่ใส่ มันจะตั้งค่า Default ทุกอย่างตาม ThemeData.light().textTheme
        ),
      ),
      home: Home(
        characteristicRX: null,
        characteristicTX: null,
      ),
    );
  }
}
