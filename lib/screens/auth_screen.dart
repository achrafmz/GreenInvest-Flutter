// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/snackbar_helper.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsSignup;
  
  const AuthScreen({super.key, this.initialIsSignup = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLoginMode;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Investisseur';

  @override
  void initState() {
    super.initState();
    _isLoginMode = !widget.initialIsSignup;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (username.isEmpty || password.isEmpty) {
      showTopSnackBar(context, 'Nom d\'utilisateur et mot de passe requis', isError: true);
      return;
    }

    if (!_isLoginMode && email.isEmpty) {
      showTopSnackBar(context, 'L\'email est requis pour l\'inscription', isError: true);
      return;
    }

    final authService = context.read<AuthService>();

    if (_isLoginMode) {
      // ✅ LOGIN via USERNAME
      final success = await authService.login(username, password);
      if (success && mounted) {
        final user = authService.currentUser;
        final roleLower = user?.role?.toLowerCase() ?? '';
        
        // Admin → Dashboard Admin
        if (roleLower.contains('admin')) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } 
        else if (roleLower.contains('porteur') || roleLower.contains('project_owner')) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        else {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else if (mounted) {
        showTopSnackBar(context, 'Échec de la connexion. Vérifiez vos identifiants.', isError: true);
      }
    } else {
      // ✅ SIGNUP
      String backendRole = 'INVESTISSEUR';
      if (_selectedRole == 'Porteur de projet') {
        backendRole = 'PORTEUR_PROJET';
      } else if (_selectedRole == 'Administrateur') {
        backendRole = 'ADMIN';
      }

      final result = await authService.signup(
        username: username,
        email: email,
        password: password,
        role: backendRole,
      );

      if (mounted) {
        if (result['success'] == true) {
          showTopSnackBar(
            context,
            result['message'] ?? 'Inscription réussie ! Veuillez vous connecter.',
          );
          setState(() {
            _isLoginMode = true;
          });
        } else {
          showTopSnackBar(
            context,
            result['message'] ?? 'Erreur lors de l\'inscription.',
            isError: true,
            duration: const Duration(seconds: 5),
          );
        }
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

              // Toggle Connexion / Créer un compte
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'tab_login',
                        identifier: 'tab_login',
                        child: GestureDetector(
                          key: const Key('tab_login'),
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
                    ),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'tab_signup',
                        identifier: 'tab_signup',
                        child: GestureDetector(
                          key: const Key('tab_signup'),
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ✅ USERNAME (Toujours visible et en PREMIER)
              _buildTextField(
                label: 'Nom d\'utilisateur',
                controller: _usernameController,
                icon: Icons.person,
                hintText: 'username',
                semanticsLabel: 'input_username',
              ),
              const SizedBox(height: 24),

              // ✅ EMAIL (Uniquement pour SIGNUP)
              if (!_isLoginMode) ...[
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  hintText: 'votre@email.com',
                  semanticsLabel: 'input_email',
                ),
                const SizedBox(height: 24),
              ],

              // ✅ PASSWORD (Toujours visible)
              _buildTextField(
                label: 'Mot de passe',
                controller: _passwordController,
                icon: Icons.lock,
                hintText: '••••••••',
                obscureText: true,
                semanticsLabel: 'input_password',
              ),

              // ✅ RÔLE (Uniquement pour SIGNUP)
              if (!_isLoginMode) ...[
                const SizedBox(height: 24),
                _buildRoleDropdown(),
              ],

              const Spacer(),

              // Bouton d'action
              Consumer<AuthService>(
                builder: (context, auth, child) {
                  return auth.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: Semantics(
                              label: 'btn_submit_auth',
                              identifier: 'btn_submit_auth',
                              button: true,
                              child: ElevatedButton(
                                key: const Key('btn_submit_auth'),
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
                        );
                },
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
    String? semanticsLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Semantics(
            label: semanticsLabel,
            identifier: semanticsLabel,
            child: TextField(
              key: semanticsLabel != null ? Key(semanticsLabel) : null,
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
        Semantics(
          label: 'dropdown_role',
          child: DropdownButtonFormField<String>(
          key: const Key('dropdown_role'),
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
            ],
          ),
        ),
      ],
    );
  }
}