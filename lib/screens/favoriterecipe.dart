// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartcook_cor/models/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({Key? key}) : super(key: key);

  @override
  _FavoriteRecipesScreenState createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  List<Recipe> favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRecipesString = prefs.getStringList('favorites') ?? [];
    List<Recipe> loadedFavorites = [];

    for (String recipeString in favoriteRecipesString) {
      try {
        // Decode the JSON string to a Map before using `fromJson`
        final Map<String, dynamic> recipeMap = json.decode(recipeString);
        loadedFavorites.add(Recipe.fromJson(recipeMap));
      } catch (e) {
        // Handle the error or log it
        debugPrint('Error decoding Recipe: $e');
      }
    }

    setState(() {
      favoriteRecipes = loadedFavorites;
    });
  }

  String serializeRecipe(Recipe recipe) {
    final Map<String, dynamic> recipeMap = recipe.toJson();
    return json.encode(recipeMap);
  }

  void _confirmRemoveFromFavorites(Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Recipe'),
          content: Text(
              'Are you sure you want to remove ${recipe.title} from your favorites?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _removeFromFavorites(
                    recipe); // Proceed with removing the recipe
              },
            ),
          ],
        );
      },
    );
  }

  void _removeFromFavorites(Recipe recipe) async {
    setState(() {
      favoriteRecipes.remove(recipe);
    });
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRecipesString =
        favoriteRecipes.map((recipe) => serializeRecipe(recipe)).toList();
    await prefs.setStringList('favorites', favoriteRecipesString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        title: const Text('Favorite Recipes'),
      ),
      body: ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Card(
            margin: const EdgeInsets.all(6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                recipe.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                '${recipe.ingredients.join(', ')}, ${recipe.cookingStyle}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _confirmRemoveFromFavorites(recipe);
                },
              ),
              onTap: () {
                launchUrl(Uri.parse(recipe.youtubeLink));
              },
              contentPadding: const EdgeInsets.all(8),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
