import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/recipe_model.dart';
import '../../providers/recipe_provider.dart';
import 'recipes/recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<String> _searchHistory = ['Cupcake', 'Ice Cream'];
  List<String> _searchSuggestions = ['Chocolate Cupcake', 'Ice Cream Sundae'];
  
  // Filter states
  Difficulty? _selectedDifficulty;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).subscribeToRecipes();
    });
    
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
    if (query.isNotEmpty) {
      // Update suggestions based on query
      _searchSuggestions = ['Cupcake', 'Cupcake matcha']
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) {
          _searchHistory.removeLast();
        }
      }
      _isSearching = false;
    });
    
    _searchFocusNode.unfocus();
    Provider.of<RecipeProvider>(context, listen: false).searchRecipes(query);
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Search Results or Main Content
            Expanded(
              child: _isSearching || _searchController.text.isNotEmpty
                  ? _buildSearchContent()
                  : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png', // Your Recipe Daily logo
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'RECIPE\nDAILY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                  height: 1.2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Back arrow (only show when searching)
          if (_isSearching || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _isSearching = false;
                });
                _searchFocusNode.unfocus();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          
          if (_isSearching || _searchController.text.isNotEmpty)
            const SizedBox(width: 8),
          
          // Search Field
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _performSearch,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: _isSearching ? '' : 'Search recipes',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.black),
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          
          // Filter button
          if (!_isSearching && _searchController.text.isEmpty)
            const SizedBox(width: 12),
          
          if (!_isSearching && _searchController.text.isEmpty)
            IconButton(
              icon: Icon(
                Icons.tune,
                color: _selectedDifficulty != null || _selectedTags.isNotEmpty
                    ? AppColors.primary
                    : Colors.grey[600],
              ),
              onPressed: _showFilterModal,
            ),
          
          // Filter icon with selected tags (when searching)
          if (_searchController.text.isNotEmpty && (_selectedDifficulty != null || _selectedTags.isNotEmpty))
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.primary),
              onPressed: _showFilterModal,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_searchController.text.isEmpty) {
      // Show search history and suggestions
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search History
            if (_searchHistory.isNotEmpty) ...[
              ..._searchHistory.map((query) {
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(query, style: const TextStyle(fontSize: 16)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                );
              }).toList(),
              
              const SizedBox(height: 24),
            ],
            
            // Suggestions
            const Text(
              'Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),
            
            ..._searchSuggestions.map((suggestion) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () {
                    _searchController.text = suggestion;
                    _performSearch(suggestion);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    } else {
      // Show search results
      return Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final recipes = provider.recipes;
          
          if (recipes.isEmpty) {
            return const Center(
              child: Text('No recipes found'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(recipes[index]);
            },
          );
        },
      );
    }
  }

  Widget _buildMainContent() {
    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final recipes = provider.recipes;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              
              // Trending Section
              _buildSectionHeader('Trending', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildTrendingSection(recipes.take(5).toList()),
              
              const SizedBox(height: 32),
              
              // Popular Recipes
              _buildSectionHeader('Popular Recipes', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildPopularRecipes(recipes),
              
              const SizedBox(height: 32),
              
              // Recommend
              _buildSectionHeader('Recommend', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildRecommendSection(recipes),
              
              const SizedBox(height: 32),
              
              // Popular Creators
              _buildSectionHeader('Popular Creators', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildPopularCreators(),
              
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(List<RecipeModel> recipes) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: recipe.authorPhotoUrl != null
                            ? NetworkImage(recipe.authorPhotoUrl!)
                            : null,
                        child: recipe.authorPhotoUrl == null
                            ? Text(
                                recipe.authorName[0].toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'By ${recipe.authorName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Recipe image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: recipe.coverImageUrl != null
                            ? Image.network(
                                recipe.coverImageUrl!,
                                width: 200,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 200,
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              ),
                      ),
                      
                      // Likes badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, size: 14, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.likesCount}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bookmark button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bookmark_border, size: 18, color: AppColors.primary),
                        ),
                      ),
                      
                      // Play button (if video)
                      if (recipe.coverVideoUrl != null)
                        const Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      
                      // Duration
                      Positioned(
                        bottom: 8,
                        right: 8,
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
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Recipe title
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Stats
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalCalories} Kcal',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        recipe.difficulty.displayName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularRecipes(List<RecipeModel> recipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: recipes.length > 6 ? 6 : recipes.length,
        itemBuilder: (context, index) {
          return _buildRecipeCard(recipes[index]);
        },
      ),
    );
  }

  Widget _buildRecommendSection(List<RecipeModel> recipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: recipes.length > 6 ? 6 : recipes.length,
        itemBuilder: (context, index) {
          return _buildRecipeCard(recipes[index]);
        },
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
          // Square Image
          AspectRatio(
            aspectRatio: 1.0, // Square ratio
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: recipe.coverImageUrl != null
                      ? Image.network(
                          recipe.coverImageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                ),
                
                // Bookmark
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border, size: 16, color: AppColors.primary),
                  ),
                ),
                
                // Duration
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDuration(recipe.cookTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Title
          Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 3),
          
          // Stats
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 11, color: Colors.grey),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  '${recipe.totalCalories} Kcal',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                recipe.difficulty.displayName,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCreators() {
    final creators = [
      {'name': 'Troyan\nSmith', 'image': null},
      {'name': 'James\nWolden', 'image': null},
      {'name': 'Niki\nSamantha', 'image': null},
      {'name': 'Zayn', 'image': null},
      {'name': 'Robe\nAnn', 'image': null},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: creators.length,
        itemBuilder: (context, index) {
          final creator = creators[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    creator['name']!.split('\n')[0][0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  creator['name']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterModal() {
    Difficulty? tempDifficulty = _selectedDifficulty;
    List<String> tempTags = List.from(_selectedTags);

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Spacer(),
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempDifficulty = null;
                          tempTags.clear();
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Filter Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Difficulty
                      const Text(
                        'Difficulty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: Difficulty.values.map((difficulty) {
                          final isSelected = tempDifficulty == difficulty;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(difficulty.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempDifficulty = selected ? difficulty : null;
                                });
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Apply Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDifficulty = tempDifficulty;
                        _selectedTags = tempTags;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
}