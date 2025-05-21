class SuccessStory {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String date;
  final int donorsInvolved;
  final double fundsRaised;
  final int volunteersInvolved;
  final String campaignId;

  SuccessStory({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.date,
    required this.donorsInvolved,
    required this.fundsRaised,
    required this.volunteersInvolved,
    required this.campaignId,
  });

  factory SuccessStory.fromJson(Map<String, dynamic> json) {
    return SuccessStory(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      date: json['date'] as String,
      donorsInvolved: json['donorsInvolved'] as int,
      fundsRaised: (json['fundsRaised'] as num).toDouble(),
      volunteersInvolved: json['volunteersInvolved'] as int,
      campaignId: json['campaignId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'date': date,
      'donorsInvolved': donorsInvolved,
      'fundsRaised': fundsRaised,
      'volunteersInvolved': volunteersInvolved,
      'campaignId': campaignId,
    };
  }
}
