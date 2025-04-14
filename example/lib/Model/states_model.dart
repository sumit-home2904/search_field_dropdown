class StatesModel {
  int id;
  String name;
  int code;
  int countryId;

  StatesModel({
    required this.id,
    required this.name,
    required this.code,
    required this.countryId,
  });

  factory StatesModel.fromJson(Map<String, dynamic> json) => StatesModel(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        countryId: json["country_id"],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatesModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "country_id": countryId,
      };
}
