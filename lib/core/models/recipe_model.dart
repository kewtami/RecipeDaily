class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> images;
  final int cookingTime;
  final String difficulty;
  final String authorId;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.images,
    required this.cookingTime,
    required this.difficulty,
    required this.authorId,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      cookingTime: map['cookingTime'] ?? 0,
      difficulty: map['difficulty'] ?? 'Medium',
      authorId: map['authorId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'images': images,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}