import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:testing_flutter/geolocation_controller.dart';

PlatformMapController? googleMapController;

class SecondRoute extends StatelessWidget {
  @override
  var goal;
  final controller = Get.put(GeolocationController());
  final mapController = Get.put(MapViewController());
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Stack(children: <Widget>[
        Obx(
          () => PlatformMap(
            initialCameraPosition: CameraPosition(
              target: const LatLng(22.456728, 114.000813),
              zoom: 19.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            onMapCreated: (googleMapController) {
              googleMapController
                  .getVisibleRegion()
                  .then((bounds) => print("bounds: ${bounds.toString()}"));
            },
            markers: Set<Marker>.of(mapController.allmarker),
            polylines: Set<Polyline>.of(mapController.all_Polyline),
            polygons: Set<Polygon>.of(mapController.all_polygon),
            mapType: MapType.normal,
            onTap: (location) {
              mapController.add_maker(location);
            },
            onCameraMove: (cameraUpdate) =>
                print('onCameraMove: $cameraUpdate'),
          ),
        ),
        Obx(
          () => Visibility(
              visible: mapController.routing.value,
              child: Positioned(
                  left: 20,
                  bottom: 20,
                  child: ElevatedButton(
                      onPressed: () async {
                        await controller.getGeoLocationPosition();
                        mapController.add_goal(
                            LatLng(controller.position!.value.latitude,
                                controller.position!.value.longitude),
                            mapController.allmarker[0].position);
                        mapController.add_polyline();
                        Future.delayed(Duration(seconds: 1));
                        mapController.routing.value = false;
                      },
                      child: Text('Start routing')))),
        )
      ]),
    );
  }
}
