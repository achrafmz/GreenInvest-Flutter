import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
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

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomController.dispose();
    _descController.dispose();
    // ... (rest of dispose)
    _montantController.dispose();
    _contrepartieController.dispose();
    _rendementController.dispose();
    _dureeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = context.read<ProjectService>();
      
      // Etape 1: Créer le projet
      final projectId = await service.createProject(
        nom: _nomController.text.trim(),
        description: _descController.text.trim(),
        montantObjectif: double.parse(_montantController.text),
        contrepartie: _contrepartieController.text.trim(),
        pourcentageRendement: double.parse(_rendementController.text),
        dureeContrepartie: int.parse(_dureeController.text),
        typeContrepartie: _typeContrepartie,
      );

      if (!mounted) return;

      if (projectId != null) {
        bool imageSuccess = true;

        // Etape 2: Upload de l'image (si sélectionnée)
        if (_selectedImage != null) {
          showTopSnackBar(context, 'Projet créé. Upload de l\'image en cours...', backgroundColor: Colors.blue);
          imageSuccess = await service.uploadProjectImage(projectId, _selectedImage!);
        }

        if (!mounted) return;

        if (imageSuccess) {
           showTopSnackBar(context, 'Projet créé avec succès !');
           Navigator.pop(context);
        } else {
           showTopSnackBar(context, 'Projet créé mais erreur lors de l\'upload d\'image.', isError: true);
           // On ferme quand même car le projet est créé
           Navigator.pop(context);
        }
      } else {
        showTopSnackBar(context, service.error ?? 'Erreur lors de la création du projet', isError: true);
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
                // Image Picker Section
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Ajouter une image de couverture', style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb
                                  ? Image.network(_selectedImage!.path, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.image)) // On Web XFile path is blob url usually
                                  : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Informations Générales'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nomController,
                  label: 'Nom du projet',
                  hint: 'Ex: Ferme Solaire Agadir',
                  icon: Icons.title,
                  semanticsLabel: 'input_project_name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Décrivez votre projet en détail...',
                  icon: Icons.description,
                  maxLines: 4,
                  semanticsLabel: 'input_project_desc',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _montantController,
                  label: 'Montant Objectif (MAD)',
                  hint: 'Ex: 100000',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  isNumber: true,
                  semanticsLabel: 'input_project_amount',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contrepartieController,
                  label: 'Détail de la contrepartie',
                  hint: 'Ex: Part des bénéfices annuels...',
                  icon: Icons.card_giftcard,
                  semanticsLabel: 'input_project_counterpart',
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
                        semanticsLabel: 'input_project_roi',
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
                        semanticsLabel: 'input_project_duration',
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
                      child: Semantics(
                          label: 'btn_submit_project',
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
    String? semanticsLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Semantics(
            label: semanticsLabel,
            child: TextFormField(
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
          ),
      ],
    );
  }
}