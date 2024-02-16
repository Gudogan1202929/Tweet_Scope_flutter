class OffensiveData {
  final String topic;
  final int totalTweets;

  OffensiveData({
    required this.topic,
    required this.totalTweets,
  });

  factory OffensiveData.fromJson(Map<String, dynamic> json) {
    return OffensiveData(
      topic: json['topic'] as String,
      totalTweets: json['totalTweets'] as int,
    );
  }
}
