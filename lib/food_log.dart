import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorie_tracker/food.dart';
import 'main.dart';

/// Клас FoodLog представляє запис про споживану страву
class FoodLog {
  /// Назва страви
  late String foodName;
  /// Вага в грамах
  late int grams;
  /// Година та хвилина споживання
  late int hour, minute;

  /// Конструктор, що створює об'єкт FoodLog з JSON об'єкта
  FoodLog({required this.grams, required this.foodName});

  /// Конструктор з JSON об'єкта
  FoodLog.fromJson(Map<String, dynamic> json)
      : foodName = json['name'],
        grams = json['grams'],
        hour = json['hour'],
        minute = json['minute'];

  /// Перетворення в JSON об'єкт
  Map<String, dynamic> toJson() =>
      {'name': foodName, 'grams': grams, 'hour': hour, 'minute': minute};

  /// Метод для обчислення макронутрієнтів страви.
  MacroNutrients calculateMacros() {
    double protein = -1; // Білки.
    double carbs = 0; // Вуглеводи.
    double fat = 0; // Жири.
    double calories = 0; // Калорії.
    for (int i = 0; i < Foods.length; i++) {
      if (Foods[i].name == foodName) { // Пошук страви в списку Foods
        double foodRatio = grams.toDouble() / 100.0; // Відсоток грам у вагу страви
        protein = Foods[i].macros.protein * foodRatio; // Розрахунок білків
        carbs = Foods[i].macros.carbohidrates * foodRatio; // Розрахунок вуглеводів
        fat = Foods[i].macros.fat * foodRatio; // Розрахунок жирів
        calories = Foods[i].macros.calories * foodRatio; // Розрахунок калорій
        return MacroNutrients(
            calories: calories,
            protein: protein,
            carbohidrates: carbs,
            fat: fat); // Повернення об'єкта з макронутрієнтами
      }
    }
    return MacroNutrients(
        calories: -1, protein: -1, carbohidrates: -1, fat: -1); // Повернення значень за відсутності страви в списку.
  }

  /// Метод для отримання віджета запису про споживану страву.
  Widget getLogWidget() {
    var macros = calculateMacros(); // Обчислення макронутрієнтів страви.
    if (macros.protein == -1) {
      // Перевірка наявності страви в списку.
      return Text('Food $foodName not found'); // Виведення повідомлення, якщо страва не знайдена.
    }
    // Побудова віджета для відображення запису про споживану страву.
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.amber[900],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            // Відображення назви страви та грам у віджеті.
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "$foodName(${grams}g)",
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Відображення години та хвилини споживання страви.
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "${hour < 10 ? "0$hour" : hour.toString()}:${minute < 10 ? "0$minute" : minute.toString()}",
                  style: GoogleFonts.mukta(color: Colors.white),
                ),
              ),
            ),
            // Відображення кількості калорій.
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "${macros.calories.toStringAsFixed(2)}cal",
                  style: GoogleFonts.mukta(color: Colors.white),
                ),
              ),
            ),
            // Відображення макронутрієнтів (білки, вуглеводи, жири).
            Positioned(
              top: 20,
              width: 350,
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                children: [
                  Text(
                    "🥩${macros.protein.toStringAsFixed(2)}", // Білки.
                    style: GoogleFonts.bebasNeue(color: Colors.white),
                  ),
                  Text(
                    "🥔${macros.carbohidrates.toStringAsFixed(2)}", // Вуглеводи.
                    style: GoogleFonts.bebasNeue(color: Colors.white),
                  ),
                  Text(
                    "🧀${macros.fat.toStringAsFixed(2)}", // Жири.
                    style: GoogleFonts.bebasNeue(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
