class User {
  int? id; // Boleh kosong saat membuat, akan diisi oleh database
  String nama;
  String username;
  String password; // Sebaiknya simpan password yang sudah di-hash
  String companyName;
  String role;
  String dateNow; // Format: 'yyyy-MM-dd'
  String? timeCheckin; // Format: 'HH:mm:ss'
  String? timeCheckout;
  String? lateCheckin;
  String? photo;

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
  });

  // Konversi dari User Object ke Map
  // Ini adalah yang akan kita gunakan untuk insert ke database
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
    };
  }
}