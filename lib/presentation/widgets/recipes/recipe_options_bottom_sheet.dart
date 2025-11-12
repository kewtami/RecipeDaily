import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/recipe_model.dart';
import '../../providers/recipe_provider.dart';
import '../../screens/main/recipes/edit_recipe_screen.dart';

class RecipeOptionsBottomSheet extends StatelessWidget {
  final RecipeModel recipe;
  final String mode; // 'owner' or 'viewer'
  final VoidCallback? onDeleted;
  final VoidCallback? onEdited;
  final bool shouldPopAfterDelete;

  const RecipeOptionsBottomSheet({
    Key? key,
    required this.recipe,
    required this.mode,
    this.onDeleted,
    this.onEdited,
    this.shouldPopAfterDelete = true,
  }) : super(key: key);

  // Show the bottom sheet
  static void show({
    required BuildContext context,
    required RecipeModel recipe,
    required String mode,
    VoidCallback? onDeleted,
    VoidCallback? onEdited,
    bool shouldPopAfterDelete = true,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => RecipeOptionsBottomSheet(
        recipe: recipe,
        mode: mode,
        onDeleted: onDeleted,
        onEdited: onEdited,
        shouldPopAfterDelete: shouldPopAfterDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share Recipe
          ListTile(
            leading: const Icon(Icons.share, color: AppColors.primary),
            title: const Text('Share Recipe'),
            onTap: () {
              Navigator.pop(context);
              // Using root navigator to show snackbar on the main scaffold
              final parentContext = Navigator.of(context, rootNavigator: true).context;
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text('Share feature coming soon!'),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // Edit Recipe - Only for owner
          if (mode == 'owner') ...[
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Recipe'),
              onTap: () async {
                // Save parent context before closing modal
                final parentNavigator = Navigator.of(context, rootNavigator: true);
                Navigator.pop(context);

                final result = await parentNavigator.push(
                  MaterialPageRoute(
                    builder: (context) => EditRecipeScreen(recipe: recipe),
                  ),
                );

                if (result == true) {
                  final scaffoldContext = parentNavigator.context;
                  if (scaffoldContext.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Recipe updated successfully!'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    onEdited?.call();

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Provider.of<RecipeProvider>(scaffoldContext, listen: false)
                          .subscribeToUserRecipes(user.uid);
                    }
                  }
                }
              },
            ),

            const Divider(),

            // Delete Recipe - Only for owner
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Recipe'),
              onTap: () {
                // Get root navigator before closing modal
                final rootNavigator = Navigator.of(context, rootNavigator: true);
                final rootContext = rootNavigator.context;
                
                // Close bottom sheet first
                Navigator.pop(context);
                
                // Then show delete confirmation dialog
                _showDeleteConfirmation(rootContext, rootNavigator);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext parentContext, NavigatorState parentNavigator) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: AppColors.error),
              SizedBox(width: 12),
              Text('Delete Recipe?'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${recipe.title}"?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                if (!parentContext.mounted) return;

                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Deleting recipe...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                try {
                  print('Starting delete for recipe: ${recipe.id}');
                  final provider = Provider.of<RecipeProvider>(parentContext, listen: false);
                  print('Provider obtained');
                  
                  final success = await provider.deleteRecipe(recipe.id);
                  print('Delete completed: $success');

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).hideCurrentSnackBar();
                    
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Recipe deleted successfully'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );

                  // Callback when deleted
                    onDeleted?.call();

                    // Reload user recipes
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      provider.subscribeToUserRecipes(user.uid);
                    }

                    if (shouldPopAfterDelete && parentNavigator.canPop()) {
                      parentNavigator.pop();
                    }
                  }
                } catch (e) {
                  print('Delete error: $e');
                  
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).hideCurrentSnackBar();
                    
                    String errorMsg = 'Failed to delete recipe';

                    if (e.toString().contains('network') || 
                        e.toString().contains('connection')) {
                      errorMsg = 'Network error. Please try again';
                    } else if (e.toString().contains('permission') || 
                               e.toString().contains('denied')) {
                      errorMsg = 'You do not have permission to delete this recipe';
                    }

                    showDialog(
                      context: parentContext,
                      builder: (errorContext) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Delete Failed'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(errorMsg),
                            const SizedBox(height: 8),
                            Text(
                              'Error details: ${e.toString()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(errorContext),
                            child: const Text('OK'),
                          ),
                          if (e.toString().contains('network') || 
                              e.toString().contains('connection'))
                            TextButton(
                              onPressed: () {
                                Navigator.pop(errorContext);
                                _showDeleteConfirmation(parentContext, parentNavigator);
                              },
                              child: const Text(
                                'Retry',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}