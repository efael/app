// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/widgets/chat_item.dart'
    as _widgetbook_workspace_widgets_chat_item;
import 'package:widgetbook_workspace/widgets/message_preview.dart'
    as _widgetbook_workspace_widgets_message_preview;
import 'package:widgetbook_workspace/widgets/username.dart'
    as _widgetbook_workspace_widgets_username;
import 'package:widgetbook_workspace/widgets/userpic.dart'
    as _widgetbook_workspace_widgets_userpic;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookLeafComponent(
        name: 'ChatItem',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_chat_item.build,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'MessagePreview',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_message_preview.build,
        ),
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Username',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Secure=No, Mute=No',
            builder: _widgetbook_workspace_widgets_username.buildNoSecureNoMute,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Secure=Yes, Mute=No',
            builder: _widgetbook_workspace_widgets_username.buildSecureNoMute,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Secure=Yes, Mute=Yes',
            builder: _widgetbook_workspace_widgets_username.buildSecureMute,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'Userpic',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Medium',
            builder: _widgetbook_workspace_widgets_userpic.buildMedium,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Small',
            builder: _widgetbook_workspace_widgets_userpic.buildSmall,
          ),
        ],
      ),
    ],
  ),
];
