import 'package:flutter/material.dart';
import 'package:messenger/widgets/message_preview.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers/mock_event_timeline_item.dart';
import 'package:messenger/src/bindings/bindings.dart';

@widgetbook.UseCase(name: 'Default', type: MessagePreview)
Widget build(BuildContext context) {
  EventTimelineItem? eventTimelineItem = mockEventTimelineItem();

  return MessagePreview(event: eventTimelineItem);
}
