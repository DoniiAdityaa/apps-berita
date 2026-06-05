import 'package:app_berita/data/api/api_service.dart';
import 'package:app_berita/model/news_response_model.dart';

class NewsRepository {
  final ApiService api;

  NewsRepository(this.api);
  Future<NewsResponseModel> getTrendingNews({
    required String country,
    int? pageSize,
    int? page,
  }) async {
    final res = await api.getTopHeadlines(
      country: country,
      pageSize: pageSize,
      page: page,
    );

    // cek response dari NewsAPI
    if (res.status == 'ok') {
      return res;
    }

    throw Exception('gagal mengambil berita trending');
  }

  // mengambil berita berdasarkan category
  Future<NewsResponseModel> getNewsByCategory({
    required String country,
    String? category,
    int? pageSize,
    int? page,
  }) async {
    final res = await api.getTopHeadlines(
      country: country,
      category: category,
      pageSize: pageSize,
      page: page,
    );

    if (res.status == 'ok') {
      return res;
    }

    throw Exception('Gagal mengambil berita category $category');
  }

  // mengambil berita secara umum menggunakan search query & custom sorting
  Future<NewsResponseModel> getEverything({
    required String query,
    String? sortBy,
    int? pageSize,
    int? page,
  }) async {
    final res = await api.getEverything(
      query: query,
      sortBy: sortBy,
      pageSize: pageSize,
      page: page,
    );

    if (res.status == 'ok') {
      return res;
    }

    throw Exception('Gagal mengambil berita pencarian query: $query');
  }
}
