import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todolity/data/repositories/shared_tasks_repository.dart';
import 'package:todolity/data/repositories/user_repository.dart';
import 'package:todolity/presentation/blocs/auth/auth_event.dart';
import 'package:todolity/presentation/blocs/auth/auth_state.dart';
import 'package:todolity/presentation/blocs/shared_tasks/shared_tasks_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/firebase_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/tasks/task_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/tasks/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Firebase Messaging
  final messaging = FirebaseMessaging.instance;

  try {
    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM Token only if authorized
      final fcmToken = await messaging.getToken();
      print('FCM Token: $fcmToken');

      if (fcmToken != null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({
            'fcmTokens': FieldValue.arrayUnion([fcmToken])
          });
        }
      }
    }
  } catch (e) {
    print('Failed to get FCM token: $e');
    // Continue with app initialization even if FCM fails
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AuthRepository authRepository = AuthRepository();
  final TaskRepository taskRepository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SharedTaskBloc>(
      create: (context) => SharedTaskBloc(
        repository: SharedTaskRepository(),
      ),
    ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: authRepository,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(
            taskRepository: taskRepository,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, 
        title: 'Todolity',
         theme: ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      
    ),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF036ac9),
      secondary: const Color(0xFF2A2A2A),
      surface: const Color(0xFF2A2A2A),
      background: const Color(0xFF1E1E1E),
    ),
  ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Show splash screen while checking auth state
            if (state is AuthLoading) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            // Navigate based on auth state
            if (state is AuthSuccess) {
              return TaskListScreen();
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}