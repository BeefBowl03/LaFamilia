import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../onboarding/welcome_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    
    // Get system theme
    final brightness = MediaQuery.of(context).platformBrightness;
    _darkMode = brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.logout();
      
      if (mounted) {
        // Navigate to welcome screen and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final currentFamily = authProvider.currentFamily;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User profile header
            if (currentUser != null) _buildUserProfileCard(currentUser.name, currentUser.role.name),
            
            const SizedBox(height: 24),
            
            // Settings sections
            _buildSectionHeader('Appearance'),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch(
                value: _darkMode,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  // This would actually change the theme in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme preference saved')),
                  );
                },
              ),
            ),
            
            const Divider(),
            
            _buildSectionHeader('Notifications'),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(
                      value ? 'Notifications enabled' : 'Notifications disabled'
                    )),
                  );
                },
              ),
            ),
            
            const Divider(),
            
            _buildSectionHeader('Family'),
            _buildSettingItem(
              icon: Icons.family_restroom,
              title: 'Family Name',
              subtitle: currentFamily?.name ?? 'Not available',
              onTap: () {
                // Would open family rename dialog in a full implementation
                if (authProvider.isParent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Family renaming would be implemented here')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Only parents can rename the family')),
                  );
                }
              },
            ),
            
            // Admin-only settings for parents
            if (authProvider.isParent) ...[  
              _buildSettingItem(
                icon: Icons.admin_panel_settings,
                title: 'Family Management',
                subtitle: 'Manage family members and roles',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Family management would be implemented here')),
                  );
                },
              ),
            ],
            
            const Divider(),
            
            _buildSectionHeader('Account'),
            _buildSettingItem(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile editing would be implemented here')),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support would be implemented here')),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About info would be implemented here')),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: AppTheme.dangerColor,
              titleColor: AppTheme.dangerColor,
              onTap: _logout,
            ),
            
            const SizedBox(height: 24),
            
            // Version info
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(String name, String role) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.substring(0, 1).toUpperCase() + role.substring(1),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile would be implemented here')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}