import 'package:expense_pro/models/category_model.dart';
import 'package:expense_pro/models/expense_model.dart';
import 'package:expense_pro/screens/home_screen.dart';
import 'package:expense_pro/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Later: register adapters here
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());

  await HiveService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Pro',
      // theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      themeMode: ThemeMode.system, // <-- auto light/dark
      // theme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.light,
      //   primarySwatch: Colors.blue,
      //   scaffoldBackgroundColor: Colors.grey.shade50,
      //   floatingActionButtonTheme: const FloatingActionButtonThemeData(
      //     backgroundColor: Colors.blue,
      //   ),
      // ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.dark,
      //   primarySwatch: Colors.blue,
      //   scaffoldBackgroundColor: Colors.black,
      //   floatingActionButtonTheme: const FloatingActionButtonThemeData(
      //     backgroundColor: Colors.blueAccent,
      //   ),
      // ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Same seed, different brightness
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}
