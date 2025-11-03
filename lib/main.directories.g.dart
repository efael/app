// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:messenger/features/onboarding/ui/verify_wb.dart'
    as _messenger_features_onboarding_ui_verify_wb;
import 'package:messenger/features/security/ui/change_wb.dart'
    as _messenger_features_security_ui_change_wb;
import 'package:messenger/features/security/ui/disable_wb.dart'
    as _messenger_features_security_ui_disable_wb;
import 'package:messenger/features/security/ui/enter_wb.dart'
    as _messenger_features_security_ui_enter_wb;
import 'package:messenger/features/security/ui/reset_password_wb.dart'
    as _messenger_features_security_ui_reset_password_wb;
import 'package:messenger/features/security/ui/reset_wb.dart'
    as _messenger_features_security_ui_reset_wb;
import 'package:messenger/features/security/ui/settings_wb.dart'
    as _messenger_features_security_ui_settings_wb;
import 'package:messenger/features/security/ui/setup_wb.dart'
    as _messenger_features_security_ui_setup_wb;
import 'package:messenger/pages/home/views/chats_wb.dart'
    as _messenger_pages_home_views_chats_wb;
import 'package:messenger/pages/home/widgets/bottom_navigation_wb.dart'
    as _messenger_pages_home_widgets_bottom_navigation_wb;
import 'package:messenger/pages/home/widgets/chat_list_header_wb.dart'
    as _messenger_pages_home_widgets_chat_list_header_wb;
import 'package:messenger/pages/home/widgets/chat_list_wb.dart'
    as _messenger_pages_home_widgets_chat_list_wb;
import 'package:messenger/pages/home/widgets/chat_tile_wb.dart'
    as _messenger_pages_home_widgets_chat_tile_wb;
import 'package:messenger/widgets/user_avatar_wb.dart'
    as _messenger_widgets_user_avatar_wb;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'features',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'onboarding',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'ui',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'OnboardingVerifyUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _messenger_features_onboarding_ui_verify_wb
                        .buildUseCase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'security',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'ui',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'SecurityChangeUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _messenger_features_security_ui_change_wb.buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SecurityDisableUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _messenger_features_security_ui_disable_wb.buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SecurityEnterUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _messenger_features_security_ui_enter_wb.buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SecurityResetPasswordUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _messenger_features_security_ui_reset_password_wb
                        .buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SecurityResetUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _messenger_features_security_ui_reset_wb.buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SecuritySettingsUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _messenger_features_security_ui_settings_wb
                        .buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'SecuritySetupUI',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _messenger_features_security_ui_setup_wb.buildUseCase,
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
                    builder: _messenger_pages_home_views_chats_wb.buildUseCase,
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
                    builder:
                        _messenger_pages_home_widgets_chat_list_wb.buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatListHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _messenger_pages_home_widgets_chat_list_header_wb
                        .buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ChatTile',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _messenger_pages_home_widgets_chat_tile_wb.buildUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HomeBottomNavigationBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder: _messenger_pages_home_widgets_bottom_navigation_wb
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
            builder: _messenger_widgets_user_avatar_wb.buildUseCase,
          ),
        ],
      ),
    ],
  ),
];
