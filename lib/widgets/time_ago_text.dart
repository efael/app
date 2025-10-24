import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimeAgoText extends StatefulWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const TimeAgoText({super.key, required this.dateTime, this.style});

  @override
  State<TimeAgoText> createState() => _TimeAgoTextState();
}

class _TimeAgoTextState extends State<TimeAgoText> {
  late String _displayText;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _maybeStartTimer();
  }

  void _maybeStartTimer() {
    final now = DateTime.now();
    final isToday =
        now.year == widget.dateTime.year &&
        now.month == widget.dateTime.month &&
        now.day == widget.dateTime.day;

    if (isToday) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final difference = now.difference(widget.dateTime);
    String text;

    if (difference.inMinutes < 1) {
      text = 'now'.tr;
    } else if (difference.inMinutes < 60) {
      text = '${difference.inMinutes} ${'min'.tr}';
    } else if (difference.inHours < 24) {
      text = DateFormat('h:mm').format(widget.dateTime);
    } else if (difference.inDays == 1) {
      text = 'yesterday'.tr;
    } else if (difference.inDays < 7) {
      text = DateFormat('EEE').format(widget.dateTime);
    } else {
      text = DateFormat('d/M/y').format(widget.dateTime);
    }

    setState(() => _displayText = text);

    if (difference.inHours >= 24) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayText, style: widget.style);
  }
}
