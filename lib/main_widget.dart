import 'package:flutter/material.dart';
import 'package:calorie_tracker/food_widget.dart';
import 'package:calorie_tracker/new_food_widget.dart';
import 'package:calorie_tracker/today_widget.dart';

/// Головний віджет, який відображає головний екран додатка з нижньою панеллю навігації
class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => MainWidgetState();
}

/// Становий клас для `MainWidget`
class MainWidgetState extends State<MainWidget> {
  /// Індекс вибраного екрану у нижній панелі навігації
  static int bottomBarSelectedIndex = 0;

  /// Список віджетів для кожного екрану у нижній панелі навігації.
  static const List<StatefulWidget> widgets = <StatefulWidget>[
    FoodWidget(),
    TodayWidget(),
    NewFoodWidget()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgets[bottomBarSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // Змінює вибраний екран у нижній панелі навігації
      onTap: (int value) => setState(() {
          bottomBarSelectedIndex = value;
        }),
        currentIndex: bottomBarSelectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: "Foods"),
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "New Food")
        ],
        selectedItemColor: Colors.amber[900],
      ),
    );
  }
}
