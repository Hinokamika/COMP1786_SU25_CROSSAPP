import 'package:comp1876_su25_crossapp/auth_service.dart';
import 'package:comp1876_su25_crossapp/pages/main_pages/intro_page.dart';
import 'package:comp1876_su25_crossapp/pages/main_pages/login_page.dart';
import 'package:comp1876_su25_crossapp/pages/main_pages/menu_page.dart';
import 'package:comp1876_su25_crossapp/pages/main_pages/register_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/cart.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/home_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/profile_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/edit_profile_page.dart';
import 'package:comp1876_su25_crossapp/pages/site_pages/settings_page.dart';
import 'package:flutter/material.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/Login': (context) => const LoginPage(),
        '/Authentication': (context) => const RegisterPage(),
        '/MenuPage': (context) => const MenuPage(),
        '/IntroPage': (context) => const IntroPage(),
        '/ShowCart': (context) => const Cart(), // Placeholder for cart page
        '/ProfilePage': (context) =>
            const ProfilePage(), // Placeholder for profile page
        '/EditProfile': (context) => const EditProfilePage(),
        '/Settings': (context) => const SettingsPage(),
        '/HomePage': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const AuthGate());
        }
        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authServiceProvider,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData) {
              return const MenuPage();
            } else {
              return const IntroPage();
            }
          },
        );
      },
    );
  }
}
