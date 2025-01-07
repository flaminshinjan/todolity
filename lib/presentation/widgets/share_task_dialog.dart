import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolity/data/models/app_user_model.dart';
import 'package:todolity/data/models/task_model.dart';
import 'package:todolity/data/repositories/shared_tasks_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'package:logger/logger.dart';

class ShareTaskDialog extends StatefulWidget {
  final Task task;

  const ShareTaskDialog({Key? key, required this.task}) : super(key: key);

  @override
  _ShareTaskDialogState createState() => _ShareTaskDialogState();
}

class _ShareTaskDialogState extends State<ShareTaskDialog> {
  final TextEditingController _searchController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  final SharedTaskRepository _sharedTaskRepository = SharedTaskRepository();
  final Logger _logger = Logger();
  List<AppUser> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _searchUsers(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _errorMessage = query.isEmpty 
            ? '' 
            : 'Please enter at least 3 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _userRepository.searchUsers(query);
      setState(() {
        _searchResults = results.where((user) => 
          !widget.task.sharedWith.contains(user.id)).toList();
        
        if (_searchResults.isEmpty) {
          _errorMessage = 'No users found';
        }
      });
    } catch (e) {
      _logger.e('Error searching users: $e');
      setState(() {
        _errorMessage = 'Error searching users';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shareWithUser(AppUser user) async {
    try {
      _logger.i('Sharing task ${widget.task.id} with user ${user.id}');
      
      await _sharedTaskRepository.shareTask(
        widget.task,
        user.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task shared with ${user.email}')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      _logger.e('Error sharing task: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing task: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Share Task',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search users by email',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                hintStyle: TextStyle(color: Colors.grey[600]),
                labelStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.grey[100],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF036ac9)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[300]!),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                errorStyle: TextStyle(color: Colors.red),
              ),
              onChanged: (value) => _searchUsers(value),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: Color(0xFF036ac9)))
            else if (_searchResults.isNotEmpty)
              Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF036ac9),
                          child: Text(
                            user.email[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user.email,
                          style: TextStyle(color: Colors.black87),
                        ),
                        subtitle: user.name != null 
                          ? Text(
                              user.name!,
                              style: TextStyle(color: Colors.grey[600]),
                            ) 
                          : null,
                        trailing: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Color(0xFF036ac9),
                          ),
                          onPressed: () => _shareWithUser(user),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}