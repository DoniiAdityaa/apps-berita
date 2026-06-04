// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_error_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseErrorLogModel _$FirebaseErrorLogModelFromJson(
  Map<String, dynamic> json,
) => FirebaseErrorLogModel(
  message: json['message'] as String?,
  device: json['device'] as String?,
  stackTrace: json['stackTrace'] as String?,
  date: json['date'] as String?,
  token: json['token'] as String?,
  user: json['user'] as Map<String, dynamic>?,
  appVersion: json['appVersion'] as String?,
  path: json['path'] as String?,
);

Map<String, dynamic> _$FirebaseErrorLogModelToJson(
  FirebaseErrorLogModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'device': instance.device,
  'stackTrace': instance.stackTrace,
  'date': instance.date,
  'token': instance.token,
  'user': instance.user,
  'appVersion': instance.appVersion,
  'path': instance.path,
};
