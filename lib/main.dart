import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'repositories/friend_repository.dart';
import 'repositories/expense_repository.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp(
    friendRepository: FriendRepository(service: ApiService()),
    expenseRepository: ExpenseRepository(service: ApiService()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.friendRepository,
    required this.expenseRepository,
  });

  final FriendRepository friendRepository;
  final ExpenseRepository expenseRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => friendRepository),
        Provider(create: (context) => expenseRepository),
      ],
      builder: (context, widget) {
        return MaterialApp(
          title: 'SplitWithMe',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: ThemeMode.system,
          home: HomeScreen(
            friendRepository: context.read(),
            expenseRepository: context.read(),
          ),
        );
      },
    );
  }
}
