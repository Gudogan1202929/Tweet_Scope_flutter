class TopicData {
  final String topic;
  final int totalTweets;

  TopicData({
    required this.topic,
    required this.totalTweets,
  });

  factory TopicData.fromJson(Map<String, dynamic> json) {
    return TopicData(
      topic: json['topic'] as String,
      totalTweets: json['totalTweets'] as int,
    );
  }
}
