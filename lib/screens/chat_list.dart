import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger/src/bindings/bindings.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();

    MatrixListChatsResponse.rustSignalStream.listen((rustSignal) {
      final response = rustSignal.message;
      if (response is MatrixListChatsResponseOk) {
        setState(() {
          rooms = response.rooms;
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
        }

        // Remove signal
        else if (update is MatrixRoomListUpdateRemove) {
          final indices = List<int>.from(update.indices)..sort((a, b) => b.compareTo(a));
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

    Timer.periodic(const Duration(seconds: 3), (timer) {
      debugPrint(timer.tick.toString());
      MatrixListChatsRequest(url: "").sendSignalToRust();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          itemCount: rooms.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            height: 1,
          ),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.shade100,
                child: Text(
                  (rooms[index].name ?? "Untitled")[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                rooms[index].name ?? "Untitled",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                "Tap to open chat",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              onTap: () {
                debugPrint("Tapped room: ${rooms[index]}");
              },
            );
          },
        ),
      ),
    );
  }
}
