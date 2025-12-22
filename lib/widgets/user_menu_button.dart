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
        final initials = _getInitials(user?.username ?? 'U');
        
        return Semantics(
          label: 'menu_user',
          child: PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            offset: const Offset(0, 50),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/auth', (route) => false);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              final role = user?.role ?? '';
              final roleLower = role.toLowerCase();
              final isInvestor =
                  roleLower.contains('investisseur') || roleLower.contains('investor');
              final isProjectOwner =
                  roleLower.contains('porteur') || roleLower.contains('project_owner');
              final isAdmin = roleLower.contains('admin');

              return [
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: 'Profil',
                  value: 'profile',
                  color: AppColors.primary,
                ),
                if (isInvestor)
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Investissements',
                    value: 'investments',
                    color: const Color(0xFFF59E0B),
                  ),
                if (isProjectOwner)
                  _buildMenuItem(
                    icon: Icons.folder_rounded,
                    title: 'Mes projets',
                    value: 'projects',
                    color: const Color(0xFF8B5CF6),
                  ),
                if (isAdmin) ...[
                  PopupMenuItem(
                    height: 1,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    enabled: false,
                    child: Container(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.people_rounded,
                    title: 'Utilisateurs',
                    value: 'users',
                    color: const Color(0xFF3B82F6),
                  ),
                  _buildMenuItem(
                    icon: Icons.list_alt_rounded,
                    title: 'Projets',
                    value: 'admin_projects',
                    color: const Color(0xFF10B981),
                  ),
                ],
                PopupMenuItem(
                  height: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabled: false,
                  child: Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Se déconnecter',
                  value: 'logout',
                  color: const Color(0xFFEF4444),
                ),
              ];
            },
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: value == 'logout' ? color : AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String username) {
    if (username.isEmpty) return 'U';
    final parts = username.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }
}
