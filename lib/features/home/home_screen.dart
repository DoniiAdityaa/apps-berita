import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Category configuration
  int _selectedCategoryIndex = 0;
  final List<String> categories = [
    'All',
    'Politics',
    'Technology',
    'Business',
    'Science',
    'Health',
  ];

  // Dummy News for Trending (Horizontal Scroll)
  final List<Map<String, String>> dummyNews = [
    {
      'title':
          'Unmasking the Truth: Investigative Report Exposes Widespread Political Corruption',
      'source': 'CNN News',
      'time': '3 days ago',
      'category': 'Politics',
      'imageUrl':
          'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=600&auto=format&fit=crop&q=80',
      'url': 'https://edition.cnn.com/politics',
    },
    {
      'title':
          'Breaking News: Global Economic Agreement Set to Reshape the Market',
      'source': 'USA Today',
      'time': '2 days ago',
      'category': 'Business',
      'imageUrl':
          'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=600&auto=format&fit=crop&q=80',
      'url': 'https://www.usatoday.com/money',
    },
    {
      'title':
          'New Breakthrough: Artificial Intelligence Reaches Human Milestone',
      'source': 'BBC News',
      'time': '1 day ago',
      'category': 'Technology',
      'imageUrl':
          'https://images.unsplash.com/photo-1677442136019-21780efad99a?w=600&auto=format&fit=crop&q=80',
      'url': 'https://www.bbc.com/news/technology',
    },
  ];

  // Dummy News for Recent Stories (Vertical Scroll, filterable)
  final List<Map<String, String>> dummyRecentStories = [
    {
      'title':
          'Revolutionizing the Future: Breakthrough Technology Set to Transform Industries',
      'authorName': 'Jane Cooper',
      'authorAvatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100',
      'time': '1 min ago',
      'category': 'Technology',
      'imageUrl':
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400&auto=format&fit=crop&q=80',
      'url': 'https://www.theverge.com/tech',
    },
    {
      'title': 'Ukraine War: Drone Strikes Deep Inside Russian Territory',
      'authorName': 'Alexander S.',
      'authorAvatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100',
      'time': '4 hours ago',
      'category': 'Politics',
      'imageUrl':
          'https://images.unsplash.com/photo-1444653389962-8149286c578a?w=400&auto=format&fit=crop&q=80',
      'url': 'https://www.reuters.com/world',
    },
    {
      'title':
          'Inflation Rates Drop Faster Than Expected as Global Markets Rally',
      'authorName': 'Robert Fox',
      'authorAvatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100',
      'time': '6 hours ago',
      'category': 'Business',
      'imageUrl':
          'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=400&auto=format&fit=crop&q=80',
      'url': 'https://www.wsj.com/market-data',
    },
    {
      'title':
          'NASA Webb Telescope Captures Breathtaking New Images of the Pillar of Creation',
      'authorName': 'Albert Einstein',
      'authorAvatar':
          'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?auto=format&fit=crop&q=80&w=100',
      'time': '8 hours ago',
      'category': 'Science',
      'imageUrl':
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&auto=format&fit=crop&q=80',
      'url': 'https://www.nasa.gov/mission_pages/webb/main',
    },
    {
      'title':
          'New Vaccine Shows High Promise in Preventing Malaria Transmission',
      'authorName': 'Sarah Jenkins',
      'authorAvatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=100',
      'time': '12 hours ago',
      'category': 'Health',
      'imageUrl':
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&auto=format&fit=crop&q=80',
      'url': 'https://www.who.int/news-room',
    },
  ];

  // Helper method to filter recent stories based on selected category index
  List<Map<String, String>> get _filteredRecentStories {
    final selectedCategory = categories[_selectedCategoryIndex];
    if (selectedCategory == 'All') {
      return dummyRecentStories;
    }
    return dummyRecentStories
        .where((story) => story['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Section (Profile name & notification)
              _buildWelcomeSection(),

              // 2. Trending Section (Horizontal Scroll)
              _buildTrendingSection(),

              // 3. Category Filter Section (Horizontal chips list)
              _buildCategorySection(),

              // 4. Recent Stories Section (Vertical List)
              _buildRecentStoriesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Sub-Widget Helper Methods (Clean Code)
  // ===========================================================================

  /// Header welcome section with profile avatar and notifications badge
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Profile Photo & Name
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

          // Right: Notification Bell Container
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

  /// Trending Section Layout
  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (Trending + View All)
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

        // Horizontal List View
        SizedBox(
          height: 290,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: dummyNews.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildTrendingCard(dummyNews[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Individual Trending Card
  Widget _buildTrendingCard(Map<String, String> news) {
    final title = news['title'] ?? '';
    final source = news['source'] ?? '';
    final time = news['time'] ?? '';
    final imageUrl = news['imageUrl'] ?? '';

    return SizedBox(
      width: 270,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              height: 150,
              width: 270,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: 270,
                  color: borderNeutral,
                  child: const Icon(
                    Icons.image_outlined,
                    color: iconDarkSecondary,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 2. Headline Title (Poppins Bold)
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

          // 3. Source Info (Letter Avatar + Name + Time) - Option A
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: Text(
                  source.isNotEmpty ? source[0] : 'N',
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
                  '$source  •  $time',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: xsRegular.copyWith(color: textNeutralSecondary),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final url = news['url'] ?? '';
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

  /// Horizontal Scrollable Category Chips
  Widget _buildCategorySection() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
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

  /// Recent Stories Section Layout
  Widget _buildRecentStoriesSection() {
    final filteredStories = _filteredRecentStories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (Recent Stories + View All)
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

        // Vertical List of News Card
        if (filteredStories.isEmpty)
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
            itemCount: filteredStories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildRecentStoryCard(filteredStories[index]);
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Individual Recent Story Card (Option A: Left Details, Right Thumbnail + Share/More)
  Widget _buildRecentStoryCard(Map<String, String> story) {
    final title = story['title'] ?? '';
    final authorName = story['authorName'] ?? '';
    final authorAvatar = story['authorAvatar'] ?? '';
    final time = story['time'] ?? '';
    final imageUrl = story['imageUrl'] ?? '';
    final category = story['category'] ?? '';
    final url = story['url'] ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Headline and metadata
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag
              Text(
                category,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textNeutralSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Headline Title
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
              // Source info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      authorAvatar,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              authorName.isNotEmpty ? authorName[0] : 'N',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  $time',
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      color: textNeutralSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right Side: Image thumbnail + Share & More row below it
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 96,
                    height: 96,
                    color: borderNeutral,
                    child: const Icon(
                      Icons.image_outlined,
                      color: iconDarkSecondary,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Share & More actions (from layout screenshot)
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
}
