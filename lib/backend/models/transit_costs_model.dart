class TransitCosts {
  double airRatePerKg;
  double seaRatePerCbm;
  double minPackageWeight;
  double minPackageVolume;

  TransitCosts({
    required this.airRatePerKg,
    required this.seaRatePerCbm,
    this.minPackageWeight = 0.0,
    this.minPackageVolume = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'airRatePerKg': airRatePerKg,
      'seaRatePerCbm': seaRatePerCbm,
      'minPackageWeight': minPackageWeight,
      'minPackageVolume': minPackageVolume,
    };
  }

  factory TransitCosts.fromMap(Map<String, dynamic> map) {
    return TransitCosts(
      airRatePerKg: map['airRatePerKg'] as double,
      seaRatePerCbm: map['seaRatePerCbm'] as double,
      minPackageWeight: map['minPackageWeight'] as double,
      minPackageVolume: map['minPackageVolume'] as double,
    );
  }
}
