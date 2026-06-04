import 'package:json_annotation/json_annotation.dart';

part 'firebase_error_log_model.g.dart';

@JsonSerializable()
class FirebaseErrorLogModel {
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
  Map<String, dynamic>? user;
  @JsonKey(name: "appVersion")
  String? appVersion;
  @JsonKey(name: "path")
  String? path;

  FirebaseErrorLogModel({
    this.message,
    this.device,
    this.stackTrace,
    this.date,
    this.token,
    this.user,
    this.appVersion,
    this.path,
  });

  factory FirebaseErrorLogModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseErrorLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseErrorLogModelToJson(this);
}
