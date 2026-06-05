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

  const HomeNewsLoaded({
    required this.trendingNews,
    required this.recentNews,
    required this.selectedCategory,
    this.isRecentLoading = false,
  });

  @override
  List<Object?> get props => [
    trendingNews,
    recentNews,
    selectedCategory,
    isRecentLoading,
  ];

  // membuat instance baru dengan nilai yang sama kecuali yang diubah
  HomeNewsLoaded copyWith({
    List<ArticleModel>? trendingNews,
    List<ArticleModel>? recentNews,
    String? selectedCategory,
    bool? isRecentLoading,
  }) {
    return HomeNewsLoaded(
      trendingNews: trendingNews ?? this.trendingNews,
      recentNews: recentNews ?? this.recentNews,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isRecentLoading: isRecentLoading ?? this.isRecentLoading,
    );
  }
}

final class HomeNewsError extends HomeNewsState {
  final String message;
  const HomeNewsError({required this.message});
  @override
  List<Object?> get props => [message];
}
