import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/investment_service.dart';
import '../constants/app_colors.dart';

class InvestmentDialog extends StatefulWidget {
  final String projectId;
  final String projectName;
  final double projectRoi;

  const InvestmentDialog({
    Key? key,
    required this.projectId,
    required this.projectName,
    required this.projectRoi,
  }) : super(key: key);

  @override
  State<InvestmentDialog> createState() => _InvestmentDialogState();
}

class _InvestmentDialogState extends State<InvestmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final investmentService = Provider.of<InvestmentService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    final amount = double.parse(_amountController.text);

    setState(() => _isLoading = true);

    final success = await investmentService.invest(
      projectId: widget.projectId,
      investorId: user.id,
      amount: amount,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // Refresh user data to update balance
        await authService.retryUserFetch(); 
        if (mounted) {
           Navigator.of(context).pop(amount); // Return amount on success
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(investmentService.error ?? 'Erreur inconnue')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final balance = user?.solde ?? 0.0;

    return AlertDialog(
      title: const Text('Investir dans le projet'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.projectName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Votre solde disponible:'),
                    Text(
                      '${balance.toStringAsFixed(2)} MAD',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant à investir (MAD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Montant invalide';
                  }
                  if (amount > balance) {
                    return 'Solde insuffisant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Retour estimé: ${widget.projectRoi}%',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Valider'),
        ),
      ],
    );
  }
}
