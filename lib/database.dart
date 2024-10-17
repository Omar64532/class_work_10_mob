import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CardDatabase {
  static final CardDatabase instance = CardDatabase._init();

  static Database? _database;

  CardDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create the Folders Table
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create the Cards Table
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        folderId INTEGER NOT NULL,
        FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');

    // Insert folders for suits
    await db.insert('folders', {'name': 'Hearts'});
    await db.insert('folders', {'name': 'Spades'});
    await db.insert('folders', {'name': 'Diamonds'});
    await db.insert('folders', {'name': 'Clubs'});

    // Insert 3 cards per suit
    await _insertCards(db, 'Hearts');
    await _insertCards(db, 'Spades');
    await _insertCards(db, 'Diamonds');
    await _insertCards(db, 'Clubs');
  }

  Future<void> _insertCards(Database db, String suit) async {
    List<Map<String, String>> cards = [
      {'name': '1 of $suit', 'imageUrl': 'assets/images/${suit.toLowerCase()}_1.png'},
      {'name': '2 of $suit', 'imageUrl': 'assets/images/${suit.toLowerCase()}_2.png'},
      {'name': '3 of $suit', 'imageUrl': 'assets/images/${suit.toLowerCase()}_3.png'},
    ];

    for (var card in cards) {
      await db.insert('cards', {
        'name': card['name'],
        'suit': suit,
        'imageUrl': card['imageUrl'],
        'folderId': suit == 'Hearts' ? 1 : suit == 'Spades' ? 2 : suit == 'Diamonds' ? 3 : 4,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await instance.database;
    return await db.query('folders');
  }

  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    final db = await instance.database;
    return await db.query('cards', where: 'folderId = ?', whereArgs: [folderId]);
  }

  Future<int> addCard(Map<String, dynamic> card) async {
    final db = await instance.database;
    return await db.insert('cards', card);
  }

  Future<int> updateCard(Map<String, dynamic> card) async {
    final db = await instance.database;
    return await db.update('cards', card, where: 'id = ?', whereArgs: [card['id']]);
  }

  Future<int> deleteCard(int id) async {
    final db = await instance.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
