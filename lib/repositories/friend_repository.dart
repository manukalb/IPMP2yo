import '../models/friend.dart';
import '../services/api_service.dart';
import '../utils/result.dart';

class FriendRepository {
  FriendRepository({required ApiService service}) : _service = service;
  final ApiService _service;

  Future<Result<List<Friend>>> fetchFriends() async {
    try {
      final response = await _service.get('/friends');
      if (response is List) {
        final friends = response.map((json) => Friend.fromJson(json)).toList();
        return Result.ok(friends);
      }
      throw Exception('Formato de respuesta inválido');
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Friend>> addFriend(Friend friend) async {
    try {
      final response = await _service.post('/friends', {'name': friend.name, 'email': friend.email ?? ''});
      return Result.ok(Friend.fromJson(response));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> removeFriend(int? id) async {
    if (id == null) {
      return Result.error(Exception('ID de amigo no válido'));
    }
    try {
      await _service.delete('/friends/$id');
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
