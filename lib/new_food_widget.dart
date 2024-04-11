import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calorie_tracker/food.dart';
import 'main.dart';

// Клас, що дозволяє користувачеві додавати нові записи про їжу
class NewFoodWidget extends StatefulWidget {
  const NewFoodWidget({Key? key}) : super(key: key);

  @override
  State<NewFoodWidget> createState() => NewFoodState();
}

class NewFoodState extends State<NewFoodWidget> {
  // Зображення за замовчуванням для нової страви
  static ImageProvider image = const AssetImage("assets/burger.png");
  // Файл зображення для вибраної страви
  static late File imageFile;
  static late BuildContext buildContext;
  // Прапорець, що показує, чи ініціалізоване зображення
  static bool imageInited = false;
  // Контролери для введення даних про нову страву
  static TextEditingController proteinController = TextEditingController(),
      carbController = TextEditingController(),
      fatController = TextEditingController(),
      nameController = TextEditingController(),
      calorieController = TextEditingController();
  // Метод для отримання текстового поля вводу
  Widget getInputField(String label, TextEditingController controller,
      {bool isnumber = true}) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        keyboardType: isnumber ? TextInputType.number : TextInputType.text);
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return Stack(
      children: [
        Positioned(
            top: 50,
            left: 10,
            child:
            Image(image: image, width: 150, height: 150, fit: BoxFit.fill)),
        Positioned(
            top: 200,
            left: 45,
            child: TextButton(
              onPressed: () => addImagePressed(),
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.amber[900]!),
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white)),
              child: const Text("Add Image"),
            )),
        Positioned(
            top: 60,
            left: 180,
            width: 140,
            height: 50,
            child: getInputField("Name", nameController, isnumber: false)),
        Positioned(
            left: 180,
            top: 120,
            width: 100,
            height: 50,
            child: getInputField("Calories", calorieController)),
        Positioned(
            left: 180,
            top: 170,
            width: 100,
            height: 50,
            child: getInputField("🥩", proteinController)),
        Positioned(
            left: 180,
            top: 220,
            width: 100,
            height: 50,
            child: getInputField("🥔", carbController)),
        Positioned(
            left: 180,
            top: 270,
            width: 100,
            height: 50,
            child: getInputField("🧀", fatController)),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton(
                  onPressed: addFoodPressed, child: const Icon(Icons.check)),
            ))
      ],
    );
  }

  // Метод, що викликається при натисканні кнопки для додавання страви
  void addFoodPressed() async {
    final manager = ScaffoldMessenger.of(buildContext);
    // Показати сповіщення користувачеві, якщо не всі поля заповнені
    if (proteinController.text == "" ||
        carbController.text == "" ||
        fatController.text == "" ||
        nameController.text == "" ||
        calorieController.text == "") {
      manager.showSnackBar(
          const SnackBar(content: Text("Please fill in all the inputs above")));
      return;
    }
    // Отримати значення введених даних та перевірити їхню коректність
    double? protein = double.tryParse(proteinController.text);
    double? carbs = double.tryParse(carbController.text);
    double? fat = double.tryParse(fatController.text);
    double? calories = double.tryParse(calorieController.text);
    if (calories == null || protein == null || fat == null || carbs == null) {
      manager.showSnackBar(const SnackBar(content: Text("Only numbers")));
      return;
    }
    String name = nameController.text;
    if (imageInited) {
      String path = await getFilePath(name + extension(imageFile.path));
      imageFile = await imageFile.copy(path);
    }
    // Створення нового об'єкта страви
    Food newFood = Food(
        imagefile: (imageInited ? basename(imageFile.path) : "none"),
        name: name,
        macros: MacroNutrients(
            protein: protein,
            fat: fat,
            carbohidrates: carbs,
            calories: calories));
    for (int i = 0; i < Foods.length; i++) {
      if (Foods[i].name == name) {
        Foods.removeAt(i);
        break;
      }
    }
    // Додати нову страву в список і зберегти його
    Foods.add(newFood);
    saveFoods();
    // Показати сповіщення користувачеві про успішне додавання страви
    manager.showSnackBar(const SnackBar(content: Text("Food added")));
  }

  // Метод, що викликається при натисканні кнопки для додавання зображення страви
  void addImagePressed() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (photo != null) {
        imageFile = File(photo.path);
        image = FileImage(imageFile);
        imageInited = true;
      }
    });
  }
}
