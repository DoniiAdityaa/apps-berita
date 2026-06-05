import 'package:json_annotation/json_annotation.dart';
// 1. Import ArticleModel agar bisa digunakan di sini
import 'article_model.dart';

part 'news_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class NewsResponseModel {
  @JsonKey(name: "status")
  String? status;

  @JsonKey(name: "totalResults")
  int? totalResults;

  // 2. Gunakan ArticleModel (dari article_model.dart) yang memiliki field lengkap (termasuk gambar & url)
  @JsonKey(name: "articles")
  List<ArticleModel>? articles;

  NewsResponseModel({this.status, this.totalResults, this.articles});

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NewsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsResponseModelToJson(this);
}

// 3. Class Article dan Source di sini DIHAPUS karena sudah diwakili oleh article_model.dart
