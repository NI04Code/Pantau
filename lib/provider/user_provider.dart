
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/user.dart';


class UserNotifier extends StateNotifier<User>{
  UserNotifier(): super(User());
  void updateUser(User user){
    state = user;
  }
  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void updateUid(String newUid) {
    state = state.copyWith(uid: newUid);
  }

  void updateBio(String newBio) {
    state = state.copyWith(bio: newBio);
  }

  void updateFollowing(List newFollowing) {
    state = state.copyWith(following: newFollowing);
  }

  void updateFollowers(List newFollowers) {
    state = state.copyWith(followers: newFollowers);
  }

  void updatePhotoUrl(String? newPhotoUrl) {
    state = state.copyWith(photoUrl: newPhotoUrl);
  }

  void updateTelephoneNumber(String? newTelephoneNumber) {
    state = state.copyWith(telephoneNumber: newTelephoneNumber);
  }

  void updateUsername(String newUsername) {
    state = state.copyWith(username: newUsername);
  }

  void updateEmail(String newEmail) {
    state = state.copyWith(email: newEmail);
  }
}
final userProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());

class UserList extends StateNotifier<List<User>>{
  UserList(): super([]);
  void setUsers(List<User> users){
    state = [...users];
  }
}
final userListProvider = StateNotifierProvider<UserList, List<User>>((ref) => UserList());