
import 'package:pantau/models/user.dart';

const ROOM_RELATIVE_PATH = 'Rooms';

class Message {
  final String username;
  final String uid;
  final String chat;
  final DateTime time;

  Message({
    required this.username,
    required this.uid,
    required this.chat,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uid': uid,
      'chat': chat,
      'time': time.toIso8601String(),
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      username: map['username'],
      uid: map['uid'],
      chat: map['chat'],
      time: DateTime.parse(map['time']),
    );
  }
}

class Room {
  final List<User> users;
  final List<String> uid;
  final String roomId;
  final List<Message> messages;

  Room({
    required this.uid,
    required this.users,
    required this.roomId,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'users': users.map((user) => user.convertJSON()).toList(),
      'roomId': roomId,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }

  static Room fromMap(Map<String, dynamic> map) {
    return Room(
      uid: List<String>.from(map['uid']),
      users: List<User>.from(map['users'].map((user) => User.fromMap(user))),
      roomId: map['roomId'],
      messages: List<Message>.from(
          map['messages'].map((message) => Message.fromMap(message))),
    );
  }
}