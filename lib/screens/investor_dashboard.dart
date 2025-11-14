// lib/screens/investor_dashboard.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

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
                  const Text(
                    'Projets disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  final projects = [
                    {
                      'title': 'Parc solaire communautaire',
                      'description': 'Installation de 500 panneaux solaires pour alimenter 200 foyers en énergie propre.',
                      'location': 'Ouarzazate, Maroc',
                      'progress': 75,
                      'amount': '75,000 MAD / 100,000 MAD',
                      'type': 'Solaire',
                      'image': 'https://images.unsplash.com/photo-1593720213428-28a5b9e94613?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80',
                    },
                    {
                      'title': 'Parc éolien côtier',
                      'description': 'Parc éolien de 10 turbines pour produire 5 MW d’électricité renouvelable.',
                      'location': 'Essaouira, Maroc',
                      'progress': 40,
                      'amount': '40,000 MAD / 100,000 MAD',
                      'type': 'Éolien',
                      'image': 'https://images.unsplash.com/photo-1509391366360-2e959784a276?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80',
                    },
                    {
                      'title': 'Mini-centrale hydraulique',
                      'description': 'Petite centrale hydroélectrique sur un cours d’eau local pour fournir de l’énergie aux villages environnants.',
                      'location': 'Azilal, Maroc',
                      'progress': 20,
                      'amount': '20,000 MAD / 100,000 MAD',
                      'type': 'Hydraulique',
                      'image': 'https://images.unsplash.com/photo-1581092580497-e0d23cbdf340?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=80',
                    },
                  ];

                  final project = projects[index];

                  return Card(
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
                                project['image'] as String,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(child: Text('Image indisponible')),
                                ),
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
                                  project['type'] as String,
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
                                project['title'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project['description'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                project['location'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: (project['progress'] as int) / 100,
                                backgroundColor: Colors.grey[200],
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${project['progress']}% financé',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    project['amount'] as String,
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
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/project-detail');
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
                            ],
                          ),
                        ),
                      ],
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