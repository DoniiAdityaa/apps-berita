import 'dart:math';

import 'package:app_berita/model/article_model.dart';
import 'package:app_berita/repository/news_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_news_state.dart';

class HomeNewsCubit extends Cubit<HomeNewsState> {
  final NewsRepository _newsRepository;

  HomeNewsCubit(this._newsRepository) : super(HomeNewsInitial());

  // Mengambil data awal untuk Home Screen (Trending & Recent 'All')
  Future<void> fetchHomeData() async {
    try {
      emit(HomeNewsLoading());

      // 1. Ambil berita trending (berita breaking news utama dari US)
      final trendingResponse = await _newsRepository.getTrendingNews(
        country: 'us',
        pageSize: 5,
      );

      // 2. Pilih sorting acak untuk getEverything (Opsi C) agar berita berubah saat di-refresh
      final sortMethods = ['publishedAt', 'popularity', 'relevancy'];
      final randomSort = sortMethods[Random().nextInt(sortMethods.length)];

      // 3. Ambil berita recent dengan query general 'news' dan sorting acak
      final recentResponse = await _newsRepository.getEverything(
        query: 'news',
        sortBy: randomSort,
        pageSize: 25, // Ambil lebih banyak untuk cadangan setelah difilter
      );

      final trendingArticles = trendingResponse.articles ?? [];
      final recentArticles = recentResponse.articles ?? [];

      // 4. Saring duplikat: berita yang sudah ada di Trending tidak boleh muncul di Recent Stories
      final trendingUrls = trendingArticles.map((e) => e.url).toSet();
      final uniqueRecent = recentArticles
          .where((article) => article.url != null && !trendingUrls.contains(article.url))
          .take(15)
          .toList();

      emit(
        HomeNewsLoaded(
          trendingNews: trendingArticles,
          recentNews: uniqueRecent,
          selectedCategory: 'All',
        ),
      );
    } catch (e) {
      emit(HomeNewsError(message: e.toString()));
    }
  }

  // Mengubah kategori berita Recent Stories
  Future<void> changeCategory(String category) async {
    if (state is! HomeNewsLoaded) return;
    final currentState = state as HomeNewsLoaded;

    if (currentState.selectedCategory == category) return;

    final loadingState = currentState.copyWith(
      selectedCategory: category,
      isRecentLoading: true,
    );
    emit(loadingState);

    try {
      // Map kategori di UI ke query pencarian untuk endpoint /everything
      String apiQuery = 'news';
      if (category != 'All') {
        apiQuery = category.toLowerCase();
      }

      // Gunakan sorting acak saat ganti kategori agar konten bervariasi
      final sortMethods = ['publishedAt', 'popularity', 'relevancy'];
      final randomSort = sortMethods[Random().nextInt(sortMethods.length)];

      final response = await _newsRepository.getEverything(
        query: apiQuery,
        sortBy: randomSort,
        pageSize: 25,
      );

      final newArticles = response.articles ?? [];

      // Saring duplikat terhadap trendingNews yang ada di state saat ini
      final trendingUrls = currentState.trendingNews.map((e) => e.url).toSet();
      final uniqueRecent = newArticles
          .where((article) => article.url != null && !trendingUrls.contains(article.url))
          .take(15)
          .toList();

      emit(
        loadingState.copyWith(
          recentNews: uniqueRecent,
          isRecentLoading: false,
        ),
      );
    } catch (e) {
      emit(loadingState.copyWith(isRecentLoading: false));
    }
  }
}
