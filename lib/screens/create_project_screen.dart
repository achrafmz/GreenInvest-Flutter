// lib/screens/create_project_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un projet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(hintText: 'Titre du projet')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Description')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Budget (MAD)')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Localisation')),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Projet soumis !')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Soumettre le projet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}