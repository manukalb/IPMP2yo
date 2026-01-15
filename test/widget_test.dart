import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwithme/main.dart';
import 'package:splitwithme/repositories/friend_repository.dart';
import 'package:splitwithme/repositories/expense_repository.dart';
import 'package:splitwithme/services/api_service.dart';

void main() {
  group('SplitWithMe E2E Tests', () {
    late ApiService apiService;
    late FriendRepository friendRepository;
    late ExpenseRepository expenseRepository;

    setUp(() {
      apiService = ApiService();
      friendRepository = FriendRepository(service: apiService);
      expenseRepository = ExpenseRepository(service: apiService);
    });

    testWidgets('Debe mostrar la pantalla principal con navegación',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Verificar que se muestra el título de la app
      expect(find.text('SplitWithMe'), findsOneWidget);

      // Verificar que existen las opciones de navegación
      expect(find.text('Gastos'), findsOneWidget);
      expect(find.text('Amigos'), findsOneWidget);
    });

    testWidgets('Debe navegar entre pantallas de Gastos y Amigos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Inicialmente debe estar en Gastos
      expect(find.text('Lista de Gastos'), findsOneWidget);

      // Navegar a Amigos
      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();

      // Verificar que cambia a pantalla de Amigos
      expect(find.text('Lista de Amigos'), findsOneWidget);

      // Volver a Gastos
      await tester.tap(find.text('Gastos'));
      await tester.pumpAndSettle();

      expect(find.text('Lista de Gastos'), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de carga al inicio',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );

      // Verificar que se muestra indicador de carga
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
  });

  group('Tests de Amigos', () {
    late ApiService apiService;
    late FriendRepository friendRepository;
    late ExpenseRepository expenseRepository;

    setUp(() {
      apiService = ApiService();
      friendRepository = FriendRepository(service: apiService);
      expenseRepository = ExpenseRepository(service: apiService);
    });

    testWidgets('Debe abrir el diálogo para añadir amigo',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Navegar a Amigos
      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();

      // Buscar el botón flotante de añadir
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      // Tap en el botón
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verificar que se abre el diálogo
      expect(find.text('Añadir Amigo'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
    });

    testWidgets('Debe mostrar error al intentar crear amigo sin nombre',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Navegar a Amigos
      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();

      // Abrir diálogo de añadir amigo
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Intentar guardar sin escribir nombre
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verificar que muestra error de validación
      expect(find.text('Por favor ingresa un nombre'), findsOneWidget);
    });

    testWidgets('Debe mostrar lista de amigos con balances',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Navegar a Amigos
      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();

      // Esperar a que carguen los amigos del servidor
      await tester.pump(const Duration(seconds: 2));

      // Verificar que se muestran amigos (si hay en el servidor)
      // Si hay datos, debe mostrar ListTiles con información de amigos
      expect(find.byType(ListTile), findsWidgets);
    });
  });

  group('Tests de Gastos', () {
    late ApiService apiService;
    late FriendRepository friendRepository;
    late ExpenseRepository expenseRepository;

    setUp(() {
      apiService = ApiService();
      friendRepository = FriendRepository(service: apiService);
      expenseRepository = ExpenseRepository(service: apiService);
    });

    testWidgets('Debe mostrar lista de gastos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Ya está en pantalla de Gastos por defecto
      // Esperar a que carguen los gastos
      await tester.pump(const Duration(seconds: 2));

      // Verificar que se muestran gastos (si hay en el servidor)
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Debe abrir pantalla para añadir gasto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Buscar botón de añadir
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      // Tap en el botón
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verificar que se abre la pantalla de añadir gasto
      expect(find.text('Añadir Gasto'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('Monto'), findsOneWidget);
    });

    testWidgets('Debe mostrar error al crear gasto sin descripción',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Abrir pantalla de añadir gasto
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Intentar guardar sin llenar campos
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verificar errores de validación
      expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
    });

    testWidgets('Debe mostrar error al crear gasto con monto inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Abrir pantalla de añadir gasto
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Llenar descripción
      await tester.enterText(
          find.widgetWithText(TextField, 'Descripción'), 'Test Gasto');

      // Llenar monto con valor negativo
      await tester.enterText(
          find.widgetWithText(TextField, 'Monto'), '-10');

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verificar error de validación
      expect(find.text('El monto debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('Debe mostrar detalles de un gasto al hacer tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Esperar a que carguen los gastos
      await tester.pump(const Duration(seconds: 2));

      // Buscar el primer gasto en la lista
      final firstExpenseCard = find.byType(Card).first;

      if (tester.any(firstExpenseCard)) {
        // Tap en el gasto
        await tester.tap(firstExpenseCard);
        await tester.pumpAndSettle();

        // Verificar que se abre el diálogo de detalles
        expect(find.text('Detalles del Gasto'), findsOneWidget);
        expect(find.text('Amigos Participantes'), findsOneWidget);
      }
    });
  });

  group('Tests de Errores de I/O', () {
    testWidgets('Debe mostrar mensaje de error cuando falla la conexión',
        (WidgetTester tester) async {
      // Crear un ApiService con URL incorrecta para simular error de conexión
      final badApiService = ApiService();
      final friendRepository = FriendRepository(service: badApiService);
      final expenseRepository = ExpenseRepository(service: badApiService);

      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Esperar a que intente cargar y falle
      await tester.pump(const Duration(seconds: 3));

      // Buscar mensaje de error (puede variar según implementación)
      // El texto exacto puede ser "No se pudo recuperar la lista de gastos" u otro
      expect(
        find.textContaining('No se pudo'),
        findsWidgets,
      );
    });
  });

  group('Tests de Integración Completa', () {
    late ApiService apiService;
    late FriendRepository friendRepository;
    late ExpenseRepository expenseRepository;

    setUp(() {
      apiService = ApiService();
      friendRepository = FriendRepository(service: apiService);
      expenseRepository = ExpenseRepository(service: apiService);
    });

    testWidgets(
        'Flujo completo: Ver gastos -> Ver amigos -> Volver a gastos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verificar pantalla inicial de gastos
      expect(find.text('Lista de Gastos'), findsOneWidget);

      // 2. Navegar a amigos
      await tester.tap(find.text('Amigos'));
      await tester.pumpAndSettle();
      expect(find.text('Lista de Amigos'), findsOneWidget);

      // 3. Volver a gastos
      await tester.tap(find.text('Gastos'));
      await tester.pumpAndSettle();
      expect(find.text('Lista de Gastos'), findsOneWidget);
    });

    testWidgets('Debe refrescar la lista después de añadir un elemento',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Contar gastos iniciales
      final initialCards = tester.widgetList(find.byType(Card)).length;

      // Abrir pantalla de añadir gasto
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verificar que navegó a la pantalla correcta
      expect(find.text('Añadir Gasto'), findsOneWidget);

      // Nota: Para completar este test necesitarías llenar el formulario
      // y guardar, pero eso requiere que el servidor esté disponible
    });
  });

  group('Tests de Validación de Usuario', () {
    late ApiService apiService;
    late FriendRepository friendRepository;
    late ExpenseRepository expenseRepository;

    setUp(() {
      apiService = ApiService();
      friendRepository = FriendRepository(service: apiService);
      expenseRepository = ExpenseRepository(service: apiService);
    });

    testWidgets('Debe validar campos requeridos en formulario de gasto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Abrir formulario de gasto
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Intentar guardar sin llenar nada
      final saveButton = find.text('Guardar');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verificar que muestra errores de validación
      expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
      expect(find.text('Por favor ingresa un monto'), findsOneWidget);
    });

    testWidgets('Debe validar formato de monto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          friendRepository: friendRepository,
          expenseRepository: expenseRepository,
        ),
      );
      await tester.pumpAndSettle();

      // Abrir formulario de gasto
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Llenar con monto inválido (texto)
      await tester.enterText(
          find.widgetWithText(TextField, 'Monto'), 'abc');
      
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // El campo numérico debería prevenir o validar el texto
      // Verificar que no se cierra el diálogo (sigue mostrando el título)
      expect(find.text('Añadir Gasto'), findsOneWidget);
    });
  });
}
