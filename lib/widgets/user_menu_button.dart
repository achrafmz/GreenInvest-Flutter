import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';

class UserMenuButton extends StatelessWidget {
  const UserMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        return PopupMenuButton<String>(
          icon: const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          tooltip: 'Menu utilisateur',
          onSelected: (value) {
            switch (value) {
              case 'profile':
                Navigator.pushNamed(context, '/profile');
                break;
              case 'investments':
                Navigator.pushNamed(context, '/my-investments');
                break;
              case 'projects':
                Navigator.pushNamed(context, '/dashboard');
                break;
              case 'admin_projects':
                Navigator.pushNamed(context, '/pending-projects');
                break;
              case 'users':
                Navigator.pushNamed(context, '/admin-users');
                break;
              case 'logout':
                authService.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            final role = user?.role ?? '';
            final roleLower = role.toLowerCase();
            final isInvestor = roleLower.contains('investisseur') || roleLower.contains('investor');
            final isProjectOwner = roleLower.contains('porteur') || roleLower.contains('project_owner');
            final isAdmin = roleLower.contains('admin');

            return [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              if (isInvestor)
                const PopupMenuItem(
                  value: 'investments',
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Investissements'),
                    ],
                  ),
                ),
              if (isProjectOwner)
                const PopupMenuItem(
                  value: 'projects',
                  child: Row(
                    children: [
                      Icon(Icons.work, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Mes projets'),
                    ],
                  ),
                ),
              if (isAdmin) ...[
                const PopupMenuItem(
                  value: 'users',
                  child: Row(
                    children: [
                      Icon(Icons.group, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Utilisateurs'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'admin_projects',
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Projets'),
                    ],
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ];
          },
        );
      },
    );
  }
}
