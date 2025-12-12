// lib/screens/create_project_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/project_service.dart';
import '../widgets/snackbar_helper.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nomController = TextEditingController();
  final _descController = TextEditingController();
  final _montantController = TextEditingController();
  final _contrepartieController = TextEditingController();
  final _rendementController = TextEditingController();
  final _dureeController = TextEditingController();
  String _typeContrepartie = 'POURCENTAGE_BENEFICES';

  @override
  void dispose() {
    _nomController.dispose();
    _descController.dispose();
    _montantController.dispose();
    _contrepartieController.dispose();
    _rendementController.dispose();
    _dureeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = context.read<ProjectService>();
      
      final success = await service.createProject(
        nom: _nomController.text.trim(),
        description: _descController.text.trim(),
        montantObjectif: double.parse(_montantController.text),
        contrepartie: _contrepartieController.text.trim(),
        pourcentageRendement: double.parse(_rendementController.text),
        dureeContrepartie: int.parse(_dureeController.text),
        typeContrepartie: _typeContrepartie,
      );

      if (!mounted) return;

      if (success) {
        showTopSnackBar(context, 'Projet créé avec succès !');
        Navigator.pop(context);
        // Optionnel : Recharger le dashboard
      } else {
        showTopSnackBar(context, service.error ?? 'Erreur lors de la création', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer un projet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informations Générales'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nomController,
                  label: 'Nom du projet',
                  hint: 'Ex: Ferme Solaire Agadir',
                  icon: Icons.title,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Décrivez votre projet en détail...',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _montantController,
                  label: 'Montant Objectif (MAD)',
                  hint: 'Ex: 100000',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contrepartieController,
                  label: 'Détail de la contrepartie',
                  hint: 'Ex: Part des bénéfices annuels...',
                  icon: Icons.card_giftcard,
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Détails Financiers'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _rendementController,
                        label: 'Rendement (%)',
                        hint: 'Ex: 10',
                        icon: Icons.percent,
                        keyboardType: TextInputType.number,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _dureeController,
                        label: 'Durée (Mois)',
                        hint: 'Ex: 36',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                const Text('Type de Contrepartie', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _typeContrepartie,
                  items: const [
                    DropdownMenuItem(
                      value: 'POURCENTAGE_BENEFICES', 
                      child: Text('Pourcentage Bénéfices')
                    ),
                    DropdownMenuItem(
                      value: 'TITRES_PARTICIPATIFS', 
                      child: Text('Titres Participatifs')
                    ),
                    DropdownMenuItem(
                      value: 'AUTRE', 
                      child: Text('Autre')
                    ),
                  ],
                  onChanged: (v) => setState(() => _typeContrepartie = v!),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputBg,
                    prefixIcon: const Icon(Icons.category, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Consumer<ProjectService>(
                  builder: (context, service, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: service.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: service.isLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Créer le projet',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: AppColors.primary
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Champ requis';
            if (isNumber && double.tryParse(value) == null) return 'Valeur invalide';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            alignLabelWithHint: maxLines > 1,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}