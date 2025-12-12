// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/project_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/project_owner_dashboard.dart';
import 'screens/create_project_screen.dart';
import 'screens/investor_dashboard.dart';

import 'screens/my_investments_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/pending_projects_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/investment_confirmation_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProjectService()),
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
      title: 'GreenInvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/auth': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final isSignup = args is bool ? args : false;
          return AuthScreen(initialIsSignup: isSignup);
        },
        '/dashboard': (context) => const ProjectOwnerDashboard(),
        '/create-project': (context) => const CreateProjectScreen(),
        '/investor-dashboard': (context) => const InvestorDashboard(),

        '/my-investments': (context) => const MyInvestmentsScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin-users': (context) => const AdminUsersScreen(),
        '/pending-projects': (context) => const PendingProjectsScreen(),
        '/investment-confirmation': (context) => const InvestmentConfirmationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}