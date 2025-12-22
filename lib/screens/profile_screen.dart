import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/snackbar_helper.dart';
import '../widgets/user_menu_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _soldeController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _soldeController = TextEditingController(text: user?.solde?.toString() ?? '0.0');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _soldeController.dispose();
    super.dispose();
  }

  bool get _isInvestor {
    final user = context.read<AuthService>().currentUser;
    return user?.role.toUpperCase() == 'INVESTISSEUR';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthService>();
      final user = auth.currentUser;
      
      if (user == null) return;

      final success = await auth.updateProfile(
        // id: user.id,  // ✅ Plus nécessaire avec /users/me
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        solde: _isInvestor ? double.tryParse(_soldeController.text) : null,
      );
      
      if (!mounted) return;

      if (success) {
        showTopSnackBar(context, 'Profil mis à jour avec succès');
        setState(() => _isEditing = false);
      } else {
        showTopSnackBar(context, 'Erreur lors de la mise à jour', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Utilisateur non connecté')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: true, // Default is true, but being explicit
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            key: const Key('btn_edit_profile'),
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          const UserMenuButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user.role,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildTextField(
                controller: _usernameController,
                label: 'Nom d\'utilisateur',
                icon: Icons.person,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                enabled: _isEditing,
              ),

              // Champ Solde uniquement pour les Investisseurs
              if (_isInvestor) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _soldeController,
                  label: 'Solde (MAD)',
                  icon: Icons.account_balance_wallet,
                  enabled: _isEditing,
                  isNumber: true,
                  semanticsLabel: 'input_solde',
                ),
              ],

              if (_isEditing) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: 'btn_save_profile',
                    child: ElevatedButton(
                      key: const Key('btn_save_profile'),
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enregistrer les modifications',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool isNumber = false,
    String? semanticsLabel,
  }) {
    return Semantics(
      label: semanticsLabel,
      child: TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ce champ est requis';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: enabled ? AppColors.inputBg : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      key: semanticsLabel != null ? Key(semanticsLabel) : null,
    ),
  );
}
}
