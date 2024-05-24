// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:smartcook_cor/models/index.dart';
// Import Firebase if you're using it
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartcook_cor/screens/index.dart';

class ManageRecipesScreen extends StatefulWidget {
  const ManageRecipesScreen({Key? key}) : super(key: key);

  @override
  _ManageRecipesScreenState createState() => _ManageRecipesScreenState();
}

class _ManageRecipesScreenState extends State<ManageRecipesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Recipe> recipes = [];
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

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final QuerySnapshot snapshot = await _firestore.collection('recipes').get();
    final List<Recipe> loadedRecipes = snapshot.docs.map((doc) {
      // Use the data() method to get the data as a map
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Pass the document ID as well
      return Recipe.fromSnapshot(data, doc.id);
    }).toList();
    setState(() {
      recipes = loadedRecipes;
    });
  }

  void _addNewRecipe() {
    // Navigate to the screen to add a new recipe
    // Pass a callback function to reload recipes after adding
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditRecipeScreen(
          onSave: _loadRecipes,
          vegetables: vegetables, // Make sure this is populated
          meats: meats, // Make sure this is populated
          stapleFoods: stapleFoods, // Make sure this is populated
        ),
      ),
    );
  }

  void _editRecipe(Recipe recipe) {
    // Navigate to the screen to edit the recipe
    // Pass the recipe to be edited and a callback function to reload recipes after editing
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditRecipeScreen(
          recipe: recipe,
          onSave: _loadRecipes,
          vegetables: vegetables,
          meats: meats,
          stapleFoods: stapleFoods,
        ),
      ),
    );
  }

  Future<void> _deleteRecipe(String recipeId) async {
    // Use the recipeId to delete the recipe
    await _firestore.collection('recipes').doc(recipeId).delete();
    _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          // Clean up the ingredients list to remove any empty strings or null values
          final ingredientsList = recipe.ingredients
              .where((ingredient) => ingredient.isNotEmpty)
              .toList();
          // Join the cleaned list with commas
          final ingredientsText = ingredientsList.join(', ');

          return ListTile(
            title: Text(recipe.title),
            subtitle: Text('Ingredients: $ingredientsText'),
            onTap: () {
              // Navigate to RecipeDetailViewScreen with the selected recipe
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecipeDetailViewScreen(recipe: recipe),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editRecipe(recipe),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRecipe(recipe.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecipe,
        child: const Icon(Icons.add),
      ),
    );
  }
}
