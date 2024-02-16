class TweetSummary {
  final int numHate;
  final int numNormal;
  final int numOffensive;
  final DateTime time;

  TweetSummary({
    required this.numHate,
    required this.numNormal,
    required this.numOffensive,
    required this.time,
  });

  factory TweetSummary.fromJson(Map<String, dynamic> json) {
    String dateString = json['time'];
    // Extract only the date part before the 'T'
    dateString = dateString.split('T')[0];
    return TweetSummary(
      numHate: json['numHate'],
      numNormal: json['numNormal'],
      numOffensive: json['numOffensive'],
      time: DateTime.parse(dateString), // Now using only the date part
    );
  }
}
