import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartcook_cor/models/index.dart';

class EatWhatScreen extends StatefulWidget {
  const EatWhatScreen({Key? key}) : super(key: key);

  @override
  _EatWhatScreenState createState() => _EatWhatScreenState();
}

class _EatWhatScreenState extends State<EatWhatScreen> {
  int selectedNumber = 1;
  List<Recipe> randomRecipes = [];

  Future<List<Recipe>> fetchRandomRecipesFromFirestore(
      int numberOfRecipes) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('recipes').get();

    List<QueryDocumentSnapshot> allRecipes = querySnapshot.docs;
    List<Recipe> recipes = [];

    if (allRecipes.length <= numberOfRecipes) {
      for (var recipeDoc in allRecipes) {
        String? cookingStyle = recipeDoc['cookingStyle'] as String?;
        if (cookingStyle != null) {
          Recipe recipe = Recipe(
            id: recipeDoc['id'],
            title: recipeDoc['title'],
            ingredients: List<String>.from(recipeDoc['ingredients']),
            cookingStyle: cookingStyle,
            youtubeLink: recipeDoc['youtubeLink'],
          );
          recipes.add(recipe);
        }
      }
    } else {
      // Generate random indices to select unique recipes
      Set<int> randomIndices = Set();
      while (randomIndices.length < numberOfRecipes) {
        randomIndices.add(Random().nextInt(allRecipes.length));
      }

      for (int index in randomIndices) {
        var recipeDoc = allRecipes[index];
        String? cookingStyle = recipeDoc['cookingStyle'] as String?;
        if (cookingStyle != null) {
          Recipe recipe = Recipe(
            title: recipeDoc['title'],
            ingredients: List<String>.from(recipeDoc['ingredients']),
            cookingStyle: cookingStyle,
            youtubeLink: recipeDoc['youtubeLink'], id: '',
          );
          recipes.add(recipe);
        }
      }
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        automaticallyImplyLeading: false,
        title: const Text('Today Eat What'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (selectedNumber > 1) {
                        selectedNumber--;
                      }
                    });
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(7.0),
                    decoration: const ShapeDecoration(
                      color: Color(0xFFdc754e),
                      shape: CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  selectedNumber.toString(),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedNumber++;
                    });
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(7.0),
                    decoration: const ShapeDecoration(
                      color: Color(0xFFdc754e),
                      shape: CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                onPressed: () async {
                  if (selectedNumber < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Number of recipes should be at least 1.'),
                      ),
                    );
                    return;
                  }

                  List<Recipe> newRecipes =
                      await fetchRandomRecipesFromFirestore(selectedNumber);

                  setState(() {
                    randomRecipes = newRecipes;
                  });
                },
                icon: const Icon(Icons.sync),
                label: const Text('Randomize'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: randomRecipes.map((recipe) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe5edf9),
                      side: const BorderSide(color: Color(0xFFc4dafb)),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse(recipe.youtubeLink));
                    },
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3b5bd4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
