import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/currency_model.dart';

class CurrencyDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertCurrency(Currency currency) async {
    final db = await dbHelper.database;
    return await db.insert(
      'currencies',
      currency.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEvent(Currency currency) async {
    final db = await dbHelper.database;
    await db.update(
      'currencies',
      currency.toMap(),
      where: 'id = ?',
      whereArgs: [currency.id],
    );
  }

  Future<List<Currency>> getAllCurrencies() async {
    final db = await dbHelper.database;
    final result = await db.query('currencies');

    return result.map((map) => Currency.fromMap(map)).toList();
  }

  Future<void> deleteCurrency(int id) async {
    final db = await dbHelper.database;
    await db.delete('currencies', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertDefaultData() async {
    final db = await dbHelper.database;
    // Vérifier si des données existent déjà
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM currencies'));
    if (count == 0) {
      // Insérer des propriétaires
      await db.insert('currencies', {
        'id': 1,
        'code': "FCFA",
        'name': "Franc CFA",
      });
      await db.insert('currencies', {
        'id': 2,
        'code': "USD",
        'name': "Dollar USD",
      });
      await db.insert('currencies', {
        'id': 3,
        'code': "Euro",
        'name': "Euro",
      });
    }
  }
}
