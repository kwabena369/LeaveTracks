import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leave_tracks/screens/auth_screen.dart'; // From previous setup
import 'package:leave_tracks/Screens/CameraCapture/CameraScreen.dart';
import 'package:leave_tracks/Screens/Dashboard/DashBoard.dart';
import 'package:leave_tracks/Screens/Trips/LandingPage.dart';
import 'package:leave_tracks/Screens/VideoChat/ReroutingRoutes/RRoute.dart';
import 'package:leave_tracks/Screens/VideoChat/TestRoom/AIAssistedMap.dart';
import 'package:leave_tracks/Screens/VideoChat/TestRoom/test.dart';
import 'package:leave_tracks/Service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Firebase Error: $e')),
      ),
    ));
    return;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Leave Tracks",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/auth': (context) => const AuthScreen(),
      '/home': (context) => const LandingPage(),
      '/myRoute': (context) => const LandingPage(),
      '/settings': (context) => const LandingPage(),
      '/testVideo': (context) => const TestRoom(),
      '/aiShine': (context) => const AIAssistedMap(),
      '/cameraCapture': (context) => const CameraScreen(),
      '/dashboard': (context) => const Dashboard(),
      '/route': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return Rroute(
          tripName: args['tripName'],
          routeId: args['routeId'],
        );
      },
    };
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Waiting for auth state...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          print('Auth stream error: ${snapshot.error}');
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final bool isAuthenticated = snapshot.hasData;
        final User? user = snapshot.data;
        print('User authenticated: $isAuthenticated');
        return MainScreen(
          isAuthenticated: isAuthenticated,
          authService: authService,
          user: user,
        );
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  final bool isAuthenticated;
  final AuthService authService;
  final User? user;

  const MainScreen({
    super.key,
    required this.isAuthenticated,
    required this.authService,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Tracks'),
      ),
      body: const LandingPage(), // Always show LandingPage
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),
            _buildDrawerItem(context, 'Home', Icons.home, '/home'),
            _buildDrawerItem(context, 'My Route', Icons.route, '/myRoute'),
            _buildDrawerItem(context, 'Settings', Icons.settings, '/settings'),
            _buildDrawerItem(context, 'Test Video', Icons.videocam, '/testVideo'),
            _buildDrawerItem(context, 'AI Shine', Icons.map, '/aiShine'),
            _buildDrawerItem(context, 'Camera Capture', Icons.camera_alt, '/cameraCapture'),
            _buildDrawerItem(context, 'Dashboard', Icons.dashboard, '/dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      accountName: Text(
        isAuthenticated ? (user?.displayName ?? 'User') : 'Guest',
        style: const TextStyle(fontSize: 18),
      ),
      accountEmail: Text(
        isAuthenticated ? (user?.email ?? '') : 'Not logged in',
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: isAuthenticated && user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : null,
        child: !isAuthenticated || user?.photoURL == null
            ? const Icon(Icons.person, size: 40)
            : null,
      ),
      otherAccountsPictures: [
        if (isAuthenticated)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                await authService.signOut();
                print('User signed out');
                if (context.mounted) {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              } catch (e) {
                print('Sign out error: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              }
            },
          ),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isAuthenticated && _isProtectedRoute(route)) {
          Navigator.pushNamed(context, '/auth');
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  bool _isProtectedRoute(String route) {
    const protectedRoutes = [
      '/myRoute',
      '/settings',
      '/testVideo',
      '/aiShine',
      '/cameraCapture',
      '/dashboard',
    ];
    return protectedRoutes.contains(route);
  }
}