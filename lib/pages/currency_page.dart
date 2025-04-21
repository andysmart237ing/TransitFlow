import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:transit_flow/backend/dao/currency_dao.dart';
import 'package:transit_flow/backend/models/currency_model.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final currencyDao = CurrencyDao();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Currency>>(
          future: currencyDao.getAllCurrencies(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Erreur: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Aucune devise enregistrée !"));
            }

            final currencies = snapshot.data!;

            return AnimationLimiter(
              child: ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 1000),
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: Card(
                          child: ListTile(
                            leading: Text(currency.name),
                            title: Text("(${currency.code})"),
                            subtitle: Text("${currency.id}"),
                            trailing: Icon(Icons.more_vert),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
