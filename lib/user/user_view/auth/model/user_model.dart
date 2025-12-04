import 'dart:ffi';

import 'package:goemployee/goemployee.dart';

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
  String? latitude;
  String? longitude;
  String? radius;

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
    this.latitude,
    this.longitude,
    this.radius
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
      'latitude': latitude,
      'longitude' : longitude,
      'radius' : radius,
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
      latitude: map['latitude'],
      longitude: map['longitude'],
      radius: map['radius']
    );
  }

  factory User.fromLogin(UserModels loginResponse) {
    return User(
      id: loginResponse.id,
      nama: loginResponse.nama,
      username: loginResponse.username,
      password: loginResponse.password,
      companyName: loginResponse.companyName,
      role: loginResponse.role,
      dateNow: loginResponse.dateNow,
      timeCheckin: loginResponse.timeCheckin,
      timeCheckout: loginResponse.timeCheckout,
      lateCheckin: loginResponse.lateCheckin,
      photo: loginResponse.photo,
      jadwalMulaiKerja: loginResponse.jadwalMulaiKerja,
      jadwalSelesaiKerja: loginResponse.jadwalSelesaiKerja,
      latitude: loginResponse.latitude,
      longitude: loginResponse.longitude,
      radius: loginResponse.radius,
    );
  }

  @override
  String toString() {
    return '''
        User(
          id: $id,
          nama: $nama,
          username: $username,
          password: $password,
          companyName: $companyName,
          role: $role,
          dateNow: $dateNow,
          timeCheckin: $timeCheckin,
          timeCheckout: $timeCheckout,
          lateCheckin: $lateCheckin,
          photo: $photo,
          jadwalMulaiKerja: $jadwalMulaiKerja,
          jadwalSelesaiKerja: $jadwalSelesaiKerja,
          latitude: $latitude,
          longitude: $longitude,
          radius: $radius
        )
        ''';
  }
}