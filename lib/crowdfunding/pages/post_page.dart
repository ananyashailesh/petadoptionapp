import 'package:adoption_ui_app/crowdfunding/components/blog.dart';
import 'package:adoption_ui_app/crowdfunding/components/color.dart';
import 'package:adoption_ui_app/crowdfunding/components/donation_dialog.dart';
import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  static const String name = '/post';

  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Help Save Lives';
    final imageUrl =
        args?['imageUrl'] as String? ??
        'assets/images/crowdfunding/campaign1.jpg';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: AppColor.mainColor,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.mainColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              height: 300,
              width: double.infinity,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.favorite,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Donation Progress Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Donation Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.mainColor,
                              ),
                            ),
                            Text(
                              '\$2,500 / \$5,000',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.secondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.secondary,
                          ),
                          minHeight: 10,
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('50%', 'Goal Reached'),
                            _buildStatItem('150', 'Donors'),
                            _buildStatItem('15', 'Days Left'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Article Content
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Every living being deserves a chance at life. This beautiful creature has faced unimaginable challenges but continues to show incredible strength and resilience. With your help, we can give them the care and support they need to thrive.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.textColor,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Our dedicated team of experts and volunteers has been working tirelessly to provide the best possible care. Through rehabilitation and specialized treatment, we\'ve seen remarkable progress. Now, we need your support to continue this life-saving work.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.textColor,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Your donation can make a real difference. Every contribution helps us provide essential care, medical treatment, and rehabilitation for animals in need. Together, we can give these incredible beings a second chance at life.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.textColor,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Donate Button
                  Center(
                    child: DonateButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => DonationDialog(
                                title: title,
                                targetAmount: 5000,
                                currentAmount: 2500,
                              ),
                        );
                      },
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.secondary,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: AppColor.labelColor)),
      ],
    );
  }
}
