class TweetModel {
  final int tweetId;
  final String tweetContent;
  final String topic;
  final String offensiveType;
  final DateTime timestamp;

  TweetModel({
    required this.tweetId,
    required this.tweetContent,
    required this.topic,
    required this.offensiveType,
    required this.timestamp,
  });

  factory TweetModel.fromJson(List<dynamic> json) {
    String dateStr = json[5] as String;
    int indexOfT = dateStr.indexOf("T");
    if (indexOfT != -1) {
      dateStr = dateStr.substring(0, indexOfT);
    }
    return TweetModel(
      tweetId: json[0] as int,
      tweetContent: json[4] as String,
      topic: json[3] as String,
      offensiveType: json[2] as String,
      timestamp: DateTime.tryParse(dateStr) ??
          DateTime.now(), // Provide a default value if parsing fails
    );
  }
}
