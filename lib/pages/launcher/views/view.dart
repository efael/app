import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class LauncherPage extends GetView<LauncherController> {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
