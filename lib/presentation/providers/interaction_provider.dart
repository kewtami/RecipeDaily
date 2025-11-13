import 'package:flutter/foundation.dart';
import '../../core/services/interaction_service.dart';
import '../../core/models/interaction_models.dart';

class InteractionProvider extends ChangeNotifier {
  final InteractionService _service = InteractionService();

  // Liked recipes cache
  Set<String> _likedRecipeIds = {};
  Set<String> get likedRecipeIds => _likedRecipeIds;

  // Saved recipes cache
  Set<String> _savedRecipeIds = {};
  Set<String> get savedRecipeIds => _savedRecipeIds;

  // Comments cache
  Map<String, List<RecipeComment>> _commentsCache = {};
  
  // Loading states
  bool _isTogglingLike = false;
  bool _isTogglingSave = false;
  bool _isAddingComment = false;

  bool get isTogglingLike => _isTogglingLike;
  bool get isTogglingSave => _isTogglingSave;
  bool get isAddingComment => _isAddingComment;

  // ==================== LIKES ====================

  // Subscribe to user's liked recipes
  void subscribeToLikedRecipes(String userId) {
    _service.getLikedRecipeIds(userId).listen((likedIds) {
      _likedRecipeIds = Set.from(likedIds);
      notifyListeners();
    });
  }

  // Check if recipe is liked
  bool isRecipeLiked(String recipeId) {
    return _likedRecipeIds.contains(recipeId);
  }

  // Toggle like on a recipe
  Future<void> toggleLike(String recipeId, String userId) async {
    if (_isTogglingLike) return;

    _isTogglingLike = true;
    notifyListeners();

    try {
      // Optimistic update
      final wasLiked = _likedRecipeIds.contains(recipeId);
      if (wasLiked) {
        _likedRecipeIds.remove(recipeId);
      } else {
        _likedRecipeIds.add(recipeId);
      }
      notifyListeners();

      // Actual update
      await _service.toggleLike(recipeId, userId);
    } catch (e) {
      // Revert on error
      final wasLiked = _likedRecipeIds.contains(recipeId);
      if (wasLiked) {
        _likedRecipeIds.remove(recipeId);
      } else {
        _likedRecipeIds.add(recipeId);
      }
      notifyListeners();
      rethrow;
    } finally {
      _isTogglingLike = false;
      notifyListeners();
    }
  }

  // ==================== SAVED RECIPES ====================

  // Subscribe to user's saved recipes
  void subscribeToSavedRecipes(String userId) {
    _service.getSavedRecipeIds(userId).listen((savedIds) {
      _savedRecipeIds = Set.from(savedIds);
      notifyListeners();
    });
  }

  // Check if recipe is saved
  bool isRecipeSaved(String recipeId) {
    return _savedRecipeIds.contains(recipeId);
  }

  // Toggle save on a recipe
  Future<void> toggleSave(String recipeId, String userId) async {
    if (_isTogglingSave) return;

    _isTogglingSave = true;
    notifyListeners();

    try {
      // Optimistic update
      final wasSaved = _savedRecipeIds.contains(recipeId);
      if (wasSaved) {
        _savedRecipeIds.remove(recipeId);
      } else {
        _savedRecipeIds.add(recipeId);
      }
      notifyListeners();

      // Actual update
      await _service.toggleSave(recipeId, userId);
    } catch (e) {
      // Revert on error
      final wasSaved = _savedRecipeIds.contains(recipeId);
      if (wasSaved) {
        _savedRecipeIds.remove(recipeId);
      } else {
        _savedRecipeIds.add(recipeId);
      }
      notifyListeners();
      rethrow;
    } finally {
      _isTogglingSave = false;
      notifyListeners();
    }
  }

  // ==================== COMMENTS ====================
  
  // Subscribe to comments for a recipe
  void subscribeToComments(String recipeId) {
    _service.getComments(recipeId).listen((comments) {
      _commentsCache[recipeId] = comments;
      notifyListeners();
    });
  }

  // Get comments for a recipe
  List<RecipeComment> getComments(String recipeId) {
    return _commentsCache[recipeId] ?? [];
  }

  // Get comment count for a recipe
  int getCommentCount(String recipeId) {
    return _commentsCache[recipeId]?.length ?? 0;
  }

  // Add a comment
  Future<String> addComment({
    required String recipeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String text,
  }) async {
    if (_isAddingComment) throw Exception('Already adding comment');

    _isAddingComment = true;
    notifyListeners();

    try {
      final commentId = await _service.addComment(
        recipeId: recipeId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        text: text,
      );
      return commentId;
    } finally {
      _isAddingComment = false;
      notifyListeners();
    }
  }

  // Update a comment
  Future<void> updateComment(String commentId, String newText) async {
    await _service.updateComment(commentId, newText);
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    await _service.deleteComment(commentId);
  }

  // Clear cache
  void clearCache() {
    _likedRecipeIds.clear();
    _savedRecipeIds.clear();
    _commentsCache.clear();
    notifyListeners();
  }
}