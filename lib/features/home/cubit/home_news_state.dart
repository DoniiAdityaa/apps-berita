part of 'home_news_cubit.dart';

sealed class HomeNewsState extends Equatable {
  const HomeNewsState();

  @override
  List<Object?> get props => [];
}

final class HomeNewsInitial extends HomeNewsState {}

final class HomeNewsLoading extends HomeNewsState {}

final class HomeNewsLoaded extends HomeNewsState {
  final List<ArticleModel> trendingNews;
  final List<ArticleModel> recentNews;
  final String selectedCategory;
  final bool isRecentLoading;

  // Fields for Trending List Screen
  final List<ArticleModel> trendingListArticles;
  final int trendingPage;
  final bool hasReachedMaxTrending;
  final bool isTrendingListLoadingMore;
  final String? trendingListErrorMessage;

  const HomeNewsLoaded({
    required this.trendingNews,
    required this.recentNews,
    required this.selectedCategory,
    this.isRecentLoading = false,
    this.trendingListArticles = const [],
    this.trendingPage = 1,
    this.hasReachedMaxTrending = false,
    this.isTrendingListLoadingMore = false,
    this.trendingListErrorMessage,
  });

  @override
  List<Object?> get props => [
    trendingNews,
    recentNews,
    selectedCategory,
    isRecentLoading,
    trendingListArticles,
    trendingPage,
    hasReachedMaxTrending,
    isTrendingListLoadingMore,
    trendingListErrorMessage,
  ];

  // membuat instance baru dengan nilai yang sama kecuali yang diubah
  HomeNewsLoaded copyWith({
    List<ArticleModel>? trendingNews,
    List<ArticleModel>? recentNews,
    String? selectedCategory,
    bool? isRecentLoading,
    List<ArticleModel>? trendingListArticles,
    int? trendingPage,
    bool? hasReachedMaxTrending,
    bool? isTrendingListLoadingMore,
    String? trendingListErrorMessage,
    bool clearTrendingError = false,
  }) {
    return HomeNewsLoaded(
      trendingNews: trendingNews ?? this.trendingNews,
      recentNews: recentNews ?? this.recentNews,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRecentLoading: isRecentLoading ?? this.isRecentLoading,
      trendingListArticles: trendingListArticles ?? this.trendingListArticles,
      trendingPage: trendingPage ?? this.trendingPage,
      hasReachedMaxTrending: hasReachedMaxTrending ?? this.hasReachedMaxTrending,
      isTrendingListLoadingMore: isTrendingListLoadingMore ?? this.isTrendingListLoadingMore,
      trendingListErrorMessage: clearTrendingError ? null : (trendingListErrorMessage ?? this.trendingListErrorMessage),
    );
  }
}

final class HomeNewsError extends HomeNewsState {
  final String message;
  const HomeNewsError({required this.message});
  @override
  List<Object?> get props => [message];
}
