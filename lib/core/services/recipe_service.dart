import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloudinary_service.dart';
import 'dart:io';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // CREATE Recipe
  Future<String> createRecipe(RecipeModel recipe) async {
    try {
      final docRef = await _firestore.collection('recipes').add(recipe.toFirestore());
      print('Recipe created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print(' Error creating recipe: $e');
      rethrow;
    }
  }

  // READ Single Recipe
  Future<RecipeModel?> getRecipe(String recipeId) async {
    try {
      final doc = await _firestore.collection('recipes').doc(recipeId).get();
      if (!doc.exists) return null;
      return RecipeModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting recipe: $e');
      return null;
    }
  }

  // READ Multiple Recipes with Pagination
  Stream<List<RecipeModel>> getRecipes({
    int limit = 20,
    String? lastRecipeId,
  }) {
    Query query = _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastRecipeId != null) {
      query = query.startAfterDocument(
        _firestore.collection('recipes').doc(lastRecipeId).snapshots() as DocumentSnapshot,
      );
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();
    });
  }

  // READ User's Recipes
  Stream<List<RecipeModel>> getUserRecipes(String userId) {
    return _firestore
        .collection('recipes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();
    });
  }

  // UPDATE Recipe
  Future<void> updateRecipe(String recipeId, RecipeModel recipe) async {
    try {
      await _firestore.collection('recipes').doc(recipeId).update(
            recipe.toFirestore(),
          );
      print('Recipe updated: $recipeId');
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }

  // DELETE Recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      // Get recipe first to delete associated images
      final recipe = await getRecipe(recipeId);
      
      if (recipe != null) {
        // Delete cover image
        if (recipe.coverImageUrl != null) {
          await _deleteImageFromUrl(recipe.coverImageUrl!);
        }
        
        // Delete step images
        for (var step in recipe.steps) {
          if (step.imageUrl != null) {
            await _deleteImageFromUrl(step.imageUrl!);
          }
        }
      }

      // Delete recipe document
      await _firestore.collection('recipes').doc(recipeId).delete();
      print('Recipe deleted: $recipeId');
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }

  // SEARCH Recipes
  Stream<List<RecipeModel>> searchRecipes(String query) {
    return _firestore
        .collection('recipes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();
    });
  }

  // LIKE Recipe
  Future<void> likeRecipe(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final recipeRef = _firestore.collection('recipes').doc(recipeId);
        final likeRef = _firestore.collection('likes').doc('${userId}_$recipeId');

        final recipeDoc = await transaction.get(recipeRef);
        final likeDoc = await transaction.get(likeRef);

        if (likeDoc.exists) {
          // Unlike
          transaction.delete(likeRef);
          transaction.update(recipeRef, {
            'likesCount': (recipeDoc.data()?['likesCount'] ?? 1) - 1,
          });
        } else {
          // Like
          transaction.set(likeRef, {
            'userId': userId,
            'recipeId': recipeId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(recipeRef, {
            'likesCount': (recipeDoc.data()?['likesCount'] ?? 0) + 1,
          });
        }
      });
    } catch (e) {
      print('Error liking recipe: $e');
      rethrow;
    }
  }

  // Check if user liked recipe
  Future<bool> isRecipeLiked(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('likes')
          .doc('${userId}_$recipeId')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // UPLOAD Image
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final url = await _cloudinaryService.uploadImage(
        imageFile: imageFile,
        folder: path,
      );
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // DELETE Image from URL
  Future<void> _deleteImageFromUrl(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      if (segments.length < 3) return;

      final publicIdWithExtension = segments.sublist(2).join('/').split('.').first;
      final publicId = publicIdWithExtension;

      final success = await _cloudinaryService.deleteMedia(publicId);
      if (success) {
        print('Image deleted: $publicId');
      } else {
        print('Failed to delete image: $publicId');
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Get Recipe Comments
  Stream<List<Comment>> getComments(String recipeId) {
    return _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();
    });
  }

  // Add Comment
  Future<void> addComment(String recipeId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userPhotoUrl': user.photoURL,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }
}

// Comment Model
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userPhotoUrl: data['userPhotoUrl'],
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}