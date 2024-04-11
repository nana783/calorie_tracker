import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calorie_tracker/add_log_widget.dart';
import 'package:calorie_tracker/food_log.dart';
import 'main.dart';
import 'dart:convert';

// Клас, який відображає інформацію про їжу та дозволяє користувачеві додавати записи про прийом їжі.
class TodayWidget extends StatefulWidget {
  const TodayWidget({Key? key}) : super(key: key);

  @override
  State<TodayWidget> createState() => TodayWidgetState();
}

class TodayWidgetState extends State<TodayWidget> {
  // Контролер для введення цілей калорій на день
  TextEditingController calorieGoalController = TextEditingController();
  late Widget selectedWidget;
  // Прапорець, що показує, чи відображається меню додавання нової страви
  bool inAddMenu = false;

  // Метод для отримання віджета при відсутності доданої інформації про страви
  Widget getOffDayWidget() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 100, right: 100, top: 200),
            child: TextField(
                controller: calorieGoalController,
                decoration: const InputDecoration(
                  labelText: "Calories",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
          TextButton(
              onPressed: () {
                if (calorieGoalController.text == "") return;
                preferenceInstance.setBool("onday", true);
                preferenceInstance.setInt(
                    "caloriegoal", int.parse(calorieGoalController.text));
                preferenceInstance.setInt(
                    "caloriesleft", int.parse(calorieGoalController.text));
                preferenceInstance.setString("todaylog", '[]');
                setState(() {
                  selectedWidget = getOnDayWidget();
                });
              },
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.amber[900]!),
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white)),
              child: const Text("Start"))
        ],
      ),
    );
  }

  // Метод для отримання віджета з відображенням інформації про прийом їжі під час активного дня
  Widget getOnDayWidget() {
    String? foodsJson = preferenceInstance.getString("todaylog");
    // Стек віджетів, що містить список записів про прийом їжі, кнопки для додавання нової страви
    // та завершення дня, а також відображення залишкових калорій та макронутрієнтів
    List<Widget> logWidgets = <Widget>[];
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    int caloriesLeft = preferenceInstance.getInt("caloriesleft")!;
    int caloriesMax = preferenceInstance.getInt("caloriegoal")!;
    if (foodsJson != null) {
      logWidgets.add(const Padding(padding: EdgeInsets.only(top: 30)));
      Iterable l = json.decode(foodsJson);
      l.forEach(((element) {
        var log = FoodLog.fromJson(element);
        var macros = log.calculateMacros();
        protein += macros.protein;
        fat += macros.fat;
        carbs += macros.carbohidrates;
        logWidgets.add(log.getLogWidget());
      }));
      logWidgets.add(const Padding(padding: EdgeInsets.only(bottom: 100)));
    }
    return Stack(
      children: [
        logWidgets.isEmpty
            ? const Align(
            alignment: Alignment.topCenter,
            child: Text("No food added yet"))
            : ListView(children: logWidgets),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () {
                  inAddMenu = true;
                  setState(() {
                    selectedWidget = AddLogWidget(closeCallback: () {
                      setState(() {
                        inAddMenu = false;
                      });
                    });
                  });
                },
                child: const Icon(Icons.add),
              ),
            )),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    AlertDialog dialog = AlertDialog(
                      title: const Text("Are you sure you want to end the day"),
                      content: const Text("Yes or no"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                preferenceInstance.setBool("onday", false);
                                preferenceInstance.setString("todaylog", '[]');
                              });
                            },
                            child: const Text("Yes")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("No"))
                      ],
                    );
                    showDialog(context: context, builder: (_) => dialog);
                  });
                },
                child: const Icon(Icons.check),
              )),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blueAccent[400]),
              height: 50,
              width: 250,
              child: Column(
                children: [
                  Text("Calories left: $caloriesLeft",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "🥩${protein.toStringAsFixed(2)}g",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "🥔${carbs.toStringAsFixed(2)}g",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "🧀${fat.toStringAsFixed(2)}g",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ])
                ],
              )),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Отримання інформації про активний день
    bool onday = preferenceInstance.getBool("onday") ?? false;
    // Вибір відповідного віджета в залежності від стану дня (активний або неактивний)
    if (!inAddMenu) {
      selectedWidget = onday ? getOnDayWidget() : getOffDayWidget();
    }
    return Padding(
        padding: const EdgeInsets.only(top: 50), child: selectedWidget);
  }
}
