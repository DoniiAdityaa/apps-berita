import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/shared_widget/loading_indicator.dart';

class DummyArticle {
  final String title;
  final String sourceName;
  final String sourceLogoChar;
  final String timeAgo;
  final String imageUrl;
  final int views;
  final int comments;
  final String category;

  const DummyArticle({
    required this.title,
    required this.sourceName,
    required this.sourceLogoChar,
    required this.timeAgo,
    required this.imageUrl,
    required this.views,
    required this.comments,
    required this.category,
  });
}

class RecentStoriesListScreen extends StatefulWidget {
  const RecentStoriesListScreen({super.key});

  @override
  State<RecentStoriesListScreen> createState() =>
      _RecentStoriesListScreenState();
}

class _RecentStoriesListScreenState extends State<RecentStoriesListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  String _selectedCategory = 'All';
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  int _visibleCount = 6;

  final List<String> _categories = [
    'All',
    'Politics',
    'Technology',
    'Business',
    'Science',
    'Health',
  ];

  // Dummy articles data representing standard categories
  final List<DummyArticle> _allDummyArticles = const [
    DummyArticle(
      title: 'Revolutionizing the Future: Breakthrough Technology Set to Transform Industries',
      sourceName: 'Jane Cooper',
      sourceLogoChar: 'J',
      timeAgo: '1 min ago',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=500&auto=format&fit=crop&q=60',
      views: 378,
      comments: 2,
      category: 'Technology',
    ),
    DummyArticle(
      title: 'Economic Boom on the Horizon: Experts Predict Record Growth in Key Sectors',
      sourceName: 'NBC News',
      sourceLogoChar: 'N',
      timeAgo: '2 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=500&auto=format&fit=crop&q=60',
      views: 852,
      comments: 3,
      category: 'Business',
    ),
    DummyArticle(
      title: 'Breakthrough Discovery: Promising Treatment Shows Potential in Cancer Battle',
      sourceName: 'Brooklyn Simmons',
      sourceLogoChar: 'B',
      timeAgo: '3 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1530026405186-ed1ea0ac7a63?w=500&auto=format&fit=crop&q=60',
      views: 1200,
      comments: 5,
      category: 'Health',
    ),
    DummyArticle(
      title: 'Innovation Unleashed: Groundbreaking Tech Unveiled at Global Summit',
      sourceName: 'BBC News',
      sourceLogoChar: 'B',
      timeAgo: '3 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500&auto=format&fit=crop&q=60',
      views: 1300,
      comments: 2,
      category: 'Technology',
    ),
    DummyArticle(
      title: 'Runway Extravaganza: Highlights from the Latest Fashion Week',
      sourceName: 'Fox News',
      sourceLogoChar: 'F',
      timeAgo: '5 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&auto=format&fit=crop&q=60',
      views: 940,
      comments: 12,
      category: 'Health',
    ),
    DummyArticle(
      title: 'Global Climate Summit: World Leaders Agree on Landmark Emissions Targets',
      sourceName: 'Reuters',
      sourceLogoChar: 'R',
      timeAgo: '10 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500&auto=format&fit=crop&q=60',
      views: 2450,
      comments: 89,
      category: 'Politics',
    ),
    DummyArticle(
      title: 'AI in Medicine: Diagnosis Accuracy Reaches Unprecedented Levels',
      sourceName: 'Science Daily',
      sourceLogoChar: 'S',
      timeAgo: '15 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=500&auto=format&fit=crop&q=60',
      views: 630,
      comments: 14,
      category: 'Science',
    ),
    DummyArticle(
      title: 'Market Surge: Stocks Hit All-Time Highs Amid Tech Sector Rally',
      sourceName: 'Bloomberg',
      sourceLogoChar: 'B',
      timeAgo: '20 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=500&auto=format&fit=crop&q=60',
      views: 1890,
      comments: 45,
      category: 'Business',
    ),
    DummyArticle(
      title: 'NASA Unveils Stunning New Images of Deep Space from Webb Telescope',
      sourceName: 'Space.com',
      sourceLogoChar: 'S',
      timeAgo: '30 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1454789548928-9efd52dc4031?w=500&auto=format&fit=crop&q=60',
      views: 4120,
      comments: 112,
      category: 'Science',
    ),
    DummyArticle(
      title: 'New Policy Reform: Education Board to Update Standardized Curriculum',
      sourceName: 'CNN',
      sourceLogoChar: 'C',
      timeAgo: '45 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?w=500&auto=format&fit=crop&q=60',
      views: 730,
      comments: 8,
      category: 'Politics',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent * 0.9;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore || _hasReachedMax) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay of 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final filtered = _getFilteredArticles();
      setState(() {
        _isLoadingMore = false;
        if (_visibleCount >= filtered.length) {
          _hasReachedMax = true;
        } else {
          _visibleCount = (_visibleCount + 4).clamp(0, filtered.length);
          if (_visibleCount >= filtered.length) {
            _hasReachedMax = true;
          }
        }
      });
    });
  }

  List<DummyArticle> _getFilteredArticles() {
    if (_selectedCategory == 'All') {
      return _allDummyArticles;
    }
    return _allDummyArticles
        .where((article) => article.category == _selectedCategory)
        .toList();
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _visibleCount = 6;
      _isLoadingMore = false;
      _hasReachedMax = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredArticles();
    final displayed = filtered.take(_visibleCount).toList();
    final showFooter = _isLoadingMore || _hasReachedMax || (filtered.length > displayed.length);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category list
            _buildCategorySection(),
            // Main list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() {
                      _visibleCount = 6;
                      _hasReachedMax = false;
                    });
                  }
                },
                child: displayed.isEmpty
                    ? const Center(
                        child: Text(
                          'No stories found in this category.',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 14,
                            color: textNeutralSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        itemCount: displayed.length + (showFooter ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          if (index == displayed.length) {
                            if (_isLoadingMore) {
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
                            if (_hasReachedMax || displayed.length >= filtered.length) {
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
                            return const SizedBox.shrink();
                          }
                          return _buildArticleItem(displayed[index]);
                        },
                      ),
              ),
            ),
          ],
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
        'Recent Stories',
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

  Widget _buildCategorySection() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => _changeCategory(_categories[index]),
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
                  _categories[index],
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

  Widget _buildArticleItem(DummyArticle story) {
    final title = story.title;
    final sourceName = story.sourceName;
    final timeStr = story.timeAgo;
    final imageUrl = story.imageUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      story.sourceLogoChar,
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
                      sourceName,
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
              const SizedBox(height: 6),
              // Meta Row with Views and Comments
              Row(
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: textNeutralSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 13,
                    color: textNeutralSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${story.views}',
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: textNeutralSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 13,
                    color: textNeutralSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${story.comments}',
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: textNeutralSecondary,
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
              child: CachedNetworkImage(
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
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Clipboard.setData(const ClipboardData(text: 'https://newsapi.org')).then((_) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Link copied to clipboard!',
                            style: TextStyle(fontFamily: 'poppins'),
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
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
