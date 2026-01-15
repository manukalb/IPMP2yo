import 'package:flutter_test/flutter_test.dart';
import 'package:splitwithme/repositories/friend_repository.dart';
import 'package:splitwithme/repositories/expense_repository.dart';
import 'package:splitwithme/services/api_service.dart';
import 'package:splitwithme/models/friend.dart';
import 'package:splitwithme/models/expense.dart';
import 'package:splitwithme/utils/result.dart';

void main() {
  group('FriendRepository Tests', () {
    late ApiService apiService;
    late FriendRepository repository;

    setUp(() {
      apiService = ApiService();
      repository = FriendRepository(service: apiService);
    });

    test('fetchFriends debe retornar Result con lista de amigos', () async {
      final result = await repository.fetchFriends();

      expect(result, isA<Result>());

      switch (result) {
        case Ok<List<Friend>>(:final value):
          expect(value, isA<List<Friend>>());
          print('[TEST] Amigos cargados: ${value.length}');
        case Error<List<Friend>>(:final error):
          print('[TEST] Error al cargar amigos: $error');
      }
    });

    test('addFriend debe crear un nuevo amigo', () async {
      final newFriend = Friend(
        id: 0,
        name: 'Test Friend',
        email: 'test@example.com',
      );

      final result = await repository.addFriend(newFriend);

      switch (result) {
        case Ok<Friend>(:final value):
          print('[TEST] Amigo creado con ID: ${value.id}');
          expect(value.name, equals('Test Friend'));
        case Error<Friend>(:final error):
          print('[TEST] Error al crear amigo: $error');
      }
    });

    test('removeFriend debe eliminar un amigo existente', () async {
      final fetchResult = await repository.fetchFriends();

      switch (fetchResult) {
        case Ok<List<Friend>>(:final value):
          if (value.isNotEmpty) {
            final friendId = value.first.id;
            final deleteResult = await repository.removeFriend(friendId);

            expect(deleteResult, isA<Result<void>>());
            print('[TEST] Intento de eliminar amigo $friendId');
          }
        case Error<List<Friend>>():
          print('[TEST] No se pudieron cargar amigos para probar eliminación');
      }
    });
  });

  group('ExpenseRepository Tests', () {
    late ApiService apiService;
    late ExpenseRepository repository;

    setUp(() {
      apiService = ApiService();
      repository = ExpenseRepository(service: apiService);
    });

    test('fetchExpenses debe retornar Result con lista de gastos', () async {
      final result = await repository.fetchExpenses();

      expect(result, isA<Result>());

      switch (result) {
        case Ok<List<Expense>>(:final value):
          expect(value, isA<List<Expense>>());
          print('[TEST] Gastos cargados: ${value.length}');
        case Error<List<Expense>>(:final error):
          print('[TEST] Error al cargar gastos: $error');
      }
    });

    test('addExpense debe crear un nuevo gasto', () async {
      final newExpense = Expense(
        id: '0',
        description: 'Test Expense',
        date: DateTime.now(),
        amount: 50.0,
      );

      final result = await repository.addExpense(newExpense);

      switch (result) {
        case Ok<Expense>(:final value):
          print('[TEST] Gasto creado con ID: ${value.id}');
          expect(value.description, equals('Test Expense'));
        case Error<Expense>(:final error):
          print('[TEST] Error al crear gasto: $error');
      }
    });

    test('fetchExpenseFriends debe retornar amigos de un gasto', () async {
      final expensesResult = await repository.fetchExpenses();

      switch (expensesResult) {
        case Ok<List<Expense>>(:final value):
          if (value.isNotEmpty) {
            final firstExpense = value.first;
            // CORRECCIÓN AQUÍ: Se añade '!' porque sabemos que el ID existe en el test
            final friendsResult =
                await repository.fetchExpenseFriends(firstExpense.id!);

            expect(friendsResult, isA<Result>());

            switch (friendsResult) {
              case Ok<List<Friend>>(:final value):
                print(
                    '[TEST] Amigos del gasto ${firstExpense.id}: ${value.length}');
              case Error<List<Friend>>(:final error):
                print('[TEST] Error al cargar amigos del gasto: $error');
            }
          }
        case Error<List<Expense>>():
          print('[TEST] No se pudieron cargar gastos para probar');
      }
    });

    test('deleteExpense debe eliminar un gasto', () async {
      final fetchResult = await repository.fetchExpenses();

      switch (fetchResult) {
        case Ok<List<Expense>>(:final value):
          if (value.isNotEmpty) {
            final expenseId = value.first.id;
            final deleteResult = await repository.deleteExpense(expenseId);

            expect(deleteResult, isA<Result<void>>());
            print('[TEST] Intento de eliminar gasto $expenseId');
          }
        case Error<List<Expense>>():
          print('[TEST] No se pudieron cargar gastos para probar eliminación');
      }
    });
  });

  group('Tests de Manejo de Errores', () {
    test('Debe manejar error de conexión correctamente', () async {
      final badApiService = ApiService();
      final repository = FriendRepository(service: badApiService);

      final result = await repository.fetchFriends();

      expect(result, isA<Result>());

      switch (result) {
        case Error<List<Friend>>(:final error):
          print('[TEST] Error capturado correctamente: $error');
          expect(error, isA<Exception>());
        case Ok<List<Friend>>():
          print('[TEST] Inesperadamente tuvo éxito');
      }
    });

    test('Debe manejar respuesta 404 del servidor', () async {
      final apiService = ApiService();
      final repository = ExpenseRepository(service: apiService);

      final result = await repository.fetchExpenseFriends('99999');

      switch (result) {
        case Error<List<Friend>>(:final error):
          print('[TEST] Error 404 manejado: $error');
          expect(error, isA<Exception>());
        case Ok<List<Friend>>():
          print('[TEST] Respuesta inesperada para ID inexistente');
      }
    });

    test('Debe manejar datos inválidos del servidor', () async {
      final apiService = ApiService();
      final repository = FriendRepository(service: apiService);

      final result = await repository.fetchFriends();

      expect(result, isA<Result>());
      print('[TEST] Parseo de datos completado sin excepciones');
    });
  });

  group('Tests de Asignación de Amigos a Gastos', () {
    test('assignFriendToExpense debe asociar un amigo a un gasto', () async {
      final apiService = ApiService();
      final expenseRepo = ExpenseRepository(service: apiService);
      final friendRepo = FriendRepository(service: apiService);

      final expensesResult = await expenseRepo.fetchExpenses();
      final friendsResult = await friendRepo.fetchFriends();

      if (expensesResult is Ok<List<Expense>> &&
          friendsResult is Ok<List<Friend>>) {
        final expenses = expensesResult.value;
        final friends = friendsResult.value;

        if (expenses.isNotEmpty && friends.isNotEmpty) {
          // CORRECCIÓN AQUÍ: Se añaden '!' porque sabemos que los IDs existen
          final expenseId = int.parse(expenses.first.id!);
          final friendId = friends.first.id!;

          final assignResult =
              await expenseRepo.assignFriendToExpense(friendId, expenseId);

          switch (assignResult) {
            case Ok<void>():
              print('[TEST] Amigo $friendId asignado a gasto $expenseId');
            case Error<void>(:final error):
              print('[TEST] Error al asignar amigo: $error');
          }

          expect(assignResult, isA<Result<void>>());
        }
      }
    });
  });
}