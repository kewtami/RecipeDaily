import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  // Helper to check if user is Google account
  bool _isGoogleUser(User? user) {
    return user?.providerData.any(
      (provider) => provider.providerId == 'google.com'
    ) ?? false;
  }

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
              backgroundColor: AppColors.primary,
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
                color: AppColors.secondary,
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

            // Delete Account Button
            CustomButton(
              text: 'Delete Account',
              backgroundColor: AppColors.error,
              onPressed: () {
                _showDeleteAccountDialog(context);
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
              
              // Show logging out snackbar
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
              
              // Logout
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
              // Only show password field for email users
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
                // Validate password for email users
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

                // Start deleting
                setState(() {
                  isDeleting = true;
                });
                
                try {
                  if (user == null) {
                    throw Exception('No user logged in');
                  }

                  if (isGoogleUser) {
                    // Google users: Direct delete
                    await user.delete();
                  } else {
                    // Email users: Re-authenticate then delete
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: passwordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);
                    await user.delete();
                  }
                  
                  // Close dialog
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  // Show success message
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
}