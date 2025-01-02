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
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              onChanged: (value) => _searchUsers(value),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.email[0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.email),
                      subtitle: user.name != null ? Text(user.name!) : null,
                      trailing: IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () => _shareWithUser(user),
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
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}