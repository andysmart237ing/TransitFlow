class Package {
  final double volume;
  final String dimensionUnit;
  final double weight;
  final String weightUnit;
  final int quantity;
  final double unitPrice;

  Package({
    required this.quantity,
    required this.unitPrice,
    this.volume = 0.0,
    this.dimensionUnit = "mm",
    this.weight = 0.0,
    this.weightUnit = "g",
  });

  double get cbm {
    final conversionFactor = _getDimensionConversionFactor(dimensionUnit);
    return (volume * conversionFactor) / 1000000000;
  }

  double get totalWeightInKg {
    final conversionFactor = _getWeightConversionFactor(weightUnit);
    return weight * conversionFactor;
  }

  double get totalPrice {
    return unitPrice * quantity;
  }

  double _getDimensionConversionFactor(String unit) {
    switch (unit) {
      case 'mm':
        return 1;
      case 'cm':
        return 1000;
      case 'm':
        return 1000000000;
      default:
        return 1;
    }
  }

  double _getWeightConversionFactor(String unit) {
    switch (unit) {
      case 'g':
        return 0.001;
      case 'kg':
        return 1;
      default:
        return 1;
    }
  }
}
