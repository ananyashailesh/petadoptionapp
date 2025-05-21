import 'package:adoption_ui_app/modules/crowdfunding/components/color.dart';
import 'package:adoption_ui_app/modules/crowdfunding/components/donation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessStoryPage extends StatelessWidget {
  static const String name = 'success_story';

  const SuccessStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Handle null arguments with default values
    final title = args?['title'] as String? ?? 'Success Story';
    final imageUrl =
        args?['image'] as String? ??
        'assets/images/crowdfunding/success/story1.jpg';
    final date = args?['date'] as String? ?? 'Recent';
    final content =
        args?['content'] as String? ??
        'Thanks to generous donations, we successfully rehabilitated and released an injured elephant back into its natural habitat. The elephant, named "Hope", was found injured in a local village. After six months of dedicated care and rehabilitation, Hope was successfully released back into the wild. This success story demonstrates the power of community support and dedicated conservation efforts. Through specialized veterinary care, proper nutrition, and behavioral enrichment, Hope made a remarkable recovery. Today, she leads a herd of wild elephants, protecting and guiding them through the sanctuary.';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Success Story',
          style: TextStyle(
            color: AppColor.mainColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image with Gradient Overlay
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.asset(imageUrl, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Content
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      color: AppColor.textColor,
                      height: 1.8,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Impact Section
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
                          'Impact Made',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildImpactItem('Donors', '150+'),
                            _buildImpactItem('Funds Raised', '\$25,000'),
                            _buildImpactItem('Volunteers', '45'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  // Call to Action
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make a Difference',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.secondary,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Join us in making more success stories possible. Your support can help us create positive change for wildlife and ecosystems.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.textColor,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => DonationDialog(
                                    title: title,
                                    targetAmount: 25000,
                                    currentAmount: 25000,
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.secondary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Support Our Cause',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildImpactItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColor.secondary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
