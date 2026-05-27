import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models.dart';
import '../services/api_service.dart';
import '../widgets.dart';

// ===================== DEALS SCREEN =====================
class DealsScreen extends StatefulWidget {
  const DealsScreen({Key? key}) : super(key: key);

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  late Future<List<Deal>> _dealsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dealsFuture = _apiService.getTrendingDeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deals'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Featured'),
            Tab(text: 'Electronics'),
            Tab(text: 'Fashion'),
            Tab(text: 'Books'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDealsList('Featured'),
          _buildDealsList('Electronics'),
          _buildDealsList('Fashion'),
          _buildDealsList('Books'),
        ],
      ),
    );
  }

  Widget _buildDealsList(String category) {
    return FutureBuilder<List<Deal>>(
      future: _dealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerProductCard(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading deals: ${snapshot.error}'),
              ],
            ),
          );
        }

        List<Deal> deals = snapshot.data ?? [];

        // Filter by category
        if (category != 'Featured') {
          deals = deals
              .where((deal) =>
                  deal.category.toLowerCase() == category.toLowerCase())
              .toList();
        } else {
          deals = deals.where((deal) => deal.isFeatured).toList();
        }

        if (deals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_offer_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No deals in this category'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: deals.length,
          itemBuilder: (context, index) {
            return DealCard(
              deal: deals[index],
              onTap: () {
                _showDealDetails(context, deals[index]);
              },
            );
          },
        );
      },
    );
  }

  void _showDealDetails(BuildContext context, Deal deal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DealDetailsSheet(deal: deal),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class _DealDetailsSheet extends StatelessWidget {
  final Deal deal;

  const _DealDetailsSheet({required this.deal});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              deal.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deal Price',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Text(
                      '\$${deal.dealPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Original',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Text(
                      '\$${deal.originalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              deal.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('View Deal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== SAVED SCREEN =====================
class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late Box _savedBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSavedBox();
  }

  void _initializeSavedBox() async {
    _savedBox = Hive.box('saved_items');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSavedList(),
    );
  }

  Widget _buildSavedList() {
    final savedItems = _savedBox.values.toList();

    if (savedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No saved items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Products you save will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to search
              },
              child: const Text('Start Saving'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: savedItems.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key('saved_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _savedBox.deleteAt(index);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item removed')),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Saved Item ${index + 1}'),
              subtitle: const Text('Tap to view comparisons'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Product details coming soon')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ===================== PROFILE SCREEN =====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box _preferencesBox;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _preferencesBox = Hive.box('user_preferences');
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _darkMode = _preferencesBox.get('darkMode', defaultValue: false);
      _notifications = _preferencesBox.get('notifications', defaultValue: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepOrange.withOpacity(0.1),
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to PricePeek',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to save your preferences',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Authentication coming soon')),
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                ],
              ),
            ),
            // Preferences Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                  _preferencesBox.put('darkMode', value);
                });
              },
            ),
            // Notifications Toggle
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Price drop alerts'),
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                  _preferencesBox.put('notifications', value);
                });
              },
            ),
            const Divider(),
            // Settings Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              subtitle: const Text('USD'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            // About Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PricePeek v1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out')),
                        );
                      },
                      child: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
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
