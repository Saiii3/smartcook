import 'package:flutter/material.dart';

class IngredientChip extends StatelessWidget {
  final String ingredient;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const IngredientChip({
    Key? key,
    required this.ingredient,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        ingredient,
        softWrap: true, // Allow the text to wrap onto multiple lines
        overflow: TextOverflow.visible, // Allow the text to be visible outside of the bounds of the chip
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: Colors.grey)),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 2.0), // Increase padding if needed to provide more space for the text
      labelStyle: isSelected
          ? const TextStyle(color: Colors.white)
          : const TextStyle(color: Colors.black),
    );
  }
}
