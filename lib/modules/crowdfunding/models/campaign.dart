class Campaign {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final double targetAmount;
  final double currentAmount;
  final int donorsCount;
  final String status;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.targetAmount,
    required this.currentAmount,
    required this.donorsCount,
    required this.status,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      date: json['date'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      donorsCount: json['donorsCount'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'donorsCount': donorsCount,
      'status': status,
    };
  }
}
