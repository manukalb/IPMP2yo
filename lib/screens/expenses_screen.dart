import 'package:flutter/material.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/friend_repository.dart';
import 'add_expense_screen.dart';
import 'expense_details_dialog.dart'; // Import the new dialog widget

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({
    super.key, 
    required this.expenseRepository,
    this.friendRepository,
  });

  final ExpenseRepository expenseRepository;
  final FriendRepository? friendRepository;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final ExpenseViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ExpenseViewModel(expenseRepository: widget.expenseRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          ListenableBuilder(
            listenable: _viewModel.load,
            builder: (context, child) {
              return IconButton(
                icon: _viewModel.load.running
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: _viewModel.load.running ? null : () => _viewModel.load.execute(),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.load.running && _viewModel.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.load.error && _viewModel.expenses.isEmpty) {
            return _buildErrorWidget(context, _viewModel);
          }

          if (_viewModel.expenses.isEmpty) {
            return _buildEmptyState();
          }

          return _buildExpensesList(context, _viewModel);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                expenseRepository: widget.expenseRepository,
                friendRepository: widget.friendRepository,
              ),
            ),
          ).then((_) {
            // Recargar la lista de gastos al volver
            _viewModel.load.execute();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesList(BuildContext context, ExpenseViewModel viewModel) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: viewModel.expenses.length,
        itemBuilder: (context, index) {
          return _buildExpenseCard(context, viewModel.expenses[index], viewModel);
        },
      );
    }

    return ListView.builder(
      itemCount: viewModel.expenses.length,
      itemBuilder: (context, index) {
        final expense = viewModel.expenses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(expense.description[0].toUpperCase()),
            ),
            title: Text(expense.description),
            subtitle: Text(expense.formattedDate),
            trailing: Text(
              expense.formattedAmount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _showExpenseDetails(context, expense, viewModel),
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense, ExpenseViewModel viewModel) {
    return Card(
      child: InkWell(
        onTap: () => _showExpenseDetails(context, expense, viewModel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  expense.description[0].toUpperCase(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      expense.description,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      expense.formattedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                expense.formattedAmount,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense, ExpenseViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => ExpenseDetailsDialog(
        expense: expense,
        viewModel: viewModel,
        expenseRepository: widget.expenseRepository,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, ExpenseViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'Error al cargar gastos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => viewModel.load.execute(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay gastos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer gasto',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
