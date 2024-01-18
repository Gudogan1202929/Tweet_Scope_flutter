import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:circular_chart_flutter/circular_chart_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tweet_scope/models/ChartModel.dart';
import 'package:tweet_scope/models/CountryData.dart';
import 'package:tweet_scope/models/OffensiveData.dart';
import 'package:tweet_scope/models/TopicData.dart';

class ListUser extends StatefulWidget {
  ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  List<Widget> widgetPages = [
    Dashboard(),
    Offinsiive(),
    Region(),
  ];
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 900;

    if (isPhone) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tweet Scope"),
              SizedBox(width: 16),
              Image(image: AssetImage("images/twitter.png"), height: 30),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black87,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.topic),
              label: "Topics",
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Offensive",
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Regions",
              backgroundColor: Colors.blue,
            ),
          ],
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        body: widgetPages.elementAt(selectedIndex),
      );
    } else {
      return DashDesk();
    }
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var response = http.Response('', 200);
  String? token;
  String result = "";
  String ipAddress = 'IP address not found';
  int touchedIndex = -1;

  Future<List<TopicData>> getData() async {
    ipAddress = await getIpAddress();

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweet/topic/classifications');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweet/topic/classifications');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweet/topic/classifications');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweet/topic/classifications');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<TopicData> topicDataList = (data as List)
          .map((json) => TopicData.fromJson(json as List<dynamic>))
          .toList();

      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<TopicData>> getRecentTopic() async {
    ipAddress = await getIpAddress();

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweet/recent/topic');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweet/recent/topic');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweet/recent/topic');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweet/recent/topic');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<TopicData> topicDataList = (data as List)
          .map((json) => TopicData.fromJson(json as List<dynamic>))
          .toList();

      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> getIpAddress() async {
    if (kIsWeb) {
      try {
        final response =
            await http.get(Uri.parse('https://api.ipify.org?format=json'));
        if (response.statusCode == 200) {
          final ipAddress = jsonDecode(response.body)['ip'];
          return ipAddress;
        }
      } catch (e) {
        print('Error getting IP address: $e');
      }
      return 'IP address not found';
    } else {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type.name.toLowerCase() == 'ipv4') {
            return addr.address;
          }
        }
      }
      return 'IP address not found';
    }
  }

  List<PieChartSectionData> generatePieChartSections(
      List<TopicData> topicDataList) {
    return List.generate(
      topicDataList.length,
      (index) {
        final topicData = topicDataList[index];
        final isTouched = index == touchedIndex;
        final double fontSize = isTouched ? 16 : 12;
        final double radius = isTouched ? 60 : 50;

        return PieChartSectionData(
          color: getRandomColor(),
          value: topicData.count.toDouble(),
          title: '${topicData.topic}\n${topicData.count}',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        );
      },
    );
  }

  Color getRandomColor() {
    final r = Random().nextInt(256);
    final g = Random().nextInt(256);
    final b = Random().nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<TopicData>>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No data available');
                } else {
                  final topicDataList = snapshot.data!;
                  return buildTopicsClassificationContainer(
                      context, topicDataList);
                }
              },
            ),
            SizedBox(height: 20),
            buildRecentTopicsContainer(context),
          ],
        ),
      ),
    );
  }

  Container buildTopicsClassificationContainer(
      BuildContext context, List<TopicData> topicDataList) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 238, 236, 236),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Topics Classification',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2.8,
                  minHeight: MediaQuery.of(context).size.height / 2.8),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<TopicData, String>(
                    dataSource: topicDataList,
                    xValueMapper: (TopicData data, _) => data.topic,
                    yValueMapper: (TopicData data, _) => data.count,
                    dataLabelMapper: (TopicData data, _) =>
                        '${data.topic}\n${data.count}',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    enableTooltip: true,
                    explode: true,
                    explodeIndex: touchedIndex,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildRecentTopicsContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Recent Topics',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: buildRecentTopicsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecentTopicsList() {
    return FutureBuilder<List<TopicData>>(
      future: getRecentTopic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final topicDataList = snapshot.data!;
          return ListView.builder(
            itemCount: topicDataList.length,
            itemBuilder: (context, index) {
              final data = topicDataList[index];
              return ListTile(
                title: Center(
                  child: Text(
                    '${data.topic}: ${data.count}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class Offinsiive extends StatefulWidget {
  const Offinsiive({super.key});

  @override
  State<Offinsiive> createState() => _OffinsiiveState();
}

class _OffinsiiveState extends State<Offinsiive> {
  var response = http.Response('', 200);
  String? token;
  String result = "";
  String ipAddress = 'IP address not found';
  int touchedIndex = -1;

  Future<List<OffensiveData>> recentHate() async {
    ipAddress = await getIpAddress();
    var url;
    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweet/summary/offensive');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweet/summary/offensive');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweet/summary/offensive');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweet/summary/offensive');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<OffensiveData> topRegion = (data as List)
          .map((json) => OffensiveData.fromJson(json as List<dynamic>))
          .toList();

      return topRegion;
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> getIpAddress() async {
    if (kIsWeb) {
      try {
        final response =
            await http.get(Uri.parse('https://api.ipify.org?format=json'));
        if (response.statusCode == 200) {
          final ipAddress = jsonDecode(response.body)['ip'];
          return ipAddress;
        }
      } catch (e) {
        print('Error getting IP address: $e');
      }
      return 'IP address not found';
    } else {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type.name.toLowerCase() == 'ipv4') {
            return addr.address;
          }
        }
      }
      return 'IP address not found';
    }
  }

  Container buildOffinsiveContainer(
      BuildContext context, List<OffensiveData> topicDataList) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 238, 236, 236),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Offinsive summary',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.height / 1.2,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<OffensiveData, String>(
                    dataSource: topicDataList,
                    xValueMapper: (OffensiveData data, _) => data.offensive,
                    yValueMapper: (OffensiveData data, _) => data.count,
                    dataLabelMapper: (OffensiveData data, _) =>
                        '${data.offensive}\n${data.count}',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    enableTooltip: true,
                    explode: true,
                    explodeIndex: touchedIndex,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2,
              margin: EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.white,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.green],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Offinsive Chart',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: TweetCategoryChart(),
                      ),
                      MyLegend(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width / 1,
              height: MediaQuery.of(context).size.height / 2,
              child: FutureBuilder<List<OffensiveData>>(
                future: recentHate(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No data available');
                  } else {
                    final cachedRecentHateSpeechData = snapshot.data!;
                    return buildOffinsiveContainer(
                        context, cachedRecentHateSpeechData);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TweetCategoryChart extends StatefulWidget {
  const TweetCategoryChart({super.key});

  @override
  State<TweetCategoryChart> createState() => _TweetCategoryChartState();
}

class _TweetCategoryChartState extends State<TweetCategoryChart> {
  List<TweetModel> data = [];
  var response = http.Response('', 200);
  String? token;
  String result = "";
  String ipAddress = 'IP address not found';
  final Map<String, Map<String, int>> monthlyData = {};
  List<TweetModel>? cachedTweetData;

  Future<String> getIpAddress() async {
    if (kIsWeb) {
      try {
        final response =
            await http.get(Uri.parse('https://api.ipify.org?format=json'));
        if (response.statusCode == 200) {
          final ipAddress = jsonDecode(response.body)['ip'];
          return ipAddress;
        }
      } catch (e) {
        print('Error getting IP address: $e');
      }
      return 'IP address not found';
    } else {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type.name.toLowerCase() == 'ipv4') {
            return addr.address;
          }
        }
      }
      return 'IP address not found';
    }
  }

  Future<List<TweetModel>> getData() async {
    if (cachedTweetData != null) {
      // Return the cached tweet data if it exists
      return cachedTweetData!;
    }

    ipAddress = await getIpAddress();
    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweet/offensive/chart');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweet/offensive/chart');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweet/offensive/chart');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweet/offensive/chart');
    }
    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return <TweetModel>[];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<TweetModel> topicDataList = (data as List)
          .map((json) => TweetModel.fromJson(json as List))
          .toList();

      cachedTweetData = topicDataList; // Store fetched tweet data in the cache
      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<void> fetchData() async {
    data = await getData();
    print(data.length);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }

    return FutureBuilder<void>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          monthlyData.clear(); // Clear the data map

          for (var tweet in data) {
            final monthYear =
                '${tweet.timestamp.month}-${tweet.timestamp.year}';
            if (!monthlyData.containsKey(monthYear)) {
              monthlyData[monthYear] = {
                'HateSpeech': 0,
                'Pornograph': 0,
                'Abusive': 0,
              };
            }

            final offensiveType = tweet.offensiveType ?? 'Unknown';
            monthlyData[monthYear]?[offensiveType] =
                (monthlyData[monthYear]?[offensiveType] ?? 0) + 1;
          }

          final List<ChartData> chartData = [];

          // Create a list of ChartData objects
          monthlyData.forEach((monthYear, categories) {
            final hateSpeechCount = categories['HateSpeech'] ?? 0;
            final pornographyCount = categories['Pornograph'] ?? 0;
            final abusiveCount = categories['Abusive'] ?? 0;
            chartData.add(ChartData(
                monthYear, hateSpeechCount, pornographyCount, abusiveCount));
          });

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: <ChartSeries<ChartData, String>>[
                LineSeries<ChartData, String>(
                  color: Colors.blue,
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.monthYear,
                  yValueMapper: (ChartData data, _) => data.hateSpeechCount,
                  name: 'HateSpeech',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                ),
                LineSeries<ChartData, String>(
                  color: Colors.red,
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.monthYear,
                  yValueMapper: (ChartData data, _) => data.pornographyCount,
                  name: 'Pornograph',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                ),
                LineSeries<ChartData, String>(
                  color: Colors.green,
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.monthYear,
                  yValueMapper: (ChartData data, _) => data.abusiveCount,
                  name: 'Abusive',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class MyLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text('Hate Speech', style: TextStyle(color: Colors.black)),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.circle,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text('Pornography', style: TextStyle(color: Colors.black)),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.circle,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('Abusive', style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String monthYear;
  final int hateSpeechCount;
  final int pornographyCount;
  final int abusiveCount;

  ChartData(this.monthYear, this.hateSpeechCount, this.pornographyCount,
      this.abusiveCount);
}

class Region extends StatefulWidget {
  const Region({super.key});

  @override
  State<Region> createState() => _RegionState();
}

class _RegionState extends State<Region> {
  var response = http.Response('', 200);
  String? token;
  String ipAddress = 'IP address not found';
  late TooltipBehavior _tooltip;

  Future<List<CountryData>> getData() async {
    ipAddress = await getIpAddress();

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/global/distribution');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweeter/user/global/distribution');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweeter/user/global/distribution');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/global/distribution');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _tooltip = TooltipBehavior(enable: true);

      final List<CountryData> countryDataList = (data as List)
          .map((json) => CountryData.fromJson(json as List<dynamic>))
          .toList();

      return countryDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<CountryData>> getTopRegion() async {
    ipAddress = await getIpAddress();

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/top/regions');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweeter/user/top/regions');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweeter/user/top/regions');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/top/regions');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<CountryData> topRegion = (data as List)
          .map((json) => CountryData.fromJson(json as List<dynamic>))
          .toList();

      return topRegion;
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> getIpAddress() async {
    if (kIsWeb) {
      try {
        final response =
            await http.get(Uri.parse('https://api.ipify.org?format=json'));
        if (response.statusCode == 200) {
          final ipAddress = jsonDecode(response.body)['ip'];
          return ipAddress;
        }
      } catch (e) {
        print('Error getting IP address: $e');
      }
      return 'IP address not found';
    } else {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type.name.toLowerCase() == 'ipv4') {
            return addr.address;
          }
        }
      }
      return 'IP address not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<CountryData>>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No data available');
                } else {
                  final countryDataList = snapshot.data!;
                  return buildCountryDataContainer(context, countryDataList);
                }
              },
            ),
            SizedBox(height: 20),
            buildTopRegionContainer(context),
          ],
        ),
      ),
    );
  }

  Container buildCountryDataContainer(
      BuildContext context, List<CountryData> countryDataList) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Bar Region offensive',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <ChartSeries<CountryData, String>>[
                  BarSeries<CountryData, String>(
                    dataSource: countryDataList,
                    xValueMapper: (CountryData data, _) => data.country,
                    yValueMapper: (CountryData data, _) => data.count,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildTopRegionContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Top Regions Offensive',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: buildTopRegionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopRegionList() {
    return FutureBuilder<List<CountryData>>(
      future: getTopRegion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final topRegionData = snapshot.data!;
          return buildTopRegionDataList(topRegionData);
        }
      },
    );
  }

  ListView buildTopRegionDataList(List<CountryData> topRegionData) {
    return ListView.builder(
      itemCount: topRegionData.length,
      itemBuilder: (context, index) {
        final data = topRegionData[index];
        return ListTile(
          title: Center(
            child: Text(
              '${data.country}: ${data.count}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
          ),
        );
      },
    );
  }
}

class DashDesk extends StatefulWidget {
  const DashDesk({super.key});

  @override
  State<DashDesk> createState() => _DashDeskState();
}

class _DashDeskState extends State<DashDesk> {
  var response = http.Response('', 200);
  String? token;
  String result = "";
  String ipAddress = 'IP address not found';
  int touchedIndex = -1;
  late TooltipBehavior _tooltip;
  List<TopicData>? cachedData;
  List<TopicData>? cachedRecentTopicData;
  List<OffensiveData>? cachedRecentHateSpeechData;
  String? cachedRecentPornographyData;
  List<CountryData>? cachedGlobalDistributionData;
  List<CountryData>? cachedTopRegions;
  String? cachedRecentAbusive;

  Future<List<TopicData>> getData() async {
    if (cachedData != null) {
      // Return the cached data if it exists
      return cachedData!;
    }

    ipAddress = await getIpAddress();

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweet/topic/classifications');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweet/topic/classifications');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweet/topic/classifications');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweet/topic/classifications');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<TopicData> topicDataList = (data as List)
          .map((json) => TopicData.fromJson(json as List<dynamic>))
          .toList();

      cachedData = topicDataList; // Store fetched data in the cache
      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<TopicData>> getRecentTopic() async {
    if (cachedRecentTopicData != null) {
      // Return the cached recent topic data if it exists
      return cachedRecentTopicData!;
    }

    ipAddress = await getIpAddress();

    var url;
    if (kIsWeb) {
      url = Uri.parse('http://127.0.0.1:9096/tweet/recent/topic');
    } else if (Platform.isAndroid) {
      url = Uri.parse('http://10.0.2.2:9096/tweet/recent/topic');
    } else if (Platform.isIOS) {
      url = Uri.parse('http://localhost:9096/tweet/recent/topic');
    } else {
      url = Uri.parse('http://127.0.0.1:9096/tweet/recent/topic');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<TopicData> topicDataList = (data as List)
          .map((json) => TopicData.fromJson(json as List<dynamic>))
          .toList();

      cachedRecentTopicData =
          topicDataList; // Store fetched recent topic data in the cache
      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> getIpAddress() async {
    if (kIsWeb) {
      try {
        final response =
            await http.get(Uri.parse('https://api.ipify.org?format=json'));
        if (response.statusCode == 200) {
          final ipAddress = jsonDecode(response.body)['ip'];
          return ipAddress;
        }
      } catch (e) {
        print('Error getting IP address: $e');
      }
      return 'IP address not found';
    } else {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type.name.toLowerCase() == 'ipv4') {
            return addr.address;
          }
        }
      }
      return 'IP address not found';
    }
  }

  List<PieChartSectionData> generatePieChartSections(
      List<TopicData> topicDataList) {
    return List.generate(
      topicDataList.length,
      (index) {
        final topicData = topicDataList[index];
        final isTouched = index == touchedIndex;
        final double fontSize = isTouched ? 16 : 12;
        final double radius = isTouched ? 60 : 50;

        return PieChartSectionData(
          color: getRandomColor(),
          value: topicData.count.toDouble(),
          title: '${topicData.topic}\n${topicData.count}',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        );
      },
    );
  }

  Color getRandomColor() {
    final r = Random().nextInt(256);
    final g = Random().nextInt(256);
    final b = Random().nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  Container buildTopicsClassificationContainer(
      BuildContext context, List<TopicData> topicDataList) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 238, 236, 236),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Topics Classification',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 300, minHeight: 200),
                child: SfCircularChart(
                  series: <CircularSeries>[
                    PieSeries<TopicData, String>(
                      dataSource: topicDataList,
                      xValueMapper: (TopicData data, _) => data.topic,
                      yValueMapper: (TopicData data, _) => data.count,
                      dataLabelMapper: (TopicData data, _) =>
                          '${data.topic}\n${data.count}',
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                      ),
                      enableTooltip: true,
                      explode: true,
                      explodeIndex: touchedIndex,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildRecentTopicsContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Recent Topics',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: buildRecentTopicsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecentTopicsList() {
    return FutureBuilder<List<TopicData>>(
      future: getRecentTopic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final topicDataList = snapshot.data!;
          return ListView.builder(
            itemCount: topicDataList.length,
            itemBuilder: (context, index) {
              final data = topicDataList[index];
              return ListTile(
                title: Center(
                  child: Text(
                    '${data.topic}: ${data.count}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<OffensiveData>> recentHate() async {
    if (cachedRecentHateSpeechData != null) {
      return cachedRecentHateSpeechData!;
    }

    ipAddress = await getIpAddress();
    var url;
    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweet/summary/offensive');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweet/summary/offensive');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweet/summary/offensive');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweet/summary/offensive');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<OffensiveData> topRegion = (data as List)
          .map((json) => OffensiveData.fromJson(json as List<dynamic>))
          .toList();

      cachedRecentHateSpeechData =
          topRegion; // Store fetched top regions data in the cache
      return topRegion;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<CountryData>> getDataglobalDistribution() async {
    if (cachedGlobalDistributionData != null) {
      // Return the cached global distribution data if it exists
      return cachedGlobalDistributionData!;
    }

    ipAddress = await getIpAddress();
    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/global/distribution');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweeter/user/global/distribution');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweeter/user/global/distribution');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/global/distribution');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _tooltip = TooltipBehavior(enable: true);

      final List<CountryData> countryDataList = (data as List)
          .map((json) => CountryData.fromJson(json as List<dynamic>))
          .toList();

      cachedGlobalDistributionData =
          countryDataList; // Store fetched global distribution data in the cache
      return countryDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<CountryData>> getTopRegion() async {
    if (cachedTopRegions != null) {
      // Return the cached top regions data if it exists
      return cachedTopRegions!;
    }

    ipAddress = await getIpAddress();
    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/top/regions');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/tweeter/user/top/regions');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/tweeter/user/top/regions');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/tweeter/user/top/regions');
    }

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return [];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<CountryData> topRegion = (data as List)
          .map((json) => CountryData.fromJson(json as List<dynamic>))
          .toList();

      cachedTopRegions =
          topRegion; // Store fetched top regions data in the cache
      return topRegion;
    } else {
      throw Exception(response.body);
    }
  }

  Container buildCountryDataContainer(
      BuildContext context, List<CountryData> countryDataList) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Bar Region offensive',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <ChartSeries<CountryData, String>>[
                  BarSeries<CountryData, String>(
                    dataSource: countryDataList,
                    xValueMapper: (CountryData data, _) => data.country,
                    yValueMapper: (CountryData data, _) => data.count,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildTopRegionContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Top Regions Offensive',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: buildTopRegionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopRegionList() {
    return FutureBuilder<List<CountryData>>(
      future: getTopRegion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final topRegionData = snapshot.data!;
          return buildTopRegionDataList(topRegionData);
        }
      },
    );
  }

  ListView buildTopRegionDataList(List<CountryData> topRegionData) {
    return ListView.builder(
      itemCount: topRegionData.length,
      itemBuilder: (context, index) {
        final data = topRegionData[index];
        return ListTile(
          title: Center(
            child: Text(
              '${data.country}: ${data.count}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
          ),
        );
      },
    );
  }

  Container buildOffinsiveContainer(
      BuildContext context, List<OffensiveData> topicDataList) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 238, 236, 236),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Offinsive summary',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 300, minHeight: 200),
                child: SfCircularChart(
                  series: <CircularSeries>[
                    PieSeries<OffensiveData, String>(
                      dataSource: topicDataList,
                      xValueMapper: (OffensiveData data, _) => data.offensive,
                      yValueMapper: (OffensiveData data, _) => data.count,
                      dataLabelMapper: (OffensiveData data, _) =>
                          '${data.offensive}\n${data.count}',
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                      ),
                      enableTooltip: true,
                      explode: true,
                      explodeIndex: touchedIndex,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 165, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Tweet Scope"),
            SizedBox(width: 16),
            Image(image: AssetImage("images/twitter.png"), height: 30),
          ],
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<List<TopicData>>(
                    future: getData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No data available');
                      } else {
                        final topicDataList = snapshot.data!;
                        return buildTopicsClassificationContainer(
                            context, topicDataList);
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  buildRecentTopicsContainer(context),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2 - 68,
                    margin: EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      color: Colors.white,
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.green],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Offinsive Chart',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height / 35,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(child: TweetCategoryChart()),
                            MyLegend(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2 - 68,
                    margin: EdgeInsets.all(8.0),
                    child: FutureBuilder<List<OffensiveData>>(
                      future: recentHate(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('No data available');
                        } else {
                          final cachedRecentHateSpeechData = snapshot.data!;
                          return buildOffinsiveContainer(
                              context, cachedRecentHateSpeechData);
                        }
                      },
                    ),
                  )
                ],
              )),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<List<CountryData>>(
                  future: getDataglobalDistribution(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No data available');
                    } else {
                      final countryDataList = snapshot.data!;
                      return buildCountryDataContainer(
                          context, countryDataList);
                    }
                  },
                ),
                SizedBox(height: 20),
                buildTopRegionContainer(context),
              ],
            ),
          )
        ],
      ),
    );
  }
}
