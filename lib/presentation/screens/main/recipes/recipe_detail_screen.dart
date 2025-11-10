import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/recipe_model.dart';
import '../../../providers/recipe_provider.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _currentServings = 1;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isFollowing = false;
  final TextEditingController _commentController = TextEditingController();
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    
    try {
      await provider.fetchRecipe(widget.recipeId);
      
      if (provider.currentRecipe != null) {
        setState(() {
          _currentServings = provider.currentRecipe!.serves;
          _loadError = null;
        });
        
        // Check if recipe is liked
        _isLiked = await provider.isRecipeLiked(widget.recipeId);
        if (mounted) {
          setState(() {});
        }
      } else {
        setState(() {
          _loadError = 'Recipe not found';
        });
      }
    } catch (e) {
      String errorMsg = 'Failed to load recipe';
      
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMsg = 'Network error. Check your connection';
      } else if (e.toString().contains('permission') || e.toString().contains('denied')) {
        errorMsg = 'Access denied';
      }
      
      setState(() {
        _loadError = errorMsg;
      });
    }
  }

  void _adjustServings(int change) {
    setState(() {
      _currentServings = (_currentServings + change).clamp(1, 20);
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTimer(Duration? timer) {
    if (timer == null) return '';
    
    final hours = timer.inHours;
    final minutes = timer.inMinutes.remainder(60);
    final seconds = timer.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          // Loading state
          if (provider.isLoading && _loadError == null) {
            return _buildLoadingState();
          }

          // Error state
          if (_loadError != null || provider.currentRecipe == null) {
            return _buildErrorState(_loadError ?? 'Recipe not found');
          }

          final recipe = provider.currentRecipe!;

          return CustomScrollView(
            slivers: [
              // Cover Image with AppBar
              _buildCoverImage(recipe),
              
              // Recipe Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Difficulty
                      _buildHeader(recipe),
                      const SizedBox(height: 16),
                      
                      // Stats Row
                      _buildStatsRow(recipe),
                      const SizedBox(height: 16),
                      
                      // Author Info
                      _buildAuthorInfo(recipe),
                      const SizedBox(height: 24),
                      
                      // Description
                      _buildDescription(recipe),
                      const SizedBox(height: 32),
                      
                      // Ingredients Section
                      _buildIngredientsSection(recipe),
                      const SizedBox(height: 32),
                      
                      // Steps Section
                      _buildStepsSection(recipe),
                      const SizedBox(height: 32),
                      
                      // Tags Section
                      if (recipe.tags.isNotEmpty) _buildTagsSection(recipe),
                      if (recipe.tags.isNotEmpty) const SizedBox(height: 32),
                      
                      // Author Card
                      _buildAuthorCard(recipe),
                      const SizedBox(height: 32),
                      
                      // Comments Section
                      _buildCommentsSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Loading recipe...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                errorMessage.contains('network') || errorMessage.contains('connection')
                    ? Icons.wifi_off
                    : Icons.restaurant_menu,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                errorMessage.contains('network') || errorMessage.contains('connection')
                    ? 'Connection Error'
                    : 'Recipe Not Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage.contains('network') || errorMessage.contains('connection')
                    ? 'Please check your internet connection\nand try again.'
                    : 'This recipe may have been deleted\nor is no longer available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (errorMessage.contains('network') || errorMessage.contains('connection'))
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadError = null;
                        });
                        _loadRecipe();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (errorMessage.contains('network') || errorMessage.contains('connection'))
                    const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(RecipeModel recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.secondary, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.more_horiz, color: AppColors.secondary, size: 20),
          ),
          onPressed: () {
            _showMoreOptions(context, recipe);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe.coverImageUrl != null)
              Image.network(
                recipe.coverImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image failed to load',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 64),
              ),
            
            // Bookmark Button
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSaved = !_isSaved;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(_isSaved ? 'Recipe saved' : 'Recipe unsaved'),
                        ],
                      ),
                      backgroundColor: _isSaved ? AppColors.success : Colors.grey[700],
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? AppColors.primary : AppColors.secondary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RecipeModel recipe) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(RecipeModel recipe) {
    return Row(
      children: [
        // Difficulty
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            recipe.difficulty.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Cook Time
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              _formatDuration(recipe.cookTime),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const Spacer(),
        
        // Likes
        GestureDetector(
          onTap: () async {
            final provider = Provider.of<RecipeProvider>(context, listen: false);
            try {
              await provider.toggleLike(recipe.id);
              setState(() {
                _isLiked = !_isLiked;
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(_isLiked ? 'Recipe liked' : 'Like removed'),
                      ],
                    ),
                    backgroundColor: _isLiked ? Colors.red : Colors.grey[700],
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
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
          child: Row(
            children: [
              Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${recipe.likesCount} Likes',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorInfo(RecipeModel recipe) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: recipe.authorPhotoUrl != null
              ? NetworkImage(recipe.authorPhotoUrl!)
              : null,
          child: recipe.authorPhotoUrl == null
              ? Text(
                  recipe.authorName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          recipe.authorName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          recipe.description,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(RecipeModel recipe) {
    final scaledIngredients = recipe.getScaledIngredients(_currentServings);
    final scaledCalories = recipe.getScaledCalories(_currentServings);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Ingredients for',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const Spacer(),
            
            // Serving Adjuster
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _currentServings > 1 ? () => _adjustServings(-1) : null,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_currentServings',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => _adjustServings(1),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$_currentServings servings',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        // Ingredients List
        ...scaledIngredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '${ingredient.quantity}${ingredient.unit}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' - ${ingredient.name}'),
                        TextSpan(
                          text: ' (${ingredient.method.displayName})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: ' - ${ingredient.calories} kcal',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        const SizedBox(height: 16),
        
        // Total Calories
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TOTAL CALORIES: $scaledCalories kcal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Steps',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        
        ...recipe.steps.map((step) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Number
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Step Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.instruction,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      
                      // Step Image
                      if (step.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            step.imageUrl!,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image unavailable',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      // Timer
                      if (step.timer != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Step Timer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatTimer(step.timer),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTagsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_offer, size: 22, color: AppColors.secondary),
            const SizedBox(width: 8),
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAuthorCard(RecipeModel recipe) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: recipe.authorPhotoUrl != null
                ? NetworkImage(recipe.authorPhotoUrl!)
                : null,
            child: recipe.authorPhotoUrl == null
                ? Text(
                    recipe.authorName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          
          Text(
            'By',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            recipe.authorName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isFollowing = !_isFollowing;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          _isFollowing ? Icons.person_add : Icons.person_remove,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isFollowing
                              ? 'Now following ${recipe.authorName}'
                              : 'Unfollowed ${recipe.authorName}',
                        ),
                      ],
                    ),
                    backgroundColor: _isFollowing ? AppColors.success : Colors.grey[700],
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey[300] : AppColors.primary,
                foregroundColor: _isFollowing ? AppColors.secondary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Add Comment Input
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment',
                  hintStyle: TextStyle(fontSize: 15, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    // TODO: Implement comment posting
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Comment posted!'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _commentController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.primary),
                title: const Text('Share Recipe'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.share, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('Share feature coming soon!'),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit Recipe'),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Navigate to Edit Recipe Screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditRecipeScreen(recipe: recipe),
                    ),
                  );
                  
                  // Reload recipe if updated
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.refresh, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Reloading updated recipe...'),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _loadRecipe();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Recipe'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, recipe);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, RecipeModel recipe) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: const [
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
                Navigator.pop(dialogContext); // Close dialog
                
                // Show deleting message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
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
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                try {
                  final provider = Provider.of<RecipeProvider>(context, listen: false);
                  await provider.deleteRecipe(recipe.id);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Recipe deleted successfully'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context); // Close detail screen
                  }
                } catch (e) {
                  if (mounted) {
                    String errorMsg = 'Failed to delete recipe';
                    
                    if (e.toString().contains('network') || e.toString().contains('connection')) {
                      errorMsg = 'Network error. Please try again';
                    } else if (e.toString().contains('permission') || e.toString().contains('denied')) {
                      errorMsg = 'You do not have permission to delete this recipe';
                    }
                    
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: const [
                            Icon(Icons.error_outline, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Delete Failed'),
                          ],
                        ),
                        content: Text(errorMsg),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDelete(context, recipe); // Retry
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