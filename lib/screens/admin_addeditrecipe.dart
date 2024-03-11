// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:smartcook_cor/models/index.dart';
// Import Firebase if you're using it
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/ingredientchips.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  final VoidCallback onSave;
  final List<String> vegetables;
  final List<String> meats;
  final List<String> stapleFoods;

  const AddEditRecipeScreen({
    Key? key,
    this.recipe,
    required this.onSave,
    required this.vegetables,
    required this.meats,
    required this.stapleFoods,
  }) : super(key: key);

  @override
  _AddEditRecipeScreenState createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _youtubeLinkController;
  bool _isFavorited = false;

  List<String> selectedIngredients = [];
  String? selectedCookingStyle;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe?.title ?? '');
    _youtubeLinkController =
        TextEditingController(text: widget.recipe?.youtubeLink ?? '');
    _isFavorited = widget.recipe?.isFavorited ?? false;
    selectedIngredients = widget.recipe?.ingredients ?? [];
    selectedCookingStyle = widget.recipe?.cookingStyle ?? '';
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text.trim();

      Recipe recipe = Recipe(
        id: widget.recipe?.id ?? '',
        title: title,
        ingredients: selectedIngredients,
        cookingStyle: selectedCookingStyle ?? 'Default',
        youtubeLink: _youtubeLinkController.text.trim(),
        isFavorited: _isFavorited,
      );

      if (widget.recipe == null) {
        await _firestore.collection('recipes').add(recipe.toJson());
        // Navigate back to AdminManageRecipePage after adding the recipe
        Navigator.of(context)
            .pop(); // This will take you back to the previous screen
      } else {
        await _firestore
            .collection('recipes')
            .doc(recipe.id)
            .update(recipe.toJson());
        Navigator.of(context).pop(); // Also navigate back after updating
      }
      widget.onSave();
    }
  }

  List<String> availableCookingStyles = [
    '🎛️ Oven',
    '🥘 Air Fryer',
    '📟 Microwave Oven',
    '🍚 Rice Cooker',
    '🍲 Large Pot',
  ];

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

  String? selectedVegetable;
  String? selectedMeat;
  String? selectedStapleFood;

// Call `updateTitle` whenever an ingredient or cooking style is selected or deselected

  Widget _buildSelectedIngredientsChips() {
    // This method will build the chips for selected ingredients
    // It should be called in the build method to display the chips
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: selectedIngredients.map((ingredient) {
        return Chip(
          label: Text(ingredient),
          onDeleted: () {
            setState(() {
              selectedIngredients.remove(ingredient);
            });
          },
        );
      }).toList(),
    );
  }

  // Updated UI for ingredient selection
  Widget _buildIngredientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Ingredients',
            style: Theme.of(context).textTheme.titleLarge),
        _buildIngredientGrid(widget.vegetables, 'Vegetables'),
        _buildIngredientGrid(widget.meats, 'Meats'),
        _buildIngredientGrid(widget.stapleFoods, 'Staple Foods'),
      ],
    );
  }

  // Modify the _buildIngredientGrid method
  Widget _buildIngredientGrid(List<String> ingredients, String category) {
    return Theme(
      data: Theme.of(context).copyWith(
          dividerColor:
              Colors.transparent), // This will remove the divider lines
      child: ExpansionTile(
        title: Text(category),
        initiallyExpanded: true,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Keeping the cross axis count to 3
              childAspectRatio:
                  5 / 1, // Adjusted child aspect ratio for balance
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return IngredientChip(
                ingredient: ingredient,
                isSelected: selectedIngredients.contains(ingredient),
                onSelected: (isSelected) {
                  setState(() {
                    isSelected
                        ? selectedIngredients.add(ingredient)
                        : selectedIngredients.remove(ingredient);
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: TextStyle(fontSize: 20),
          ),
          style: const TextStyle(fontSize: 18),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCookingStyleChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Select Cooking Style:',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: availableCookingStyles.map((style) {
            return ChoiceChip(
              label: Text(style),
              selected: selectedCookingStyle == style,
              onSelected: (bool selected) {
                setState(() {
                  selectedCookingStyle = selected ? style : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYouTubeLinkInput() {
    return TextFormField(
      controller: _youtubeLinkController,
      decoration: const InputDecoration(
        labelText: 'YouTube Link',
        prefixIcon: Icon(Icons.link),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(fontSize: 20),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a YouTube link';
        }
        // Add any additional validation for URLs if needed
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleInput(),
              const SizedBox(height: 20),
              _buildIngredientSelection(),
              const SizedBox(height: 20),
              _buildSelectedIngredientsChips(),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              Text('Cooking Style',
                  style: Theme.of(context).textTheme.titleLarge),
              _buildCookingStyleChips(),
              const SizedBox(height: 20),
              _buildYouTubeLinkInput(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: Text(
                    widget.recipe == null ? 'Add Recipe' : 'Update Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _titleController.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
  }
}
