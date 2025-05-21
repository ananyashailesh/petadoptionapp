import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campaign.dart';
import '../models/donor.dart';
import '../models/success_story.dart';

class ApiService {
  static const String baseUrl =
      'YOUR_API_BASE_URL'; // Replace with your actual API URL

  // Campaigns
  Future<List<Campaign>> getCampaigns() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/campaigns'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Campaign.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load campaigns');
      }
    } catch (e) {
      // For development, return mock data
      return _getMockCampaigns();
    }
  }

  // Top Donors
  Future<List<Donor>> getTopDonors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/donors/top'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Donor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top donors');
      }
    } catch (e) {
      // For development, return mock data
      return _getMockDonors();
    }
  }

  // Success Stories
  Future<List<SuccessStory>> getSuccessStories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/success-stories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SuccessStory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load success stories');
      }
    } catch (e) {
      // For development, return mock data
      return _getMockSuccessStories();
    }
  }

  // Mock Data Methods
  List<Campaign> _getMockCampaigns() {
    return [
      Campaign(
        id: '1',
        title: 'Save Endangered Species',
        description:
            'Help us protect and preserve endangered wildlife species through conservation efforts and habitat restoration.',
        imageUrl: 'assets/images/crowdfunding/campaign1.jpg',
        date: 'March 20, 2024',
        targetAmount: 50000,
        currentAmount: 35000,
        donorsCount: 150,
        status: 'active',
      ),
      Campaign(
        id: '2',
        title: 'Protect Marine Life',
        description:
            'Support our mission to clean up oceans, protect coral reefs, and save marine species.',
        imageUrl: 'assets/images/crowdfunding/campaign2.jpg',
        date: 'March 18, 2024',
        targetAmount: 40000,
        currentAmount: 28000,
        donorsCount: 120,
        status: 'active',
      ),
      Campaign(
        id: '3',
        title: 'Wildlife Rehabilitation Center',
        description:
            'Support our efforts to build a new rehabilitation center for injured and orphaned wildlife, providing them with the care they need.',
        imageUrl: 'assets/images/crowdfunding/campaign3.jpg',
        date: 'March 15, 2024',
        targetAmount: 75000,
        currentAmount: 45000,
        donorsCount: 180,
        status: 'active',
      ),
      Campaign(
        id: '4',
        title: 'Emergency Animal Rescue',
        description:
            'Help us maintain our rapid response team for emergency animal rescues. Your support saves lives in critical situations.',
        imageUrl: 'assets/images/crowdfunding/campaign4.jpg',
        date: 'March 12, 2024',
        targetAmount: 30000,
        currentAmount: 22000,
        donorsCount: 95,
        status: 'active',
      ),
    ];
  }

  List<Donor> _getMockDonors() {
    return [
      Donor(
        id: '1',
        name: 'Sarah Chen',
        imageUrl: 'assets/images/crowdfunding/donors/donor2.jpg',
        totalDonations: 8500,
        campaignsSupported: 5,
        supportedCampaignIds: ['1', '2', '3', '4', '5'],
        joinDate: '2024-01-15',
      ),
      Donor(
        id: '2',
        name: 'Michael Rodriguez',
        imageUrl: 'assets/images/crowdfunding/donors/donor1.jpeg',
        totalDonations: 7200,
        campaignsSupported: 4,
        supportedCampaignIds: ['1', '2', '3', '4'],
        joinDate: '2024-01-20',
      ),
      // Add more mock donors...
    ];
  }

  List<SuccessStory> _getMockSuccessStories() {
    return [
      SuccessStory(
        id: '1',
        title: 'Rescued Elephant Returns to Wild',
        content:
            'Thanks to generous donations, we successfully rehabilitated and released an injured elephant back into its natural habitat. The elephant, named "Hope", was found injured in a local village. After six months of dedicated care and rehabilitation, Hope was successfully released back into the wild. This success story demonstrates the power of community support and dedicated conservation efforts.',
        imageUrl: 'assets/images/crowdfunding/success/story1.jpg',
        date: 'March 15, 2024',
        donorsInvolved: 150,
        fundsRaised: 25000,
        volunteersInvolved: 45,
        campaignId: '1',
      ),
      SuccessStory(
        id: '2',
        title: 'Coral Reef Restoration Success',
        content:
            'Our coral reef restoration project has shown remarkable results. Over 500 coral fragments have been successfully transplanted, and the reef ecosystem is showing signs of recovery. Local fish populations have increased, and the reef is now more resilient to climate change impacts.',
        imageUrl: 'assets/images/crowdfunding/success/story2.jpg',
        date: 'March 10, 2024',
        donorsInvolved: 120,
        fundsRaised: 20000,
        volunteersInvolved: 30,
        campaignId: '2',
      ),
      SuccessStory(
        id: '3',
        title: 'Urban Wildlife Sanctuary Established',
        content:
            'We\'ve successfully created a new urban wildlife sanctuary, providing a safe haven for local wildlife in the heart of the city. This sanctuary now houses various species of birds, small mammals, and reptiles, offering them protection while educating the community about urban wildlife conservation.',
        imageUrl: 'assets/images/crowdfunding/success/story3.jpg',
        date: 'March 5, 2024',
        donorsInvolved: 200,
        fundsRaised: 35000,
        volunteersInvolved: 60,
        campaignId: '3',
      ),
    ];
  }
}
