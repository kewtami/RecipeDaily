import 'package:cloud_firestore/cloud_firestore.dart';

// Like Recipe
class RecipeLike {
  final String id;
  final String recipeId;
  final String userId;
  final DateTime createdAt;

  RecipeLike({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.createdAt,
  });

  factory RecipeLike.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeLike(
      id: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Saved Recipe
class SavedRecipe {
  final String id;
  final String recipeId;
  final String userId;
  final DateTime savedAt;

  SavedRecipe({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.savedAt,
  });

  factory SavedRecipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedRecipe(
      id: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      savedAt: (data['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}

/// Comment on Recipe
class RecipeComment {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecipeComment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
    this.updatedAt,
  });

  factory RecipeComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeComment(
      id: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userPhotoUrl: data['userPhotoUrl'],
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}