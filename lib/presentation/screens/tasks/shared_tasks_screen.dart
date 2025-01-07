import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolity/data/repositories/shared_tasks_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../blocs/shared_tasks/shared_tasks_bloc.dart';
import '../../blocs/shared_tasks/shared_tasks_event.dart';
import '../../widgets/shared_task_item.dart';
import '../../blocs/shared_tasks/shared_task_state.dart';

class SharedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SharedTaskBloc(
        repository: SharedTaskRepository(),
      )..add(LoadSharedTasks(FirebaseAuth.instance.currentUser!.uid)),
      child: SharedTasksView(),
    );
  }
}

class SharedTasksView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top padding for status bar
            SizedBox(height: MediaQuery.of(context).padding.top + 0),
            // Title
             Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text(
            'Shared Tasks',
            style: TextStyle(
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          ),
            SizedBox(height: 20),
            // Custom Tab Bar
            Container(

              margin: EdgeInsets.symmetric(horizontal: 0),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Color(0xffF6DEC2),
                  borderRadius: BorderRadius.circular(20),
                  
                ),
                labelColor: Colors.black,
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold
                ),
                unselectedLabelColor: Color.fromARGB(255, 0, 0, 0),
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text('Shared with Me', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text('Shared by Me',style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  _buildSharedWithMeTab(),
                  _buildSharedByMeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedWithMeTab() {
    return BlocBuilder<SharedTaskBloc, SharedTaskState>(
      builder: (context, state) {
        if (state is SharedTaskLoading) {
          return Center(child: CircularProgressIndicator(color: Color(0xffF6DEC2)));
        } else if (state is SharedTaskLoaded) {
          if (state.sharedWithMeTasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks shared with you',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(top: 8),
            itemCount: state.sharedWithMeTasks.length,
            itemBuilder: (context, index) {
              return SharedTaskItem(
                
                task: state.sharedWithMeTasks[index],
                isSharedByMe: false,
              );
            },
          );
        } else if (state is SharedTaskError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        return Center(
          child: Text(
            'No shared tasks found',
            style: TextStyle(color: Colors.black54),
          ),
        );
      },
    );
  }

  Widget _buildSharedByMeTab() {
    return BlocBuilder<SharedTaskBloc, SharedTaskState>(
      builder: (context, state) {
        if (state is SharedTaskLoading) {
          return Center(child: CircularProgressIndicator(color: Color(0xffF6DEC2)));
        } else if (state is SharedTaskLoaded) {
          if (state.sharedByMeTasks.isEmpty) {
            return Center(
              child: Text(
                'You haven\'t shared any tasks',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(top: 8),
            itemCount: state.sharedByMeTasks.length,
            itemBuilder: (context, index) {
              return SharedTaskItem(
                task: state.sharedByMeTasks[index],
                isSharedByMe: true,
              );
            },
          );
        } else if (state is SharedTaskError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        return Center(
          child: Text(
            'No shared tasks found',
            style: TextStyle(color: Colors.black54),
          ),
        );
      },
    );
  }
}