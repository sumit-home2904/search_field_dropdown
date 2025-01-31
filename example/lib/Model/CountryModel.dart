import 'dart:convert';

CountryModel countryModelFromJson(String str) =>
    CountryModel.fromJson(json.decode(str));

String countryModelToJson(CountryModel data) => json.encode(data.toJson());

class CountryModel {
  int id;
  String name;
  String code;
  int phoneCode;
  String isActive;

  CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.phoneCode,
    required this.isActive,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        phoneCode: json["phoneCode"],
        isActive: json["isActive"],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "phoneCode": phoneCode,
        "isActive": isActive,
      };
}
