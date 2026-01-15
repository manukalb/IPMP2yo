import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/friend_viewmodel.dart';
import '../repositories/expense_repository.dart';
import '../repositories/friend_repository.dart';
import '../utils/result.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.expenseRepository,
    this.friendRepository,
  });

  final ExpenseRepository expenseRepository;
  final FriendRepository? friendRepository;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  int? _selectedPayerId;
  final Set<int> _selectedSharedWithIds = {};
  DateTime _selectedDate = DateTime.now();

  late final ExpenseViewModel _expenseViewModel;
  late final FriendViewModel? _friendViewModel;

  @override
  void initState() {
    super.initState();
    _expenseViewModel = ExpenseViewModel(expenseRepository: widget.expenseRepository);
    _friendViewModel = widget.friendRepository != null
        ? FriendViewModel(friendRepository: widget.friendRepository!)
        : null;
    _friendViewModel?.load.execute();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _expenseViewModel.dispose();
    _friendViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un monto';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_friendViewModel != null)
              ListenableBuilder(
                listenable: _friendViewModel!,
                builder: (context, child) {
                  if (_friendViewModel!.friends.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay amigos. Agrega amigos primero.'),
                      ),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Pagado por',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    value: _selectedPayerId,
                    items: _friendViewModel!.friends
                        .map((friend) => DropdownMenuItem(
                              value: friend.id,
                              child: Text(friend.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPayerId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona quién pagó';
                      }
                      return null;
                    },
                  );
                },
              ),
            const SizedBox(height: 16),
            if (_friendViewModel != null)
              ListenableBuilder(
                listenable: _friendViewModel!,
                builder: (context, child) {
                  if (_friendViewModel!.friends.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compartido con:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._friendViewModel!.friends.map((friend) {
                        final friendId = friend.id;
                        if (friendId == null) return const SizedBox.shrink();
                        
                        return CheckboxListTile(
                          title: Text(friend.name),
                          value: _selectedSharedWithIds.contains(friendId),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedSharedWithIds.add(friendId);
                              } else {
                                _selectedSharedWithIds.remove(friendId);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              leading: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _expenseViewModel.addExpense,
              builder: (context, child) {
                return FilledButton(
                  onPressed: _expenseViewModel.addExpense.running
                      ? null
                      : _saveExpense,
                  child: _expenseViewModel.addExpense.running
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final allFriendIds = <int>{};
    if (_selectedPayerId != null) {
      allFriendIds.add(_selectedPayerId!);
    }
    allFriendIds.addAll(_selectedSharedWithIds);
    
    print('[v0] Creating expense with ${allFriendIds.length} unique friends');
    print('[v0] Selected friend IDs: $allFriendIds');

    final expense = Expense(
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: 'General',
      creditBalance: 0.0,
      numFriends: allFriendIds.isNotEmpty ? allFriendIds.length : 1,
    );

    await _expenseViewModel.addExpense.execute(expense);

    if (mounted) {
      if (_expenseViewModel.addExpense.completed) {
        final createdExpense = _expenseViewModel.expenses.last;
        final expenseId = createdExpense.id;
        
        print('[v0] Expense created with ID: $expenseId');
        
        if (expenseId != null && allFriendIds.isNotEmpty) {
          try {
            final expenseIdInt = int.parse(expenseId);
            print('[v0] Assigning ${allFriendIds.length} friends to expense $expenseIdInt');
            
            for (final friendId in allFriendIds) {
              print('[v0] Assigning friend $friendId to expense $expenseIdInt');
              final result = await widget.expenseRepository.assignFriendToExpense(friendId, expenseIdInt);
              
              switch (result) {
                case Ok<void>():
                  print('[v0] Successfully assigned friend $friendId');
                case Error<void>(:final error):
                  print('[v0] Error assigning friend $friendId: $error');
                  throw error;
              }
            }
            
            print('[v0] All friends assigned successfully');
          } catch (e) {
            print('[v0] Error assigning friends: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gasto creado pero error asignando amigos: $e')),
              );
            }
            return;
          }
        } else {
          print('[v0] No friends to assign. ExpenseId: $expenseId, Friends: ${allFriendIds.length}');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gasto agregado con amigos asignados')),
          );
          Navigator.pop(context);
        }
      } else if (_expenseViewModel.addExpense.error) {
        print('[v0] Error creating expense: ${_expenseViewModel.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_expenseViewModel.errorMessage ?? 'Error al agregar gasto')),
        );
      }
    }
  }
}
