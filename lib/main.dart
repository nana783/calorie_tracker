import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_widget.dart';
import 'food.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Список об'єктів для зберігання інформації про їжу.
List<Food> Foods = [];

/// Об'єкт для доступу до спільних налаштувань.
late SharedPreferences preferenceInstance;

/// Функція для збереження списку їжі в спільних налаштуваннях.
void saveFoods() {
  preferenceInstance.setString("foods", jsonEncode(Foods));
}
/// Головна функція додатка.
void main() async {
  runApp(const MyApp());

  // Ініціалізуємо об'єкт preferenceInstance для роботи зі спільними налаштуваннями.
  preferenceInstance = await SharedPreferences.getInstance();

  // Отримуємо збережений список їжі та розпаковуємо його, якщо він існує.
  String? foodsJson = preferenceInstance.getString("foods");
  Foods = <Food>[];
  if (foodsJson != null) {
    Iterable l = json.decode(foodsJson);
    Foods = List<Food>.from(l.map((model) => Food.fromJson(model)));
  } else {
    Foods = [];
  }
}

/// Головний клас додатка.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    // Встановлюємо колір панелі.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.amber[900],
    ));
    // Повертаємо основний віджет додатка.
    return const MaterialApp(home: MainWidget());
  }
}
