class OffensiveData {
  final String offensive;
  final int count;

  OffensiveData(this.offensive, this.count);

  factory OffensiveData.fromJson(List<dynamic> json) {
    if (json.length != 2) {
      throw FormatException('Invalid JSON format for CountryData');
    }
    return OffensiveData(json[0] as String, json[1] as int);
  }
}
