import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/friend.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../repositories/expense_repository.dart';
import '../utils/result.dart';

class ExpenseDetailsDialog extends StatefulWidget {
  const ExpenseDetailsDialog({
    super.key,
    required this.expense,
    required this.viewModel,
    required this.expenseRepository,
  });

  final Expense expense;
  final ExpenseViewModel viewModel;
  final ExpenseRepository expenseRepository;

  @override
  State<ExpenseDetailsDialog> createState() => _ExpenseDetailsDialogState();
}

class _ExpenseDetailsDialogState extends State<ExpenseDetailsDialog> {
  List<Friend>? _friends;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    if (widget.expense.id == null) {
      setState(() {
        _loading = false;
        _error = 'Gasto sin ID';
      });
      return;
    }

    final result = await widget.expenseRepository.fetchExpenseFriends(widget.expense.id!);
    
    if (mounted) {
      setState(() {
        _loading = false;
        switch (result) {
          case Ok<List<Friend>>(:final value):
            _friends = value;
          case Error<List<Friend>>():
            _error = 'No se pudieron cargar los amigos';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense.description),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.euro, 'Monto', widget.expense.formattedAmount),
            _buildInfoRow(Icons.calendar_today, 'Fecha', widget.expense.formattedDate),
            if (widget.expense.category != null)
              _buildInfoRow(Icons.category, 'Categoría', widget.expense.category!),
            _buildInfoRow(
              Icons.credit_score,
              'Balance de crédito',
              '€${widget.expense.creditBalance?.toStringAsFixed(2) ?? '0.00'}',
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Amigos participantes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            else if (_friends == null || _friends!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No hay amigos asignados a este gasto'),
              )
            else
              ..._friends!.map((friend) => _buildFriendTile(context, friend)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (widget.expense.id != null) {
              widget.viewModel.removeExpense.execute(widget.expense.id!);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFriendTile(BuildContext context, Friend friend) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          child: Text(friend.name[0].toUpperCase()),
        ),
        title: Text(friend.name),
        subtitle: Row(
          children: [
            const Icon(Icons.credit_score, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Text('€${friend.creditBalance?.toStringAsFixed(2) ?? '0.00'}'),
            const SizedBox(width: 12),
            const Icon(Icons.credit_card, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text('€${friend.debitBalance?.toStringAsFixed(2) ?? '0.00'}'),
          ],
        ),
      ),
    );
  }
}
