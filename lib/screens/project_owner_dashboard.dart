// lib/screens/project_owner_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/user_menu_button.dart';

class ProjectOwnerDashboard extends StatelessWidget {
  const ProjectOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Consumer<AuthService>(
          builder: (context, auth, child) {
            final username = auth.currentUser?.username ?? 'Utilisateur';
            final capitalized = username.isNotEmpty 
                ? '${username[0].toUpperCase()}${username.substring(1)}' 
                : username;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour $capitalized',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Bienvenue sur votre tableau de bord',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          },
        ),
        actions: const [
          UserMenuButton(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Removed custom container header
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-project');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Créer un nouveau projet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mes projets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  final List<Map<String, dynamic>> projects = [
                    {
                      'name': 'Parc solaire',
                      'amount': '1,000,000 MAD',
                      'status': 'Financé',
                      'color': Colors.green,
                    },
                    {
                      'name': 'Biomasse',
                      'amount': '750,000 MAD',
                      'status': 'Validé',
                      'color': Color(0xFFFF9800),
                    },
                    {
                      'name': 'Hydraulique',
                      'amount': '1,050,000 MAD',
                      'status': 'En attente',
                      'color': Colors.grey,
                    },
                  ];

                  final project = projects[index];
                  final String name = project['name'] as String;
                  final String amount = project['amount'] as String;
                  final String status = project['status'] as String;
                  final Color color = project['color'] as Color;

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(amount, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

