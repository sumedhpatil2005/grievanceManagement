import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/models/user_model.dart';
import 'presentations/views/login_screen.dart';
import 'presentations/views/signup_screen.dart';
import 'presentations/views/moderator/moderator_dashboard.dart';
import 'presentations/views/principle/principal_dashboard.dart';
import 'presentations/views/student/submit_complaint.dart';
import 'presentations/views/splash_screen.dart'; // Import the SplashScreen
import 'services/auth_service.dart';
import 'services/complaint_service.dart'; // Import the ComplaintService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAaHnxnOLhPpDwf7P8iyfnzUthA9tOfUKk",
      appId: "1:184633312583:android:8306b4c86a9367e9ed7862",
      messagingSenderId: "184633312583",
      projectId: "grievancemanagement-85970",
    ),
  ); // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ), // Provide AuthService
        Provider(
          create: (_) => ComplaintService(), // Provide ComplaintService
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grievance Redressal System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => AuthWrapper(), // Role-based dashboard
      },
    );
  }
}

// Wrapper to check authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return FutureBuilder<bool>(
      future:
          authService.checkLoginStatus(), // Check if user is already logged in
      builder: (context, loginSnapshot) {
        if (loginSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (loginSnapshot.data == true) {
          // User is already logged in, fetch user details
          return StreamBuilder<User?>(
            stream: authService.userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasData) {
                // User is logged in, fetch user details
                return FutureBuilder<UserModel?>(
                  future: authService.getUserDetails(snapshot.data!.uid),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    } else if (userSnapshot.hasData &&
                        userSnapshot.data != null) {
                      // Redirect to role-based dashboard
                      return getRoleBasedScreen(userSnapshot.data!);
                    } else {
                      // User data not found, log out
                      authService.signOut();
                      return LoginScreen();
                    }
                  },
                );
              } else {
                // User is not logged in, show login screen
                return LoginScreen();
              }
            },
          );
        } else {
          // User is not logged in, show login screen
          return LoginScreen();
        }
      },
    );
  }
}

// Get role-based screen
Widget getRoleBasedScreen(UserModel user) {
  switch (user.role) {
    case 'student':
      return SubmitComplaintScreen(studentId: user.id);
    case 'moderator':
      return ModeratorDashboard(moderatorId: user.id);
    case 'principal':
      return PrincipleDashboard();
    default:
      throw Exception('Invalid role: ${user.role}');
  }
}
