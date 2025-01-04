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

  // Light theme configuration
  final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF036ac9)),
      titleTextStyle: TextStyle(
        color: Color(0xFF036ac9),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF036ac9),
      secondary: Color(0xFFE0E0E0),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF1E1E1E),
      onSurface: Color(0xFF1E1E1E),
      onBackground: Color(0xFF1E1E1E),
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF036ac9)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF036ac9),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // Dark theme configuration
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF036ac9)),
      titleTextStyle: TextStyle(
        color: Color(0xFF036ac9),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF036ac9),
      secondary: Color(0xFF2A2A2A),
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF2A2A2A),
      elevation: 2,
      shadowColor: Colors.black26,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF036ac9)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF036ac9),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

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
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system, // This will follow system theme settings
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Show splash screen while checking auth state
            if (state is AuthLoading) {
              return const Scaffold(
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