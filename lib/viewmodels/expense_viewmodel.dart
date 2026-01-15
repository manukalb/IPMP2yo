import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../utils/result.dart';
import '../utils/command.dart';

class ExpenseViewModel extends ChangeNotifier {
  ExpenseViewModel({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository {
    load = Command0(_load);
    addExpense = Command1(_addExpense);
    removeExpense = Command1(_removeExpense);
    if (expenses.isEmpty) {
      load.execute();
    }
  }

  final ExpenseRepository _expenseRepository;
  late final Command0 load;
  late final Command1<void, Expense> addExpense;
  late final Command1<void, String> removeExpense;

  List<Expense> expenses = [];
  Expense? selectedExpense;
  String? errorMessage;

  Future<Result<void>> _load() async {
    final result = await _expenseRepository.fetchExpenses();
    switch (result) {
      case Ok<List<Expense>>():
        expenses = result.value;
        notifyListeners();
        return const Result.ok(null);
      case Error<List<Expense>>():
        errorMessage = "No se pudo recuperar la lista de gastos";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _addExpense(Expense expense) async {
    final result = await _expenseRepository.addExpense(expense);

    switch (result) {
      case Ok<Expense>():
        expenses.add(result.value);
        notifyListeners();
        return const Result.ok(null);
      case Error<Expense>():
        errorMessage = "No se pudo agregar el gasto";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _removeExpense(String id) async {
    final result = await _expenseRepository.deleteExpense(id);

    switch (result) {
      case Ok<void>():
        expenses.removeWhere((expense) => expense.id == id);
        notifyListeners();
        return const Result.ok(null);
      case Error<void>():
        errorMessage = "No se pudo eliminar el gasto";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  void setExpense(Expense expense) {
    selectedExpense = expense;
    notifyListeners();
  }
}
