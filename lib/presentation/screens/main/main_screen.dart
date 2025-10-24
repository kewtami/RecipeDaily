import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

// List of screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const SavedScreen(),
    const CreateScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Home Screen - Coming Soon!'),
      ),
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: const Center(
        child: Text('Saved Screen - Coming Soon!'),
      ),
    );
  }
}

class CreateScreen extends StatelessWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
      ),
      body: const Center(
        child: Text('Create Screen - Coming Soon!'),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const Center(
        child: Text('Notifications Screen - Coming Soon!'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: user?.photoURL != null 
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            
            const SizedBox(height: 20),
            
            // Name
            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Email Verification Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: user?.emailVerified == true 
                    ? Colors.green[50] 
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user?.emailVerified == true 
                      ? Colors.green 
                      : Colors.orange,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user?.emailVerified == true 
                        ? Icons.verified 
                        : Icons.warning,
                    size: 16,
                    color: user?.emailVerified == true 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user?.emailVerified == true 
                        ? 'Verified' 
                        : 'Not Verified',
                    style: TextStyle(
                      fontSize: 12,
                      color: user?.emailVerified == true 
                          ? Colors.green[800] 
                          : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Profile Options
            _buildProfileOption(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
              },
            ),
            
            _buildProfileOption(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
              },
            ),
            
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
              },
            ),
            
            _buildProfileOption(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
              },
            ),
            
            const SizedBox(height: 40),
            
            // Logout Button
            CustomButton(
              text: 'Logout',
              backgroundColor: AppColors.primary,
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
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
              // Close dialog
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              // Logout
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              
              // Navigate to login
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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
}