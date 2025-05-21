import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/modules/marketplace/screens/marketplace_page.dart';
import 'package:adoption_ui_app/modules/marketplace/screens/product_detail_page.dart';
import 'dart:async';

class ProductSlider extends StatefulWidget {
  final List<ProductItem> products;
  final String title;

  const ProductSlider({
    Key? key,
    required this.products,
    this.title = 'Featured Products',
  }) : super(key: key);

  @override
  _ProductSliderState createState() => _ProductSliderState();
}

class _ProductSliderState extends State<ProductSlider>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );

  int _currentPage = 0;
  Timer? _autoPlayTimer;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller safely
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController!);
    _animationController?.repeat();

    _startAutoPlay();

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < widget.products.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              _buildIndicators(),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildProductCard(widget.products[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductItem product, int index) {
    double scale = _currentPage == index ? 1.0 : 0.9;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 350),
      tween: Tween(begin: scale, end: scale),
      curve: Curves.ease,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColor.cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 8),
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
                        height: 115,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                          child: Image.asset(
                            product.image,
                            fit: BoxFit.cover,
                            height: 115,
                            width: double.infinity,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 115,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.pets,
                                    size: 40,
                                    color: AppColor.secondary,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      if (product.discount > 0)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: Colors.white,
                                  size: 8,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "${product.discount}% OFF",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Add a shimmer effect overlay
                      if (_currentPage == index && _animation != null)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: _animation!,
                            builder: (context, child) {
                              return Container(
                                height: 2,
                                width: double.infinity,
                                child: LinearProgressIndicator(
                                  value: _animation!.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.secondary.withOpacity(0.5),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  // Product Info
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                product.category,
                                style: TextStyle(
                                  color: AppColor.secondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 10),
                                SizedBox(width: 2),
                                Text(
                                  product.rating.toString(),
                                  style: TextStyle(
                                    color: AppColor.labelColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.discount > 0)
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.normal,
                                      color: AppColor.labelColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  '\$${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColor.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 9,
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
          ),
        );
      },
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.products.length,
        (index) => GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _currentPage == index ? 20 : 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color:
                  _currentPage == index
                      ? AppColor.secondary
                      : AppColor.labelColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
