class TopicData {
  final String topic;
  final int count;

  TopicData({
    required this.topic,
    required this.count,
  });

  factory TopicData.fromJson(List<dynamic> json) {
    if (json.length == 2) {
      return TopicData(
        topic: json[0] as String,
        count: json[1] as int,
      );
    } else {
      throw Exception('Invalid JSON format for TopicData');
    }
  }
}
