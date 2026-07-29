import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yensss/controllers/language_controller.dart';
import 'package:yensss/controllers/main_nav_controller.dart';
import 'package:yensss/controllers/notifications_controller.dart';
import 'package:yensss/core/app_config.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/firebase_options.dart';
import 'package:yensss/pages/cart_provider.dart';
import 'package:yensss/presentation/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(
          create: (_) => NotificationsController()..ensureSeeded(),
        ),
        ChangeNotifierProxyProvider<NotificationsController, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, notifications, cart) {
            cart!.setNotificationsController(notifications);
            return cart;
          },
        ),
        ChangeNotifierProvider(create: (_) => MainNavController()),
        Provider<YensRepository>(
          create: (_) => YensRepository(),
          dispose: (_, YensRepository r) => r.dispose(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appDisplayName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: YensTheme.yellow,
          onPrimary: YensTheme.navy,
          secondary: YensTheme.navy,
          onSecondary: Colors.white,
          surface: YensTheme.cream,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: YensTheme.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: YensTheme.yellow,
          foregroundColor: YensTheme.navy,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
