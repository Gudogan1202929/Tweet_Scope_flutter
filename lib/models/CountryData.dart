class CountryData {
  final String country;
  final int count;

  CountryData(this.country, this.count);

  factory CountryData.fromJson(List<dynamic> json) {
    if (json.length != 2) {
      throw FormatException('Invalid JSON format for CountryData');
    }
    return CountryData(json[0] as String, json[1] as int);
  }
}
