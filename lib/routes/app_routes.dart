import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/customer/customer_list_screen.dart';
import '../screens/sync/sync_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../core/theme/app_theme.dart';

class AppRoutes extends StatelessWidget {
  const AppRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VNPAY Nước',
      theme: AppTheme.lightTheme,
      initialRoute: "/splash", // Thiết lập màn hình chờ làm màn hình khởi đầu
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
        "/customer-list": (context) => const CustomerListScreen(),
        "/sync": (context) => const SyncScreen(),
        "/history": (context) => const HistoryScreen(),
        "/profile": (context) => const ProfileScreen(),
      },
    );
  }
}
