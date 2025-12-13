class Investment {
  final String id;
  final double amount;
  final String dateInvestissement;
  final String investisseurId;
  final String nomInvestisseur;
  final String projetId;
  final String nomProjet;
  final String numeroContrat;

  Investment({
    required this.id,
    required this.amount,
    required this.dateInvestissement,
    required this.investisseurId,
    required this.nomInvestisseur,
    required this.projetId,
    required this.nomProjet,
    required this.numeroContrat,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      amount: (json['montant'] ?? 0).toDouble(),
      dateInvestissement: json['dateInvestissement'],
      investisseurId: json['investisseurId'],
      nomInvestisseur: json['nomInvestisseur'],
      projetId: json['projetId'],
      nomProjet: json['nomProjet'],
      numeroContrat: json['numeroContrat'],
    );
  }
}
