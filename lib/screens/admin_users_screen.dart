import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../constants/app_colors.dart';
import 'admin_user_detail_screen.dart';
import '../widgets/user_menu_button.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedFilter = 'Tous'; // 'Tous', 'PORTEUR_PROJET', 'INVESTISSEUR', 'ADMIN'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await context.read<AuthService>().fetchAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

   List<User> get _filteredUsers {
    if (_selectedFilter == 'Tous') return _users;
    return _users.where((u) => u.role.toUpperCase() == _selectedFilter).toList();
  }

  void _showAddAdminDialog() {
    final _formKey = GlobalKey<FormState>();
    final _usernameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isCreating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un Administrateur'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                      validator: (value) => value!.isEmpty ? 'Requis' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Requis' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'Min 6 caractères' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _isCreating ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isCreating = true);
                      
                      final success = await context.read<AuthService>().createAdmin(
                        username: _usernameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Admin créé avec succès')),
                          );
                          _loadUsers(); // Refresh list
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erreur lors de la création'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: _isCreating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: const [UserMenuButton()],
      ),
      body: Column(
        children: [
          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Tous', 'Tous'),
                const SizedBox(width: 8),
                _buildFilterChip('Porteurs', 'PORTEUR_PROJET'),
                const SizedBox(width: 8),
                _buildFilterChip('Investisseurs', 'INVESTISSEUR'),
                const SizedBox(width: 8),
                _buildFilterChip('Admins', 'ADMIN'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text('Erreur: $_errorMessage'))
                  : ListView.separated(
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ListTile(
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminUserDetailScreen(user: user),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(user.role),
                            foregroundColor: Colors.white,
                            child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?'),
                          ),
                          title: Text(user.username),
                          subtitle: Text('${user.email} • ${_formatRole(user.role)}'),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAdminDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_moderator),
        tooltip: 'Ajouter un Admin',
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: AppColors.primary,
    );
  }

  String _formatRole(String role) {
    if (role == 'PORTEUR_PROJET') return 'Porteur';
    if (role == 'INVESTISSEUR') return 'Investisseur';
    return role;
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN': return Colors.blue;
      case 'INVESTISSEUR': return Colors.green;
      case 'PORTEUR_PROJET': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
