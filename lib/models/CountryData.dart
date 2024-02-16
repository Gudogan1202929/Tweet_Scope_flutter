class CountryData {
  final String country;
  final int count;

  CountryData({required this.country, required this.count});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      country: json['topic'] as String, // Changed from json[0]
      count: json['totalTweets'] as int, // Changed from json[1]
    );
  }
}
