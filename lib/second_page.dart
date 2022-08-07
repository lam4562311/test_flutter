import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'appnode.dart';
import 'package:get/get.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:testing_flutter/geolocation_controller.dart';

PlatformMapController? googleMapController;

class SecondRoute extends StatelessWidget {
  @override
  var home;

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
                        // await controller.getGeoLocationPosition();
                        rosController.navigate_pub(
                            LatLng(
                                controller
                                    .optimized_position!.value['latitude'],
                                controller
                                    .optimized_position!.value['longitude']),
                            // LatLng(controller.position!.value.latitude,
                            //     controller.position!.value.longitude),
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
                            LatLng(
                                controller
                                    .optimized_position!.value['latitude'],
                                controller
                                    .optimized_position!.value['longitude']),
                            // LatLng(controller.position!.value.latitude,
                            //     controller.position!.value.longitude),
                            mapController.allmarker[0].position,
                            LatLng(22.456169335506456, 114.00028388947248),
                            LatLng(22.457302152759784, 114.00134067982435),
                            LatLng(22.4567357441, 114.000812285),
                            false);
                      },
                      child: Text('Stop routing')))),
        ),
        Positioned(
          right: 50,
          bottom: 50,
          child: ElevatedButton(
              onPressed: () async {
                // await controller.getGeoLocationPosition();
                home = LatLng(controller.optimized_position!.value['latitude'],
                    controller.optimized_position!.value['longitude']);
                // goal = LatLng(controller.position!.value.latitude,
                //     controller.position!.value.longitude);
                print(home);
                mapController.add_home(home);
              },
              child: Text('Set Home')),
        ),
        Obx(() => Visibility(
            visible: mapController.home_routing.value,
            child: Positioned(
                right: 50,
                bottom: 10,
                child: ElevatedButton(
                    child: Text('Back Home'),
                    onPressed: () async {
                      // await controller.getGeoLocationPosition();

                      rosController.navigate_pub(
                          LatLng(
                              controller.optimized_position!.value['latitude'],
                              controller
                                  .optimized_position!.value['longitude']),
                          // LatLng(controller.position!.value.latitude,
                          //     controller.position!.value.longitude),
                          home!,
                          LatLng(22.456169335506456, 114.00028388947248),
                          LatLng(22.457302152759784, 114.00134067982435),
                          LatLng(22.4567357441, 114.000812285),
                          true);
                      mapController.home_routing.value = false;
                      mapController.stop_routing.value = true;
                    })))),
      ]),
    );
  }
}
