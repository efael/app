import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/pages/home/controllers/controller.dart';

class CallsListView extends GetView<HomeController> {
  const CallsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calls")),
      body: Center(),
    );
  }
}
