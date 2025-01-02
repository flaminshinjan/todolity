import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Profile Section
            Container(
              padding: EdgeInsets.fromLTRB(24, 
                MediaQuery.of(context).padding.top + 20, 24, 24),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFF9BE03),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: currentUser?.photoURL != null
                          ? CachedNetworkImage(
                              imageUrl: currentUser!.photoURL!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey[600],
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi,',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          currentUser?.displayName ?? 'Shinjan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUser?.email ?? 'email@example.com',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Statistics Cards
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Tasks',
                      '20',
                      Icons.task_alt,
                      Color(0xFF1E88E5),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      '15',
                      Icons.check_circle,
                      Color(0xFF43A047),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      '5',
                      Icons.pending_actions,
                      Color(0xFFFB8C00),
                    ),
                  ),
                ],
              ),
            ),
            // Settings Section Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Color(0xFFF9BE03),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Settings Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSettingsTile(
                    'Edit Profile',
                    Icons.edit,
                    onTap: () {
                      // Navigate to edit profile
                    },
                  ),
                  _buildSettingsTile(
                    'Notifications',
                    Icons.notifications,
                    onTap: () {
                      // Navigate to notifications
                    },
                  ),
                  _buildSettingsTile(
                    'Privacy & Security',
                    Icons.security,
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                  _buildSettingsTile(
                    'Help & Support',
                    Icons.help,
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  _buildSettingsTile(
                    'Logout',
                    Icons.logout,
                    isDestructive: true,
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out. Please try again.'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : Color(0xFFF9BE03).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Color(0xFFF9BE03),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : Colors.white54,
        ),
      ),
    );
  }
}