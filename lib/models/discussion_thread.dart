class DiscussionThread {
  final String id;
  final String title;
  final String author;
  final String profilePhoto;
  final List<String> comments;
  final List<String> upvotes;
  final List<String> downvotes;
  final List<String> thumbnail;
  final String content;
  final DateTime postedAt;
  final String userid;
  final String postid;

  DiscussionThread({
    required this.userid,
    required this.id,
    required this.title,
    required this.author,
    required this.profilePhoto,
    required this.comments,
    required this.upvotes,
    required this.downvotes,
    required this.thumbnail,
    required this.content,
    required this.postedAt,
    required this.postid
  });

  Map<String, dynamic> toMap() {
    return {
      'postid': postid,
      'userid': userid,
      'id': id,
      'title': title,
      'author': author,
      'profilePhoto': profilePhoto,
      'comments': comments,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'thumbnail': thumbnail,
      'content': content,
      'postedAt': postedAt.millisecondsSinceEpoch,
    };
  }

  factory DiscussionThread.fromMap(Map<String, dynamic> map) {
    return DiscussionThread(
      postid: map['postid'],
      userid: map['userid'],
      id: map['id'],
      title: map['title'],
      author: map['author'],
      profilePhoto: map['profilePhoto'],
      comments: List<String>.from(map['comments']),
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      thumbnail: List<String>.from(map['thumbnail']),
      content: map['content'],
      postedAt: DateTime.fromMillisecondsSinceEpoch(map['postedAt']),
    );
  }
}