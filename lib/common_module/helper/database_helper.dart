import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
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

  Future<int> updateUserCheckIn(int userId, String checkInTime) async {
    final db = await instance.database;

    // Ambil tanggal hari ini
    final String dateNow = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());

    final int rowsAffected = await db.update(
      'users', // Nama tabel
      {
        'time_checkin': checkInTime,
        'date_now': dateNow,
        // Anda juga bisa menambahkan logika untuk 'late_checkin' di sini
        // 'late_checkin': ...
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    print('DatabaseHelper: Check-in user $userId berhasil. ($rowsAffected baris)');
    return rowsAffected;
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

    await db.execute('''
      CREATE TABLE cuti (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        jenis_cuti TEXT NOT NULL,
        tanggal_mulai TEXT NOT NULL,
        tanggal_selesai TEXT NOT NULL,
        alasan TEXT NOT NULL,
        dokumen_url TEXT,
        status TEXT NOT NULL DEFAULT 'PENDING',
        tanggal_pengajuan TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    print("DatabaseHelper: Tabel berhasil dibuat.");
  }

  Future<int> insertCuti(CutiModel cuti, int userId) async {
    final db = await instance.database;

    // 1. Siapkan data yang akan di-insert
    //    Ini adalah gabungan dari CutiModel + data sistem
    final Map<String, dynamic> data = {
      'user_id': userId, // <-- ID dari user yang login
      'jenis_cuti': cuti.jenisCuti,
      'tanggal_mulai': cuti.tanggalMulai,
      'tanggal_selesai': cuti.tanggalSelesai,
      'alasan': cuti.alasan,
      'dokumen_url': cuti.dokumenUrl,
      // 'status' akan otomatis 'PENDING' (sesuai DEFAULT)
      'tanggal_pengajuan': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Tanggal hari ini
    };

    // 2. Lakukan insert ke tabel 'cuti'
    final int id = await db.insert(
      'cuti',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('DatabaseHelper: Cuti baru (ID: $id) untuk user $userId berhasil disimpan.');
    return id;
  }

  /// Mengambil semua riwayat cuti milik satu user
  Future<List<CutiModel>> getRiwayatCuti(int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'cuti',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal_mulai DESC', // Tampilkan yang terbaru dulu
    );

    // Jika tidak ada data, kembalikan list kosong
    if (maps.isEmpty) {
      return [];
    }

    // Ubah List<Map> menjadi List<CutiModel>
    return List.generate(maps.length, (i) {
      return CutiModel.fromMap(maps[i]);
    });
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

  Future<int> deleteAllUsers() async {
    final db = await instance.database;
    final int rowsDeleted = await db.delete('users');

    // Hapus juga sesi yang mungkin masih tersimpan
    await SessionManager().clearSession();

    print('DatabaseHelper: ALL users deleted ($rowsDeleted rows). Session cleared.');
    return rowsDeleted;
  }

  Future<int> deleteUserById(int id) async {
    final db = await instance.database;
    final int rowsDeleted = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('DatabaseHelper: User $id deleted, $rowsDeleted rows affected.');
    return rowsDeleted;
  }

  Future<void> deleteCurrentUserAndLogout() async {
    final sessionManager = SessionManager();
    try {
      // 1. Ambil ID dari sesi
      final String? userIdString = await sessionManager.getSession();

      if (userIdString != null) {
        final int userId = int.parse(userIdString);

        // 2. Hapus user dari database menggunakan ID
        await deleteUserById(userId);
      }

      // 3. Hapus sesi (baik jika user ditemukan atau tidak)
      await sessionManager.clearSession();

      print('DatabaseHelper: Current user deleted and session cleared.');
    } catch (e) {
      print('DatabaseHelper: Error during user deletion: $e');
      // Jika terjadi error, tetap paksa hapus sesi
      await sessionManager.clearSession();
    }
  }

  Future<User?> getSingleUser() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }


  /*

  void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda? '
          'Semua data Anda akan hilang secara permanen dan tidak dapat dikembalikan.',
        ),
        actions: [
          // Tombol Batal
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Tutup dialog
            },
          ),
          // Tombol Hapus
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              // 1. Panggil fungsi hapus dari DatabaseHelper
              await _dbHelper.deleteCurrentUserAndLogout();

              // 2. Arahkan kembali ke LoginPage
              if (mounted) {
                // Tutup dialog
                Navigator.of(dialogContext).pop();
                // Panggil _forceLogout (yang sudah ada) untuk navigasi
                _forceLogout();
              }
            },
          ),
        ],
      );
    },
  );
}

// (Fungsi _forceLogout Anda yang sudah ada)
Future<void> _forceLogout() async {
  await _sessionManager.clearSession(); // Pastikan sesi bersih
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

   */

}