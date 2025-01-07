import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todolity/presentation/screens/dashboard/dashboard_screen.dart';
import '../../../data/repositories/user_repository.dart';
import 'dart:io';

class NoTransitionRoute extends MaterialPageRoute {
  NoTransitionRoute({required WidgetBuilder builder})
      : super(builder: builder);

  @override
  Duration get transitionDuration => Duration.zero;
  
  @override
  Duration get reverseTransitionDuration => Duration.zero;
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedMemoji;
  Color _selectedBackground = Colors.blue;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _currentMemojiUrl;
  
  final List<Color> _backgroundColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.red,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        
        // Get user data from Firestore
        final userData = await UserRepository()
            .getUserStream(user.uid)
            .first;
        
        if (userData != null) {
          setState(() {
            _currentMemojiUrl = userData.photoUrl;
            // Convert the stored color value back to a Color object
            if (userData.backgroundColor != null) {
              _selectedBackground = Color(userData.backgroundColor!);
            }
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _selectMemoji() async {
  try {
    // Request permissions when trying to pick image
    final status = await Permission.photos.request();
    
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _selectedMemoji = File(image.path);
        });
      }
    } else if (status.isPermanentlyDenied) {
      // Show settings option if permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable photo access in settings'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    } else {
      // Show regular denial message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access photos was denied')),
      );
    }
  } catch (e) {
    print('Error picking image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error selecting image')),
    );
  }
}

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload memoji if selected
        String? memojiUrl = _currentMemojiUrl;
        if (_selectedMemoji != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('memojis')
              .child('${user.uid}.png');
          await ref.putFile(_selectedMemoji!);
          memojiUrl = await ref.getDownloadURL();
        }

        // Update user profile
        await user.updateDisplayName(_nameController.text);
        
        // Update custom user data in Firestore
        await UserRepository().updateUserProfile(
          userId: user.uid,
          data: {
            'name': _nameController.text,
            'photoUrl': memojiUrl,
            'backgroundColor': _selectedBackground.value,
          },
        );

        // Navigate back to dashboard
        Navigator.of(context).pushReplacement(
          NoTransitionRoute(
            builder: (context) => DashboardScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              NoTransitionRoute(
                builder: (context) => DashboardScreen(),
              ),
            );
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Memoji Section
            Center(
              child: GestureDetector(
                onTap: _selectMemoji,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _selectedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: _selectedMemoji != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedMemoji!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _currentMemojiUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _currentMemojiUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 40,
                            ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Background Color Selection
            Text(
              'Choose Background',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _backgroundColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBackground = color),
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedBackground == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 32),

            // Name Input
            Text(
              'Your Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}