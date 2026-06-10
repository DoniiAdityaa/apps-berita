import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/model/article_model.dart';
import 'package:app_berita/repository/news_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_news_state.dart';

class HomeNewsCubit extends Cubit<HomeNewsState> {
  final NewsRepository _newsRepository;
  final UserPreference _userPreference;

  HomeNewsCubit(this._newsRepository, this._userPreference) : super(HomeNewsInitial());

  // Mengambil data awal untuk Home Screen (Trending & Recent 'All')
  Future<void> fetchHomeData() async {
    try {
      emit(HomeNewsLoading());

      final user = _userPreference.getUser();
      final countryCode = user.country ?? 'us';

      // 1. Ambil berita trending dari negara terpilih
      final trendingResponse = await _newsRepository.getTrendingNews(
        country: countryCode,
        pageSize: 15, // Ambil lebih banyak untuk dibagikan ke Trending & Recent
      );

      final trendingArticles = trendingResponse.articles ?? [];
      
      // Ambil 5 teratas untuk Trending
      final trendingList = trendingArticles.take(5).toList();

      // Ambil sisanya untuk Recent Stories (All)
      final recentList = trendingArticles.skip(5).take(10).toList();

      emit(
        HomeNewsLoaded(
          trendingNews: trendingList,
          recentNews: recentList,
          selectedCategory: 'All',
          trendingListArticles: trendingList,
          trendingPage: 1,
          hasReachedMaxTrending: false,
          isTrendingListLoadingMore: false,
          trendingListErrorMessage: null,
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
      final user = _userPreference.getUser();
      final countryCode = user.country ?? 'us';

      List<ArticleModel> uniqueRecent = [];

      if (category == 'All') {
        final response = await _newsRepository.getTrendingNews(
          country: countryCode,
          pageSize: 15,
        );
        final articles = response.articles ?? [];
        final trendingUrls = currentState.trendingNews.map((e) => e.url).toSet();
        uniqueRecent = articles
            .where((article) => article.url != null && !trendingUrls.contains(article.url))
            .take(10)
            .toList();
      } else {
        // Cek apakah kategori didukung secara standar oleh endpoint top-headlines NewsAPI
        final isStandardCategory = const [
          'business',
          'entertainment',
          'general',
          'health',
          'science',
          'sports',
          'technology'
        ].contains(category.toLowerCase());

        List<ArticleModel> newArticles = [];
        if (isStandardCategory) {
          final response = await _newsRepository.getNewsByCategory(
            country: countryCode,
            category: category.toLowerCase(),
            pageSize: 20,
          );
          newArticles = response.articles ?? [];
        } else {
          final response = await _newsRepository.getEverything(
            query: category.toLowerCase(),
            sortBy: 'publishedAt',
            pageSize: 20,
          );
          newArticles = response.articles ?? [];
        }

        // Saring duplikat terhadap trendingNews yang ada di state saat ini
        final trendingUrls = currentState.trendingNews.map((e) => e.url).toSet();
        uniqueRecent = newArticles
            .where((article) => article.url != null && !trendingUrls.contains(article.url))
            .take(10) // Dibatasi maksimal 10 berita
            .toList();
      }

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

  // Inisialisasi/reset list trending dengan data yang sudah ada di home
  void initTrendingList() {
    if (state is! HomeNewsLoaded) return;
    final currentState = state as HomeNewsLoaded;
    emit(currentState.copyWith(
      trendingListArticles: currentState.trendingNews,
      trendingPage: 1,
      hasReachedMaxTrending: false,
      isTrendingListLoadingMore: false,
      clearTrendingError: true,
    ));
  }

  // Mengambil halaman berita trending berikutnya (load more)
  Future<void> loadMoreTrending() async {
    if (state is! HomeNewsLoaded) return;
    final currentState = state as HomeNewsLoaded;

    if (currentState.isTrendingListLoadingMore || currentState.hasReachedMaxTrending) return;

    emit(currentState.copyWith(
      isTrendingListLoadingMore: true,
      clearTrendingError: true,
    ));

    try {
      final user = _userPreference.getUser();
      final countryCode = user.country ?? 'us';
      final nextPage = currentState.trendingPage + 1;

      final response = await _newsRepository.getTrendingNews(
        country: countryCode,
        page: nextPage,
        pageSize: 8,
      );

      final newArticles = response.articles ?? [];

      if (newArticles.isEmpty) {
        emit(currentState.copyWith(
          isTrendingListLoadingMore: false,
          hasReachedMaxTrending: true,
        ));
      } else {
        emit(currentState.copyWith(
          trendingListArticles: List.of(currentState.trendingListArticles)..addAll(newArticles),
          trendingPage: nextPage,
          isTrendingListLoadingMore: false,
          hasReachedMaxTrending: newArticles.length < 8,
        ));
      }
    } catch (e, stackTrace) {
      print("Error in HomeNewsCubit.loadMoreTrending: $e");
      print(stackTrace);
      emit(currentState.copyWith(
        isTrendingListLoadingMore: false,
        trendingListErrorMessage: e.toString(),
      ));
    }
  }

  // Reload berita trending dari halaman 1 (pull to refresh)
  Future<void> refreshTrending() async {
    if (state is! HomeNewsLoaded) return;
    final currentState = state as HomeNewsLoaded;

    try {
      final user = _userPreference.getUser();
      final countryCode = user.country ?? 'us';

      final response = await _newsRepository.getTrendingNews(
        country: countryCode,
        page: 1,
        pageSize: 8,
      );

      final articles = response.articles ?? [];

      emit(currentState.copyWith(
        trendingListArticles: articles,
        trendingPage: 1,
        hasReachedMaxTrending: articles.length < 8,
        isTrendingListLoadingMore: false,
        clearTrendingError: true,
      ));
    } catch (e, stackTrace) {
      print("Error in HomeNewsCubit.refreshTrending: $e");
      print(stackTrace);
      emit(currentState.copyWith(
        trendingListErrorMessage: e.toString(),
      ));
    }
  }
}
