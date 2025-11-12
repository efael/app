import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:messenger/constants.dart";

class VerificationDeviceItem extends StatelessWidget {
  VerificationDeviceUIModel model;
  VerificationDeviceItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final iconColor = Color(0xff656d77);
    final double width = MediaQuery.of(context).size.width > 400
        ? 400
        : MediaQuery.of(context).size.width;

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffebedf0), width: 2),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xfff0f2f5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(CupertinoIcons.device_laptop, color: iconColor, size: 24),
                ),
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  model.name,
                  style: consts.typography.text3.copyWith(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Signed in",
                    style: consts.typography.text3.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    model.date,
                    style: consts.typography.text3.copyWith(color: Colors.black, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const SizedBox(width: 42),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Device ID",
                      style: consts.typography.text3.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      model.deviceId,
                      style: consts.typography.text3.copyWith(color: Colors.black, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VerificationDeviceUIModel {
  final String name;
  final String date;
  final String deviceId;

  VerificationDeviceUIModel({required this.name, required this.date, required this.deviceId});
}
