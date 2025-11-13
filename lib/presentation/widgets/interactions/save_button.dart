import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/interaction_provider.dart';
import '../../../core/constants/app_colors.dart';

class SaveButton extends StatelessWidget {
  final String recipeId;
  final double iconSize;
  final EdgeInsets? padding;
  final bool useContainer;

  const SaveButton({
    Key? key,
    required this.recipeId,
    this.iconSize = 24,
    this.padding,
    this.useContainer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Consumer<InteractionProvider>(
      builder: (context, provider, _) {
        final isSaved = provider.isRecipeSaved(recipeId);

        Widget iconWidget = Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? AppColors.primary : AppColors.secondary,
          size: iconSize,
        );

        if (useContainer) {
          iconWidget = Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                ),
              ],
            ),
            child: iconWidget,
          );
        }

        return GestureDetector(
          onTap: () async {
            try {
              await provider.toggleSave(recipeId, user.uid);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          isSaved ? Icons.bookmark_border : Icons.bookmark,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(isSaved ? 'Recipe unsaved' : 'Recipe saved'),
                      ],
                    ),
                    backgroundColor: isSaved ? Colors.grey[700] : AppColors.success,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.error_outline, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Failed to update save'),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: iconWidget,
          ),
        );
      },
    );
  }
}