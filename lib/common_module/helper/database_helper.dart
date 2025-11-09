import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:goemployee/goemployee.dart';

class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const String _keyStorageName = 'db_master_key';
  final _secureStorage = const FlutterSecureStorage();

  // Getter publik untuk database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Fungsi inisialisasi utama
  Future<Database> _initDatabase() async {
    try {
      // 1. Dapatkan atau Buat Master Key
      final String dbKey = await _getOrCreateDatabaseKey();

      // 2. Tentukan path database
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'encrypted_database.db');

      // 3. Buka database terenkripsi menggunakan key sebagai password
      // 'password' adalah tempat SQLCipher menggunakan key Anda
      final db = await openDatabase(
        path,
        version: 1,
        password: dbKey, // <-- KUNCI DIGUNAKAN DI SINI
        onCreate: _onCreate,
      );

      print("DatabaseHelper: Database terenkripsi berhasil dibuka.");
      return db;
    } catch (e) {
      print("DatabaseHelper: Gagal membuka database: $e");
      // Handle error, mungkin key salah atau database korup
      rethrow;
    }
  }

  Future<bool> hasUsers() async {
    final db = await instance.database;

    // Menghitung jumlah baris di tabel users
    final int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users')
    );

    // Jika count tidak null dan lebih dari 0, berarti tabel sudah terisi
    return count != null && count > 0;
  }



  // Fungsi untuk mengambil atau membuat key
  Future<String> _getOrCreateDatabaseKey() async {
    // Coba baca key dari Secure Storage
    String? key = await _secureStorage.read(key: _keyStorageName);

    if (key == null) {
      print("DatabaseHelper: Key tidak ditemukan. Membuat key baru...");
      // Jika tidak ada (first install/re-install), buat key baru
      key = _generateDatabaseKey();
      // Simpan key baru di Secure Storage
      await _secureStorage.write(key: _keyStorageName, value: key);
      print("DatabaseHelper: Key baru berhasil dibuat dan disimpan.");
    } else {
      print("DatabaseKey: Key berhasil diambil dari secure storage.");
    }

    // Kita gunakan hash dari key sebagai password, ini praktik yang baik
    // Meskipun key-nya sendiri sudah acak.
    return sha256.convert(utf8.encode(key)).toString();
  }

  // Fungsi untuk membuat string acak yang kuat (256-bit)
  String _generateDatabaseKey() {
    final random = Random.secure();
    // Hasilkan 32 byte acak (32 byte * 8 bit = 256 bit)
    final List<int> keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    // Encode ke Base64 agar aman disimpan sebagai string
    return base64Url.encode(keyBytes);
  }

  // Fungsi yang dipanggil saat database dibuat pertama kali
  Future<void> _onCreate(Database db, int version) async {
    // Buat tabel Anda di sini
      await db.execute('''
        CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        company_name TEXT NOT NULL,
        role TEXT NOT NULL,
        date_now TEXT NOT NULL,
        time_checkin TEXT,
        time_checkout TEXT,
        late_checkin TEXT,
        photo TEXT
      )
    ''');

    // Contoh membuat tabel lain
    await db.execute('''
      CREATE TABLE izin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipe TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        alasan TEXT
      )
    ''');
    print("DatabaseHelper: Tabel berhasil dibuat.");
  }

  // --- CRUD METHODS (Contoh) ---
  Future<int> insertUser(User user) async {
    final db = await instance.database;

    // db.insert() akan mengembalikan ID dari baris yang baru dimasukkan.
    return await db.insert(
      'users', // Nama tabel
      user.toMap(), // Data dari model User

      // Ini penting karena Anda punya 'username UNIQUE'
      // Jika username sudah ada, ganti datanya (UPDATE)
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      // Jika user ditemukan, kembalikan sebagai User object
      return User.fromMap(maps.first);
    } else {
      // Jika tidak ditemukan
      return null;
    }
  }


  Future<User?> getCurrentLoggedInUser() async {
    // 1. Buat instance SessionManager
    final sessionManager = SessionManager();

    try {
      // 2. Ambil ID dari sesi
      final String? userIdString = await sessionManager.getSession();

      if (userIdString == null || userIdString.isEmpty) {
        // Tidak ada sesi, kembalikan null
        print("DB Helper: Tidak ada sesi aktif.");
        return null;
      }

      // 3. Ubah ID string menjadi integer
      final int userId = int.parse(userIdString);

      // 4. Panggil fungsi getUserById (yang sudah Anda buat)
      final User? user = await getUserById(userId);

      if (user != null) {
        // Sukses! Kembalikan data user
        print("DB Helper: User '${user.nama}' ditemukan.");
        return user;
      } else {
        // Sesi ada, tapi data user tidak ada (sesi invalid)
        print("DB Helper: Sesi invalid, user $userId tidak ada di DB.");
        await sessionManager.clearSession(); // Hapus sesi buruk
        return null;
      }
    } catch (e) {
      // Error (misal: parsing, db error)
      print("DB Helper (getCurrentLoggedInUser) Error: $e");
      await sessionManager.clearSession(); // Hapus sesi buruk
      return null;
    }
  }

}