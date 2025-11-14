import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/interaction_provider.dart';
import '../../../core/constants/app_colors.dart';

class LikeButton extends StatelessWidget {
  final String recipeId;
  final int likesCount;
  final bool showCount;
  final double iconSize;
  final EdgeInsets? padding;
  final VoidCallback? onLikeChanged;

  const LikeButton({
    Key? key,
    required this.recipeId,
    required this.likesCount,
    this.showCount = true,
    this.iconSize = 20,
    this.padding,
    this.onLikeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Consumer<InteractionProvider>(
      builder: (context, provider, _) {
        final isLiked = provider.isRecipeLiked(recipeId);
        // Get updated likes count
        final displayCount = provider.getLikesCount(recipeId, likesCount);

        return GestureDetector(
          onTap: () async {
            try {
              await provider.toggleLike(recipeId, user.uid);
              onLikeChanged?.call();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite_border : Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(isLiked ? 'Like removed' : 'Recipe liked'),
                      ],
                    ),
                    backgroundColor: isLiked ? Colors.grey[700] : Colors.red,
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
                        Text('Failed to update like'),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : AppColors.primary,
                  size: iconSize,
                ),
                if (showCount) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$displayCount',
                    style: TextStyle(
                      fontSize: iconSize * 0.7,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}