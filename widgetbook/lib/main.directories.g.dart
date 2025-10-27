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
import 'package:widgetbook_workspace/pages/home/views/chats.dart'
    as _widgetbook_workspace_pages_home_views_chats;
import 'package:widgetbook_workspace/pages/home/widgets/bottom_navigation.dart'
    as _widgetbook_workspace_pages_home_widgets_bottom_navigation;
import 'package:widgetbook_workspace/pages/home/widgets/chat_list.dart'
    as _widgetbook_workspace_pages_home_widgets_chat_list;
import 'package:widgetbook_workspace/pages/home/widgets/chat_list_header.dart'
    as _widgetbook_workspace_pages_home_widgets_chat_list_header;
import 'package:widgetbook_workspace/pages/home/widgets/chat_tile.dart'
    as _widgetbook_workspace_pages_home_widgets_chat_tile;
import 'package:widgetbook_workspace/widgets/user_avatar.dart'
    as _widgetbook_workspace_widgets_user_avatar;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'pages',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'home',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'views',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'Chats',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _widgetbook_workspace_pages_home_views_chats
                        .buildUseCase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'widgets',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ChatList',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _widgetbook_workspace_pages_home_widgets_chat_list
                        .buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatListHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_pages_home_widgets_chat_list_header
                            .buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _widgetbook_workspace_pages_home_widgets_chat_tile
                        .buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HomeBottomNavigationBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_pages_home_widgets_bottom_navigation
                            .buildUseCase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'UserAvatar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_widgets_user_avatar.buildUseCase,
          ),
        ],
      ),
    ],
  ),
];
