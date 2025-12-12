class Project {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String ownerId;
  final String status; // 'pending', 'approved', 'funded'

  final String? contrepartie;
  final double? pourcentageRendement;
  final int? dureeContrepartie;
  final String? typeContrepartie;
  final String? dateCreation;
  final int? nombreInvestisseurs;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.ownerId,
    required this.status,
    this.contrepartie,
    this.pourcentageRendement,
    this.dureeContrepartie,
    this.typeContrepartie,
    this.dateCreation,
    this.nombreInvestisseurs,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['nom'] ?? json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      targetAmount: (json['montantObjectif'] ?? json['targetAmount'] ?? json['montant_objectif'] ?? 0).toDouble(),
      currentAmount: (json['montantInvesti'] ?? json['currentAmount'] ?? json['montant_investi'] ?? 0).toDouble(),
      ownerId: json['porteurId'] ?? json['ownerId'] ?? json['porteur_id'] ?? '',
      status: json['statut'] ?? json['status'] ?? 'pending',
      contrepartie: json['contrepartie'],
      pourcentageRendement: (json['pourcentageRendement'] ?? json['pourcentage_rendement'] ?? 0).toDouble(),
      dureeContrepartie: json['dureeContrepartie'] ?? json['duree_contrepartie'],
      typeContrepartie: json['typeContrepartie'] ?? json['type_contrepartie'],
      dateCreation: json['dateCreation'] ?? json['date_creation'],
      nombreInvestisseurs: json['nombreInvestisseurs'] ?? json['nombre_investisseurs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'ownerId': ownerId,
      'status': status,
      'contrepartie': contrepartie,
      'pourcentageRendement': pourcentageRendement,
      'dureeContrepartie': dureeContrepartie,
      'typeContrepartie': typeContrepartie,
      'dateCreation': dateCreation,
      'nombreInvestisseurs': nombreInvestisseurs,
    };
  }
}
