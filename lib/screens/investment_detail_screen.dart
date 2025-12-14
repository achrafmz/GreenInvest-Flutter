import 'package:flutter/material.dart';
import '../models/investment_model.dart';
import '../constants/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class InvestmentDetailScreen extends StatelessWidget {
  final Investment investment;

  const InvestmentDetailScreen({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Détails de l\'investissement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(),
            const SizedBox(height: 24),
            _buildContractSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.solar_power, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    investment.nomProjet,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow('Montant investi', '${investment.amount.toStringAsFixed(2)} MAD', isBold: true),
            const SizedBox(height: 16),
            _buildInfoRow('Date', investment.dateInvestissement),
            const SizedBox(height: 16),
            _buildInfoRow('investisseur', investment.nomInvestisseur),
             const SizedBox(height: 16),
            _buildInfoRow('Numéro de contrat', investment.numeroContrat),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildContractSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _generateAndDownloadPdf(context),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Télécharger le contrat (PDF)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generateAndDownloadPdf(BuildContext context) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('GreenInvest', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Contrat d\'Investissement', style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Numéro de contrat: ${investment.numeroContrat}'),
                pw.Text('Date: ${investment.dateInvestissement}'),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text('Entre les soussignés :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('L\'Investisseur : ${investment.nomInvestisseur}'),
                pw.Text('Et GreenInvest (pour le compte du projet : ${investment.nomProjet})'),
                pw.SizedBox(height: 20),
                pw.Text('Détails de l\'investissement :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Bullet(text: 'Projet : ${investment.nomProjet}'),
                pw.Bullet(text: 'Montant investi : ${investment.amount.toStringAsFixed(2)} MAD'),
                pw.Bullet(text: 'ID Projet : ${investment.projetId}'),
                pw.SizedBox(height: 40),
                pw.Text('Ce document certifie que l\'investissement a été réalisé avec succès.'),
                pw.SizedBox(height: 50),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Signature GreenInvest'),
                    pw.Text('Signature Investisseur'),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Fermer le loader
      Navigator.of(context).pop();

      if (kIsWeb) {
        // Téléchargement direct pour le Web
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "Contrat_${investment.numeroContrat}.pdf")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Pour mobile/desktop, on ouvre le dialogue d'impression/partage
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Contrat_${investment.numeroContrat}.pdf',
        );
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du PDF: $e')),
        );
      }
    }
  }
}
