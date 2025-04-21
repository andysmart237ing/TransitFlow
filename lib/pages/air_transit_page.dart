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

class AirTransitPage extends StatefulWidget {
  const AirTransitPage({super.key});

  @override
  State<AirTransitPage> createState() => _AirTransitPageState();
}

class _AirTransitPageState extends State<AirTransitPage> {
  final _formKey = GlobalKey<FormState>();
  final currencyDao = CurrencyDao();
  final transitCostsDao = TransitCostsDao();

  final weightController = TextEditingController();
  String? selectedWeightUnit;
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  String? selectedCurrency;
  TextEditingController airRateController = TextEditingController();
  TransitCosts? _transitCosts;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Charger la dernière devise sélectionnée
  Future<void> _loadPreferences() async {
    selectedCurrency = await PreferenceHelper.getSelectedCurrency();
    selectedWeightUnit = await PreferenceHelper.getSelectedWeightUnit();
    final transitCosts = await transitCostsDao.getTransitCosts();
    if (transitCosts != null) {
      _transitCosts = transitCosts;
      airRateController.text = "${transitCosts.airRatePerKg}";
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    weightController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }

  Future<void> _calculate() async {
    final weight = weightController.text;
    final quantity = quantityController.text;
    final unitPrice = unitPriceController.text;
    final package = Package(
      weight: double.parse(weight),
      weightUnit: selectedWeightUnit!,
      quantity: int.parse(quantity),
      unitPrice: double.parse(unitPrice),
    );
    await CalculationService.calculateTransitCostByAir(
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
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: weightController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Poids total",
                        hintText: "Entrer le poids total du colis",
                        border: OutlineInputBorder(),
                        suffixIcon: CalculatorService.calculatorSuffixIcon(
                          context: context,
                          controller: weightController,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le poids total du colis";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  IntrinsicWidth(
                    child: Builder(builder: (context) {
                      selectedWeightUnit ??= "g";
                      return DropdownButtonFormField(
                        items: [
                          DropdownMenuItem(
                            value: "g",
                            child: Text("g"),
                          ),
                          DropdownMenuItem(
                            value: "kg",
                            child: Text("kg"),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: "unité",
                          border: OutlineInputBorder(),
                          // helperText: "",
                        ),
                        value: selectedWeightUnit,
                        onChanged: (value) {
                          setState(() {
                            selectedWeightUnit = value!;
                          });
                        },
                      );
                    }),
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
                    return "Veuillez entrer la quantité de produits";
                  }
                  return null;
                },
                controller: quantityController,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
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
                  labelText: "Tarif par Kg pour le transit aéien",
                  hintText: "Entrer le tarif par Kg",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer la valeur du tarif par Kg";
                  }
                  return null;
                },
                controller: airRateController,
              ),
            ),
            SizedBox(
              width: 130,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final airRate = airRateController.text;
                    final transitCosts =
                        await transitCostsDao.getTransitCosts();
                    //Sauvegarde de données par défaut
                    if (transitCosts != null) {
                      _transitCosts?.airRatePerKg = double.parse(airRate);
                      transitCosts.airRatePerKg = double.parse(airRate);
                      await transitCostsDao
                          .insertOrUpdateTransitCosts(transitCosts);
                    }
                    if (selectedCurrency != null &&
                        selectedWeightUnit != null) {
                      await PreferenceHelper.saveSelectedWeightUnit(
                          selectedWeightUnit!);
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
                  .fade(begin: 0.8)
                  .scaleXY(duration: 200.ms, begin: 0.95),
            ),
          ],
        ),
      ),
    );
  }
}
