class User {
  int? id;
  String nama;
  String username;
  String password;
  String companyName;
  String role;
  String dateNow;
  String? timeCheckin;
  String? timeCheckout;
  String? lateCheckin;
  String? photo;
  String? jadwalMulaiKerja;
  String? jadwalSelesaiKerja;

  User({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.companyName,
    required this.role,
    required this.dateNow,
    this.timeCheckin,
    this.timeCheckout,
    this.lateCheckin,
    this.photo,
    this.jadwalMulaiKerja,
    this.jadwalSelesaiKerja,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'password': password,
      'company_name': companyName,
      'role': role,
      'date_now': dateNow,
      'time_checkin': timeCheckin,
      'time_checkout': timeCheckout,
      'late_checkin': lateCheckin,
      'photo': photo,
      'jadwal_mulai_kerja' : jadwalMulaiKerja,
      'jadwal_selesai_kerja' : jadwalSelesaiKerja,
    };
  }

  // --- TAMBAHKAN FUNGSI INI ---
  /// Konversi dari Map (hasil database) ke User Object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nama: map['nama'],
      username: map['username'],
      password: map['password'],
      companyName: map['company_name'],
      role: map['role'],
      dateNow: map['date_now'],
      timeCheckin: map['time_checkin'],
      timeCheckout: map['time_checkout'],
      lateCheckin: map['late_checkin'],
      photo: map['photo'],
      jadwalMulaiKerja: map['jadwal_mulai_kerja'],
      jadwalSelesaiKerja: map['jadwal_selesai_kerja'],
    );
  }
}