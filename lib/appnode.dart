import 'dart:async';
// import 'package:dartros/dartros.dart' as dartros;
// import 'package:dartx/dartx.dart';
import 'package:testing_flutter/reverse_geocoding.dart';
// import 'package:sensor_msgs/msgs.dart' as sensor_msgs;
import 'package:flutter/material.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:testing_flutter/geolocation_controller.dart';
import 'package:std_msgs/msgs.dart' hide Duration;
import 'dart:convert';

class ROSnodeController extends GetxController {
  static ROSnodeController get to => Get.find();
  static MapViewController get map => Get.find();
  static GeolocationController get geo => Get.find();
  int msgToPublished = 0;
  late Ros ros;
  late Service navigation;
  late Service gps_compass;
  RxBool navigation_stat = false.obs;
  late Topic nav;
  late Topic polyline;

  void connect_to_server() {
    print('ros');
    Ros ros = Ros(url: 'ws://192.168.12.1:9090');
    // Ros ros = Ros(url: 'ws://lam4562311.tplinkdns.com:9090');
    gps_compass = Service(
      ros: ros,
      name: '/GPS_COMPASS',
      type: "ps4_bot/GpsCompass",
    );
    navigation = Service(
      ros: ros,
      name: '/navigation',
      type: "ps4_bot/navigation",
    );
    nav = Topic(
      ros: ros,
      name: '/navigation_stat',
      type: "std_msgs/Bool",
      reconnectOnClose: true,
      queueLength: 1,
      queueSize: 1,
    );
    polyline = Topic(
      ros: ros,
      name: '/polyline',
      type: "ps4_bot/vertices",
      reconnectOnClose: true,
      queueLength: 1,
      queueSize: 1,
    );
    ros.connect();
    print('connected');
    Timer(const Duration(seconds: 10), () async {
      await gps_compass.advertise(posHandler);
      print('advertise');
    });
    Timer(const Duration(milliseconds: 10), () async {
      await nav.subscribe(subscribe_stat);
      print("subscribe");
    });
    Timer(const Duration(milliseconds: 10), () async {
      await polyline.subscribe(sub_polyline);
      print("Polyline subscribe");
    });
  }

  void destroyConnection() async {
    // await chatter.unsubscribe();
    await ros.close();
    update();
  }

  Future<void> sub_polyline(Map<String, dynamic> msg) async {
    var msg_vertices = msg['vertices'];
    List<LatLng> list_of_point = [];
    map.list_of_point.clear();
    for (var i = 0; i < msg_vertices.length; i++) {
      map.list_of_point.add(
          LatLng(msg_vertices[i]['latitude'], msg_vertices[i]['longitude']));
    }
    map.add_polyline();
  }

  Future<void> subscribe_stat(Map<String, dynamic> msg) async {
    var msg_vertices = msg['data'];
    print(msg_vertices);
    if (!msg_vertices) {
      map.all_Polyline.clear();
      map.list_of_point.clear();
      map.stop_routing.value = false;
      sleep(Duration(seconds: 1));
      Get.dialog(
        AlertDialog(
          title: Text("The auto navigation is stopped"),
        ),
        barrierDismissible: true,
      );
    }
    update();
  }

  Future<Map<String, dynamic>>? posHandler(Map<String, dynamic> args) async {
    Map<String, dynamic> response = {};
    print("start");
    await geo.getGeoLocationPosition();
    response['position'] = {
      'latitude': geo.position!.value.latitude,
      'longitude': geo.position!.value.longitude
    };
    response['angle'] = geo.direction.value;
    update();
    print(response);
    return response;
  }

  void navigate_pub(LatLng start, LatLng end, LatLng min_pt, LatLng max_pt,
      LatLng center, bool status) async {
    var geopoint_start = {
      'latitude': start.latitude,
      'longitude': start.longitude,
    };
    var geopoint_goal = {
      'latitude': end.latitude,
      'longitude': end.longitude,
    };
    var boundary = {
      'min_pt': {
        'latitude': min_pt.latitude,
        'longitude': min_pt.longitude,
      },
      'max_pt': {
        'latitude': max_pt.latitude,
        'longitude': max_pt.longitude,
      }
    };
    var center_point = {
      'latitude': center.latitude,
      'longitude': center.longitude,
    };
    var polygons = [
      {
        'vertices': [
          {
            'latitude': 22.4570046961716,
            'longitude': 114.00095410645008,
          },
          {
            'latitude': 22.457102609035683,
            'longitude': 114.00092426687479,
          },
          {
            'latitude': 22.457119031123202,
            'longitude': 114.0010553598404,
          },
          {
            'latitude': 22.457017709910684,
            'longitude': 114.00106374174356,
          }
        ]
      },
      {
        'vertices': [
          {
            'latitude': 22.45692010683777,
            'longitude': 114.00063794106245,
          },
          {
            'latitude': 22.456775406282567,
            'longitude': 114.0006248652935,
          },
          {
            'latitude': 22.45679337766594,
            'longitude': 114.00079149752855,
          },
          {
            'latitude': 22.45698083764678,
            'longitude': 114.00077506899834,
          }
        ]
      }
    ];
    Map<String, dynamic> json = {
      "start": geopoint_start,
      "goal": geopoint_goal,
      'boundary': boundary,
      'center': center_point,
      'polygons': polygons,
      'navigation_status': status
    };
    var result = await navigation.call(json);
    if (result != null) {
      var msg_vertices = result['polylines']['vertices'];
      List<LatLng> list_of_point = [];
      map.list_of_point.clear();
      for (var i = 0; i < msg_vertices.length; i++) {
        map.list_of_point.add(
            LatLng(msg_vertices[i]['latitude'], msg_vertices[i]['longitude']));
      }
      map.add_polyline();
    }
    update();
  }
}

Album text = Album(userId: 13, id: 13, title: "title");
// var outputMatrix = mapfetching();
// var myFile = await DefaultCacheManager().getSingleFile('https://maps.googleapis.com/maps/api/staticmap?center=Brooklyn+Bridge,New+York,NY&zoom=13&size=900x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:red%7Clabel:C%7C40.718217,-73.998284&key=AIzaSyB-tnCNMsE5fPFMVZXgg9hAgFwX8Qlwz5k&map_id=Map1.png');
// var outputMatrix = await File('assets/images/temp.png').readAsBytes();
// Image imageNew = Image.asset('assets/temp.png');
var im12;
var outputMatrix;
ImageProvider? image;
Future<dynamic> imagegetter() async {
  String audioasset = "assets/images/temp.png"; //path to asset
  ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
  Uint8List outputMatrix =
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  return outputMatrix;
}

// var outputMatrix = imagegetter();
class Third extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Route"),
      ),
      body: Center(
        child: Column(children: [
          Text('${text.userId}+${text.id}+${text.title}'),
          ElevatedButton(
              child: Text('a'),
              onPressed: () async {
                // text = await text.fetchAlbum();
                print("go");
                outputMatrix = await fetchmap();
              }),
          FutureBuilder<dynamic>(
              future: fetchmap(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var outputMatrix = snapshot.data;
                  print(outputMatrix);
                  return Image.memory(outputMatrix);
                }
                return Text('future_builder_for image viewer');
              }),
          Image.asset('assets/images/map.png')
        ]),
      ),
    );
  }
}
