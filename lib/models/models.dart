// Models for PricePeek App

// Product Model
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Price Comparison Model
class PriceComparison {
  final String retailerId;
  final String retailerName;
  final String retailerLogo;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final String productUrl;
  final String availability;
  final int? deliveryDays;
  final String? deliveryInfo;
  final double? shippingCost;
  final double? totalPrice;
  final DateTime lastUpdated;

  PriceComparison({
    required this.retailerId,
    required this.retailerName,
    required this.retailerLogo,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.productUrl,
    this.availability = 'In Stock',
    this.deliveryDays,
    this.deliveryInfo,
    this.shippingCost = 0,
    this.totalPrice,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory PriceComparison.fromJson(Map<String, dynamic> json) {
    return PriceComparison(
      retailerId: json['retailerId'] ?? '',
      retailerName: json['retailerName'] ?? '',
      retailerLogo: json['retailerLogo'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice']).toDouble()
          : null,
      discountPercentage: json['discountPercentage'],
      productUrl: json['productUrl'] ?? '',
      availability: json['availability'] ?? 'In Stock',
      deliveryDays: json['deliveryDays'],
      deliveryInfo: json['deliveryInfo'],
      shippingCost: json['shippingCost'] != null
          ? (json['shippingCost']).toDouble()
          : 0,
      totalPrice: json['totalPrice'] != null
          ? (json['totalPrice']).toDouble()
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retailerId': retailerId,
      'retailerName': retailerName,
      'retailerLogo': retailerLogo,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'productUrl': productUrl,
      'availability': availability,
      'deliveryDays': deliveryDays,
      'deliveryInfo': deliveryInfo,
      'shippingCost': shippingCost,
      'totalPrice': totalPrice,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get finalPrice => totalPrice ?? price;
}

// Deal Model
class Deal {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double dealPrice;
  final int discountPercentage;
  final String retailerName;
  final String productUrl;
  final DateTime expiresAt;
  final int views;
  final bool isFeatured;
  final String category;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.dealPrice,
    required this.discountPercentage,
    required this.retailerName,
    required this.productUrl,
    required this.expiresAt,
    this.views = 0,
    this.isFeatured = false,
    this.category = 'General',
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0.0).toDouble(),
      dealPrice: (json['dealPrice'] ?? 0.0).toDouble(),
      discountPercentage: json['discountPercentage'] ?? 0,
      retailerName: json['retailerName'] ?? '',
      productUrl: json['productUrl'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(days: 7)),
      views: json['views'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'dealPrice': dealPrice,
      'discountPercentage': discountPercentage,
      'retailerName': retailerName,
      'productUrl': productUrl,
      'expiresAt': expiresAt.toIso8601String(),
      'views': views,
      'isFeatured': isFeatured,
      'category': category,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get hoursRemaining {
    final difference = expiresAt.difference(DateTime.now());
    return difference.inHours;
  }
}

// Search Result Model
class SearchResult {
  final Product product;
  final List<PriceComparison> comparisons;

  SearchResult({
    required this.product,
    required this.comparisons,
  });

  PriceComparison? get bestPrice {
    if (comparisons.isEmpty) return null;
    return comparisons.reduce((a, b) => a.finalPrice < b.finalPrice ? a : b);
  }

  double get priceRange {
    if (comparisons.isEmpty) return 0;
    final prices = comparisons.map((e) => e.finalPrice).toList();
    return prices.reduce((a, b) => a > b ? a : b) -
        prices.reduce((a, b) => a < b ? a : b);
  }
}

// User Preferences Model
class UserPreferences {
  final String userId;
  final List<String> savedProductIds;
  final List<String> searchHistory;
  final bool isDarkMode;
  final bool enableNotifications;
  final String preferredCurrency;
  final List<String> favoriteCategories;

  UserPreferences({
    required this.userId,
    this.savedProductIds = const [],
    this.searchHistory = const [],
    this.isDarkMode = false,
    this.enableNotifications = true,
    this.preferredCurrency = 'USD',
    this.favoriteCategories = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] ?? '',
      savedProductIds: List<String>.from(json['savedProductIds'] ?? []),
      searchHistory: List<String>.from(json['searchHistory'] ?? []),
      isDarkMode: json['isDarkMode'] ?? false,
      enableNotifications: json['enableNotifications'] ?? true,
      preferredCurrency: json['preferredCurrency'] ?? 'USD',
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'savedProductIds': savedProductIds,
      'searchHistory': searchHistory,
      'isDarkMode': isDarkMode,
      'enableNotifications': enableNotifications,
      'preferredCurrency': preferredCurrency,
      'favoriteCategories': favoriteCategories,
    };
  }
}
