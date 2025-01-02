import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolity/presentation/screens/home/home_screen.dart';
import 'package:todolity/presentation/screens/profile/profile_screen.dart';
import 'package:todolity/presentation/screens/tasks/shared_tasks_screen.dart';
import 'package:todolity/presentation/screens/tasks/task_list_screen.dart';
import 'package:todolity/presentation/widgets/add_task_dialog.dart';
import 'package:logger/logger.dart';
import 'package:todolity/presentation/widgets/date_strip.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final Logger _logger = Logger();

  final List<Widget> _screens = [
    HomeScreen(),
    TaskListScreen(),
    SharedTasksScreen(),
    ProfileScreen(),
  ];

  void _showAddTaskDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SingleChildScrollView(
      child: AddTaskDialog(),
    ),
  );
  }

  void _onTabChanged(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _selectedIndex = index);
      _logger.i('Tab changed to: $index');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 12, 12, 12),
    appBar: _selectedIndex == 0 ? PreferredSize(  // Only show AppBar when home tab is selected
      preferredSize: Size.fromHeight(100),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: const Color(0xFFf9be03),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: _currentUser?.photoURL != null
                    ? NetworkImage(_currentUser!.photoURL!)
                    : null,
                child: _currentUser?.photoURL == null
                    ? Icon(Icons.person, color: Colors.black54)
                    : null,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hi,',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _currentUser?.displayName ?? 'Shinjan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined),
                  color: Colors.black87,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _logger.i('Notifications button pressed');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ) : null,  // Return null for AppBar when not on home tab
 
      body: SafeArea(
        bottom: false,
        child:Column(children: [
         
Expanded(child: _screens[_selectedIndex],),
        ],) 
      ),
      bottomNavigationBar: Padding(
  padding: const EdgeInsets.fromLTRB(15, 15, 10, 32),
  child: Row(
    children: [
      Expanded(
        flex: 4,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFF9BE04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(  // Added black border
              color: Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home')),
                Expanded(child: _buildNavItem(1, Icons.task_outlined, Icons.task, 'Tasks')),
                Expanded(child: _buildNavItem(2, Icons.share_outlined, Icons.share, 'Shared')),
                Expanded(child: _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile')),
              ],
            ),
          ),
        ),
      ),
      SizedBox(width: 10),
      Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF036ac9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(  // Added black border
            color: Colors.black,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAddTaskDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    ],
  ),
),
      extendBody: true,
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onTabChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? Colors.black : Colors.black54,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logger.i('DashboardScreen disposed');
    super.dispose();
  }
}