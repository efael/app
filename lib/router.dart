import 'package:go_router/go_router.dart';
import 'package:messenger/screens/authorize.dart';
import 'package:messenger/screens/chat_list.dart';
import 'package:messenger/screens/init.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => InitScreen()),
    GoRoute(path: '/authorize', builder: (context, state) => AuthorizeScreen()),
    GoRoute(path: '/chat-list', builder: (context, state) => ChatListScreen()),
  ],
);
