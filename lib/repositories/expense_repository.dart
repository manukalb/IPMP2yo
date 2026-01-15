import '../models/expense.dart';
import '../models/friend.dart';
import '../services/api_service.dart';
import '../utils/result.dart';

class ExpenseRepository {
  ExpenseRepository({required ApiService service}) : _service = service;
  final ApiService _service;

  Future<Result<List<Expense>>> fetchExpenses() async {
    try {
      final response = await _service.get('/expenses');
      if (response is List) {
        final expenses = response.map((json) => Expense.fromJson(json)).toList();
        return Result.ok(expenses);
      }
      throw Exception('Formato de respuesta inválido');
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Expense>> addExpense(Expense expense) async {
    try {
      final response = await _service.post('/expenses', expense.toJson());
      return Result.ok(Expense.fromJson(response));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> deleteExpense(String? id) async {
    if (id == null) {
      return Result.error(Exception('ID de gasto no válido'));
    }
    try {
      await _service.delete('/expenses/$id');
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Friend>>> fetchExpenseFriends(String expenseId) async {
    try {
      final response = await _service.get('/expenses/$expenseId/friends');
      if (response is List) {
        final friends = response.map((json) => Friend.fromJson(json)).toList();
        return Result.ok(friends);
      }
      throw Exception('Formato de respuesta inválido');
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> assignFriendToExpense(int friendId, int expenseId) async {
    try {
      await _service.post('/expenses/$expenseId/friends?friend_id=$friendId', {});
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
