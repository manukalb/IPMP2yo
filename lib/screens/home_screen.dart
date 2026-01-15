import 'package:flutter/material.dart';
import '../repositories/friend_repository.dart';
import '../repositories/expense_repository.dart';
import '../viewmodels/friend_viewmodel.dart';
import 'expenses_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.friendRepository,
    required this.expenseRepository,
  });

  final FriendRepository friendRepository;
  final ExpenseRepository expenseRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final FriendViewModel friendViewModel;

  @override
  void initState() {
    super.initState();
    friendViewModel = FriendViewModel(friendRepository: widget.friendRepository);
  }

  @override
  void dispose() {
    friendViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final screens = [
      ExpensesScreen(
        expenseRepository: widget.expenseRepository,
        friendRepository: widget.friendRepository,
      ),
      FriendsScreen(
        title: 'Lista de amigos',
        viewModel: friendViewModel,
      ),
    ];

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('Gastos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Amigos'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: screens[_selectedIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Amigos',
          ),
        ],
      ),
    );
  }
}
