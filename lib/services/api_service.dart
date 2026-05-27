import 'package:dio/dio.dart';
import 'models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.pricepeek.com/v1', // Replace with your API
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          return handler.next(error);
        },
      ),
    );
  }

  // Search for products and get price comparisons
  Future<List<SearchResult>> searchProducts(String query) async {
    try {
      // TODO: Replace with actual API call
      // final response = await _dio.get('/products/search', queryParameters: {'q': query});
      
      // For MVP, return mock data
      return _getMockSearchResults(query);
    } on DioException catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  // Get trending deals
  Future<List<Deal>> getTrendingDeals() async {
    try {
      // TODO: Replace with actual API call
      // final response = await _dio.get('/deals/trending');
      
      return _getMockTrendingDeals();
    } on DioException catch (e) {
      print('Error fetching trending deals: $e');
      rethrow;
    }
  }

  // Get product details with all comparisons
  Future<SearchResult?> getProductDetails(String productId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await _dio.get('/products/$productId');
      
      return _getMockProductDetails(productId);
    } on DioException catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }
  }

  // Get price comparison for a specific product
  Future<List<PriceComparison>> getPriceComparisons(String productId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await _dio.get('/products/$productId/comparisons');
      
      return _getMockPriceComparisons(productId);
    } on DioException catch (e) {
      print('Error fetching price comparisons: $e');
      rethrow;
    }
  }

  // MOCK DATA - Replace with real API calls

  List<SearchResult> _getMockSearchResults(String query) {
    final products = [
      Product(
        id: '1',
        name: query,
        description: 'Latest model with advanced features',
        imageUrl:
            'https://via.placeholder.com/300x300?text=${query.replaceAll(" ", "+")}',
        category: 'Electronics',
        rating: 4.5,
        reviewCount: 1250,
      ),
      Product(
        id: '2',
        name: '$query Pro',
        description: 'Professional edition with premium features',
        imageUrl:
            'https://via.placeholder.com/300x300?text=${query.replaceAll(" ", "+")}+Pro',
        category: 'Electronics',
        rating: 4.7,
        reviewCount: 950,
      ),
      Product(
        id: '3',
        name: '$query Max',
        description: 'Maximum performance variant',
        imageUrl:
            'https://via.placeholder.com/300x300?text=${query.replaceAll(" ", "+")}+Max',
        category: 'Electronics',
        rating: 4.8,
        reviewCount: 800,
      ),
    ];

    return products.map((product) {
      return SearchResult(
        product: product,
        comparisons: _getMockPriceComparisons(product.id),
      );
    }).toList();
  }

  List<Deal> _getMockTrendingDeals() {
    return [
      Deal(
        id: 'deal1',
        title: 'iPhone 16 Pro Max - Limited Time Offer',
        description: 'Latest flagship with A18 Pro chip',
        imageUrl:
            'https://via.placeholder.com/300x300?text=iPhone+16+Pro+Max',
        originalPrice: 1299.99,
        dealPrice: 999.99,
        discountPercentage: 23,
        retailerName: 'Amazon',
        productUrl: 'https://amazon.com',
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        views: 15420,
        isFeatured: true,
        category: 'Smartphones',
      ),
      Deal(
        id: 'deal2',
        title: 'Sony WH-1000XM5 Headphones Flash Sale',
        description: 'Premium noise-cancelling headphones',
        imageUrl: 'https://via.placeholder.com/300x300?text=Sony+XM5',
        originalPrice: 399.99,
        dealPrice: 299.99,
        discountPercentage: 25,
        retailerName: 'Best Buy',
        productUrl: 'https://bestbuy.com',
        expiresAt: DateTime.now().add(const Duration(days: 2)),
        views: 8920,
        isFeatured: true,
        category: 'Audio',
      ),
      Deal(
        id: 'deal3',
        title: 'Samsung 4K Smart TV 55" - 40% OFF',
        description: 'Ultra HD with HDR10+ support',
        imageUrl: 'https://via.placeholder.com/300x300?text=Samsung+TV',
        originalPrice: 899.99,
        dealPrice: 539.99,
        discountPercentage: 40,
        retailerName: 'Walmart',
        productUrl: 'https://walmart.com',
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        views: 12350,
        isFeatured: false,
        category: 'Electronics',
      ),
      Deal(
        id: 'deal4',
        title: 'iPad Air - Education Discount',
        description: 'Powerful tablet for work and creativity',
        imageUrl: 'https://via.placeholder.com/300x300?text=iPad+Air',
        originalPrice: 599.99,
        dealPrice: 499.99,
        discountPercentage: 17,
        retailerName: 'Apple Store',
        productUrl: 'https://apple.com',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        views: 6780,
        isFeatured: false,
        category: 'Tablets',
      ),
    ];
  }

  List<PriceComparison> _getMockPriceComparisons(String productId) {
    return [
      PriceComparison(
        retailerId: 'amazon',
        retailerName: 'Amazon',
        retailerLogo: 'https://via.placeholder.com/100x50?text=Amazon',
        price: 999.99,
        originalPrice: 1299.99,
        discountPercentage: 23,
        productUrl: 'https://amazon.com/dp/ASIN',
        availability: 'In Stock',
        deliveryDays: 2,
        deliveryInfo: 'Free 2-day delivery with Prime',
        shippingCost: 0,
        totalPrice: 999.99,
      ),
      PriceComparison(
        retailerId: 'bestbuy',
        retailerName: 'Best Buy',
        retailerLogo: 'https://via.placeholder.com/100x50?text=BestBuy',
        price: 1049.99,
        originalPrice: 1299.99,
        discountPercentage: 19,
        productUrl: 'https://bestbuy.com/site/PRODUCT',
        availability: 'In Stock',
        deliveryDays: 1,
        deliveryInfo: 'Next day delivery available',
        shippingCost: 9.99,
        totalPrice: 1059.98,
      ),
      PriceComparison(
        retailerId: 'walmart',
        retailerName: 'Walmart',
        retailerLogo: 'https://via.placeholder.com/100x50?text=Walmart',
        price: 1019.99,
        originalPrice: 1299.99,
        discountPercentage: 22,
        productUrl: 'https://walmart.com/ip/PRODUCT',
        availability: 'Limited Stock',
        deliveryDays: 3,
        deliveryInfo: 'Free shipping on orders $35+',
        shippingCost: 0,
        totalPrice: 1019.99,
      ),
      PriceComparison(
        retailerId: 'ebay',
        retailerName: 'eBay',
        retailerLogo: 'https://via.placeholder.com/100x50?text=eBay',
        price: 989.99,
        originalPrice: 1299.99,
        discountPercentage: 24,
        productUrl: 'https://ebay.com/itm/PRODUCT',
        availability: 'In Stock',
        deliveryDays: 5,
        deliveryInfo: 'Standard shipping included',
        shippingCost: 0,
        totalPrice: 989.99,
      ),
      PriceComparison(
        retailerId: 'target',
        retailerName: 'Target',
        retailerLogo: 'https://via.placeholder.com/100x50?text=Target',
        price: 1029.99,
        originalPrice: 1299.99,
        discountPercentage: 21,
        productUrl: 'https://target.com/p/PRODUCT',
        availability: 'In Stock',
        deliveryDays: 2,
        deliveryInfo: 'Free shipping for RedCard members',
        shippingCost: 5.99,
        totalPrice: 1035.98,
      ),
    ];
  }

  SearchResult? _getMockProductDetails(String productId) {
    final product = Product(
      id: productId,
      name: 'iPhone 16 Pro',
      description:
          'The iPhone 16 Pro features a dynamic island, always-on display, advanced camera system, and A18 Pro chip.',
      imageUrl: 'https://via.placeholder.com/300x300?text=iPhone+16+Pro',
      category: 'Smartphones',
      rating: 4.6,
      reviewCount: 2350,
    );

    return SearchResult(
      product: product,
      comparisons: _getMockPriceComparisons(productId),
    );
  }
}
