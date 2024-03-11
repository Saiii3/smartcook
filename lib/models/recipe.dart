class Recipe {
  final String id; // Add an id field to store the Firestore document ID
  final String title;
  final List<String> ingredients;
  final String cookingStyle;
  final String youtubeLink;
  bool isFavorited;

  Recipe({
    required this.id, // Make sure to require the id in the constructor
    required this.title,
    required this.ingredients,
    required this.cookingStyle,
    required this.youtubeLink,
    this.isFavorited = false,
  });

  // Constructor to create a Recipe from a Firestore document snapshot
  Recipe.fromSnapshot(Map<String, dynamic> snapshot, this.id)
      : title = snapshot['title'],
        ingredients = List<String>.from(snapshot['ingredients']),
        cookingStyle = snapshot['cookingStyle'],
        youtubeLink = snapshot['youtubeLink'],
        isFavorited = snapshot['isFavorited'] ??
            false; // Handle the case where it might not be set

  // Add a fromJson constructor
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ??
          'default-id', // Provide a default value or handle it as nullable
      title: json['title'] ?? 'Default Title',
      ingredients:
          List<String>.from(json['ingredients'] as List<dynamic>? ?? []),
      cookingStyle: json['cookingStyle'] ?? 'Default Cooking Style',
      youtubeLink: json['youtubeLink'] ?? '',
      isFavorited: json['isFavorited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // You typically don't need to include the id in the JSON for Firestore
      'title': title,
      'ingredients': ingredients,
      'cookingStyle': cookingStyle,
      'youtubeLink': youtubeLink,
      'isFavorited': isFavorited, // Include the new field
    };
  }

  // Method to toggle the favorite status
  void toggleFavorite() {
    isFavorited = !isFavorited;
  }
}
