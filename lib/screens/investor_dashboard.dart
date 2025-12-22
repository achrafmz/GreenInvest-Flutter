// lib/screens/investor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/user_menu_button.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';
import '../models/project_model.dart';
import 'project_detail_screen.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<ProjectService>().fetchPublicProjects()
    );
  }

  String _getProjectImage(dynamic project) { 
    // Si une image est uploadée, l'utiliser
    if (project is Project && project.imageUrl != null && project.imageUrl!.isNotEmpty) {
      if (project.imageUrl!.startsWith('http')) {
        return project.imageUrl!;
      }
      
      // Robust URL construction
      String baseUrl = ApiService.baseUrl;
      String path = project.imageUrl!;
      
      if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
        return '$baseUrl/$path';
      }
      return '$baseUrl$path';
    }

    // Fallback: Images par défaut selon le type
    final description = (project is Project) ? project.description : (project as String);
    if (description.toLowerCase().contains('solaire')) {
      return 'https://images.unsplash.com/photo-1593720213428-28a5b9e94613?auto=format&fit=crop&w=800&q=80';
    } else if (description.toLowerCase().contains('eolien') || description.toLowerCase().contains('éolien')) {
      return 'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=800&q=80';
    } else if (description.toLowerCase().contains('hydraulique')) {
      return 'https://images.unsplash.com/photo-1581092580497-e0d23cbdf340?auto=format&fit=crop&w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?auto=format&fit=crop&w=800&q=80';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête vert
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Projets disponibles',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const UserMenuButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un projet...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildFilterChip('Filtres', Icons.filter_alt),
                  const SizedBox(width: 8),
                  _buildFilterChip('Solaire'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Éolien'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hydraulique'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ProjectService>(
                builder: (context, projectService, child) {
                  if (projectService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (projectService.projects.isEmpty) {
                    return const Center(child: Text('Aucun projet disponible'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: projectService.projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final project = projectService.projects[index];
                      final progress = (project.targetAmount > 0) 
                          ? (project.currentAmount / project.targetAmount) 
                          : 0.0;
                      
                      // Déterminer le type pour l'image (logique simple pour l'instant)
                      final type = project.description.toLowerCase().contains('eolien') ? 'Éolien' : 'Solaire';

                      return GestureDetector(
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(project: project),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      _getProjectImage(project),
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, exception, stackTrace) {
                                        debugPrint('❌ Failed to load image: ${_getProjectImage(project)}');
                                        debugPrint('❌ Error: $exception');
                                        return Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        project.status,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    /*
                                    Text(
                                      project['location'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    */
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[200],
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${(progress * 100).toStringAsFixed(1)}% financé',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          '${project.currentAmount} / ${project.targetAmount} MAD',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Semantics(
                                        label: 'btn_view_project_$index',
                                        child: OutlinedButton(
                                        key: Key('btn_view_project_$index'),
                                        onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProjectDetailScreen(project: project),
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: BorderSide(color: AppColors.primary),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Text('Voir plus'),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_ios, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, [IconData? icon]) {
    return FilterChip(
      label: Row(
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.grey[700]),
          if (icon != null) const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
      selected: false,
      onSelected: (bool selected) {},
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: const TextStyle(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}

