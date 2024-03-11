import 'package:flutter/material.dart';
import 'package:smartcook_cor/components/customfloatingactionbutton.dart';
import 'package:smartcook_cor/models/index.dart';
import 'package:smartcook_cor/recipe_repository.dart';
import 'package:smartcook_cor/screens/index.dart';

class IngredientSelectionScreen extends StatefulWidget {
  const IngredientSelectionScreen({super.key});

  @override
  _IngredientSelectionScreenState createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends State<IngredientSelectionScreen> {
  List<Recipe> recipes = [];
  String selectedCookingStyle = '';
  List<String> selectedIngredients = [];
  bool fuzzyChoice = true;

  List<String> vegetables = [
    '🥔 Potatoes',
    '🥕 Carrots',
    '🥦 Cauliflower',
    '🥣 White Radish',
    '🥒 Zucchini',
    '🍅 Tomatoes',
    '🥬 Celery',
    '🥒 Cucumbers',
    '🧅 Onions',
    '🎍 Lettuce',
    '🍲 Tofu',
    '🍄 Mushrooms',
    '🍆 Eggplant',
    '🥗 Napa Cabbage',
    '🥬 Cabbage',
  ];

  List<String> meats = [
    '🥓 Lunch Meat',
    '🌭 Sausage',
    '🐤 Chicken',
    '🐷 Pork',
    '🥚 Eggs',
    '🦐 Shrimp',
    '🐮 Beef',
    '🦴 Bones',
  ];

  List<String> stapleFoods = [
    '🍝 Pasta',
    '🍞 Bread',
    '🍚 Rice',
    '🍜 Instant Noodles',
  ];

  List<String> cookingStyles = [
    '🎛️ Oven',
    '🥘 Air Fryer',
    '📟 Microwave Oven',
    '🍚 Rice Cooker',
    '🍲 Large Pot',
  ];

  void _handleCookingStyleSelection(String item) {
    setState(() {
      if (selectedCookingStyle == item) {
        selectedCookingStyle =
            ''; // Deselect if the same item is selected again
      } else {
        selectedCookingStyle = item; // Select the new item
      }
    });
  }

  void _handleCategorySelection(String item, List<String> category) {
    setState(() {
      if (category.contains(item)) {
        if (selectedIngredients.contains(item)) {
          selectedIngredients.remove(item);
        } else {
          selectedIngredients.add(item);
        }
      }
    });
  }

  ButtonStyle _rectangularButtonStyle(
      Color backgroundColor, Color borderColor) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(backgroundColor),
      side: MaterialStateProperty.all(BorderSide(color: borderColor)),
      shape: MaterialStateProperty.all(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(10))), // This makes the button rectangular
      ),
    );
  }

  Widget _buildCategory(
    String title,
    List<String> items,
    Color selectedColor,
    Color unselectedColor,
    Color selectedTextColor,
    Color unselectedTextColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) {
            final bool isSelected = selectedIngredients.contains(item);

            return ElevatedButton(
              style: _rectangularButtonStyle(
                isSelected ? selectedColor : unselectedColor,
                borderColor,
              ),
              onPressed: () {
                _handleCategorySelection(item, items);
              },
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCookingStylesCategory(
    String title,
    List<String> items,
    Color selectedColor,
    Color unselectedColor,
    Color selectedTextColor,
    Color unselectedTextColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: cookingStyles.map((item) {
            final bool isSelected = selectedCookingStyle == item;
            return ElevatedButton(
              style: _rectangularButtonStyle(
                isSelected ? selectedColor : unselectedColor,
                borderColor,
              ),
              onPressed: () {
                _handleCookingStyleSelection(item);
              },
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected
                      ? const Color(0xFFe7e5e4)
                      : const Color(0xFF585655),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1, // Adjust the value to control the shadow depth
        automaticallyImplyLeading: false,
        title: const Text('🥘 Select Ingredients'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildCategory(
            '🥬 Vegetables',
            vegetables,
            const Color(0xFF5daa65),
            const Color(0xFFecfbef),
            Colors.white,
            const Color(0xFF306339),
            const Color(0xFFc7f5d3),
          ),
          _buildCategory(
            '🥩 Meat',
            meats,
            const Color(0xFFe0635d),
            const Color(0xFFfceeed),
            Colors.white,
            const Color(0xFF8c2822),
            const Color(0xFFf6cdcc),
          ),
          _buildCategory(
            '🍚 Staple Food',
            stapleFoods,
            const Color(0xFFe2b53e),
            const Color(0xFFfef9e0),
            Colors.white,
            const Color(0xFF8e6739),
            const Color(0xFFfcf097),
          ),
          _buildCookingStylesCategory(
            '🍳 Cooking Styles',
            cookingStyles,
            const Color(0xFF56534f),
            const Color(0xFFfdfdfd),
            Colors.white,
            const Color(0xFF585655),
            const Color(0xFFe7e5e4),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFloatingActionButton(
            onPressed: () {
              setState(() {
                selectedIngredients.clear();
                selectedCookingStyle = '';
              });
            },
            tooltip: 'Clear Selection',
            icon: Icons.clear,
          ),
          const SizedBox(height: 16.0),
          CustomFloatingActionButton(
            onPressed: () {
              if (selectedIngredients.isEmpty) {
                // Show an alert if no ingredients are selected
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Alert',
                        style: TextStyle(color: Color(0xFFA53328)),
                      ),
                      content: const Text(
                          'You didn\'t select any ingredients. Please choose ingredients to show the recipe～'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Navigate to the recipe page with selected ingredients
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecipePage(
                      selectedIngredients,
                      selectedCookingStyle,
                      RecipeRepository
                          .recipes, // Pass the list of recipes to RecipePage
                    ),
                  ),
                );
              }
            },
            tooltip: 'Get Recipe',
            icon: Icons.restaurant_menu,
          ),
        ],
      ),
    );
  }
}
