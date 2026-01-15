import 'package:flutter_test/flutter_test.dart';
import 'package:splitwithme/models/friend.dart';
import 'package:splitwithme/models/expense.dart';

void main() {
  group('Friend Model Tests', () {
    test('Debe crear Friend desde JSON correctamente', () {
      final json = {
        'id': 1,
        'name': 'Juan Pérez',
        'email': 'juan@example.com',
        'credit_balance': 50.0,
        'debit_balance': 30.0,
      };

      final friend = Friend.fromJson(json);

      expect(friend.id, 1);
      expect(friend.name, 'Juan Pérez');
      expect(friend.email, 'juan@example.com');
      expect(friend.creditBalance, 50.0);
      expect(friend.debitBalance, 30.0);
    });

    test('Debe convertir Friend a JSON correctamente', () {
      final friend = Friend(
        id: 1,
        name: 'María García',
        email: 'maria@example.com',
        creditBalance: 100.0,
        debitBalance: 0.0,
      );

      final json = friend.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'María García');
      expect(json['email'], 'maria@example.com');
      expect(json['credit_balance'], 100.0);
      expect(json['debit_balance'], 0.0);
    });

    test('Debe manejar valores opcionales correctamente', () {
      final friend1 = Friend(
        id: 1,
        name: 'Pedro',
        email: 'pedro@example.com',
      );

      expect(friend1.creditBalance, isNull);
      expect(friend1.debitBalance, isNull);

      final friend2 = Friend(
        id: 2,
        name: 'Ana',
      );

      expect(friend2.email, isNull);
    });

    test('Debe parsear JSON con campos opcionales', () {
      final json = {
        'id': 1,
        'name': 'Luis',
      };

      final friend = Friend.fromJson(json);

      expect(friend.id, 1);
      expect(friend.name, 'Luis');
      expect(friend.email, isNull);
      expect(friend.creditBalance, isNull);
      expect(friend.debitBalance, isNull);
    });
  });

  group('Expense Model Tests', () {
    test('Debe crear Expense desde JSON correctamente', () {
      final json = {
        'id': '1',
        'description': 'Cena restaurante',
        'amount': 150.0,
        'date': '2025-01-15',
        'credit_balance': 75.0,
        'num_friends': 2,
        'category': 'Comida',
      };

      final expense = Expense.fromJson(json);

      expect(expense.id, '1');
      expect(expense.description, 'Cena restaurante');
      expect(expense.amount, 150.0);
      expect(expense.creditBalance, 75.0);
      expect(expense.numFriends, 2);
      expect(expense.category, 'Comida');
    });

    test('Debe convertir Expense a JSON correctamente', () {
      final expense = Expense(
        id: '1',
        description: 'Supermercado',
        amount: 80.0,
        date: DateTime(2025, 1, 15),
        creditBalance: 40.0,
        numFriends: 2,
      );

      final json = expense.toJson();

      expect(json['description'], 'Supermercado');
      expect(json['amount'], 80.0);
      expect(json['date'], '2025-01-15');
      if (json.containsKey('credit_balance')) {
        expect(json['credit_balance'], 40.0);
      }
      if (json.containsKey('num_friends')) {
        expect(json['num_friends'], 2);
      }
    });

    test('Debe parsear fecha correctamente', () {
      final expense = Expense(
        id: '1',
        description: 'Test',
        amount: 50.0,
        date: DateTime(2025, 1, 15, 14, 30),
      );

      expect(expense.date.year, 2025);
      expect(expense.date.month, 1);
      expect(expense.date.day, 15);
    });

    test('Debe crear expense con campos mínimos requeridos', () {
      final expense = Expense(
        description: 'Test mínimo',
        amount: 50.0,
        date: DateTime.now(),
      );

      expect(expense.description, 'Test mínimo');
      expect(expense.amount, 50.0);
      expect(expense.id, isNull);
      expect(expense.category, isNull);
      expect(expense.creditBalance, isNull);
      expect(expense.numFriends, isNull);
    });

    test('Debe formatear monto correctamente', () {
      final expense = Expense(
        id: '1',
        description: 'Test',
        amount: 123.456,
        date: DateTime.now(),
      );

      final formatted = expense.formattedAmount;
      expect(formatted, '€123.46');
    });

    test('Debe formatear fecha correctamente', () {
      final expense = Expense(
        id: '1',
        description: 'Test',
        amount: 50.0,
        date: DateTime(2025, 1, 15),
      );

      expect(expense.formattedDate, '15/01/2025');
    });

    test('Debe manejar campos opcionales en JSON', () {
      final json = {
        'id': '1',
        'description': 'Test',
        'amount': 100.0,
        'date': '2025-01-15',
        // No incluye credit_balance ni num_friends
      };

      final expense = Expense.fromJson(json);

      expect(expense.id, '1');
      expect(expense.description, 'Test');
      expect(expense.amount, 100.0);
      expect(expense.creditBalance, isNull);
      expect(expense.numFriends, isNull);
    });

    test('Debe parsear diferentes formatos de fecha', () {
      final json1 = {
        'description': 'Test',
        'amount': 50.0,
        'date': '2025-01-15',
      };

      final expense1 = Expense.fromJson(json1);
      expect(expense1.date.year, 2025);
      expect(expense1.date.month, 1);
      expect(expense1.date.day, 15);

      final json2 = {
        'description': 'Test',
        'amount': 50.0,
        'date': '2025-01-15T14:30:00.000Z',
      };

      final expense2 = Expense.fromJson(json2);
      expect(expense2.date.year, 2025);
      expect(expense2.date.month, 1);
      expect(expense2.date.day, 15);
    });

    test('Debe manejar formattedAmount con valores null', () {
      final expense = Expense(
        description: 'Test',
        amount: 50.5,
        date: DateTime.now(),
        creditBalance: null,
      );

      // Verificar que no lanza error con creditBalance null
      expect(expense.formattedAmount, '€50.50');
      expect(() => expense.formattedAmount, returnsNormally);
    });
  });

  group('Tests de Serialización Completa', () {
    test('Friend debe mantener datos después de serializar y deserializar', () {
      final original = Friend(
        id: 42,
        name: 'Test User',
        email: 'test@test.com',
        creditBalance: 100.0,
        debitBalance: 50.0,
      );

      final json = original.toJson();
      final deserialized = Friend.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.email, original.email);
      expect(deserialized.creditBalance, original.creditBalance);
      expect(deserialized.debitBalance, original.debitBalance);
    });

    test('Expense debe mantener datos después de serializar y deserializar', () {
      final original = Expense(
        id: '123',
        description: 'Test Expense',
        amount: 99.99,
        date: DateTime(2025, 1, 15),
        category: 'Test Category',
        creditBalance: 49.99,
        numFriends: 2,
      );

      final json = original.toJson();
      final deserialized = Expense.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.description, original.description);
      expect(deserialized.amount, original.amount);
      expect(deserialized.date.year, original.date.year);
      expect(deserialized.date.month, original.date.month);
      expect(deserialized.date.day, original.date.day);
      expect(deserialized.category, original.category);
    });
  });
}
