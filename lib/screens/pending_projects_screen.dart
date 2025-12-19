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
  String _selectedStatus = 'TOUS';
  List<dynamic> _projects = [];
  bool _isLoading = true;

  final List<String> _statusOptions = [
    'TOUS',
    'EN_ATTENTE',
    'VALIDE',
    'REJETE',
    'EN_COURS',
    'TERMINE',
  ];

  @override
  void initState() {
    super.initState();
    // Récupérer le statut initial depuis les arguments de navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && _statusOptions.contains(args)) {
        setState(() => _selectedStatus = args);
      }
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      // Utiliser fetchProjects qui met à jour _projects dans le provider
      final projectService = context.read<ProjectService>();
      await projectService.fetchProjects(size: 100); // Fetch more to get all
      
      if (mounted) {
        setState(() {
          _projects = projectService.projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading projects: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gestion des Projets'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
          const UserMenuButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _statusOptions.map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_formatStatus(status)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                  builder: (context) {
                    final filtered = _projects.where((p) {
                      if (_selectedStatus == 'TOUS') return true;
                      return (p.status?.toUpperCase() ?? '') == _selectedStatus;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             const Icon(Icons.folder_open, size: 48, color: Colors.grey),
                             const SizedBox(height: 16),
                             Text("Aucun projet ${_formatStatus(_selectedStatus).toLowerCase()}"),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final project = filtered[index];
                        return Semantics(
                          label: 'project_item_$index',
                          child: Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Porteur: ${project.ownerId}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('Statut: '),
                                      _getStatusChip(project.status),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
                                ).then((_) {
                                   _loadProjects(); // Refresh list on return
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'TOUS': return 'Tous';
      case 'EN_ATTENTE': return 'En attente';
      case 'VALIDE': return 'Validé';
      case 'REJETE': return 'Rejeté';
      case 'EN_COURS': return 'En cours';
      case 'TERMINE': return 'Terminé';
      default: return status;
    }
  }

  Widget _getStatusChip(String? status) {
    Color color = Colors.grey;
    switch (status) {
      case 'VALIDE': color = Colors.green; break;
      case 'REJETE': color = Colors.red; break;
      case 'EN_ATTENTE': color = Colors.orange; break;
      case 'EN_COURS': color = Colors.blue; break;
    }
    return Chip(
      label: Text(status ?? '?', style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}