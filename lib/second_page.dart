import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'appnode.dart';
import 'package:get/get.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:testing_flutter/geolocation_controller.dart';

PlatformMapController? googleMapController;

class SecondRoute extends StatelessWidget {
  @override
  var goal;
  final controller = Get.put(GeolocationController());
  final mapController = Get.put(MapViewController());
  final rosController = Get.put(ROSnodeController());
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Route"),
      ),
      body: Stack(children: <Widget>[
        Obx(
          () => PlatformMap(
            initialCameraPosition: CameraPosition(
              target: const LatLng(22.4567357441, 114.000811111),
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
              if (!mapController.stop_routing.value)
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
                        rosController.navigate_pub(
                            LatLng(controller.position!.value.latitude,
                                controller.position!.value.longitude),
                            mapController.allmarker[0].position,
                            LatLng(22.456169335506456, 114.00028388947248),
                            LatLng(22.457302152759784, 114.00134067982435),
                            LatLng(22.4567357441, 114.000812285),
                            true);

                        mapController.add_polyline();
                        Future.delayed(Duration(seconds: 1));
                        mapController.routing.value = false;
                        mapController.stop_routing.value = true;
                      },
                      child: Text('Start routing')))),
        ),
        Obx(
          () => Visibility(
              visible: mapController.stop_routing.value,
              child: Positioned(
                  left: 20,
                  bottom: 20,
                  child: ElevatedButton(
                      onPressed: () async {
                        mapController.routing.value = false;
                        rosController.navigate_pub(
                            LatLng(controller.position!.value.latitude,
                                controller.position!.value.longitude),
                            mapController.allmarker[0].position,
                            LatLng(22.456169335506456, 114.00028388947248),
                            LatLng(22.457302152759784, 114.00134067982435),
                            LatLng(22.4567357441, 114.000812285),
                            false);
                      },
                      child: Text('Stop routing')))),
        ),
      ]),
    );
  }
}
