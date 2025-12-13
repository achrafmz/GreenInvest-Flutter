// lib/screens/my_investments_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/user_menu_button.dart';

import 'package:provider/provider.dart';
import '../services/investment_service.dart';

class MyInvestmentsScreen extends StatefulWidget {
  const MyInvestmentsScreen({super.key});

  @override
  State<MyInvestmentsScreen> createState() => _MyInvestmentsScreenState();
}

class _MyInvestmentsScreenState extends State<MyInvestmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<InvestmentService>().fetchMyInvestments()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes investissements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        actions: const [UserMenuButton()],
      ),
      body: SafeArea(
        child: Consumer<InvestmentService>(
          builder: (context, investmentService, child) {
            if (investmentService.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final investments = investmentService.myInvestments;
            final totalInvested = investments.fold<double>(
              0, (sum, item) => sum + item.amount);

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Total investi: ${totalInvested.toStringAsFixed(2)} MAD',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${investments.length} investissements',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: investments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aucun investissement trouvé',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: investments.length,
                          itemBuilder: (context, index) {
                            final investment = investments[index];
                            final formattedDate = investment.dateInvestissement.length > 10 
                                ? investment.dateInvestissement.substring(0, 10) 
                                : investment.dateInvestissement;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(Icons.solar_power, color: AppColors.primary),
                                ),
                                title: Text(
                                  investment.nomProjet,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Date: $formattedDate'),
                                    Text('Contrat: ${investment.numeroContrat}'),
                                  ],
                                ),
                                trailing: Text(
                                  '${investment.amount.toStringAsFixed(0)} MAD',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}