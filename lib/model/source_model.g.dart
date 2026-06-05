// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceModel _$SourceModelFromJson(Map<String, dynamic> json) => SourceModel(
  message: json['message'] as String?,
  device: json['device'] as String?,
  stackTrace: json['stackTrace'] as String?,
  date: json['date'] as String?,
  token: json['token'] as String?,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  appVersion: json['appVersion'] as String?,
  path: json['path'] as String?,
);

Map<String, dynamic> _$SourceModelToJson(SourceModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'device': instance.device,
      'stackTrace': instance.stackTrace,
      'date': instance.date,
      'token': instance.token,
      'user': instance.user,
      'appVersion': instance.appVersion,
      'path': instance.path,
    };

User _$UserFromJson(Map<String, dynamic> json) => User();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{};
