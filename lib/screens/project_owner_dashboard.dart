// lib/screens/project_owner_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';
import '../widgets/user_menu_button.dart';
import 'project_detail_screen.dart';

class ProjectOwnerDashboard extends StatefulWidget {
  const ProjectOwnerDashboard({super.key});

  @override
  State<ProjectOwnerDashboard> createState() => _ProjectOwnerDashboardState();
}

class _ProjectOwnerDashboardState extends State<ProjectOwnerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      if (auth.currentUser != null) {
        context.read<ProjectService>().fetchOwnerProjects(auth.currentUser!.id);
      }
    });
  }

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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: Semantics(
                    label: 'btn_create_project_nav',
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
              child: Consumer2<AuthService, ProjectService>(
                builder: (context, auth, projectService, child) {
                  final user = auth.currentUser;
                  if (user == null) {
                    return const Center(child: Text('Veuillez vous connecter.'));
                  }
                  
                  // Utiliser getProjectsByOwner qui priorise maintenant la liste ownerProjects
                  // Ou utiliser directement projectService.ownerProjects si on est sûr que l'API filtre déjà
                  // Par prudence, on continue de filtrer par ownerId
                  final myProjects = projectService.getProjectsByOwner(user.id);

                  if (projectService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (myProjects.isEmpty) {
                    return const Center(
                      child: Text(
                        'Vous n\'avez pas encore créé de projet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: myProjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final project = myProjects[index];
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
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image section
                                SizedBox(
                                  width: 100,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                       if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                                          Image.network(
                                            () {
                                              if (project.imageUrl!.startsWith('http')) {
                                                return project.imageUrl!;
                                              }
                                              String baseUrl = ApiService.baseUrl;
                                              String path = project.imageUrl!;
                                              if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
                                                return '$baseUrl/$path';
                                              }
                                              return '$baseUrl$path';
                                            }(),
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                                            ),
                                          )
                                        else
                                          Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Icon(Icons.solar_power, size: 32, color: Colors.grey),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                // Text Content
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          project.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${project.currentAmount} / ${project.targetAmount} MAD',
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary, 
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              project.status, // Assuming status is plain text
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}

