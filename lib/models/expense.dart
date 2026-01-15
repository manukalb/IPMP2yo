import 'package:intl/intl.dart';
import '../utils/exceptions.dart';

class Expense {
  final String? id;
  final String description;
  final double amount;
  final DateTime date;
  final double? creditBalance;
  final int? numFriends;
  final String? category;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.creditBalance,
    this.numFriends,
    this.category,
  }) {
    _validate();
  }

  void _validate() {
    if (description.trim().isEmpty) {
      throw ValidationException('La descripción no puede estar vacía');
    }
    if (amount <= 0) {
      throw ValidationException('El monto debe ser mayor a cero');
    }
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    return formatter.format(amount);
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  double get amountPerPerson {
    if (numFriends == null || numFriends == 0) return amount;
    return amount / numFriends!;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'description': description,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
    };
    
    if (id != null) json['id'] = id;
    if (creditBalance != null) json['credit_balance'] = creditBalance;
    if (numFriends != null) json['num_friends'] = numFriends;
    
    return json;
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    try {
      return Expense(
        id: json['id']?.toString(),
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        creditBalance: json['credit_balance'] != null 
            ? (json['credit_balance'] as num).toDouble()
            : null,
        numFriends: json['num_friends'] as int?,
        category: json['category'] as String?,
      );
    } catch (e) {
      throw ValidationException('Error al parsear gasto: $e');
    }
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    double? creditBalance,
    int? numFriends,
    String? category,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      creditBalance: creditBalance ?? this.creditBalance,
      numFriends: numFriends ?? this.numFriends,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, description: $description, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
