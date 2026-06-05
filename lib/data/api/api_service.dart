import 'package:app_berita/config/constant.dart';
import 'package:app_berita/model/news_response_model.dart';
import 'package:dio/dio.dart';

import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: baseApi, parser: Parser.JsonSerializable)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // mengambil berita utama / berdasarkan kategory
  @GET('top-headlines')
  Future<NewsResponseModel> getTopHeadlines({
    @Query("country") String? country,
    @Query("category") String? category,
    @Query("pageSize") int? pageSize,
    @Query("page") int? page,
  });

  // mencari berita / mengambil berita secara umum
  @GET('everything')
  Future<NewsResponseModel> getEverything({
    @Query("q") String? query,
    @Query("sortBy") String? sortBy,
    @Query("pageSize") int? pageSize,
    @Query("page") int? page,
  });
}
