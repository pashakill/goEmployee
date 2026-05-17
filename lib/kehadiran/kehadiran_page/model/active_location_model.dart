class ActiveLocationModel {
  final double lat;
  final double lng;
  final double radius;
  final String? type;

  ActiveLocationModel({
    required this.lat,
    required this.lng,
    required this.radius,
    this.type,
  });

  factory ActiveLocationModel.fromJson(Map<String, dynamic> json) {
    return ActiveLocationModel(
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      radius: double.parse(json['radius'].toString()),
      type: json['type'],
    );
  }
}