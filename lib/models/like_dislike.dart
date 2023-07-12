class LikeDislikeState {
  List<String> likes;
  List<String> dislikes;

  LikeDislikeState({this.likes = const [], this.dislikes = const []});
  LikeDislikeState copyWith({List<String>? likes, List<String>? dislikes}) {
    return LikeDislikeState(
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
    );
  }
}