import 'package:flutter/material.dart';
import '../models.dart';
import '../services/api_service.dart';
import '../widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  late TextEditingController _searchController;
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    try {
      final results = await _apiService.searchProducts(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching products: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(
            onSearch: _performSearch,
          ),
          // Sort & Filter Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterButton(
                  icon: Icons.sort,
                  label: 'Sort',
                  onTap: _showSortOptions,
                ),
                _buildFilterButton(
                  icon: Icons.tune,
                  label: 'Filter',
                  onTap: _showFilterOptions,
                ),
                Text(
                  '${_searchResults.length} results',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search Results
          Expanded(
            child: _buildSearchResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (!_isSearching && _searchResults.isEmpty && _lastQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search for products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a product name to compare prices',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerProductCard(),
      );
    }

    if (_searchResults.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ProductCard(
          product: result,
          onTap: () {
            _showProductComparison(context, result);
          },
          onSave: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to saved items')),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Lowest Price'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _searchResults.sort((a, b) {
                    final priceA = a.bestPrice?.finalPrice ?? 0;
                    final priceB = b.bestPrice?.finalPrice ?? 0;
                    return priceA.compareTo(priceB);
                  });
                });
              },
            ),
            ListTile(
              title: const Text('Highest Price'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _searchResults.sort((a, b) {
                    final priceA = a.bestPrice?.finalPrice ?? 0;
                    final priceB = b.bestPrice?.finalPrice ?? 0;
                    return priceB.compareTo(priceA);
                  });
                });
              },
            ),
            ListTile(
              title: const Text('Best Rating'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _searchResults.sort((a, b) =>
                      b.product.rating.compareTo(a.product.rating));
                });
              },
            ),
            ListTile(
              title: const Text('Most Reviewed'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _searchResults.sort((a, b) =>
                      b.product.reviewCount.compareTo(a.product.reviewCount));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter by', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('In Stock Only'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Free Shipping'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Prime Eligible'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductComparison(BuildContext context, SearchResult result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(searchResult: result),
      ),
    );
  }
}

// Product Details Screen
class ProductDetailsScreen extends StatelessWidget {
  final SearchResult searchResult;

  const ProductDetailsScreen({Key? key, required this.searchResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bestPrice = searchResult.bestPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Comparison'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to saved items')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Product Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      searchResult.product.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Product Info
                  Text(
                    searchResult.product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${searchResult.product.rating}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        ' (${searchResult.product.reviewCount} reviews)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Best Price Banner
                  if (bestPrice != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best Price',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.green),
                              ),
                              Text(
                                '\$${bestPrice.finalPrice.toStringAsFixed(2)} on ${bestPrice.retailerName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Price Range Info
                  Text(
                    'Price Comparison',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lowest',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${bestPrice?.finalPrice.toStringAsFixed(2) ?? 'N/A'}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Range',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${searchResult.priceRange.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Comparison Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Available at ${searchResult.comparisons.length} retailers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final comparison = searchResult.comparisons[index];
                final isBestPrice =
                    comparison.finalPrice == bestPrice?.finalPrice;

                return ComparisonCard(
                  comparison: comparison,
                  isBestPrice: isBestPrice,
                );
              },
              childCount: searchResult.comparisons.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
