import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/screens/authorize.dart';
import 'package:messenger/screens/chat.dart';
import 'package:messenger/screens/chat_list.dart';
import 'package:messenger/screens/init.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(path: '/', builder: (context, state) => InitScreen()),
    GoRoute(path: '/authorize', builder: (context, state) => AuthorizeScreen()),
    GoRoute(path: '/chats', builder: (context, state) => ChatListScreen()),
    GoRoute(path: '/chats/:chatId', builder: (context, state) => ChatScreen()),
  ],
);
