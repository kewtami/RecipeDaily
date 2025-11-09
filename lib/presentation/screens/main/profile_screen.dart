import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/recipe_model.dart';
import 'recipes/recipe_detail_screen.dart';
import 'recipes/edit_recipe_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user's recipes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Provider.of<RecipeProvider>(context, listen: false)
            .subscribeToUserRecipes(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isGoogleUser(User? user) {
    return user?.providerData.any(
      (provider) => provider.providerId == 'google.com'
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<RecipeProvider>(
          builder: (context, recipeProvider, _) {
            final userRecipes = recipeProvider.recipes;
            final recipesCount = userRecipes.length;
            
            // Mock data for now - you can implement these later
            final followingCount = 1274; // 1.27K
            final followersCount = 112;
            final likesCount = 30700; // 30.7K
            
            return CustomScrollView(
              slivers: [
                // Header with menu
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: AppColors.primary),
                      onPressed: () => _showMoreMenu(context),
                    ),
                  ],
                ),
                
                // Profile Info
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: user?.photoURL != null 
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(recipesCount.toString(), 'Recipes'),
                            _buildStatItem(_formatCount(followingCount), 'Following'),
                            _buildStatItem(followersCount.toString(), 'Followers'),
                            _buildStatItem(_formatCount(likesCount), 'Likes'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '"Tell me what you eat, and I will tell you what you are"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Tabs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(0);
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 0 
                                        ? AppColors.primary 
                                        : Colors.white,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Recipes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _tabController.index == 0 
                                          ? Colors.white 
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(1);
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 1 
                                        ? AppColors.primary 
                                        : Colors.white,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Liked',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _tabController.index == 1 
                                          ? Colors.white 
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                
                // Recipes Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _tabController.index == 0
                      ? _buildRecipesGrid(userRecipes)
                      : _buildLikedGrid(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      final thousands = count / 1000;
      if (thousands >= 100) {
        return '${thousands.toStringAsFixed(0)}K';
      }
      return '${thousands.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}K';
    }
    return count.toString();
  }

  Widget _buildRecipesGrid(List<RecipeModel> recipes) {
    if (recipes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No recipes yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final recipe = recipes[index];
          return _buildRecipeCard(recipe);
        },
        childCount: recipes.length,
      ),
    );
  }

  Widget _buildLikedGrid() {
    // TODO: Implement liked recipes functionality
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No liked recipes yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Square Image Container
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: [
                // Recipe Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: recipe.coverImageUrl != null
                      ? Image.network(
                          recipe.coverImageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 48),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 48),
                        ),
                ),
                
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bookmark button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                // More options button
                Positioned(
                  top: 8,
                  right: 48,
                  child: GestureDetector(
                    onTap: () => _showRecipeOptions(context, recipe),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                
                // Duration badge
                Positioned(
                  bottom: 60,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDuration(recipe.cookTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Recipe info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.totalCalories} Kcal',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              recipe.difficulty.displayName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes} mins';
    } else {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}m';
    }
  }

  void _showMoreMenu(BuildContext context) {
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
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppColors.primary),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: AppColors.primary),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to help
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                title: const Text('Privacy Policy'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to privacy policy
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.primary),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Delete Account'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
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
                      Text('Logging out...'),
                    ],
                  ),
                  duration: Duration(seconds: 1),
                ),
              );
              
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = _isGoogleUser(user);
    
    final TextEditingController passwordController = TextEditingController();
    bool isDeleting = false;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action is permanent and cannot be undone!\n\n'
                'All your data will be deleted:\n'
                '• Account information\n'
                '• Saved recipes\n'
                '• All personal data',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (!isGoogleUser) ...[
                const Text(
                  'Please enter your password to confirm:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isDeleting,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else
                const Text(
                  '\n✓ Google account - no password required',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () {
                passwordController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isDeleting ? null : () async {
                if (!isGoogleUser) {
                  final password = passwordController.text;
                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your password'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                }

                setState(() {
                  isDeleting = true;
                });
                
                try {
                  if (user == null) {
                    throw Exception('No user logged in');
                  }

                  if (isGoogleUser) {
                    await user.delete();
                  } else {
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: passwordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);
                    await user.delete();
                  }
                  
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Account deleted successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    isDeleting = false;
                  });
                  
                  String message = 'Failed to delete account';
                  switch (e.code) {
                    case 'wrong-password':
                      message = 'Incorrect password';
                      break;
                    case 'requires-recent-login':
                      message = 'Please logout and login again, then try deleting';
                      break;
                    case 'too-many-requests':
                      message = 'Too many attempts. Please try again later';
                      break;
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    isDeleting = false;
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } finally {
                  passwordController.dispose();
                }
              },
              child: isDeleting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Delete',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeOptions(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Recipe
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit Recipe'),
                onTap: () async {
                  Navigator.pop(modalContext);
                  
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditRecipeScreen(recipe: recipe),
                    ),
                  );
                  
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Recipe updated successfully!'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Provider.of<RecipeProvider>(context, listen: false)
                          .subscribeToUserRecipes(user.uid);
                    }
                  }
                },
              ),
              
              const Divider(),
              
              // Delete Recipe
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Recipe'),
                onTap: () {
                  Navigator.pop(modalContext);
                  _confirmDeleteRecipe(context, recipe);
                },
              ),
              
              // Share Recipe
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.primary),
                title: const Text('Share Recipe'),
                onTap: () {
                  Navigator.pop(modalContext);
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
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteRecipe(BuildContext context, RecipeModel recipe) {
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
                Navigator.pop(dialogContext);
                
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
                    
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      provider.subscribeToUserRecipes(user.uid);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Failed to delete: ${e.toString()}'),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 3),
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