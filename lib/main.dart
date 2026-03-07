import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/firebase_options.dart';
import 'package:myapp/core/theme.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/providers/home_card_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    developer.log('Firebase Initialized Successfully', name: 'myapp.main');
  } catch (e, s) {
    developer.log('Firebase Initialization Failed', name: 'myapp.main', error: e, stackTrace: s);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<FirestoreService, HomeCardProvider>(
          create: (_) => HomeCardProvider(),
          update: (_, firestore, provider) => provider!..updateFirestore(firestore),
        ),
      ],
      child: const BabyBloomApp(),
    ),
  );
}

class BabyBloomApp extends StatelessWidget {
  const BabyBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Bloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        // ✅ 브랜드 스플래시로 교체
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F0),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🌸', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 12),
                  CircularProgressIndicator(color: Color(0xFFC97B9B)),
                ],
              ),
            ),
          );
        }

        // 인증 데이터 확인
        if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
