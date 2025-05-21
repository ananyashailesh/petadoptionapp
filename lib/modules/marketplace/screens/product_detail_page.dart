import 'package:flutter/material.dart';
import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/modules/marketplace/models/cart_item.dart';
import 'package:adoption_ui_app/modules/marketplace/services/cart_service.dart';
import 'package:adoption_ui_app/modules/marketplace/screens/marketplace_page.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductItem product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService _cartService = CartService();
  int _quantity = 1;
  bool _isFavorite = false;
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['Description', 'Reviews', 'Specifications'];

  final List<Review> _reviews = [
    Review(
      username: 'John D.',
      rating: 5.0,
      date: 'May 15, 2023',
      comment: 'Great product! My dog loves this food. Will buy again.',
      avatar: 'assets/images/pet_illustration.jpg',
    ),
    Review(
      username: 'Sarah M.',
      rating: 4.5,
      date: 'Apr 22, 2023',
      comment: 'Good quality, fast shipping. Just what I needed for my pet.',
      avatar: 'assets/images/pet_illustration.jpg',
    ),
    Review(
      username: 'Michael T.',
      rating: 3.0,
      date: 'Mar 10, 2023',
      comment: 'Average product. Does the job but nothing special.',
      avatar: 'assets/images/pet_illustration.jpg',
    ),
  ];

  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cartItem = CartItem(
      id: UniqueKey().toString(),
      name: widget.product.name,
      image: widget.product.image,
      category: widget.product.category,
      price: widget.product.price,
      quantity: _quantity,
    );

    _cartService.addToCart(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write a review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        Review(
          username: 'You',
          rating: _userRating,
          date: 'Just now',
          comment: _reviewController.text.trim(),
          avatar: 'assets/images/pet_illustration.jpg',
        ),
      );
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CustomAppBar(showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  _buildProductImage(),

                  // Product Info
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.textColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildRatingStars(widget.product.rating),
                                      SizedBox(width: 8),
                                      Text(
                                        widget.product.rating.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColor.labelColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '(${_reviews.length} reviews)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.labelColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      _isFavorite
                                          ? Colors.red.withOpacity(0.1)
                                          : AppColor.cardColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.shadowColor.withOpacity(
                                        0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _isFavorite
                                          ? Colors.red
                                          : AppColor.labelColor,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Quantity Selector
                        _buildQuantitySelector(),
                        SizedBox(height: 24),

                        // Tabs (Description, Reviews, Specifications)
                        _buildTabs(),
                        SizedBox(height: 16),

                        // Tab Content
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Cart Button
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.secondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Image.asset(
          widget.product.image,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  Icon(Icons.pets, size: 120, color: AppColor.secondary),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColor.cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildQuantityButton(
                icon: Icons.remove,
                onTap: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  '$_quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColor.secondary, size: 18),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          _tabTitles.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _selectedTabIndex == index
                          ? AppColor.secondary
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabTitles[index],
                  style: TextStyle(
                    color:
                        _selectedTabIndex == index
                            ? Colors.white
                            : AppColor.labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDescriptionTab();
      case 1:
        return _buildReviewsTab();
      case 2:
        return _buildSpecificationsTab();
      default:
        return _buildDescriptionTab();
    }
  }

  Widget _buildDescriptionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'This premium ${widget.product.category.toLowerCase()} is designed for optimal pet health and happiness. Made with high-quality materials and carefully selected ingredients that pets love.',
          style: TextStyle(
            color: AppColor.labelColor,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Our products are tested by veterinarians and loved by pets around the world. We use sustainable manufacturing processes and eco-friendly packaging.',
          style: TextStyle(
            color: AppColor.labelColor,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Features:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: 8),
        _buildFeatureItem('Premium quality materials'),
        _buildFeatureItem('Designed for durability and comfort'),
        _buildFeatureItem('Easy to clean and maintain'),
        _buildFeatureItem('Available in multiple sizes and colors'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppColor.secondary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColor.labelColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Reviews (${_reviews.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: 16),

        // Add Review Form
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColor.cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Your Rating:',
                    style: TextStyle(fontSize: 14, color: AppColor.labelColor),
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _userRating = index + 1.0;
                          });
                        },
                        child: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product...',
                  hintStyle: TextStyle(
                    color: AppColor.labelColor.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.secondary),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _submitReview,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Reviews List
        ..._reviews.map((review) => _buildReviewItem(review)).toList(),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  review.avatar,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: AppColor.secondary.withOpacity(0.2),
                        child: Icon(Icons.person, color: AppColor.secondary),
                      ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRatingStars(review.rating),
                        SizedBox(width: 8),
                        Text(
                          review.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.labelColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.labelColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Specifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: 16),
        _buildSpecItem('Brand', 'PetLife Premium'),
        _buildSpecItem('Category', widget.product.category),
        _buildSpecItem('Product Weight', '2.5 lbs'),
        _buildSpecItem('Dimensions', '10 x 8 x 6 inches'),
        _buildSpecItem('Material', 'Premium Eco-friendly Materials'),
        _buildSpecItem('Country of Origin', 'USA'),
        _buildSpecItem('Warranty', '1 Year Limited Warranty'),
        _buildSpecItem(
          'Package Contents',
          '1 x ${widget.product.name}, User Manual',
        ),
      ],
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColor.textColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppColor.labelColor),
            ),
          ),
        ],
      ),
    );
  }
}

class Review {
  final String username;
  final double rating;
  final String date;
  final String comment;
  final String avatar;

  Review({
    required this.username,
    required this.rating,
    required this.date,
    required this.comment,
    required this.avatar,
  });
}
