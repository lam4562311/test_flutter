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
  final mapController = Get.put(MapViewController());

  LatLng? goal;
  RxString location = 'Null, Press Button'.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Location',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(() => Visibility(
                  visible: controller.initized.isTrue,
                  child: Text(
                    'Latitude: ${controller.optimized_position?.value['latitude']}, \nLongitude${controller.optimized_position?.value['longitude']}',
                    // 'Latitude: ${controller.position?.value.latitude}, \nLongitude${controller.position?.value.longitude}',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                )),
            // Text(
            //   'Optimized Location',
            //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            // Obx(() => Visibility(
            //       visible: controller.initized.isTrue,
            //       child: Text(
            //         'Latitude: ${controller.optimized_position?.value['latitude']}, \nLongitude${controller.optimized_position?.value['longitude']}',
            //         style: TextStyle(color: Colors.black, fontSize: 16),
            //       ),
            //     )),
            Text(
              'Home location',
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
            Text(
              'Battery Level',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => Text(
                '${rosController.battery}',
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  // await controller.getGeoLocationPosition();
                  goal = LatLng(
                      controller.optimized_position!.value['latitude'],
                      controller.optimized_position!.value['longitude']);
                  // goal = LatLng(controller.position!.value.latitude,
                  //     controller.position!.value.longitude);
                  print(goal);
                  location.value =
                      'Latitude: ${goal!.latitude} ,\n Longitude: ${goal!.longitude}';
                  mapController.add_home(goal!);
                },
                child: Text('Set Home')),
            // SizedBox(
            //   height: 10,
            // ),
            // Text('Please connect to the wifi with'),
            // Text(' SSID: pi-ap, Password: 64842951'),
            // Text('then press the below button'),
            // ElevatedButton(
            //     onPressed: () async {
            //       rosController.connect_to_server();
            //     },
            //     child: Text('connect to the server')),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                child: Text('Open route'),
                onPressed: () {
                  Get.toNamed("/second");
                }),
            // ElevatedButton(
            //     child: Text('Back Home'),
            //     onPressed: () async {
            //       // await controller.getGeoLocationPosition();

            //       rosController.navigate_pub(
            //           LatLng(controller.optimized_position!.value['latitude'],
            //               controller.optimized_position!.value['longitude']),
            //           // LatLng(controller.position!.value.latitude,
            //           //     controller.position!.value.longitude),
            //           goal!,
            //           LatLng(22.456169335506456, 114.00028388947248),
            //           LatLng(22.457302152759784, 114.00134067982435),
            //           LatLng(22.4567357441, 114.000812285),
            //           true);
            //     }),
            SizedBox(
              height: 100,
            ),
            Obx(() => Visibility(
                  visible: rosController.Cruise.value,
                  child: ListTile(
                      title: Center(child: const Text("Cruise Control Enable")),
                      tileColor: Color.fromARGB(255, 0, 255, 0)),
                )),
          ],
        ),
      ),
    );
  }
}
