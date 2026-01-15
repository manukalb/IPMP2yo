import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwithme/main.dart';
import 'package:splitwithme/models/expense.dart';
import 'package:splitwithme/models/friend.dart';
import 'package:splitwithme/repositories/expense_repository.dart';
import 'package:splitwithme/repositories/friend_repository.dart';
import 'package:splitwithme/services/api_service.dart';
import 'package:splitwithme/utils/result.dart';
import 'package:splitwithme/utils/exceptions.dart';

// --- MOCKS ---
class MockFriendRepository implements FriendRepository {
  bool shouldFail = false;
  List<Friend> friends = [];

  @override
  ApiService get _service => throw UnimplementedError();

  MockFriendRepository({List<Friend>? initialFriends}) {
    if (initialFriends != null) friends.addAll(initialFriends);
  }

  @override
  Future<Result<List<Friend>>> fetchFriends() async {
    if (shouldFail) return Result.error(NetworkException('Error de conexión simulado'));
    return Result.ok(friends);
  }

  @override
  Future<Result<Friend>> addFriend(Friend friend) async {
    if (shouldFail) return Result.error(ServerException('Error al guardar'));
    final newFriend = Friend(
      id: friends.length + 1,
      name: friend.name,
      email: friend.email,
    );
    friends.add(newFriend);
    return Result.ok(newFriend);
  }

  @override
  Future<Result<void>> removeFriend(int? id) async {
    if (shouldFail) return Result.error(ServerException('Error al borrar'));
    friends.removeWhere((f) => f.id == id);
    return const Result.ok(null);
  }
}

class MockExpenseRepository implements ExpenseRepository {
  bool shouldFail = false;
  List<Expense> expenses = [];

  @override
  ApiService get _service => throw UnimplementedError();

  MockExpenseRepository({List<Expense>? initialExpenses}) {
    if (initialExpenses != null) expenses.addAll(initialExpenses);
  }

  @override
  Future<Result<List<Expense>>> fetchExpenses() async {
    if (shouldFail) return Result.error(NetworkException('Error de conexión simulado'));
    return Result.ok(expenses);
  }

  @override
  Future<Result<Expense>> addExpense(Expense expense) async {
    if (shouldFail) return Result.error(ServerException('Error al guardar'));
    final newExpense = expense.copyWith(id: (expenses.length + 1).toString());
    expenses.add(newExpense);
    return Result.ok(newExpense);
  }

  @override
  Future<Result<void>> deleteExpense(String? id) async {
    expenses.removeWhere((e) => e.id == id);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<Friend>>> fetchExpenseFriends(String expenseId) async {
    return const Result.ok([]);
  }

  @override
  Future<Result<void>> assignFriendToExpense(int friendId, int expenseId) async {
    return const Result.ok(null);
  }
}

void main() {
  group('Tarea 3: Tests End-to-End (E2E)', () {
    late MockFriendRepository mockFriendRepo;
    late MockExpenseRepository mockExpenseRepo;

    setUp(() {
      mockFriendRepo = MockFriendRepository();
      mockExpenseRepo = MockExpenseRepository();
    });

    testWidgets('Debe mostrar la pantalla principal y navegar entre pestañas',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        friendRepository: mockFriendRepo,
        expenseRepository: mockExpenseRepo,
      ));
      await tester.pumpAndSettle();

      // Verificar pantalla inicial (Gastos) - Título: 'Lista de Gastos'
      expect(find.text('Lista de Gastos'), findsOneWidget); 
      
      // Navegar a Amigos
      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();

      // Verificar pantalla de Amigos - Título: 'Lista de Amigos'
      expect(find.text('Lista de Amigos'), findsOneWidget);
    });

    testWidgets('Debe permitir añadir un nuevo amigo', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        friendRepository: mockFriendRepo,
        expenseRepository: mockExpenseRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Nuevo Amigo E2E');
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Amigo E2E'), findsOneWidget);
    });

    testWidgets('Debe permitir añadir un nuevo gasto', (WidgetTester tester) async {
      mockFriendRepo.friends.add(Friend(id: 1, name: 'Amigo Pagador', email: 'test@test.com'));

      await tester.pumpWidget(MyApp(
        friendRepository: mockFriendRepo,
        expenseRepository: mockExpenseRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Cena E2E');
      await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '50.50');
      
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amigo Pagador').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Cena E2E'), findsOneWidget);
      expect(find.text('€50.50'), findsOneWidget);
    });

    testWidgets('Debe validar campos obligatorios al crear gasto', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        friendRepository: mockFriendRepo,
        expenseRepository: mockExpenseRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
      expect(find.text('Por favor ingresa un monto'), findsOneWidget);
    });

    testWidgets('Debe validar monto inválido (0 o negativo)', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        friendRepository: mockFriendRepo,
        expenseRepository: mockExpenseRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Test');
      await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '0');
      
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('El monto debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de error cuando falla la carga de datos (Error E/S)',
        (WidgetTester tester) async {
      mockExpenseRepo.shouldFail = true;

      await tester.pumpWidget(MyApp(
        friendRepository: mockFriendRepo,
        expenseRepository: mockExpenseRepo,
      ));
      
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('No se pudo recuperar la lista de gastos'), findsOneWidget);
    });
  });
}