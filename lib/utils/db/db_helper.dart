import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:contact_app/ui/home/widgets/user_profile/model/user_model.dart';
import 'package:contact_app/ui/home/widgets/contact/model/contact_model.dart';

class UserDBHelper {
  static const _databaseName = 'user_database.db';
  static const _databaseVersion = 1;

  static const String userTable = 'users';
  static const String contactTable = 'contacts';

  static const String columnUserId = 'id';
  static const String columnUsername = 'username';
  static const String columnEmail = 'email';
  static const String columnPassword = 'password';
  static const String columnProfileImagePath = 'profileImagePath';
  static const String columnFirstLogin = 'firstLogin';
  static const String columnFirstContact = 'firstContact';

  static const String columnContactId = 'id';
  static const String columnContactName = 'name';
  static const String columnContactPhoneNumber = 'phoneNumber';
  static const String columnContactIsFromDevice = 'isFromDevice';
  static const String columnUserIdForeign = 'userId';

  UserDBHelper._privateConstructor();
  static final UserDBHelper instance = UserDBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    // await deleteDatabase(path); // TO DO: Eliminar todo para pruebas
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable (
        $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnProfileImagePath TEXT,
        $columnFirstLogin INTEGER NOT NULL DEFAULT 1,
        $columnFirstContact INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE $contactTable (
        $columnContactId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnContactName TEXT NOT NULL,
        $columnContactPhoneNumber TEXT NOT NULL,
        $columnContactIsFromDevice INTEGER NOT NULL,
        $columnUserIdForeign INTEGER NOT NULL,
        FOREIGN KEY ($columnUserIdForeign) REFERENCES $userTable($columnUserId) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    Database db = await instance.database;
    int id = await db.insert(userTable, user.toMap());
    return id;
  }

  Future<List<UserModel>> getAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(userTable);
    
    return result.map((userMap) => UserModel.fromMap(userMap)).toList();
  }

  Future<UserModel?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      userTable,
      where: '$columnEmail = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      userTable,
      where: '$columnUserId = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    Database db = await instance.database;

    return await db.update(
      userTable,
      user.toMap(),
      where: '$columnUserId = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateUserProfileImage(String email, String imagePath) async {
    Database db = await instance.database;

    return await db.update(
      userTable,
      {'profileImagePath': imagePath},
      where: '$columnEmail = ?',
      whereArgs: [email],
    );
  }

  Future<int> deleteAllUsers() async {
    Database db = await instance.database;
    return await db.delete(userTable);
  }

  Future<int> insertContact(ContactModel contact, int userId) async {
    Database db = await instance.database;
    return await db.insert(contactTable, {
      'name': contact.name,
      'phoneNumber': contact.phoneNumber,
      'isFromDevice': contact.isFromDevice ? 1 : 0,
      'userId': userId,
    });
  }

  Future<List<ContactModel>> getContactsForUser(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      contactTable,
      where: '$columnUserIdForeign = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty
        ? result.map((contactMap) => ContactModel.fromMap(contactMap)).toList()
        : [];
  }

  Future<int> updateContact(ContactModel contact) async {
    if (contact.isFromDevice) {
      return 0;
    }

    Database db = await instance.database;
    return await db.update(
      contactTable,
      contact.toMap(),
      where: '$columnContactId = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int contactId, bool isFromDevice) async {
    if (isFromDevice) {
      return 0;
    }

    Database db = await instance.database;
    return await db.delete(contactTable,
        where: '$columnContactId = ?', whereArgs: [contactId]);
  }
}
