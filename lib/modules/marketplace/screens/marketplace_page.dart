import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/modules/marketplace/models/cart_item.dart';
import 'package:adoption_ui_app/modules/marketplace/services/cart_service.dart';
import 'package:adoption_ui_app/modules/marketplace/screens/marketplace_cart.dart';
import 'package:adoption_ui_app/modules/marketplace/screens/product_detail_page.dart';
import 'package:adoption_ui_app/modules/adoption/widgets/product_slider.dart';
import 'dart:async';
import 'package:animations/animations.dart';

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final CartService _cartService = CartService();
  int _cartItemCount = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce;
  bool _isLoading = true;

  // All products list
  List<ProductItem> products = [
    ProductItem(
      name: "Premium Dog Food",
      price: 29.99,
      image: "assets/images/products/food/dog_food.jpeg",
      rating: 4.8,
      category: "Food",
      discount: 20,
    ),
    ProductItem(
      name: "Cat Scratching Post",
      price: 39.99,
      image: "assets/images/products/toys/cat_scratching_post.jpeg",
      rating: 4.6,
      category: "Toys",
      discount: 0,
    ),
    ProductItem(
      name: "Pet Carrier",
      price: 54.99,
      image: "assets/images/products/accessories/pet_carrier.jpeg",
      rating: 4.7,
      category: "Accessories",
      discount: 15,
    ),
    ProductItem(
      name: "Dog Leash & Collar",
      price: 24.99,
      image: "assets/images/products/accessories/dog_leash_collar.jpg",
      rating: 4.9,
      category: "Accessories",
      discount: 0,
    ),
    ProductItem(
      name: "Bird Cage",
      price: 79.99,
      image: "assets/images/products/housing/bird_cage.jpeg",
      rating: 4.5,
      category: "Housing",
      discount: 10,
    ),
    ProductItem(
      name: "Aquarium Filter",
      price: 34.99,
      image: "assets/images/products/equipment/aquarium_filter.jpg",
      rating: 4.4,
      category: "Equipment",
      discount: 0,
    ),
    ProductItem(
      name: "Cat Toys Bundle",
      price: 19.99,
      image: "assets/images/products/toys/cat_toys_bundle.jpeg",
      rating: 4.3,
      category: "Toys",
      discount: 25,
    ),
    ProductItem(
      name: "Pet Grooming Kit",
      price: 45.99,
      image: "assets/images/products/grooming/grooming_kit.webp",
      rating: 4.7,
      category: "Grooming",
      discount: 0,
    ),
    ProductItem(
      name: "Luxury Dog Bed",
      price: 89.99,
      image: "assets/images/products/housing/luxury_dog_bed.jpeg",
      rating: 4.9,
      category: "Housing",
      discount: 10,
    ),
    ProductItem(
      name: "Interactive Cat Toy",
      price: 15.99,
      image: "assets/images/products/toys/interactive_cat_toy.jpeg",
      rating: 4.7,
      category: "Toys",
      discount: 0,
    ),
    ProductItem(
      name: "Premium Cat Food",
      price: 24.99,
      image: "assets/images/products/food/cat_food.jpeg",
      rating: 4.5,
      category: "Food",
      discount: 15,
    ),
    ProductItem(
      name: "Dog Training Treats",
      price: 12.99,
      image: "assets/images/products/food/dog_treats.jpeg",
      rating: 4.6,
      category: "Food",
      discount: 0,
    ),
    ProductItem(
      name: "Pet Water Fountain",
      price: 32.99,
      image: "assets/images/products/equipment/water_fountain.jpeg",
      rating: 4.4,
      category: "Equipment",
      discount: 20,
    ),
    ProductItem(
      name: "Small Animal Cage",
      price: 49.99,
      image: "assets/images/products/housing/small_animal_cage.jpeg",
      rating: 4.3,
      category: "Housing",
      discount: 0,
    ),
    ProductItem(
      name: "Dog Shampoo",
      price: 14.99,
      image: "assets/images/products/grooming/dog_shampoo.webp",
      rating: 4.2,
      category: "Grooming",
      discount: 10,
    ),
    ProductItem(
      name: "Fish Tank Decorations",
      price: 18.99,
      image: "assets/images/products/accessories/fish_tank_decorations.jpg",
      rating: 4.0,
      category: "Accessories",
      discount: 5,
    ),
  ];

  // Featured products (discounted items)
  late List<ProductItem> featuredProducts;
  late List<ProductItem> recommendedProducts;
  late List<ProductItem> topPicksProducts;

  String selectedCategory = "All";
  List<String> categories = [
    "All",
    "Food",
    "Toys",
    "Accessories",
    "Housing",
    "Equipment",
    "Grooming",
  ];

  // Add these variables to the class
  String _showingSeeAllSection = "";
  List<ProductItem> _tempProductList = [];

  @override
  void initState() {
    super.initState();

    // Simulate loading time
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Get discounted products for featured slider
    featuredProducts = List.from(products.where((p) => p.discount > 0))
      ..sort((a, b) => b.discount.compareTo(a.discount));

    if (featuredProducts.length > 6) {
      featuredProducts = featuredProducts.sublist(0, 6);
    }

    // Create sections for recommendations and top picks
    recommendedProducts = List.from(products)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    if (recommendedProducts.length > 6) {
      recommendedProducts = recommendedProducts.sublist(0, 6);
    }

    // Top picks - random selection for this demo
    topPicksProducts = List.from(products)..shuffle();
    if (topPicksProducts.length > 6) {
      topPicksProducts = topPicksProducts.sublist(0, 6);
    }

    // Ensure cart service is initialized and get current count
    _cartItemCount = _cartService.itemCount;

    // Listen to cart changes to update badge count
    _cartService.cartStream.listen((items) {
      if (mounted) {
        setState(() {
          _cartItemCount = items.fold(0, (sum, item) => sum + item.quantity);
        });
      }
    });

    // Initialize the variables
    _showingSeeAllSection = "";
    _tempProductList = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        // Reset See All section when searching
        if (query.isNotEmpty) {
          _showingSeeAllSection = "";
          _tempProductList = [];
        }
      });
    });
  }

  void _addToCart(ProductItem product) {
    final cartItem = CartItem(
      id: UniqueKey().toString(),
      name: product.name,
      image: product.image,
      category: product.category,
      price: product.price,
    );

    _cartService.addToCart(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MarketplaceCart()),
            ).then((result) {
              // Update cart count when returning from cart page
              setState(() {
                _cartItemCount = _cartService.itemCount;

                // Handle reset action if coming from "Back to Shopping" button
                if (result != null &&
                    result is Map &&
                    result['action'] == 'reset_filters') {
                  selectedCategory = "All";
                  _searchController.clear();
                  _searchQuery = "";
                  _showingSeeAllSection = "";
                  _tempProductList = [];
                }
              });
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: AppColor.appBgColor,
        appBar: AppBar(
          backgroundColor: AppColor.appBgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColor.mainColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Pet Marketplace",
            style: TextStyle(
              color: AppColor.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColor.mainColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketplaceCart(),
                      ),
                    ).then((result) {
                      // Update cart count when returning from cart page
                      setState(() {
                        _cartItemCount = _cartService.itemCount;

                        // Handle reset action if coming from "Back to Shopping" button
                        if (result != null &&
                            result is Map &&
                            result['action'] == 'reset_filters') {
                          selectedCategory = "All";
                          _searchController.clear();
                          _searchQuery = "";
                          _showingSeeAllSection = "";
                          _tempProductList = [];
                        }
                      });
                    });
                  },
                ),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _cartItemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(color: AppColor.secondary),
                )
                : SafeArea(
                  child: Column(
                    children: [
                      // Category Filter at the top
                      SizedBox(height: 10),
                      _buildCategoryFilter(),
                      SizedBox(height: 20),

                      // Search Bar
                      _buildSearchBar(),
                      SizedBox(height: 20),

                      // Main content area (either product grid or homepage content)
                      Expanded(
                        child:
                            selectedCategory == "All" &&
                                    _searchQuery.isEmpty &&
                                    _showingSeeAllSection.isEmpty
                                ? _buildHomeContent()
                                : _buildProductGridView(),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  // Homepage content with slider and recommendations
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Products Slider
          if (featuredProducts.isNotEmpty)
            ProductSlider(
              products: featuredProducts,
              title: 'Special Offers & Discounts',
            )
          else
            _buildEmptySlider('No special offers available'),
          SizedBox(height: 25),

          // Based on browsing history section
          _buildSectionHeader("Based on your browsing history"),
          SizedBox(height: 15),
          _buildHorizontalProductList(recommendedProducts),
          SizedBox(height: 25),

          // Recommended deals section
          _buildSectionHeader("Recommended deals for you"),
          SizedBox(height: 15),
          _buildHorizontalProductList(topPicksProducts),
          SizedBox(height: 25),

          // Related top picks section
          _buildSectionHeader("Related top picks for you"),
          SizedBox(height: 15),
          _buildHorizontalProductList(topPicksProducts.reversed.toList()),
          SizedBox(height: 25),

          // Show a subset of all products
          _buildSectionHeader("All Products"),
          SizedBox(height: 15),
          _buildProductGrid(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Grid view for filtered products only (when category or search is active)
  Widget _buildProductGridView() {
    // If showing a "See All" section, use the temporary product list
    if (_showingSeeAllSection.isNotEmpty) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColor.textColor),
                  onPressed: () {
                    setState(() {
                      _showingSeeAllSection = "";
                      _tempProductList = [];
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _showingSeeAllSection,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColor.shadowColor.withOpacity(0.2)),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemCount: _tempProductList.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_tempProductList[index]);
              },
            ),
          ),
        ],
      );
    }

    // Otherwise, filter as normal for category or search
    var filteredProducts = products;

    if (_searchQuery.isNotEmpty) {
      filteredProducts =
          filteredProducts
              .where(
                (product) =>
                    product.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    product.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    if (selectedCategory != "All") {
      filteredProducts =
          filteredProducts
              .where((product) => product.category == selectedCategory)
              .toList();
    }

    return filteredProducts.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 60,
                color: AppColor.secondary.withOpacity(0.5),
              ),
              SizedBox(height: 20),
              Text(
                "No products found",
                style: TextStyle(
                  color: AppColor.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = "All";
                    _searchController.clear();
                    _searchQuery = "";
                  });
                },
                child: Text(
                  "Clear filters",
                  style: TextStyle(
                    color: AppColor.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
        : GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index]);
          },
        );
  }

  Widget _buildEmptySlider(String message) {
    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 50,
              color: AppColor.secondary.withOpacity(0.5),
            ),
            SizedBox(height: 15),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColor.labelColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppColor.labelColor),
            hintText: 'Search products...',
            hintStyle: TextStyle(color: AppColor.labelColor.withOpacity(0.5)),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: AppColor.labelColor),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                          // Reset all filters when clearing search
                          if (_showingSeeAllSection.isNotEmpty) {
                            _showingSeeAllSection = "";
                            _tempProductList = [];
                          }
                        });
                      },
                    )
                    : null,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
              // Reset See All section when searching
              if (value.isNotEmpty) {
                _showingSeeAllSection = "";
                _tempProductList = [];
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.textColor,
            ),
          ),
          TextButton(
            onPressed: () {
              // Get products for the section and show them in a grid view
              List<ProductItem> sectionProducts = [];

              if (title.contains("browsing history")) {
                sectionProducts = recommendedProducts;
              } else if (title.contains("Recommended deals")) {
                sectionProducts = topPicksProducts;
              } else if (title.contains("Related top picks")) {
                sectionProducts = topPicksProducts.reversed.toList();
              } else if (title == "All Products") {
                sectionProducts = products;
              }

              if (sectionProducts.isNotEmpty) {
                setState(() {
                  _searchQuery = "";
                  _searchController.clear();
                  _tempProductList = sectionProducts;
                  _showingSeeAllSection = title;
                });
              }
            },
            child: Text(
              "See All",
              style: TextStyle(
                color: AppColor.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categories[index];
                // Reset See All section when changing categories
                _showingSeeAllSection = "";
                _tempProductList = [];
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color:
                    selectedCategory == categories[index]
                        ? AppColor.secondary
                        : AppColor.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color:
                      selectedCategory == categories[index]
                          ? Colors.white
                          : AppColor.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductList(List<ProductItem> productsList) {
    return Container(
      height: 205,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: productsList.length,
        itemBuilder: (context, index) {
          return _buildHorizontalProductCard(productsList[index]);
        },
      ),
    );
  }

  Widget _buildHorizontalProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColor.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _buildProductImage(product.image, 110),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${product.discount}% OFF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColor.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      if (product.discount > 0) ...[
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                            color: AppColor.labelColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                      Text(
                        "\$${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColor.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    // Filter by search query and category
    var filteredProducts = products;

    if (_searchQuery.isNotEmpty) {
      filteredProducts =
          filteredProducts
              .where(
                (product) =>
                    product.name.toLowerCase().contains(_searchQuery) ||
                    product.category.toLowerCase().contains(_searchQuery),
              )
              .toList();
    }

    if (selectedCategory != "All") {
      filteredProducts =
          filteredProducts
              .where((product) => product.category == selectedCategory)
              .toList();
    }

    return filteredProducts.isEmpty
        ? Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            "No products found",
            style: TextStyle(color: AppColor.textColor, fontSize: 16),
          ),
        )
        : GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredProducts.length > 6 ? 6 : filteredProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index]);
          },
        );
  }

  Widget _buildProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 135,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: _buildProductImage(product.image, 135),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${product.discount}% OFF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColor.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.discount > 0)
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                                color: AppColor.labelColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            "\$${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColor.secondary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColor.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build product images with proper error handling
  Widget _buildProductImage(String imagePath, double height) {
    return Stack(
      children: [
        // Try to load the asset image
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          height: height,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            // On error, try to load the image with a different extension
            return _buildFallbackImage(imagePath, height);
          },
        ),
      ],
    );
  }

  Widget _buildFallbackImage(String imagePath, double height) {
    // List of possible extensions to try
    final extensions = ['', '.jpg', '.jpeg', '.webp', '.png'];

    for (var ext in extensions) {
      // Skip if the extension is already in the path
      if (imagePath.toLowerCase().endsWith(ext)) continue;

      // Try with this extension
      if (ext.isEmpty) continue; // Skip empty extension

      var pathWithExt = imagePath;
      // If the image path doesn't have an extension, add one
      if (!extensions.any(
        (e) => e.isNotEmpty && imagePath.toLowerCase().endsWith(e),
      )) {
        pathWithExt = '$imagePath$ext';
      }

      // Return a placeholder icon if all attempts fail
      return Container(
        height: height,
        alignment: Alignment.center,
        color: AppColor.secondary.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: height * 0.4, color: AppColor.secondary),
            SizedBox(height: 8),
            Text(
              "Image Not Found",
              style: TextStyle(fontSize: 10, color: AppColor.labelColor),
            ),
          ],
        ),
      );
    }

    // Return a placeholder icon if all attempts fail
    return Container(
      height: height,
      alignment: Alignment.center,
      color: AppColor.secondary.withOpacity(0.1),
      child: Icon(Icons.pets, size: height * 0.4, color: AppColor.secondary),
    );
  }
}

class ProductItem {
  final String name;
  final double price;
  final String image;
  final double rating;
  final String category;
  final int discount;

  ProductItem({
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.category,
    this.discount = 0,
  });
}
