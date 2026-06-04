import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class ApiResponse<T> {
  @JsonKey(name: 'code')
  int? code;
  @JsonKey(name: 'message')
  String? message;
  @JsonKey(name: 'data')
  T? data;

  ApiResponse();

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson<T>(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT) =>
      _$ApiResponseToJson<T>(this, toJsonT);
}
