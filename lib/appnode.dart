import 'dart:async';
import 'package:dartros/dartros.dart' as dartros;
import 'package:dartx/dartx.dart';
// import 'package:sensor_msgs/msgs.dart' as sensor_msgs;
import 'package:flutter/material.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:get/get.dart';

class ROSnodeController extends GetxController {
  static ROSnodeController get to => Get.find();
  late Ros ros;
  late Topic gpslocation;
  int msgToPublished = 0;

  void connect_to_server() {
    print('ros');
    Ros ros = Ros(url: 'ws://192.168.12.1:9090');
    Topic gpslocation = Topic(
        ros: ros,
        name: '/topic',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    ros.connect();
    Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      msgToPublished++;
      Map<String, dynamic> json = {"data": msgToPublished.toString()};
      await gpslocation.publish(json);
      update();
    });
  }
}

class Third extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Route"),
      ),
      body: Center(),
    );
  }
}
