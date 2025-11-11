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

  const RecipeOptionsBottomSheet({
    Key? key,
    required this.recipe,
    required this.mode,
    this.onDeleted,
    this.onEdited,
  }) : super(key: key);

  // Show the bottom sheet
  static void show({
    required BuildContext context,
    required RecipeModel recipe,
    required String mode,
    VoidCallback? onDeleted,
    VoidCallback? onEdited,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RecipeOptionsBottomSheet(
        recipe: recipe,
        mode: mode,
        onDeleted: onDeleted,
        onEdited: onEdited,
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
              ScaffoldMessenger.of(context).showSnackBar(
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
                Navigator.pop(context);

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRecipeScreen(recipe: recipe),
                  ),
                );

                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
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

                  // Callback when edited
                  onEdited?.call();

                  // Reload user recipes
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    Provider.of<RecipeProvider>(context, listen: false)
                        .subscribeToUserRecipes(user.uid);
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
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
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

                // Show deleting progress
                ScaffoldMessenger.of(context).showSnackBar(
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
                  final provider = Provider.of<RecipeProvider>(context, listen: false);
                  await provider.deleteRecipe(recipe.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
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

                    // Pop the detail screen if we're on it
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    String errorMsg = 'Failed to delete recipe';

                    if (e.toString().contains('network') || 
                        e.toString().contains('connection')) {
                      errorMsg = 'Network error. Please try again';
                    } else if (e.toString().contains('permission') || 
                               e.toString().contains('denied')) {
                      errorMsg = 'You do not have permission to delete this recipe';
                    }

                    showDialog(
                      context: context,
                      builder: (errorContext) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Delete Failed'),
                          ],
                        ),
                        content: Text(errorMsg),
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
                                _showDeleteConfirmation(context);
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