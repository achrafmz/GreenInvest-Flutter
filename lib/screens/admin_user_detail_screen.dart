import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../constants/app_colors.dart';
import '../services/project_service.dart';
import 'project_detail_screen.dart';
import '../widgets/user_menu_button.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final User user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les projets si c'est un porteur de projet
    if (widget.user.role == 'PORTEUR_PROJET') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use the new Admin specific method which handles pending projects
        context.read<ProjectService>().fetchUserProjectsAsAdmin(widget.user.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(widget.user.username),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: const [UserMenuButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profile
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _getRoleColor(widget.user.role),
                      child: Text(
                        widget.user.username.isNotEmpty ? widget.user.username[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.user.username,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRoleColor(widget.user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getRoleColor(widget.user.role)),
                      ),
                      child: Text(
                        widget.user.role,
                        style: TextStyle(
                          color: _getRoleColor(widget.user.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Divider(),
              const SizedBox(height: 24),

              // Contenu dynamique selon le rôle
              if (widget.user.role == 'PORTEUR_PROJET') ...[
                const Text(
                  'Projets créés',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Consumer<ProjectService>(
                  builder: (context, projectService, child) {
                    final projects = projectService.getProjectsByOwner(widget.user.id);
                    
                    if (projectService.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (projectService.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.red[50],
                        child: Text(
                          'Erreur: ${projectService.error}\n(L\'endpoint Admin pour les projets ne répond pas)',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (projects.isEmpty) {
                      return const Text('Aucun projet trouvé pour cet utilisateur.');
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final project = projects[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
                              );
                            },
                            title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${project.currentAmount} / ${project.targetAmount} MAD'),
                            trailing: Chip(
                              label: Text(
                                project.status ?? 'N/A', 
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ] else if (widget.user.role == 'INVESTISSEUR') ...[
                 const Text(
                  'Investissements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: const [
                       Icon(Icons.construction, size: 48, color: Colors.grey),
                       SizedBox(height: 16),
                       Text(
                        'Historique des investissements à venir',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                 const Text(
                  'Informations Système',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Cet utilisateur a un accès administrateur complet.'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return Colors.blue;
      case 'INVESTISSEUR': return Colors.green;
      case 'PORTEUR_PROJET': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
