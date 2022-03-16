import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class MapViewController extends GetxController {
  static MapViewController get to => Get.find();
  RxBool routing = false.obs;
  final List<Marker> allmarker = <Marker>[
    Marker(
      visible: false,
      consumeTapEvents: false,
      markerId: MarkerId("goal"),
      position: LatLng(22.4570788481, 114.001282846),
    ),
  ].obs;

  void add_maker(LatLng pos) {
    var _marker = Marker(
      consumeTapEvents: false,
      markerId: MarkerId("goal"),
      position: LatLng(pos.latitude, pos.longitude),
      // infoWindow: InfoWindow(
      //   title: 'postion',
      //   snippet: "latitude: ${pos.latitude} longitude: ${pos.longitude}",
      // ),
    );
    print("latitude: ${pos.latitude} longitude: ${pos.longitude}");
    allmarker[0] = (_marker);
    routing.value = true;
    update();
  }

  final List<Polyline> all_Polyline = <Polyline>[].obs;
  final List<LatLng> list_of_point = <LatLng>[].obs;
  void add_polyline() {
    var _polyline = Polyline(
        polylineId: PolylineId("goal_line"),
        color: Colors.blue,
        points: list_of_point);
    if (all_Polyline.isEmpty)
      all_Polyline.add(_polyline);
    else
      all_Polyline[0] = _polyline;
    update();
  }

  void add_goal(LatLng current_location, LatLng goal) async {
    if (list_of_point.isEmpty) {
      list_of_point.add(current_location);
      list_of_point.add(goal);
    } else {
      list_of_point.clear();
      list_of_point.add(current_location);
      list_of_point.add(goal);
    }

    update();
  }

  final List<Polygon> all_polygon = <Polygon>[].obs;

  void add_polygon(String IDname, list_of_vertices) {
    var _polygon = Polygon(
        polygonId: PolygonId(IDname),
        fillColor: Colors.redAccent,
        points: list_of_vertices,
        strokeColor: Colors.red,
        visible: true);
    all_polygon.add(_polygon);
    update();
  }

  @override
  void onInit() {
    var _vertices1 = <LatLng>[
      LatLng(22.4570046961716, 114.00095410645008),
      LatLng(22.457102609035683, 114.00092426687479),
      LatLng(22.457119031123202, 114.0010553598404),
      LatLng(22.457017709910684, 114.00106374174356)
    ];
    add_polygon("forbidden_zone_1", _vertices1);
    var _vertices2 = <LatLng>[
      LatLng(22.45692010683777, 114.00063794106245),
      LatLng(22.456775406282567, 114.0006248652935),
      LatLng(22.45679337766594, 114.00079149752855),
      LatLng(22.45698083764678, 114.00077506899834)
    ];
    add_polygon("forbidden_zone_2", _vertices2);
    print(all_polygon);
    super.onInit();
  }
}

class GeolocationController extends GetxController {
  static GeolocationController get to => Get.find();
  Rx<String> Address = 'Search'.obs;
  Rx<Position>? position;
  RxString location = 'Null, Press Button'.obs;

  final TextEditingController _controller = TextEditingController();
  // final _channel =
  //     WebSocketChannel.connect(Uri.parse('wss://192.168.0.100:8081'));
  late bool init;

  @override
  void onInit() {
    // super.onInit();
    init = true;
    getGeoLocationPosition();
    super.onInit();
  }

  Future<void> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    if (init) {
      Position tmp = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      position = (tmp).obs;
      position?.value = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      init = false;
    } else {
      position?.value = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      location.value =
          'Lat: ${position?.value.latitude} , Long: ${position?.value.longitude}';
    }
    update();
  }

  Future<void> GetAddressFromLatLong() async {
    double latitude = position!.value.latitude;
    double longitude = position!.value.longitude;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address.value =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    update();
  }
}
