import 'dart:convert';

CityModel cityModelFromJson(String str) => CityModel.fromJson(json.decode(str));
String cityModelToJson(CityModel data) => json.encode(data.toJson());

class CityModel {
  final int id;
  final String name;
  final int stateId;
  final String isActive;

  CityModel(
      {required this.id,
      required this.name,
      required this.stateId,
      required this.isActive});

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json["id"],
        name: json["name"],
        stateId: json["state_id"],
        isActive: json["isActive"]!,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "state_id": stateId,
        "isActive": isActive,
      };
}
