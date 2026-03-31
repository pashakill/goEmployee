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

  Future<int> updateUserCheckIn(int userId, String checkInTime, String? lateDuration) async {
    final db = await instance.database;
    final int rowsAffected = await db.update(
      'users',
      {
        'time_checkin': checkInTime,
        'late_checkin': lateDuration,
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
        photo TEXT,
        jadwal_mulai_kerja TEXT,
        jadwal_selesai_kerja TEXT,
        latitude TEXT,
        longitude TEXT,
        radius TEXT,
        division TEXT
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

    await db.execute('''
      CREATE TABLE pengajuan (
        id INTEGER PRIMARY KEY,
        kategori TEXT,
        tanggal_mulai TEXT,
        tanggal_selesai TEXT,
        jam_mulai TEXT,
        jam_selesai TEXT,
        lama TEXT,
        latitude TEXT,
        longitude TEXT,
        alasan TEXT,
        berkas TEXT,
        izin_kategori TEXT,
        jam_izin TEXT,
        status_manager TEXT,
        status_hrd TEXT,
        created_at TEXT,
        cuti_kategori TEXT,
        alamat TEXT,
        tanggal_pengajuan TEXT,
        user TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE lembur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        tanggal_pengajuan TEXT NOT NULL,
        waktu_mulai TEXT NOT NULL,
        waktu_selesai TEXT NOT NULL,
        lama_lembur TEXT NOT NULL,
        catatan_lembur TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE dinas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        tanggal_mulai TEXT NOT NULL,
        tanggal_selesai TEXT NOT NULL,
        alamat TEXT NOT NULL,
        latitude TEXT NOT NULL,
        longTitude TEXT NOT NULL,
        radius TEXT NOT NULL,
        alasan TEXT NOT NULL,
        tanggal_pengajuan TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE wfh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        tanggal_pengajuan TEXT NOT NULL,
        waktu_mulai TEXT NOT NULL,
        waktu_selesai TEXT NOT NULL,
        lama_wfh TEXT NOT NULL,
        alasan_wfh TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pengajuan_izin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        tipe TEXT NOT NULL, 
        tanggal_pengajuan TEXT NOT NULL, 
        tanggal_efektif TEXT NOT NULL, 
        jam_efektif TEXT, 
        alasan TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    print("DatabaseHelper: Tabel berhasil dibuat.");
  }

  Future<void> replaceCuti(List<CutiModel> cutiList, int userId) async {
    final db = await instance.database;

    final batch = db.batch();

    // 1. Hapus semua data lama
    batch.delete('cuti');

    // 2. Ambil maksimal 5 data
    final limitedList = cutiList.take(5).toList();

    // 3. Insert ulang data
    for (var cuti in limitedList) {
      final data = {
        'user_id': userId,
        'jenis_cuti': cuti.jenisCuti,
        'tanggal_mulai': cuti.tanggalMulai,
        'tanggal_selesai': cuti.tanggalSelesai,
        'alasan': cuti.alasan,
        'dokumen_url': cuti.dokumenUrl,
        'tanggal_pengajuan': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      batch.insert(
        'cuti',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 4. Eksekusi batch
    await batch.commit(noResult: true);

    print('DatabaseHelper: Data cuti berhasil di-replace (max 5 data).');
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

  Future<int> insertPengajuan(PengajuanData p) async {
    final db = await instance.database;

    final data = {
      'id': p.id,
      'kategori': p.kategori,
      'tanggal_mulai': p.tanggal_mulai,
      'tanggal_selesai': p.tanggal_selesai,
      'jam_mulai': p.jam_mulai,
      'jam_selesai': p.jam_selesai,
      'lama': p.lama,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'alasan': p.alasan,
      'berkas': p.berkas,
      'izin_kategori': p.izin_kategori,
      'jam_izin': p.jam_izin,
      'status_manager': p.status_manager,
      'status_hrd': p.status_hrd,
      'created_at': p.created_at,
      'cuti_kategori': p.cuti_kategori,
      'alamat': p.alamat,
      'tanggal_pengajuan': p.tanggal_pengajuan,
      'user': p.user,
    };

    final int id = await db.insert(
      'pengajuan',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('DatabaseHelper: Pengajuan (ID: $id) berhasil disimpan.');
    return id;
  }

  Future<void> replacePengajuan(List<PengajuanData> list) async {
    final db = await instance.database;

    final batch = db.batch();

    // 1. Hapus semua data lama
    batch.delete('pengajuan');

    // 2. Urutkan berdasarkan tanggal terbaru
    list.sort((a, b) => b.tanggal_pengajuan.compareTo(a.tanggal_pengajuan));

    // 3. Ambil maksimal 5 data
    final limitedList = list.take(5).toList();

    // 4. Insert ulang manual
    for (var p in limitedList) {
      final data = {
        'id': p.id,
        'kategori': p.kategori,
        'tanggal_mulai': p.tanggal_mulai,
        'tanggal_selesai': p.tanggal_selesai,
        'jam_mulai': p.jam_mulai,
        'jam_selesai': p.jam_selesai,
        'lama': p.lama,
        'latitude': p.latitude,
        'longitude': p.longitude,
        'alasan': p.alasan,
        'berkas': p.berkas,
        'izin_kategori': p.izin_kategori,
        'jam_izin': p.jam_izin,
        'status_manager': p.status_manager,
        'status_hrd': p.status_hrd,
        'created_at': p.created_at,
        'cuti_kategori': p.cuti_kategori,
        'alamat': p.alamat,
        'tanggal_pengajuan': p.tanggal_pengajuan,
        'user': p.user,
      };

      batch.insert(
        'pengajuan',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 5. Eksekusi batch
    await batch.commit(noResult: true);

    print('DatabaseHelper: Data pengajuan berhasil di-replace (max 5 data).');
  }


  Future<List<PengajuanData>> getPengajuan() async {
    final db = await database;

    final result = await db.query(
      'pengajuan',
      orderBy: 'created_at DESC',
    );

    return result.map((map) => PengajuanData.fromJson(map)).toList();
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

  Future<int> insertLembur(LemburModel lembur) async {
    final db = await instance.database;

    // 1. Siapkan data yang akan di-insert, ambil data toMap() dari model
    final Map<String, dynamic> data = lembur.toMap();

    // 2. Tambahkan field tanggal_pengajuan secara manual
    data['tanggal_pengajuan'] = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 3. Lakukan insert ke tabel 'lembur'
    final int id = await db.insert(
      'lembur',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('DatabaseHelper: Lembur baru (ID: $id) untuk user ${lembur.userId} berhasil disimpan.');
    return id;
  }

  Future<void> replaceLembur(List<LemburModel> lemburList) async {
    final db = await instance.database;

    final batch = db.batch();

    // 1. Hapus semua data lama
    batch.delete('lembur');

    // 3. Ambil maksimal 5 data
    final limitedList = lemburList.take(5).toList();

    // 4. Insert ulang data
    for (var lembur in limitedList) {
      final data = lembur.toMap();

      // Tambahkan tanggal_pengajuan
      data['tanggal_pengajuan'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      batch.insert(
        'lembur',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 5. Eksekusi batch
    await batch.commit(noResult: true);

    print('DatabaseHelper: Data lembur berhasil di-replace (max 5 data).');
  }

  // DI DALAM class DatabaseHelper

  /// Mengambil semua riwayat lembur milik satu user
  Future<List<LemburModel>> getRiwayatLembur(int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'lembur',
      where: 'user_id = ?',
      whereArgs: [userId],
      // Urutkan berdasarkan tanggal_pengajuan
      orderBy: 'tanggal_pengajuan DESC, waktu_mulai DESC',
    );

    // Jika tidak ada data, kembalikan list kosong
    if (maps.isEmpty) {
      return [];
    }

    // Ubah List<Map> menjadi List<LemburModel>
    return List.generate(maps.length, (i) {
      // PENTING: Meskipun kita mengambil tanggal_pengajuan dari DB,
      // kita tidak memasukkannya kembali ke LemburModel karena sudah kita hapus
      // dari factory constructor. Jadi, pastikan pemanggilan fromMap tetap aman.
      return LemburModel.fromMap(maps[i]);
    });
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

  Future<int> insertDinas(DinasModel dinas) async {
    final db = await instance.database;

    // 1. Siapkan data yang akan di-insert (dari toMap() model)
    final Map<String, dynamic> data = dinas.toMap();

    // 2. Lakukan insert ke tabel 'dinas'
    final int id = await db.insert(
      'dinas',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('DatabaseHelper: Permintaan Dinas baru (ID: $id) untuk user ${dinas.userId} berhasil disimpan.');
    return id;
  }

  Future<void> replaceDinas(List<DinasModel> dinasList) async {
    final db = await instance.database;

    final batch = db.batch();

    // 1. Hapus semua data lama
    batch.delete('dinas');

    // 2. (Opsional) Urutkan data terbaru dulu (kalau ada tanggal)
    dinasList.sort((a, b) => b.tanggalMulai.compareTo(a.tanggalMulai));

    // 3. Ambil maksimal 5 data
    final limitedList = dinasList.take(5).toList();

    // 4. Insert ulang data
    for (var dinas in limitedList) {
      batch.insert(
        'dinas',
        dinas.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 5. Eksekusi batch
    await batch.commit(noResult: true);

    print('DatabaseHelper: Data dinas berhasil di-replace (max 5 data).');
  }

  Future<List<DinasModel>> getRiwayatDinas(int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'dinas',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal_mulai DESC', // Tampilkan yang terbaru dulu
    );

    // Jika tidak ada data, kembalikan list kosong
    if (maps.isEmpty) {
      return [];
    }

    // Ubah List<Map> menjadi List<DinasModel>
    return List.generate(maps.length, (i) {
      return DinasModel.fromMap(maps[i]);
    });
  }

  Future<int> insertWfh(WfhModel wfh) async {
    final db = await instance.database;

    // 1. Siapkan data yang akan di-insert (dari toMap() model)
    final Map<String, dynamic> data = wfh.toMap();

    // 2. Lakukan insert ke tabel 'wfh'
    final int id = await db.insert(
      'wfh',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('DatabaseHelper: Permintaan WFH baru (ID: $id) untuk user ${wfh.userId} berhasil disimpan.');
    return id;
  }

  Future<List<WfhModel>> getRiwayatWfh(int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'wfh',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal_pengajuan DESC', // Tampilkan yang terbaru dulu
    );

    // Jika tidak ada data, kembalikan list kosong
    if (maps.isEmpty) {
      return [];
    }

    // Ubah List<Map> menjadi List<WfhModel>
    return List.generate(maps.length, (i) {
      return WfhModel.fromMap(maps[i]);
    });
  }

  Future<int> insertIzin(IzinConverterModel izinData) async {
    final db = await instance.database;
    // 1. Validasi Kunci Dasar Database
    if (izinData.userId == null) {
      throw Exception("IzinConverterModel harus memiliki userId yang valid untuk disimpan.");
    }
    // 2. Lakukan insert ke tabel 'pengajuan_izin'
    // Gunakan toMap() dari IzinConverterModel yang menangani konversi Enum ke String DB
    final int id = await db.insert(
      'pengajuan_izin',
      izinData.toMap(), // <-- MENGGUNAKAN toMap() BARU
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('DatabaseHelper: Pengajuan izin (${izinData.tipe}, ID: $id) berhasil disimpan.');
    return id;
  }

  Future<void> replaceIzin(List<IzinConverterModel> izinList) async {
    final db = await instance.database;

    final batch = db.batch();

    // 1. Hapus semua data lama
    batch.delete('pengajuan_izin');

    // 2. Validasi & filter data yang punya userId
    final validList = izinList
        .where((izin) => izin.userId != null)
        .toList();

    // 4. Ambil maksimal 5 data
    final limitedList = validList.take(5).toList();

    // 5. Insert ulang
    for (var izin in limitedList) {
      batch.insert(
        'pengajuan_izin',
        izin.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // 6. Eksekusi batch
    await batch.commit(noResult: true);

    print('DatabaseHelper: Data izin berhasil di-replace (max 5 data).');
  }



  Future<List<IzinConverterModel>> getRiwayatIzin(int userId) async {
    final db = await instance.database;
    print('userId ${userId}');

    final List<Map<String, dynamic>> maps = await db.query(
      'pengajuan_izin',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal_efektif DESC, tanggal_pengajuan DESC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      final Map<String, dynamic> dbMap = maps[i];

      // --- Penanganan Jam (Tetap Sama) ---
      final String? jamString = dbMap['jam_efektif'] as String?;
      String? fullIsoDateTime;

      if (jamString != null) {
        fullIsoDateTime = '${dbMap['tanggal_efektif']}T$jamString';
      }
      // ------------------------------------

      // 1. Rekonstruksi Map dengan Null Coalescing ('??')
      final Map<String, dynamic> reconstructedJson = {
        // Pastikan semua field String utama mendapatkan nilai default jika NULL
        'id': dbMap['id']?.toString() ?? '0',

        // IzinConverterModel.fromJson() mengharapkan 'tipe' dan 'tanggal'
        // sebagai String non-null untuk parsing
        'tipe': dbMap['tipe'] as String? ?? 'UNKNOWN', // Gunakan 'UNKNOWN' sebagai default tipe
        'status': dbMap.containsKey('status') ? dbMap['status'] as String? ?? 'PENDING' : 'PENDING',

        'tanggal': dbMap['tanggal_efektif'] as String? ?? DateFormat('yyyy-MM-dd').format(DateTime.now()), // Harus ada tanggal
        'alasan': dbMap['alasan'] as String? ?? 'Tidak ada alasan tercatat.', // Beri nilai default

        'user_id': dbMap['user_id'],
        'tanggal_pengajuan': dbMap['tanggal_pengajuan'],
        'jam': fullIsoDateTime,
      };

      // 2. Gunakan fromJson untuk konversi
      try {
        return IzinConverterModel.fromJson(reconstructedJson);
      } catch (e) {
        // Tangkap error parsing DateTime jika data tanggal tidak valid
        print("ERROR PARSING IZIN ID ${dbMap['id']}: $e. Data mentah: $dbMap");

        // Kembalikan model yang diisi dengan nilai 'unknown'
        return IzinConverterModel(
          id: dbMap['id']?.toString() ?? '0',
          tipe: IzinTipe.unknown,
          status: IzinStatus.unknown,
          tanggal: DateTime.now(),
          alasan: 'Data Korup (ID: ${dbMap['id']})',
          tanggalPengajuan: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
      }
    });
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