class UserModel {
  final int id;
  final String nama;

  UserModel({
    required this.id,
    required this.nama,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['nama'],
    );
  }
}