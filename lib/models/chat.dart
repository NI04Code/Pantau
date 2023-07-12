class Comment {
  final String idChat;
  final String message;
  final String uid;
  final String profilePhoto;
  final String username;
  final DateTime timestamp;
  final List<Reply> replies;
  final List<String> likes;
  final List<String> dislikes;

  Comment({
    required this.profilePhoto,
    required this.idChat,
    required this.message,
    required this.uid,
    required this.username,
    required this.timestamp,
    required this.replies,
    required this.likes,
    required this.dislikes,
  });

  Map<String, dynamic> toMap() {
    return {
      'idChat': idChat,
      'message': message,
      'uid': uid,
      'profilePhoto': profilePhoto,
      'username': username,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'replies': replies.map((reply) => reply.toMap()).toList(),
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  static Comment fromMap(Map<String, dynamic> map) {
    return Comment(
      profilePhoto: map['profilePhoto'],
      idChat: map['idChat'],
      message: map['message'],
      uid: map['uid'],
      username: map['username'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      replies: List<Reply>.from(map['replies']?.map((x) => Reply.fromMap(x))),
      likes: List<String>.from(map['likes']),
      dislikes: List<String>.from(map['dislikes']),
    );
  }
}

class Reply {
  final String idChat;
  final String message;
  final String uid;
  final String profilePhoto;
  final String username;
  final DateTime timestamp;
  final List<String> likes;
  final List<String> dislikes;

  Reply({
    required this.profilePhoto,
    required this.idChat,
    required this.message,
    required this.uid,
    required this.username,
    required this.timestamp,
    required this.likes,
    required this.dislikes,
  });

  Map<String, dynamic> toMap() {
    return {
      'idChat': idChat,
      'message': message,
      'uid': uid,
      'profilePhoto': profilePhoto,
      'username': username,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  static Reply fromMap(Map<String, dynamic> map) {
    return Reply(
      profilePhoto: map['profilePhoto'],
      idChat: map['idChat'],
      message: map['message'],
      uid: map['uid'],
      username: map['username'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      likes: List<String>.from(map['likes']),
      dislikes: List<String>.from(map['dislikes']),
    );
  }
}
