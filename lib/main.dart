import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ganpatibapa/pages/bottombars/aarti_page.dart';
import 'package:ganpatibapa/pages/bottombars/profile_screen.dart';
import 'package:ganpatibapa/pages/bottombars/search_result_screen.dart';
import 'package:ganpatibapa/pages/video_upload_screen.dart';
import 'firebase_options.dart';
import 'authentication/signup_page.dart';
import 'pages/splash_screen.dart';
import 'authentication/login_screen.dart';
import 'pages/home_page.dart';
import 'package:ganpatibapa/pages/bottombars/social_feed_screen.dart';
import 'package:ganpatibapa/pages/navigation/navigation.dart'; // Import NavigationService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ganpatti App',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey, // Set the navigator key
      onGenerateRoute: (settings) {
        final arguments = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignUpScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/social_feed':
            return MaterialPageRoute(builder: (context) => const VideoFeedScreen());
          case '/upload':
            final uid = arguments?['uid'] as String?;
            return MaterialPageRoute(
              builder: (context) => MediaUploadScreen(uid: uid ?? ''),
            );
          case '/aarti':
            return MaterialPageRoute(builder: (context) => const AartiPostTab());
          case '/search':
            final searchController = arguments?['searchController'] as TextEditingController?;
            return MaterialPageRoute(
              builder: (context) => SearchResultsScreen(searchController: searchController ?? TextEditingController()),
            );
          case '/profile':
            final uid = arguments?['uid'] as String?;
            return MaterialPageRoute(
              builder: (context) => ProfileScreen(uid: uid ?? ''),
            );
          default:
            return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
      },
    );
  }
}
