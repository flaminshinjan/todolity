import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:todolity/data/repositories/shared_tasks_repository.dart';
import 'package:todolity/presentation/widgets/date_strip.dart';
import '../../../data/repositories/task_repository.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatelessWidget {
  final _logger = Logger();
  final _firestore = FirebaseFirestore.instance;
  final _taskRepository = TaskRepository();
  final _sharedTaskRepository = SharedTaskRepository();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           DateStrip(),
           Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
            child: Text(
            'Tasks Overview',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          ),
          SizedBox(height: 10),
          
          _buildTaskOverviewCard(context),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
            child: Text(
            'My Tasks',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          ),
          SizedBox(height: 10),
          _buildMyTasksCard(context),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
            child: Text(
            'Shared Tasks',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          ),
          _buildSharedWithMeCard(context),
        ],
      ),
    );
  }


Widget _buildTaskOverviewCard(BuildContext context) {
  return StreamBuilder<Map<String, int>>(
    stream: _getTaskCounts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }

      if (snapshot.hasError) {
        _logger.e('Error loading task counts: ${snapshot.error}');
        return _buildErrorCard();
      }

      final counts = snapshot.data ?? {'myTasks': 0, 'sharedWithMe': 0, 'sharedByMe': 0};

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircularItem(
              'My Tasks',
              counts['myTasks'] ?? 0,
              Color(0xffFFC9C9),
              Colors.black,
            ),
            _buildCircularItem(
              'Shared with Me',
              counts['sharedWithMe'] ?? 0,
              Color(0xffBAE5FF),
              Colors.black,
            ),
            _buildCircularItem(
              'Shared by Me',
              counts['sharedByMe'] ?? 0,
              const Color(0xFFBAE5FF),
              Colors.black,
              isSpecial: true,
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildCircularItem(
  String label,
  int count,
  Color backgroundColor,
  Color textColor, {
  bool isSpecial = false,
}) {
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        customBorder: CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLoadingCard() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) => _buildShimmerCircle()),
    ),
  );
}

Widget _buildShimmerCircle() {
  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.black26,
      shape: BoxShape.circle,
    ),
  );
}

Widget _buildErrorCard() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
        (index) => _buildCircularItem(
          'Error',
          0,
          Colors.black,
          Colors.red,
        ),
      ),
    ),
  );
}
Widget _buildMyTasksCard(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: _taskRepository.getMyTasksStream(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildMyTasksLoadingCard();
      }

      if (snapshot.hasError) {
        _logger.e('Error loading my tasks: ${snapshot.error}');
        return _buildMyTasksErrorCard();
      }

      final tasks = snapshot.data?.docs ?? [];
      
      return Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tasks.length > 3 ? 3 : tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index].data() as Map<String, dynamic>;
            return Container(
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: const  Color(0xffFFC9C9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            task['description'] ?? '',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildMyTasksLoadingCard() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 15),
    child: ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    ),
  );
}

Widget _buildMyTasksErrorCard() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Text(
        'Error loading tasks',
        style: TextStyle(color: Colors.red),
      ),
    ),
  );
}

Widget _buildSharedWithMeCard(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: _sharedTaskRepository.getSharedWithMeTasksStream(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }

      if (snapshot.hasError) {
        _logger.e('Error loading shared tasks: ${snapshot.error}');
        return _buildErrorCard();
      }

      final tasks = snapshot.data?.docs ?? [];
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tasks.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No shared tasks',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tasks.length > 2 ? 2 : tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index].data() as Map<String, dynamic>;
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffBAE5FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['title'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  task['description'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
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

  

  

  Stream<Map<String, int>> _getTaskCounts() {
    return Rx.combineLatest3(
      _taskRepository.getMyTasksStream(userId),
      _sharedTaskRepository.getSharedWithMeTasksStream(userId),
      _sharedTaskRepository.getSharedByMeTasksStream(userId),
      (QuerySnapshot myTasks, 
       QuerySnapshot sharedWithMe, 
       QuerySnapshot sharedByMe) => {
        'myTasks': myTasks.docs.length,
        'sharedWithMe': sharedWithMe.docs.length,
        'sharedByMe': sharedByMe.docs.length,
      },
    );
  }
}