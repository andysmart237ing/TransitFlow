import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/transit_costs_model.dart';

class TransitCostsDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertOrUpdateTransitCosts(TransitCosts transitCosts) async {
    final db = await dbHelper.database;
    return await db.insert(
      'transit_costs',
      transitCosts.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TransitCosts?> getTransitCosts() async {
    final db = await dbHelper.database;
    final result =
        await db.query('transit_costs', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return TransitCosts.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteTransitCosts(int id) async {
    final db = await dbHelper.database;
    await db.delete('transit_costs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertDefaultTransitCosts() async {
    final db = await dbHelper.database;
    // Vérifier si des données existent déjà
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM transit_costs'));
    if (count == 0) {
      final transitCosts =
          TransitCosts(airRatePerKg: 7000, seaRatePerCbm: 330000);
      await insertOrUpdateTransitCosts(transitCosts);
    }
  }
}
