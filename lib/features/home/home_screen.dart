import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app_berita/features/home/cubit/home_news_cubit.dart';
import 'package:app_berita/model/article_model.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:app_berita/ui/shared_widget/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'All',
    'Politics',
    'Technology',
    'Business',
    'Science',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    // Memanggil API pertama kali saat layar terbuka
    context.read<HomeNewsCubit>().fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: BlocBuilder<HomeNewsCubit, HomeNewsState>(
          builder: (context, state) {
            if (state is HomeNewsLoading) {
              return _buildLoadingState();
            } else if (state is HomeNewsError) {
              return _buildErrorState(state.message, context);
            } else if (state is HomeNewsLoaded) {
              return _buildLoadedState(state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // LAYOUT STATES (LOADING, ERROR, LOADED)
  // ===========================================================================

  /// State Loading Awal (Menampilkan Shimmer di seluruh bagian)
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSectionPlaceholder(),
          _buildTrendingSectionPlaceholder(),
          _buildCategorySectionPlaceholder(),
          _buildRecentStoriesPlaceholder(),
        ],
      ),
    );
  }

  /// State Error (Menampilkan pesan error dan tombol Retry)
  Widget _buildErrorState(String message, BuildContext context) {
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

  /// State Loaded (Menampilkan data asli dari API)
  Widget _buildLoadedState(HomeNewsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeNewsCubit>().fetchHomeData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Section
            _buildWelcomeSection(),

            // 2. Trending Section
            _buildTrendingSection(state.trendingNews),

            // 3. Category Filter Section
            _buildCategorySection(state.selectedCategory),

            // 4. Recent Stories Section (Menggunakan shimmer khusus jika hanya kategori yang reload)
            if (state.isRecentLoading)
              _buildRecentStoriesPlaceholder()
            else
              _buildRecentStoriesSection(state.recentNews),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET COMPONENT DENGAN DATA ASLI API
  // ===========================================================================

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      radius: 24,
                      backgroundColor: borderNeutral,
                      child: Icon(Icons.person, color: iconDarkSecondary),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Andrew Ainsley',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: borderNeutral),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  color: iconNeutralPrimary,
                  size: 24,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(List<ArticleModel> trendingNews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // ==========================================
                  // TARUH NAVIGATOR PUSH ANDA DI SINI UNTUK
                  // PINDAH KE HALAMAN BARU (TRENDING NEWS LIST)
                  // ==========================================
                  print('View All Trending News');
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: smSemiBold.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 290,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: trendingNews.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildTrendingCard(trendingNews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(ArticleModel news) {
    final title = news.title ?? '';
    final sourceName = news.source?.name ?? 'Unknown';
    final timeStr = news.publishedAt != null
        ? timeago.format(news.publishedAt!)
        : '';
    final imageUrl = news.urlToImage ?? '';

    return SizedBox(
      width: 270,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 150,
                    width: 270,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: GradientCircularProgressIndicator(
                        size: 24,
                        strokeWidth: 3,
                        color: primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildImagePlaceholder(150, 270),
                  )
                : _buildImagePlaceholder(150, 270),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
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
                  style: xsRegular.copyWith(color: textNeutralSecondary),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final url = news.url ?? '';
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
                  size: 16,
                  color: iconDarkSecondary,
                ),
              ),
              const SizedBox(width: 12),
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
                  size: 16,
                  color: iconDarkSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String selectedCategory) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () {
              context.read<HomeNewsCubit>().changeCategory(categories[index]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryColor : borderNeutral,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : textNeutralSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentStoriesSection(List<ArticleModel> recentNews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Stories',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // ==========================================
                  // TARUH NAVIGATOR PUSH ANDA DI SINI UNTUK
                  // PINDAH KE HALAMAN BARU (RECENT STORIES LIST)
                  // ==========================================
                  print('View All Recent Stories');
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: smSemiBold.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (recentNews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Text(
              'No stories found in this category.',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 14,
                color: textNeutralSecondary,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: recentNews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildRecentStoryCard(recentNews[index]);
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecentStoryCard(ArticleModel story) {
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
              Text(
                sourceName,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textNeutralSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 2,
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

  // ===========================================================================
  // WIDGET PLACEHOLDERS (SHIMMERS)
  // ===========================================================================

  Widget _buildWelcomeSectionPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildShimmerContainer(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              _buildShimmerContainer(width: 120, height: 16),
            ],
          ),
          _buildShimmerContainer(width: 48, height: 48, borderRadius: 24),
        ],
      ),
    );
  }

  Widget _buildTrendingSectionPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerContainer(width: 100, height: 24),
              _buildShimmerContainer(width: 60, height: 16),
            ],
          ),
        ),
        SizedBox(
          height: 290,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 270,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(
                      width: 270,
                      height: 150,
                      borderRadius: 16,
                    ),
                    const SizedBox(height: 12),
                    _buildShimmerContainer(width: 240, height: 18),
                    const SizedBox(height: 6),
                    _buildShimmerContainer(width: 180, height: 18),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildShimmerContainer(
                          width: 20,
                          height: 20,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 8),
                        _buildShimmerContainer(width: 120, height: 12),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySectionPlaceholder() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _buildShimmerContainer(
            width: 80,
            height: 38,
            borderRadius: 20,
          );
        },
      ),
    );
  }

  Widget _buildRecentStoriesPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerContainer(width: 120, height: 20),
              _buildShimmerContainer(width: 60, height: 16),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerContainer(width: 80, height: 12),
                      const SizedBox(height: 6),
                      _buildShimmerContainer(
                        width: double.infinity,
                        height: 16,
                      ),
                      const SizedBox(height: 6),
                      _buildShimmerContainer(width: 180, height: 16),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildShimmerContainer(
                            width: 20,
                            height: 20,
                            borderRadius: 10,
                          ),
                          const SizedBox(width: 8),
                          _buildShimmerContainer(width: 100, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildShimmerContainer(width: 96, height: 96, borderRadius: 12),
              ],
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

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

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
