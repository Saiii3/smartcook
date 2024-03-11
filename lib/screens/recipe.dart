import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartcook_cor/models/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipePage extends StatefulWidget {
  final List<String> selectedIngredients;
  final String? selectedCookingStyle;
  final CollectionReference recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  RecipePage(
      this.selectedIngredients, this.selectedCookingStyle, List<Recipe> recipes,
      {Key? key})
      : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  String? localCookingStyle;
  String currentMode = 'Fuzzy Match'; // Default to Fuzzy Matching
  int minNumberOfRecipes = 1;
  List<Recipe> favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRecipesString = prefs.getStringList('favorites') ?? [];
    List<Recipe> loadedFavorites = favoriteRecipesString.map((recipeJson) {
      return Recipe.fromJson(json.decode(recipeJson));
    }).toList();

    setState(() {
      favoriteRecipes = loadedFavorites;
    });
  }

  //Fetch Recipe From FireStore
  Future<List<Recipe>> fetchRecipesFromFirestore() async {
    QuerySnapshot querySnapshot = await widget.recipesCollection.get();
    List<Recipe> recipes = [];

    for (var recipeDoc in querySnapshot.docs) {
      final data = recipeDoc.data() as Map<String, dynamic>?;

      if (data != null && data['cookingStyle'] != null) {
        Recipe recipe = Recipe(
          title: data['title'],
          ingredients: List<String>.from(data['ingredients']),
          cookingStyle: data['cookingStyle'],
          youtubeLink: data['youtubeLink'], id: '',
        );
        recipes.add(recipe);
      }
    }

    return recipes;
  }

  // Method to add recipe to favorites
  void _addToFavorites(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRecipesString = prefs.getStringList('favorites') ?? [];

    // Serialize the recipe to a JSON string
    String serializedRecipe = serializeRecipe(recipe);

    // Check if the serializedRecipe is not already in the list
    if (!favoriteRecipesString.contains(serializedRecipe)) {
      // Debug print to check the serialized string
      debugPrint('Serialized Recipe: $serializedRecipe');

      favoriteRecipesString.add(serializedRecipe);
      await prefs.setStringList('favorites', favoriteRecipesString);

      setState(() {
        favoriteRecipes.add(recipe);
      });
    } else {
      // Optionally show a message to the user that the recipe is already in favorites
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${recipe.title} is already in your favorites'),
        ),
      );
    }
  }

  String serializeRecipe(Recipe recipe) {
    final Map<String, dynamic> recipeMap = recipe.toJson();
    return json.encode(recipeMap);
  }

  //Filter Recipes
  List<Recipe> filterRecipes(List<Recipe> recipes, String mode) {
    switch (mode) {
      case 'Fuzzy Match':
        // Include the recipe if it contains any of the selected ingredients or matches the cooking style.
        return recipes.where((recipe) {
          bool containsAnyIngredients = widget.selectedIngredients.any(
            (ingredient) => recipe.ingredients.any(
              (rIngredient) => rIngredient
                  .toLowerCase()
                  .contains(ingredient.toLowerCase().trim()),
            ),
          );
          bool cookingStyleMatch = widget.selectedCookingStyle == null ||
              recipe.cookingStyle
                  .toLowerCase()
                  .contains(widget.selectedCookingStyle!.toLowerCase().trim());

          // Prioritize recipes that match the cooking style and contain at least one of the ingredients.
          return (cookingStyleMatch && containsAnyIngredients) ||
              (widget.selectedCookingStyle == null && containsAnyIngredients) ||
              (cookingStyleMatch && widget.selectedIngredients.isEmpty);
        }).toList();

      case 'Exact Match':
        // Include the recipe if it contains all of the selected ingredients and no more.
        return recipes.where((recipe) {
          bool containsAllIngredients = Set.from(widget.selectedIngredients)
              .difference(Set.from(recipe.ingredients))
              .isEmpty;
          bool containsNoExtraIngredients = Set.from(recipe.ingredients)
              .difference(Set.from(widget.selectedIngredients))
              .isEmpty;
          bool cookingStyleMatch = widget.selectedCookingStyle == null ||
              recipe.cookingStyle
                  .toLowerCase()
                  .contains(widget.selectedCookingStyle!.toLowerCase().trim());

          return containsAllIngredients &&
              containsNoExtraIngredients &&
              (widget.selectedCookingStyle == null || cookingStyleMatch);
        }).toList();

      case 'Survival Mode':
        // Include the recipe if it contains all of the ingredients and matches the cooking style (if selected).
        // In survival mode, the recipe must use only the ingredients that are selected.
        return recipes.where((recipe) {
          bool containsOnlySelectedIngredients =
              recipe.ingredients.every(widget.selectedIngredients.contains);
          bool cookingStyleMatch = widget.selectedCookingStyle == null ||
              recipe.cookingStyle
                  .contains(widget.selectedCookingStyle as Pattern);
          return containsOnlySelectedIngredients && cookingStyleMatch;
        }).toList();

      default:
        return recipes;
    }
  }

  //Drag Show Element
  Widget buildRecipeCard(Recipe recipe) {
    // Check if the recipe is already in the favorites
    bool isFavorite =
        favoriteRecipes.any((favRecipe) => favRecipe.title == recipe.title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            const Color(0xFFe5edf9),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Color(0xFFc4dafb)),
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.all(12.0),
          ),
        ),
        onPressed: () {
          launchUrl(Uri.parse(recipe.youtubeLink));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3b5bd4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.favorite,
              size: 25,
              color: isFavorite
                  ? Colors.red
                  : Colors
                      .grey[400], // Use a lighter grey to indicate non-favorite
            ),
          ],
        ),
      ),
    );
  }

  //Orange Three mode Button
  Widget buildModeButton(String mode) {
    bool isSelected = mode == currentMode;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentMode = mode;
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isSelected ? const Color(0xFFe87b35) : const Color(0xFFf7ece0),
        ),
        side: MaterialStateProperty.all(
          isSelected
              ? BorderSide.none
              : const BorderSide(color: Colors.transparent),
        ),
      ),
      child: Text(
        mode,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF994e33),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = [];

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          '🍲 Check out the recipes!',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: Column(
        children: [
          // Display selected ingredients and cooking style titles
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selectedIngredients.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Selected Ingredients:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (widget.selectedIngredients.isNotEmpty)
                  Wrap(
                    children: widget.selectedIngredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Chip(
                          label: Text(ingredient),
                        ),
                      );
                    }).toList(),
                  ),
                if (widget.selectedCookingStyle != null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Selected Cooking Style:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (widget.selectedCookingStyle != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      children: (widget.selectedCookingStyle ?? "")
                          .split(',')
                          .map((style) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Chip(
                            label: Text(style),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Show Mode Button
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildModeButton('Fuzzy Match'),
                const SizedBox(width: 6),
                buildModeButton('Exact Match'),
                const SizedBox(width: 6),
                buildModeButton('Survival Mode'),
              ],
            ),
          ),

          // Show matching recipes with draggable feature
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: fetchRecipesFromFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  recipes = snapshot.data!;
                  recipes = filterRecipes(recipes, currentMode);

                  if (recipes.isEmpty) {
                    return const Center(
                      child: Text('No matching recipes found.'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        Recipe recipe = recipes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: LongPressDraggable<Recipe>(
                            data: recipe,
                            dragAnchorStrategy: childDragAnchorStrategy,
                            feedback: Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // 80% of screen width
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFe1e4f0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  recipe.title,
                                  style: const TextStyle(
                                    color: Color(0xFF425acc),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            childWhenDragging: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey[300],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.kitchen,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            child: buildRecipeCard(recipe),
                          ),
                        );
                      },
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          // At the bottom of your recipe page layout
          Align(
            alignment: Alignment.bottomCenter,
            child: DragTarget<Recipe>(
              onWillAccept: (recipe) => true,
              onAccept: (recipe) {
                _addToFavorites(recipe);
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: candidateData.isEmpty
                      ? 70
                      : 120, // Expand when dragging over
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: candidateData.isEmpty
                        ? Colors.grey.shade200
                        : Colors.green.shade200,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      candidateData.isEmpty
                          ? 'Drag here to add to favorites'
                          : 'Release to add to favorites',
                      style: TextStyle(
                        color:
                            candidateData.isEmpty ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
