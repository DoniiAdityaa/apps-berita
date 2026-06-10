import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/features/profile/edit_profile_screen.dart';
import 'package:app_berita/features/settings/settings_screen.dart';
import 'package:app_berita/model/article_model.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/shared_widget/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dummy Saved Articles
  final List<ArticleModel> _dummySavedArticles = [
    ArticleModel(
      source: Source(name: 'Andrew Ainsley'),
      author: 'Andrew Ainsley',
      title:
          'The Future is Here: Exploring the Exciting World of Futuristic Tech',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      urlToImage:
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&q=80&w=300',
      url: 'https://example.com/futuristic-tech',
    ),
    ArticleModel(
      source: Source(name: 'Andrew Ainsley'),
      author: 'Andrew Ainsley',
      title:
          'From Sci-Fi to Reality: Mind-Blowing Innovations Taking Center Stage',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      urlToImage:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&q=80&w=300',
      url: 'https://example.com/sci-fi-reality',
    ),
    ArticleModel(
      source: Source(name: 'Andrew Ainsley'),
      author: 'Andrew Ainsley',
      title: 'Breaking: Groundbreaking Tech Breakthroughs Disrupting the Norm',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      urlToImage:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=300',
      url: 'https://example.com/tech-breakthroughs',
    ),
  ];

  // Dummy History Articles
  final List<ArticleModel> _dummyHistoryArticles = [
    ArticleModel(
      source: Source(name: 'TechCrunch'),
      author: 'TechCrunch Staff',
      title: 'Y Combinator W26 Batch: Key Trends and Top AI Startups to Watch',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      urlToImage:
          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&q=80&w=300',
      url: 'https://example.com/yc-trends',
    ),
    ArticleModel(
      source: Source(name: 'Wired'),
      author: 'Wired News',
      title: 'The Rise of Quantum Computing and What It Means for Cryptography',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      urlToImage:
          'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&q=80&w=300',
      url: 'https://example.com/quantum-computing',
    ),
  ];

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    final userPref = serviceLocator.get<UserPreference>();
    final savedUser = userPref.getUser();
    if (savedUser.name != null && savedUser.name!.isNotEmpty) {
      return savedUser.name!;
    }
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return 'Andrew Ainsley';
  }

  String _getUserUsername() {
    final userPref = serviceLocator.get<UserPreference>();
    final savedUser = userPref.getUser();
    if (savedUser.username != null && savedUser.username!.isNotEmpty) {
      return savedUser.username!;
    }
    final name = _getUserName().toLowerCase().replaceAll(' ', '_');
    return '@$name';
  }

  String _getUserPhotoUrl() {
    final user = FirebaseAuth.instance.currentUser;
    final userPref = serviceLocator.get<UserPreference>();
    final savedUser = userPref.getUser();
    if (savedUser.photo != null && savedUser.photo!.isNotEmpty) {
      return savedUser.photo!;
    }
    if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
      return user.photoURL!;
    }
    return 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&q=80&w=200';
  }

  String _getUserBio() {
    final userPref = serviceLocator.get<UserPreference>();
    final savedUser = userPref.getUser();
    if (savedUser.bio != null && savedUser.bio!.isNotEmpty) {
      return savedUser.bio!;
    }
    return 'Tech enthusiast, likes to share stories about technology, and the digital world.';
  }

  void _shareProfile() {
    final link =
        'https://appberita.com/profile/${_getUserUsername().substring(1)}';
    final messenger = ScaffoldMessenger.of(context);
    Clipboard.setData(ClipboardData(text: link)).then((_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Profile link copied to clipboard!\n$link',
            style: const TextStyle(fontFamily: 'poppins'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildBioSection(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  const Divider(color: borderNeutral, height: 1),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildArticleList(_dummySavedArticles),
                  _buildArticleList(_dummyHistoryArticles),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET HELPER METHODS
  // ===========================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Image.asset(
          'assets/images/img_splash_screen.png',
          width: 32,
          fit: BoxFit.contain,
        ),
      ),
      leadingWidth: 56,
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textNeutralPrimary,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: iconNeutralPrimary),
          onPressed: _shareProfile,
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: iconNeutralPrimary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((value) {
              setState(() {});
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.transparent,
          backgroundImage: CachedNetworkImageProvider(_getUserPhotoUrl()),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getUserName(),
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getUserUsername(),
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textNeutralSecondary,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            ).then((value) {
              if (value == true) {
                setState(() {});
              }
            });
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: borderNeutral),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textNeutralPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUserBio(),
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textNeutralSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('${_dummySavedArticles.length}', 'Saved'),
        _buildStatDivider(),
        _buildStatItem('${_dummyHistoryArticles.length}', 'History'),
        _buildStatDivider(),
        _buildStatItem('5', 'Preferred'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textNeutralSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 32, width: 1, color: borderNeutral);
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3.0,
      dividerColor: Colors.transparent,
      labelColor: textNeutralPrimary,
      unselectedLabelColor: textNeutralSecondary,
      overlayColor: WidgetStateProperty.all(
        Colors.transparent,
      ), // Menghilangkan kotak sorot
      splashFactory:
          NoSplash.splashFactory, // Menghilangkan efek ripple/cipratan air
      labelStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelPadding: const EdgeInsets.only(right: 24.0),
      tabs: const [
        Tab(text: 'Saved'),
        Tab(text: 'History'),
      ],
    );
  }

  Widget _buildArticleList(List<ArticleModel> articles) {
    if (articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text(
            'No articles found.',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 14,
              color: textNeutralSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: articles.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(color: borderNeutral, height: 1),
      ),
      itemBuilder: (context, index) {
        return _buildArticleItem(articles[index]);
      },
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
