import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/pages/home/controllers/controller.dart';

class ContactsListView extends GetView<HomeController> {
  const ContactsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts")),
      body: Center(),
    );
  }
}
