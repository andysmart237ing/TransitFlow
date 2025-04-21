import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transit_flow/backend/models/transit_costs_model.dart';
import '../backend/models/package_model.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar/top_snackbar.dart';

class CalculationService {
  static Future<void> calculateTransitCostByAir(
      BuildContext context,
      Package package,
      TransitCosts transitCosts,
      String? selectedCurrency) async {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: selectedCurrency,
      decimalDigits: 2,
    );
    final NumberFormat decimalFormatter = NumberFormat('#,##0.00', 'fr_FR');
    // Format du genre : 2 975,56
    final transitCostsResults =
        package.totalWeightInKg * transitCosts.airRatePerKg;
    final coutTotalAchat = transitCostsResults + package.totalPrice;
    // Rassemble le texte complet que l'on souhaite copier
    final String resultText = '''
    Résultats de calcul :
    Poids total du colis : ${decimalFormatter.format(package.totalWeightInKg)} kg
    Prix total du colis : ${currencyFormatter.format(package.totalPrice)}
    Frais de transit du colis : ${currencyFormatter.format(transitCostsResults)}
    Coût de revient total : ${currencyFormatter.format(coutTotalAchat)}
    ''';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Résultats de calcul',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 13, 59, 82),
                )),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, begin: 0.8)
                  .slideY(begin: -0.2),
            ),
            Divider(),
            SizedBox(height: 8),
            Column(
              children: [
                _buildResultItem("Poids total du colis",
                    '${decimalFormatter.format(package.totalWeightInKg)} kg'),
                _buildResultItem("Prix total du colis",
                    currencyFormatter.format(package.totalPrice)),
                _buildResultItem("Frais de transit du colis",
                    currencyFormatter.format(transitCostsResults)),
                _buildResultItem("Coût total d'achat",
                    currencyFormatter.format(coutTotalAchat)),
              ]
                  .animate()
                  .animate(interval: 300.ms)
                  .then(delay: 300.ms)
                  .fade(duration: 300.ms)
                  .slideY(begin: 0.3),
            ),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _copyAllButton(context, resultText),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fermer"),
              ),
            ]).animate(delay: 1500.ms).fade(duration: 500.ms),
          ],
        ),
      ),
    );
  }

  static Future<void> calculateTransitCostBySea(
      BuildContext context,
      Package package,
      TransitCosts transitCosts,
      String? selectedCurrency) async {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: selectedCurrency,
      decimalDigits: 2,
    );
    final NumberFormat decimalFormatter = NumberFormat('#,##0.0000', 'fr_FR');
    // Format du genre : 2 975,5650

    final transitCostsResults = package.cbm * transitCosts.seaRatePerCbm;
    final coutTotalAchat = transitCostsResults + package.totalPrice;

    // Rassemble le texte complet que l'on souhaite copier
    final String resultText = '''
    Résultats de calcul :
    Volume du colis : ${decimalFormatter.format(package.cbm)} CBM
    Prix total du colis : ${currencyFormatter.format(package.totalPrice)}
    Frais de transit du colis : ${currencyFormatter.format(transitCostsResults)}
    Coût de revient total : ${currencyFormatter.format(coutTotalAchat)}
    ''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Résultats de calcul',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 13, 59, 82),
                )),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, begin: 0.8)
                  .slideY(begin: -0.2),
            ),
            Divider(),
            SizedBox(height: 8),
            Column(
              children: [
                _buildResultItem("Volume du colis",
                    '${decimalFormatter.format(package.cbm)} CBM'),
                _buildResultItem("Prix total du colis",
                    currencyFormatter.format(package.totalPrice)),
                _buildResultItem("Frais de transit du colis",
                    currencyFormatter.format(transitCostsResults)),
                _buildResultItem("Coût de revient total",
                    currencyFormatter.format(coutTotalAchat)),
              ]
                  .animate()
                  .animate(interval: 300.ms)
                  .then(delay: 300.ms)
                  .fade(duration: 300.ms)
                  .slideY(begin: 0.3),
            ),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _copyAllButton(context, resultText),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fermer"),
              ),
            ]).animate(delay: 1500.ms).fade(duration: 500.ms),
          ],
        ),
      ),
    );
  }

  // Widget pour réaliser une copie dans le presse-papiers des résultats
  static Widget _copyAllButton(BuildContext context, String resultText) {
    return ElevatedButton(
      onPressed: () {
        // Copier l'ensemble du contenu dans le presse-papiers
        Clipboard.setData(ClipboardData(text: resultText));
        CustomTopSnackbar.show(
          context,
          "Résultats copiés dans le presse-papiers",
          leadingIcon: Icons.copy,
          backgroundColor: Colors.black54,
        );
      },
      child: Text("Copier tout"),
    );
  }

  // Widget pour afficher chaque ligne de résultat
  static Widget _buildResultItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: SelectableText(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color.fromARGB(215, 30, 111, 151),
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }
}
