import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/map_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (e) {
    print("Firebase initialization failed/skipped: $e");
  }

  runApp(EcoTrackApp(isFirebaseInitialized: isFirebaseInitialized));
}

class EcoTrackApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  const EcoTrackApp({super.key, required this.isFirebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(isFirebaseInitialized: isFirebaseInitialized)),
        ChangeNotifierProvider(create: (_) => MapState()),
      ],
      child: MaterialApp(
        title: 'EcoTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Simple state check. In a real app, might want a loading state while fetching user
    if (authService.isAuthenticated) {
      return const HomeScreen(); 
      // return const Scaffold(body: Center(child: Text("Home Screen Placeholder"))); 
    } else {
      return const LoginScreen();
    }
  }
}
