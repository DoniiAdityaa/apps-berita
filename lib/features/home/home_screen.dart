import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF1DB88E);

  final List<Map<String, String>> dummyNews = [
    {
      'title': 'Breaking News: Flutter 4.0 Released with Amazing Features',
      'source': 'TechCrunch',
      'time': '2 hours ago',
      'category': 'Technology',
    },
    {
      'title': 'Indonesia Wins Gold Medal in Asian Games 2024',
      'source': 'CNN Indonesia',
      'time': '5 hours ago',
      'category': 'Sports',
    },
    {
      'title': 'New AI Model Surpasses Human Intelligence',
      'source': 'BBC News',
      'time': '1 day ago',
      'category': 'Technology',
    },
  ];

  int selectedCategory = 0;

  final List<String> categories = [
    'All',
    'Politics',
    'Technology',
    'Business',
    'Sports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Newsline',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildWelcomeSection(),
          _buildCategoryTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyNews.length,
              itemBuilder: (context, index) {
                return _buildNewsCard(dummyNews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          CircleAvatar(radius: 24, child: Icon(Icons.person)),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back 👋'),
              Text(
                'Andrew Ainsley',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;

          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                selectedCategory = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(Map<String, String> news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['category'] ?? '',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news['title'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${news['source']} • ${news['time']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
