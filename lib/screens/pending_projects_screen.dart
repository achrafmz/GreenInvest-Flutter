// lib/screens/pending_projects_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/snackbar_helper.dart';

import '../widgets/user_menu_button.dart';

import 'package:provider/provider.dart';
import '../services/project_service.dart';
import 'project_detail_screen.dart';

class PendingProjectsScreen extends StatefulWidget {
  const PendingProjectsScreen({super.key});

  @override
  State<PendingProjectsScreen> createState() => _PendingProjectsScreenState();
}

class _PendingProjectsScreenState extends State<PendingProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // On utilise fetchProjects qui appelle /projets (qui semble retourner tout le monde pour l'instant)
      // Ou on pourrait avoir besoin d'un fetchPendingProjects spécifique si l'API le permettait.
      // Ici on va filtrer localement ce que fetchProjects retourne.
      context.read<ProjectService>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Projets en attente'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<ProjectService>(
            builder: (context, projectService, _) {
               final pendingCount = projectService.projects.where((p) => p.status == 'EN_ATTENTE').length;
               return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    '$pendingCount projets à valider',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }
          ),
          const UserMenuButton(),
        ],
      ),
      body: SafeArea(
        child: Consumer<ProjectService>(
          builder: (context, projectService, child) {
            if (projectService.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filtrage local pour les projets en attente
            // Basé sur le screenshot Postman, le statut est "EN_ATTENTE"
            final pendingProjects = projectService.projects
                .where((p) => p.status == 'EN_ATTENTE' || p.status == 'PENDING') // Safety check for both casing
                .toList();

            if (pendingProjects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun projet en attente',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pendingProjects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final project = pendingProjects[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      project.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                         Text(
                          project.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('Porteur: ${project.ownerId.substring(0, 8)}...'), // Shortened ID
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Montant: ${project.targetAmount} MAD',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(project: project),
                            ),
                          );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}