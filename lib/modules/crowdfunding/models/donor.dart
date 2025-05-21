class Donor {
  final String id;
  final String name;
  final String imageUrl;
  final double totalDonations;
  final int campaignsSupported;
  final List<String> supportedCampaignIds;
  final String joinDate;

  Donor({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.totalDonations,
    required this.campaignsSupported,
    required this.supportedCampaignIds,
    required this.joinDate,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      totalDonations: (json['totalDonations'] as num).toDouble(),
      campaignsSupported: json['campaignsSupported'] as int,
      supportedCampaignIds:
          (json['supportedCampaignIds'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      joinDate: json['joinDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'totalDonations': totalDonations,
      'campaignsSupported': campaignsSupported,
      'supportedCampaignIds': supportedCampaignIds,
      'joinDate': joinDate,
    };
  }
}
