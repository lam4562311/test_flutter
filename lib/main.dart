import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartros/dartros.dart' as dartros;
import 'package:dartx/dartx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:testing_flutter/second_page.dart';
import 'dart:io' show Platform;
import 'package:get/get.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
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
  LatLng? goal;
  RxString location = 'Null, Press Button'.obs;
  // Rx<String> Address = 'Search'.obs;
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
                '${location}',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // Text(
            //   'ADDRESS',
            //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            // ),
            SizedBox(
              height: 10,
            ),
            // Obx(
            //   () => Text(
            //     '${Address}',
            //   ),
            // ),
            ElevatedButton(
                onPressed: () async {
                  await controller.getGeoLocationPosition();
                  // GeolocationController.to.GetAddressFromLatLong();
                  goal = LatLng(controller.position!.value.latitude,
                      controller.position!.value.longitude);
                  print(goal);
                  // List<Placemark> placemarks = await placemarkFromCoordinates(
                  //     goal!.latitude, goal!.longitude);
                  // print(placemarks);
                  // Placemark place = placemarks[0];
                  // Address.value =
                  //     '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                  location.value =
                      'Lat: ${goal!.latitude} ,\n Long: ${goal!.longitude}';
                },
                child: Text('Set Home')),
            SizedBox(
              height: 10,
            ),
            Text('Please connect to the wifi with'),
            Text(' SSID: pi-ap, Password: 64842951'),
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
                child: Text('Back Home'),
                onPressed: () async {
                  await controller.getGeoLocationPosition();
                  rosController.navigate_pub(
                      LatLng(controller.position!.value.latitude,
                          controller.position!.value.longitude),
                      goal!,
                      LatLng(22.456169335506456, 114.00028388947248),
                      LatLng(22.457302152759784, 114.00134067982435),
                      LatLng(22.4567357441, 114.000812285),
                      true);
                }),
          ],
        ),
      ),
    );
  }
}
