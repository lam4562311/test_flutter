import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:json_serializable/builder.dart';
// import 'package:json_annotation/json_annotation.dart';
import 'package:dartros/dartros.dart' as dartros;
import 'package:dartx/dartx.dart';
import 'package:std_msgs/msgs.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:testing_flutter/second_page.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'package:testing_flutter/geolocation_controller.dart';
import 'package:testing_flutter/appnode.dart';

// @jsonSerializable()
// class ic {}

int msgToPublished = 0;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Homepage()),
        GetPage(
            name: '/second',
            page: () => SecondRoute(),
            transition: Transition.zoom),
        GetPage(
            name: '/third', page: () => Third(), transition: Transition.zoom),
      ],
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
  // _FlutterWifiIoTState createState() => _FlutterWifiIoTState();
}

class _HomepageState extends State<Homepage> {
  final controller = Get.put(GeolocationController());
  final rosController = Get.put(ROSnodeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Coordinates Points',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => Text(
                '${controller.location}',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'ADDRESS',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => Text(
                '${controller.Address}',
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await controller.getGeoLocationPosition();
                  GeolocationController.to.GetAddressFromLatLong();
                },
                child: Text('Get Location')),
            SizedBox(
              height: 10,
            ),
            Text('Please connect to the wifi with'),
            Text(' SSID: pi-ap, Password: 12345678'),
            Text('then press the below button'),
            ElevatedButton(
                onPressed: () async {
                  rosController.connect_to_server();
                },
                child: Text('connect to the server')),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                child: Text('Open route'),
                onPressed: () {
                  Get.toNamed("/second");
                }),
            ElevatedButton(
                child: Text('Open third route'),
                onPressed: () {
                  Get.toNamed("/third");
                })
          ],
        ),
      ),
    );
  }
}
