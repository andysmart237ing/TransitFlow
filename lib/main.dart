import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:transit_flow/backend/dao/currency_dao.dart';
import 'package:transit_flow/backend/dao/transit_costs_dao.dart';
import 'package:transit_flow/pages/about_page.dart';
import 'package:transit_flow/pages/air_transit_page.dart';
import 'package:transit_flow/pages/home.dart';
import 'package:transit_flow/pages/sea_transit_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    // Code spécifique aux plateformes de bureau
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final currencyDAO = CurrencyDao();
  final transitCostsDao = TransitCostsDao();
  await currencyDAO.insertDefaultData();
  await transitCostsDao.insertDefaultTransitCosts();

  runApp(MaterialApp(
    title: 'TransitFlow',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 30, 111, 151),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 30, 111, 151),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 30, 111, 151),
          foregroundColor: Colors.white,
        ))),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentPageIndex = 0;

  setCurrentPageIndex(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          [
            "TransitFlow",
            "TransitFlow < Air transit >",
            "TransitFlow < Sea transit >",
          ][_currentPageIndex],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'À propos',
            onPressed: () => showAboutModal(context),
          ),
        ],
      ),
      body: [
        HomePage(onTabSelect: setCurrentPageIndex),
        AirTransitPage(),
        SeaTransitPage(),
      ][_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) => setCurrentPageIndex(index),
        type: BottomNavigationBarType.fixed,
        // selectedItemColor: Colors.green,
        iconSize: 32,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.home,
                size: 35,
              ),
            ),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.airplanemode_active,
                size: 35,
              ),
            ),
            label: "Air transit",
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.directions_boat,
                size: 35,
              ),
            ),
            label: "Sea transit",
          ),
        ],
      ),
    );
  }
}
