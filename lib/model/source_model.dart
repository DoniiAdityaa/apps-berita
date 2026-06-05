import 'package:json_annotation/json_annotation.dart';

part 'source_model.g.dart';

@JsonSerializable()
class SourceModel {
  @JsonKey(name: "message")
  String? message;
  @JsonKey(name: "device")
  String? device;
  @JsonKey(name: "stackTrace")
  String? stackTrace;
  @JsonKey(name: "date")
  String? date;
  @JsonKey(name: "token")
  String? token;
  @JsonKey(name: "user")
  User? user;
  @JsonKey(name: "appVersion")
  String? appVersion;
  @JsonKey(name: "path")
  String? path;

  SourceModel({
    this.message,
    this.device,
    this.stackTrace,
    this.date,
    this.token,
    this.user,
    this.appVersion,
    this.path,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) =>
      _$SourceModelFromJson(json);

  Map<String, dynamic> toJson() => _$SourceModelToJson(this);
}

@JsonSerializable()
class User {
  User();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
