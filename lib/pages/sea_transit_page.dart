import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transit_flow/backend/models/transit_costs_model.dart';
import 'package:transit_flow/services/calculation_service.dart';
import 'package:transit_flow/services/calculator_service.dart';
import '../backend/dao/currency_dao.dart';
import '../backend/dao/transit_costs_dao.dart';
import '../backend/models/currency_model.dart';
import '../backend/models/package_model.dart';
import '../backend/preference_helper.dart';

class SeaTransitPage extends StatefulWidget {
  const SeaTransitPage({super.key});

  @override
  State<SeaTransitPage> createState() => _SeaTransitPageState();
}

class _SeaTransitPageState extends State<SeaTransitPage> {
  final _formKey = GlobalKey<FormState>();
  final currencyDao = CurrencyDao();
  final transitCostsDao = TransitCostsDao();

  String? selectedSizeUnit;
  final volumeController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  String? selectedCurrency;
  TextEditingController seaRateController = TextEditingController();
  TransitCosts? _transitCosts;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Charger les précédantes données validées
  Future<void> _loadPreferences() async {
    selectedCurrency = await PreferenceHelper.getSelectedCurrency();
    selectedSizeUnit = await PreferenceHelper.getSelectedSizeUnit();
    final transitCosts = await transitCostsDao.getTransitCosts();
    if (transitCosts != null) {
      _transitCosts = transitCosts;
      seaRateController.text = "${transitCosts.seaRatePerCbm}";
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    volumeController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }

  Future<void> _calculate() async {
    final volume = volumeController.text;
    final quantity = quantityController.text;
    final unitPrice = unitPriceController.text;
    final package = Package(
      volume: double.parse(volume),
      dimensionUnit: selectedSizeUnit ?? "mm",
      quantity: int.parse(quantity),
      unitPrice: double.parse(unitPrice),
    );
    await CalculationService.calculateTransitCostBySea(
        context, package, _transitCosts!, selectedCurrency ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                "Insérez les données",
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
              ).animate().fadeIn(duration: 500.ms, begin: 0.8).slide(),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: volumeController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Volume total",
                        hintText: "Entrer le volume total",
                        border: OutlineInputBorder(),
                        suffixIcon: CalculatorService.calculatorSuffixIcon(
                          context: context,
                          controller: volumeController,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le volume total";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  IntrinsicWidth(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "unité",
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['mm', 'cm', 'm'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text("$value³"),
                        );
                      }).toList(),
                      value: selectedSizeUnit ?? "mm",
                      onChanged: (value) {
                        setState(() {
                          selectedSizeUnit = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantité",
                  hintText: "Entrer la quantité",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer la quantité du produit";
                  }
                  return null;
                },
                controller: quantityController,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: unitPriceController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Prix unitaire",
                        hintText: "Entrer le prix unitaire",
                        border: OutlineInputBorder(),
                        suffixIcon: CalculatorService.calculatorSuffixIcon(
                          context: context,
                          controller: unitPriceController,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le prix unitaire";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  IntrinsicWidth(
                    child: FutureBuilder<List<Currency>>(
                        future: currencyDao.getAllCurrencies(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Erreur : ${snapshot.error}'));
                          } else if (snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('Aucune devise disponible'));
                          }
                          final currencies = snapshot.data!;
                          // Définir une valeur par défaut si elle n'existe pas encore
                          if (selectedCurrency == null &&
                              currencies.isNotEmpty) {
                            selectedCurrency = currencies.first.code;
                          }

                          return DropdownButtonFormField<String>(
                            value: selectedCurrency,
                            decoration: InputDecoration(
                              labelText: "devise",
                              border: OutlineInputBorder(),
                              // helperText: "",
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedCurrency = value;
                              });
                            },
                            items: currencies.map((Currency currency) {
                              return DropdownMenuItem<String>(
                                value: currency.code,
                                child: Text(
                                  currency.code,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Tarif du CBM pour transit maritime",
                  hintText: "Entrer le tarif du CBM (mètre cube)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer le tarif du CBM";
                  }
                  return null;
                },
                controller: seaRateController,
              ),
            ),
            SizedBox(
              width: 130,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final seaRate = seaRateController.text;
                    final transitCosts =
                        await transitCostsDao.getTransitCosts();
                    //Sauvegarde de données par défaut
                    if (transitCosts != null) {
                      _transitCosts?.seaRatePerCbm = double.parse(seaRate);
                      transitCosts.seaRatePerCbm = double.parse(seaRate);
                      await transitCostsDao
                          .insertOrUpdateTransitCosts(transitCosts);
                    }
                    if (selectedCurrency != null && selectedSizeUnit != null) {
                      await PreferenceHelper.saveSelectedSizeUnit(
                          selectedSizeUnit!);
                      await PreferenceHelper.saveSelectedCurrency(
                          selectedCurrency!);
                    }
                    // FocusScope.of(context).requestFocus(FocusNode());
                    _calculate();
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Calculer",
                  style: GoogleFonts.lexend(
                      textStyle: TextStyle(
                    fontSize: 20,
                  )),
                ),
              )
                  .animate(delay: 250.ms)
                  .fade(begin: 0.9)
                  .scaleXY(duration: 200.ms, begin: 0.95),
            )
          ],
        ),
      ),
    );
  }
}
