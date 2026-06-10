import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:app_berita/model/article_model.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/shared_widget/loading_indicator.dart';
import 'package:app_berita/features/home/cubit/home_news_cubit.dart';

class TrendingListScreen extends StatefulWidget {
  const TrendingListScreen({super.key});

  @override
  State<TrendingListScreen> createState() => _TrendingListScreenState();
}

class _TrendingListScreenState extends State<TrendingListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    final cubit = context.read<HomeNewsCubit>();
    if (cubit.state is HomeNewsLoaded) {
      cubit.initTrendingList();
      // Panggil loadMoreTrending untuk memuat page berikutnya segera setelah layar dirender
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HomeNewsCubit>().loadMoreTrending();
        }
      });
    } else {
      cubit.fetchHomeData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Trigger loadMoreTrending when user scrolls to 90% of the maximum scroll extent
    final threshold = _scrollController.position.maxScrollExtent * 0.9;
    if (_scrollController.position.pixels >= threshold) {
      final cubit = context.read<HomeNewsCubit>();
      final state = cubit.state;
      if (state is HomeNewsLoaded) {
        if (state.isTrendingListLoadingMore || state.hasReachedMaxTrending) {
          return;
        }
        cubit.loadMoreTrending();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocBuilder<HomeNewsCubit, HomeNewsState>(
          builder: (context, state) {
            if (state is HomeNewsInitial || state is HomeNewsLoading) {
              return const Center(
                child: GradientCircularProgressIndicator(
                  size: 32,
                  strokeWidth: 4,
                  color: primaryColor,
                ),
              );
            } else if (state is HomeNewsError) {
              return _buildErrorState(state.message);
            } else if (state is HomeNewsLoaded) {
              return _buildArticleList(state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
        'Trending',
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textNeutralPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: textNeutralPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_outlined, color: iconNeutralPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Search functionality is coming soon!',
                  style: TextStyle(fontFamily: 'poppins'),
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildArticleList(HomeNewsLoaded state) {
    final articles = state.trendingListArticles;
    final hasError = state.trendingListErrorMessage != null;
    final showFooter =
        state.isTrendingListLoadingMore ||
        hasError ||
        state.hasReachedMaxTrending;

    return RefreshIndicator(
      onRefresh: () => context.read<HomeNewsCubit>().refreshTrending(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        itemCount: articles.length + (showFooter ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            if (hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Gagal memuat berita lainnya',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          color: textNeutralSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            context.read<HomeNewsCubit>().loadMoreTrending(),
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: primaryColor,
                        ),
                        label: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state.hasReachedMaxTrending) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Semua berita telah dimuat',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      color: textNeutralSecondary,
                    ),
                  ),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: GradientCircularProgressIndicator(
                  size: 24,
                  strokeWidth: 3,
                  color: primaryColor,
                ),
              ),
            );
          }
          return _buildArticleItem(articles[index]);
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: errorColor),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 14,
                color: textNeutralSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                context.read<HomeNewsCubit>().fetchHomeData();
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(ArticleModel story) {
    final title = story.title ?? '';
    final sourceName = story.source?.name ?? 'Unknown';
    final timeStr = story.publishedAt != null
        ? timeago.format(story.publishedAt!)
        : '';
    final imageUrl = story.urlToImage ?? '';
    final url = story.url ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      sourceName.isNotEmpty ? sourceName[0] : 'N',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$sourceName  •  $timeStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textNeutralPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: GradientCircularProgressIndicator(
                          size: 20,
                          strokeWidth: 2.5,
                          color: primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildImagePlaceholder(96, 96),
                    )
                  : _buildImagePlaceholder(96, 96),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    if (url.isNotEmpty) {
                      final messenger = ScaffoldMessenger.of(context);
                      Clipboard.setData(ClipboardData(text: url)).then((_) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Link copied to clipboard!\n$url',
                              style: const TextStyle(fontFamily: 'poppins'),
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      });
                    }
                  },
                  child: const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: iconDarkSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'More options selected.',
                          style: TextStyle(fontFamily: 'poppins'),
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: iconDarkSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: borderNeutral,
      child: const Icon(
        Icons.image_outlined,
        color: iconDarkSecondary,
        size: 30,
      ),
    );
  }
}
