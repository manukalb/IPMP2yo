import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../repositories/friend_repository.dart';
import '../utils/result.dart';
import '../utils/command.dart';

class FriendViewModel extends ChangeNotifier {
  FriendViewModel({required FriendRepository friendRepository})
      : _friendRepository = friendRepository {
    load = Command0(_load);
    addFriend = Command1(_addFriend);
    removeFriend = Command1(_removeFriend);
    if (friends.isEmpty) {
      load.execute();
    }
  }

  final FriendRepository _friendRepository;
  late final Command0 load;
  late final Command1<void, String> addFriend;
  late final Command1<void, int> removeFriend;

  List<Friend> friends = [];
  Friend? selectedFriend;
  String? errorMessage;

  Future<Result<void>> _load() async {
    final result = await _friendRepository.fetchFriends();
    switch (result) {
      case Ok<List<Friend>>():
        friends = result.value;
        notifyListeners();
        return const Result.ok(null);
      case Error<List<Friend>>():
        errorMessage = "No se pudo recuperar la lista de amigos";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _addFriend(String name) async {
    final result = await _friendRepository.addFriend(Friend(name: name, email: '$name@example.com'));

    switch (result) {
      case Ok<Friend>():
        friends.add(result.value);
        notifyListeners();
        return const Result.ok(null);
      case Error<Friend>():
        errorMessage = "No se pudo agregar el amigo $name";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _removeFriend(int id) async {
    final result = await _friendRepository.removeFriend(id);

    switch (result) {
      case Ok<void>():
        friends.removeWhere((friend) => friend.id == id);
        notifyListeners();
        return const Result.ok(null);
      case Error<void>():
        errorMessage = "No se pudo eliminar el amigo";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  void setFriend(Friend friend) {
    selectedFriend = friend;
    notifyListeners();
  }
}
