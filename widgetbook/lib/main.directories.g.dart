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
import 'package:widgetbook_workspace/widgets/badge.dart'
    as _widgetbook_workspace_widgets_badge;
import 'package:widgetbook_workspace/widgets/chat_header.dart'
    as _widgetbook_workspace_widgets_chat_header;
import 'package:widgetbook_workspace/widgets/chat_item.dart'
    as _widgetbook_workspace_widgets_chat_item;
import 'package:widgetbook_workspace/widgets/chat_list_header.dart'
    as _widgetbook_workspace_widgets_chat_list_header;
import 'package:widgetbook_workspace/widgets/header_status.dart'
    as _widgetbook_workspace_widgets_header_status;
import 'package:widgetbook_workspace/widgets/message.dart'
    as _widgetbook_workspace_widgets_message;
import 'package:widgetbook_workspace/widgets/message_box.dart'
    as _widgetbook_workspace_widgets_message_box;
import 'package:widgetbook_workspace/widgets/message_preview.dart'
    as _widgetbook_workspace_widgets_message_preview;
import 'package:widgetbook_workspace/widgets/message_viewer.dart'
    as _widgetbook_workspace_widgets_message_viewer;
import 'package:widgetbook_workspace/widgets/my_custom_popup.dart'
    as _widgetbook_workspace_widgets_my_custom_popup;
import 'package:widgetbook_workspace/widgets/profile_header_widget.dart'
    as _widgetbook_workspace_widgets_profile_header_widget;
import 'package:widgetbook_workspace/widgets/username.dart'
    as _widgetbook_workspace_widgets_username;
import 'package:widgetbook_workspace/widgets/userpic.dart'
    as _widgetbook_workspace_widgets_userpic;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'Badge',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeAttach',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeAttach,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeAudio',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeAudio,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeBackward',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeBackward,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeCount',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeCount,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeForward',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeForward,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeLocation',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeLocation,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeMention',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeMention,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgePause',
            builder: _widgetbook_workspace_widgets_badge.buildBadgePause,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgePin',
            builder: _widgetbook_workspace_widgets_badge.buildBadgePin,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgePrev',
            builder: _widgetbook_workspace_widgets_badge.buildBadgePrev,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeReorder',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeReorder,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeSkip',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeSkip,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeVideoMessage',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeVideoMessage,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'BadgeWallet',
            builder: _widgetbook_workspace_widgets_badge.buildBadgeWallet,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ChatHeader',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_widgets_chat_header.build,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Long Text',
            builder: _widgetbook_workspace_widgets_chat_header.buildLongText,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ChatItem',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: '60 days ago',
            builder:
                _widgetbook_workspace_widgets_chat_item.buildMessage60DaysAgo,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_widgets_chat_item.build,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Long Text',
            builder: _widgetbook_workspace_widgets_chat_item.buildLongText,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ChatListHeader',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_widgets_chat_list_header.build,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Long Text',
            builder:
                _widgetbook_workspace_widgets_chat_list_header.buildLongText,
          ),
        ],
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'HeaderStatusTyping',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_header_status.build,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'Message',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Message Text',
          builder: _widgetbook_workspace_widgets_message.build,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'MessageBox',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_message_box.build,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'MessagePreview',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_message_preview.build,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'MessageViewer',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default Message',
          builder:
              _widgetbook_workspace_widgets_message_viewer.messageViewerUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'MyPopupMenuItem',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default Message',
          builder:
              _widgetbook_workspace_widgets_my_custom_popup.customPopupUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'ProfileHeaderWidget',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Avater=No, Online=No',
          builder: _widgetbook_workspace_widgets_profile_header_widget
              .profileHeaderAllCase,
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
