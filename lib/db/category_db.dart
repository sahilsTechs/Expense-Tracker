import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';

class CategoryDB {
  static final CategoryDB instance = CategoryDB._internal();
  factory CategoryDB() => instance;
  CategoryDB._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('categories.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCategory(CategoryModel c) async {
    final db = await database;
    return await db.insert('categories', c.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
