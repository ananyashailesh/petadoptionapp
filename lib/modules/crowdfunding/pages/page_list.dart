import 'package:adoption_ui_app/modules/crowdfunding/components/color.dart';
import 'package:adoption_ui_app/modules/crowdfunding/models/campaign.dart';
import 'package:adoption_ui_app/modules/crowdfunding/models/donor.dart';
import 'package:adoption_ui_app/modules/crowdfunding/models/success_story.dart';
import 'package:adoption_ui_app/modules/crowdfunding/pages/post_page.dart';
import 'package:adoption_ui_app/modules/crowdfunding/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO Replace with object model.
const String listItemTitleText = "Save Marine Life";
const String listItemPreviewText =
    "Help us protect and restore marine ecosystems. Your support helps us clean up oceans, protect coral reefs, and save endangered marine species.";

class ListPage extends StatefulWidget {
  static const String name = 'list';

  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final ApiService _apiService = ApiService();

  Future<List<Campaign>>? _campaignsFuture;
  Future<List<Donor>>? _donorsFuture;
  Future<List<SuccessStory>>? _storiesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _campaignsFuture = _apiService.getCampaigns();
    _donorsFuture = _apiService.getTopDonors();
    _storiesFuture = _apiService.getSuccessStories();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            'Crowdfunding',
            style: TextStyle(
              color: AppColor.mainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColor.mainColor),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
          bottom: TabBar(
            labelColor: AppColor.mainColor,
            unselectedLabelColor: AppColor.labelColor,
            indicatorColor: AppColor.secondary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Text(
                  'Funding',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Top Donors',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Success Stories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFundingTab(context),
            _buildTopDonorsTab(),
            _buildSuccessStoriesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingTab(BuildContext context) {
    return FutureBuilder<List<Campaign>>(
      future: _campaignsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading campaigns: ${snapshot.error}'),
          );
        }

        final campaigns = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Campaigns',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainColor,
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
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
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.asset(
                              campaign.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  campaign.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  campaign.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColor.textColor,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 15),
                                // Progress bar
                                LinearProgressIndicator(
                                  value:
                                      campaign.currentAmount /
                                      campaign.targetAmount,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.secondary,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${campaign.currentAmount.toStringAsFixed(0)} raised of \$${campaign.targetAmount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.labelColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${(campaign.currentAmount / campaign.targetAmount * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      campaign.date,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.labelColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          PostPage.name,
                                          arguments: {
                                            'title': campaign.title,
                                            'imageUrl': campaign.imageUrl,
                                            'description': campaign.description,
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Read More',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopDonorsTab() {
    return FutureBuilder<List<Donor>>(
      future: _donorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading donors: ${snapshot.error}'));
        }

        final donors = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Donors',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainColor,
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(15),
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(donor.imageUrl),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donor.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainColor,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Total Donations: \$${donor.totalDonations.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.labelColor,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Campaigns Supported: ${donor.campaignsSupported}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.labelColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessStoriesTab() {
    return FutureBuilder<List<SuccessStory>>(
      future: _storiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading success stories: ${snapshot.error}'),
          );
        }

        final stories = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Success Stories',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainColor,
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
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
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.asset(
                              story.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  story.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColor.textColor,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      story.date,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.labelColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          'success_story',
                                          arguments: {
                                            'title': story.title,
                                            'image': story.imageUrl,
                                            'date': story.date,
                                            'content': story.content,
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Read More',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
