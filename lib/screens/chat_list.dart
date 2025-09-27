import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger/src/bindings/bindings.dart';
import 'package:messenger/widgets/chat_item.dart';
import 'package:messenger/widgets/chat_list_header.dart';
import 'package:tuple/tuple.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Timer periodicTimer;
  List<Tuple2<RoomInfo, EventTimelineItem?>> rooms = [];

  int compareEvents(
    Tuple2<RoomInfo, EventTimelineItem?> a,
    Tuple2<RoomInfo, EventTimelineItem?> b,
  ) {
    if (a.item2 == null || b.item2 == null) {
      return a.item2 == null
          ? 1
          : b.item2 == null
          ? -1
          : (a.item1.displayName ?? "ZZZZZ").compareTo(
              b.item1.displayName ?? "ZZZZZ",
            );
    }

    return a.item2!.timestamp.value.toInt().compareTo(
      b.item2!.timestamp.value.toInt(),
    );
  }

  @override
  void initState() {
    super.initState();

    MatrixListChatsResponse.rustSignalStream.listen((rustSignal) {
      final response = rustSignal.message;
      if (response is MatrixListChatsResponseOk) {
        setState(() {
          rooms = response.rooms;
          rooms.sort(compareEvents);
        });
      } else if (response is MatrixListChatsResponseErr) {
        debugPrint("Error: ${response.message}");
      }
    });

    // Dynamic updates
    MatrixRoomListUpdate.rustSignalStream.listen((rustSignal) {
      final update = rustSignal.message;
      setState(() {
        // Replace everything signal
        if (update is MatrixRoomListUpdateList) {
          rooms = update.rooms;
          rooms.sort(compareEvents);
        }
        // Remove signal
        else if (update is MatrixRoomListUpdateRemove) {
          final indices = List<int>.from(update.indices)
            ..sort((a, b) => b.compareTo(a));
          for (final i in indices) {
            if (i >= 0 && i < rooms.length) {
              rooms.removeAt(i);
            }
          }
        }
      });
    });

    // after sync-service successfully started, it emits MatrixListChatsRequest, not from dart
    // MatrixListChatsRequest(url: "").sendSignalToRust();

    periodicTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      debugPrint(timer.tick.toString());
      MatrixListChatsRequest(url: "").sendSignalToRust();
    });
  }

  @override
  void dispose() {
    periodicTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: SafeArea(child: ChatListHeader()),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: rooms.length,
          // separatorBuilder: (context, index) =>
          //     Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
          itemBuilder: (context, index) {
            final room = rooms[index];
            return ChatItem(
              roomInfo: room.item1,
              latestEvent: room.item2,
              onTap: () {
                context.push("/chats/${room.item1.id}");
              },
            );
          },
        ),
      ),
    );
  }
}
