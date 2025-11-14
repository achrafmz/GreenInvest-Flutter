// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Investisseur'; // Par défaut

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (_isLoginMode) {
      print('CONNEXION → Email: $email');
      Navigator.pushReplacementNamed(context, '/');
    } else {
      print('INSCRIPTION → Email: $email, Rôle: $_selectedRole');
      if (_selectedRole == 'Investisseur') {
        Navigator.pushReplacementNamed(context, '/investor-dashboard');
      } else if (_selectedRole == 'Porteur de projet') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (_selectedRole == 'Administrateur') {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Logo & titre
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 28,
                child: Icon(Icons.eco, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'GreenInvest',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // Toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLoginMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isLoginMode ? Colors.white : null,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Connexion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isLoginMode
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLoginMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isLoginMode ? null : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Créer un compte',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isLoginMode
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                hintText: 'votre@email.com',
              ),
              const SizedBox(height: 24),

              // Mot de passe
              _buildTextField(
                label: 'Mot de passe',
                controller: _passwordController,
                icon: Icons.lock,
                hintText: '••••••••',
                obscureText: true,
              ),

              // ✅ RÔLE : uniquement en mode INSCRIPTION
              if (!_isLoginMode) ...[
                const SizedBox(height: 24),
                _buildRoleDropdown(),
              ],

              const Spacer(),

              // Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLoginMode ? 'Se connecter' : 'Créer un compte',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            hintText: hintText,
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          onChanged: (value) => setState(() => _selectedRole = value!),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Investisseur', child: Text('Investisseur')),
            DropdownMenuItem(
                value: 'Porteur de projet', child: Text('Porteur de projet')),
            DropdownMenuItem(value: 'Administrateur', child: Text('Administrateur')),
          ],
        ),
      ],
    );
  }
}