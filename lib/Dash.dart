import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:circular_chart_flutter/circular_chart_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tweet_scope/Auth/Login.dart';
import 'package:tweet_scope/models/ChartModel.dart';
import 'package:tweet_scope/models/CountryData.dart';
import 'package:tweet_scope/models/OffensiveData.dart';
import 'package:tweet_scope/models/TopicData.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:flutter/material.dart';

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
    TestModel(),
  ];
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 900;

    if (isPhone) {
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black87,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.add_task_sharp),
              label: "Test Models",
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

class TestModel extends StatefulWidget {
  const TestModel({super.key});

  @override
  State<TestModel> createState() => _TestModelState();
}

class _TestModelState extends State<TestModel> {
  var response = http.Response('', 200);
  String? token;
  String result = "";
  String ipAddress = 'IP address not found';
  int touchedIndex = -1;
  String data = "";
  TextEditingController textEditingController = TextEditingController();

  Future<String> getIsAbusive(String message) async {
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/classify/hate';

    var url =
        Uri.parse('$basePath$path').replace(queryParameters: {'text': message});

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json; charset=UTF-8",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return "";
    } else if (response.statusCode == 200) {
      data = response.body;
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> getIsTopic(String message) async {
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/classify/topic';

    var url =
        Uri.parse('$basePath$path').replace(queryParameters: {'text': message});

    response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return "";
    } else if (response.statusCode == 200) {
      data = response.body;
      return data;
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

  void showMyDialog(BuildContext context, String content) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (content == '"HateSpeech"' || content == '"Offensive"') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.BOTTOMSLIDE,
          title: content,
          desc: 'Our model classified this as: $content',
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        )..show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.BOTTOMSLIDE,
          title: content,
          desc: 'Our model classified this as: $content',
          btnOkOnPress: () {},
        )..show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image(image: AssetImage("images/twitter.png"), height: 200),
          Spacer(),
          Text(
            "Our Modles built in Machine lerning using bert and it accurate , you can test it here",
            style: TextStyle(
              fontSize: 15,
              fontFamily: "NotoSerif",
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Flexible(
            child: TextField(
              controller: textEditingController,
              maxLines: null, // Allows TextField to expand
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter your text here...',
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
          Spacer(),
          Container(
            child: Row(children: [
              ElevatedButton(
                onPressed: () async {
                  String message = textEditingController.text;
                  String result = await getIsAbusive(message);
                  showMyDialog(context, result);
                },
                child: Text(
                  "Check if Offinsive",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width / 8 - 20,
                      vertical: 18),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  String message = textEditingController.text;
                  String result = await getIsTopic(message);
                  showMyDialog(context, result);
                },
                child: Text(
                  "Check the Topic",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width / 8 - 20,
                      vertical: 18),
                ),
              ),
            ]),
          )
        ],
      ),
    );
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

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/topicClassification';

    var url = Uri.parse('$basePath$path');

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
      final data = json.decode(response.body) as List<dynamic>;

      final List<TopicData> topicDataList = data
          .map((jsonItem) =>
              TopicData.fromJson(jsonItem as Map<String, dynamic>))
          .toList();

      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<int> getRecentTopic() async {
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/numOfTweets';

    var url = Uri.parse('$basePath$path');

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
      return 0;
    } else if (response.statusCode == 200) {
      final int data = json.decode(response.body);
      return data;
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
          value: topicData.hashCode.toDouble(),
          title: '${topicData.topic}\n${topicData.hashCode}',
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
            buildTopicsContainerForLoad(context),
            SizedBox(height: 20),
            buildRecentTopicsContainer(context),
          ],
        ),
      ),
    );
  }

  Container buildTopicsContainerForLoad(BuildContext context) {
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
                  'Topics Classifications',
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
              child: buildTopicsClassificationContainer(context),
            ),
          ],
        ),
      ),
    );
  }

  Container buildTopicsClassificationContainer(BuildContext context) {
    return Container(
      child: FutureBuilder<List<TopicData>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final topicDataList = snapshot.data!;
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).width / 5,
                  minHeight: MediaQuery.sizeOf(context).width / 5),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<TopicData, String>(
                    dataSource: topicDataList,
                    xValueMapper: (TopicData data, _) => data.topic,
                    yValueMapper: (TopicData data, _) => data.totalTweets,
                    dataLabelMapper: (TopicData data, _) =>
                        '${data.topic}\n${data.totalTweets}',
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
            );
          }
        },
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
                  'Tweets Classified',
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
    return FutureBuilder<int>(
      future: getRecentTopic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          // Corrected condition
          return Center(child: Text('No data available'));
        } else {
          final int topicDataCount = snapshot.data!;
          // Correct way to convert double to String for display
          return Center(
            child: Text(
              'Classified Tweets\nSo Far\n${topicDataCount.toString()}',
              textAlign: TextAlign
                  .center, // Ensure the text is centered if it wraps to a new line.
              style: TextStyle(
                fontSize: 23, // Increased font size for larger text
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
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

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/offensiveSummary';

    var url = Uri.parse('$basePath$path');

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

      final List<OffensiveData> offensiveDataList = data
          .map((jsonItem) =>
              OffensiveData.fromJson(jsonItem as Map<String, dynamic>))
          .toList();

      return offensiveDataList;
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

  Container buildOffinsiveContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 251, 251, 251),
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
                  'Offinsive Summary',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: buildSummaryForLoading(context)),
          ],
        ),
      ),
    );
  }

  Container buildSummaryForLoading(BuildContext context) {
    return Container(
      child: FutureBuilder<List<OffensiveData>>(
        future: recentHate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final cachedRecentPornographyData = snapshot.data!;
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).width / 5,
                  minHeight: MediaQuery.sizeOf(context).width / 5),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<OffensiveData, String>(
                    dataSource: cachedRecentPornographyData,
                    xValueMapper: (OffensiveData data, _) => data.topic,
                    yValueMapper: (OffensiveData data, _) => data.totalTweets,
                    dataLabelMapper: (OffensiveData data, _) =>
                        '${data.topic}\n${data.totalTweets}',
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
            );
          }
        },
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
              child: buildOffinsiveContainer(context),
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
  List<TweetSummary> data = [];
  var response = http.Response('', 200);
  String? token;
  String result = "";
  String ipAddress = 'IP address not found';
  final Map<String, Map<String, int>> monthlyData = {};
  List<TweetSummary>? cachedTweetData;
  late TooltipBehavior _tooltip;

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

  Future<List<TweetSummary>> getData() async {
    if (cachedTweetData != null) {
      // Return the cached top regions data if it exists
      return cachedTweetData!;
    }
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/offensiveChart';

    var url = Uri.parse('$basePath$path');

    var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "token": '$token',
        "X-Forwarded-For": ipAddress,
      },
    );

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed("Login");
      return <TweetSummary>[];
    } else if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<TweetSummary> summaries = data
          .map((jsonItem) =>
              TweetSummary.fromJson(jsonItem as Map<String, dynamic>))
          .toList();

      cachedTweetData = summaries;

      return summaries;
    } else {
      throw Exception(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(
        enable: true); // Initialize the TooltipBehavior in initState
  }

  Future<void> fetchData() async {
    data = await getData();
  }

  Widget createChartWidget(List<ChartData> chartData) {
    chartData.sort((a, b) => a.monthYear.compareTo(b.monthYear));
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(minimum: 0),
      series: <ChartSeries>[
        // Line series for normal tweets
        // Line series for offensive tweets
        LineSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.monthYear,
          yValueMapper: (ChartData data, _) => data.offensive,
          name: 'Offensive',
          color: Colors.red,
        ),
        // Line series for hate speech tweets
        LineSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.monthYear,
          yValueMapper: (ChartData data, _) => data.hateSpeech,
          name: 'Hate Speech',
          color: Colors.blue,
        ),
      ],
      tooltipBehavior: _tooltip,
    );
  }

  Future<List<ChartData>> processData(List<TweetSummary> summaries) async {
    Map<String, ChartData> aggregatedData = {};
    for (var tweet in summaries) {
      DateTime tweetDate = tweet.time;
      String year = tweetDate.year.toString();
      String semester = tweetDate.month <= 6 ? "H1" : "H2";
      String yearSemester = "$year-$semester";

      aggregatedData.putIfAbsent(
          yearSemester, () => ChartData(yearSemester, 0, 0, 0));

      aggregatedData[yearSemester]!.offensive += tweet.numOffensive;
      aggregatedData[yearSemester]!.hateSpeech += tweet.numHate;
    }

    List<ChartData> chartDataList = aggregatedData.values.toList();
    chartDataList.sort((a, b) => a.monthYear.compareTo(b.monthYear));
    return chartDataList;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      token = arguments as String;
    }

    // Adjust FutureBuilder to work with List<ChartData>
    return FutureBuilder<List<ChartData>>(
      // First, fetch the data, and then process it
      future: getData().then((data) => processData(data)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final chartData =
              snapshot.data!; // This is now correctly List<ChartData>

          Widget chartWidget =
              createChartWidget(chartData); // Use processed chart data
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chartWidget,
          );
        } else {
          return Text('No data available');
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
              Text('Offinsive', style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  String monthYear;
  int normal;
  int offensive;
  int hateSpeech;

  ChartData(this.monthYear, this.normal, this.offensive, this.hateSpeech);
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

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/topOffensiveRegions';

    var url = Uri.parse('$basePath$path');

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
          .map((json) => CountryData.fromJson(json as Map<String, dynamic>))
          .toList();

      return countryDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<CountryData>> getTopRegion() async {
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/regionsOffensive';

    var url = Uri.parse('$basePath$path');

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

      final List<CountryData> countryDataList = (data as List)
          .map((json) => CountryData.fromJson(json as Map<String, dynamic>))
          .toList();

      return countryDataList;
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
            buildCountryDataContainer(context),
            SizedBox(height: 20),
            buildTopRegionContainer(context),
          ],
        ),
      ),
    );
  }

  Container buildCountryDataContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 255, 255, 255),
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
                  'Top Offensive Region',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: BarForLoading(context)),
          ],
        ),
      ),
    );
  }

  Container BarForLoading(BuildContext context) {
    return Container(
      child: FutureBuilder<List<CountryData>>(
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
            return Container(
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
            );
          }
        },
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
                  'Regions Offensive Tweets',
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
  int? TweetNumber;

  Future<List<TopicData>> getData() async {
    if (cachedData != null) {
      // Return the cached top regions data if it exists
      return cachedData!;
    }
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/topicClassification';

    var url = Uri.parse('$basePath$path');

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
      final data = json.decode(response.body) as List<dynamic>;

      final List<TopicData> topicDataList = data
          .map((jsonItem) =>
              TopicData.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      cachedData = topicDataList;

      return topicDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<int> getRecentTopic() async {
    if (TweetNumber != null) {
      return TweetNumber!;
    }
    ipAddress = await getIpAddress();

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/numOfTweets';

    var url = Uri.parse('$basePath$path');

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
      return 0;
    } else if (response.statusCode == 200) {
      final int data = json.decode(response.body);
      TweetNumber = data;
      return data;
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
          value: topicData.totalTweets.toDouble(),
          title: '${topicData.topic}\n${topicData.totalTweets}',
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

  Container buildTopicsClassificationContainer(BuildContext context) {
    return Container(
      child: FutureBuilder<List<TopicData>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final topicDataList = snapshot.data!;
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).width / 5,
                  minHeight: MediaQuery.sizeOf(context).width / 5),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<TopicData, String>(
                    dataSource: topicDataList,
                    xValueMapper: (TopicData data, _) => data.topic,
                    yValueMapper: (TopicData data, _) => data.totalTweets,
                    dataLabelMapper: (TopicData data, _) =>
                        '${data.topic}\n${data.totalTweets}',
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
            );
          }
        },
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
                  'Tweets Classified',
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
    return FutureBuilder<int>(
      future: getRecentTopic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          // Corrected condition
          return Center(child: Text('No data available'));
        } else {
          final int topicDataCount = snapshot.data!;
          // Correct way to convert double to String for display
          return Center(
            child: Text(
              'Classified Tweets\nSo Far\n${topicDataCount.toString()}',
              textAlign: TextAlign
                  .center, // Ensure the text is centered if it wraps to a new line.
              style: TextStyle(
                fontSize: 23, // Increased font size for larger text
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
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

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/offensiveSummary';

    var url = Uri.parse('$basePath$path');
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

      final List<OffensiveData> offensiveDataList = data
          .map((jsonItem) =>
              OffensiveData.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      cachedRecentHateSpeechData = offensiveDataList; // Store

      return offensiveDataList;
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

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/topOffensiveRegions';

    var url = Uri.parse('$basePath$path');

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
          .map((json) => CountryData.fromJson(json as Map<String, dynamic>))
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

    String basePath = kIsWeb
        ? 'http://127.0.0.1:9096'
        : Platform.isAndroid
            ? 'http://10.0.2.2:9096'
            : Platform.isIOS
                ? 'http://localhost:9096'
                : 'http://127.0.0.1:9096';
    String path = '/dataSummaries/regionsOffensive';

    var url = Uri.parse('$basePath$path');

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

      final List<CountryData> countryDataList = (data as List)
          .map((json) => CountryData.fromJson(json as Map<String, dynamic>))
          .toList();

      cachedTopRegions =
          countryDataList; // Store fetched top regions data in the cache
      return countryDataList;
    } else {
      throw Exception(response.body);
    }
  }

  Container buildCountryDataContainer(BuildContext context) {
    Container BarForLoading(BuildContext context) {
      return Container(
        child: FutureBuilder<List<CountryData>>(
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
              return Container(
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
              );
            }
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 255, 255, 255),
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
                  'Top Offensive Region',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: BarForLoading(context)),
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
                  'Regions Offensive Tweets',
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

  Container buildOffinsiveContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2 - 68,
      margin: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(255, 251, 251, 251),
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
                  'Offinsive Summary',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: buildSummaryForLoading(context)),
          ],
        ),
      ),
    );
  }

  Container buildSummaryForLoading(BuildContext context) {
    return Container(
      child: FutureBuilder<List<OffensiveData>>(
        future: recentHate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final cachedRecentPornographyData = snapshot.data!;
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).width / 5,
                  minHeight: MediaQuery.sizeOf(context).width / 5),
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<OffensiveData, String>(
                    dataSource: cachedRecentPornographyData,
                    xValueMapper: (OffensiveData data, _) => data.topic,
                    yValueMapper: (OffensiveData data, _) => data.totalTweets,
                    dataLabelMapper: (OffensiveData data, _) =>
                        '${data.topic}\n${data.totalTweets}',
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
            );
          }
        },
      ),
    );
  }

  Container buildTopicsContainerForLoad(BuildContext context) {
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
                  'Topics Classifications',
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
              child: buildTopicsClassificationContainer(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    TextEditingController textEditingController = TextEditingController();
    String data;

    if (arguments != null) {
      token = arguments as String;
    }

    Future<String> getIsAbusive(String message) async {
      ipAddress = await getIpAddress();

      String basePath = kIsWeb
          ? 'http://127.0.0.1:9096'
          : Platform.isAndroid
              ? 'http://10.0.2.2:9096'
              : Platform.isIOS
                  ? 'http://localhost:9096'
                  : 'http://127.0.0.1:9096';
      String path = '/classify/hate';

      var url = Uri.parse('$basePath$path')
          .replace(queryParameters: {'text': message});

      response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8",
          "token": '$token',
          "X-Forwarded-For": ipAddress,
        },
      );

      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacementNamed("Login");
        return "";
      } else if (response.statusCode == 200) {
        data = response.body;
        return data;
      } else {
        throw Exception(response.body);
      }
    }

    Future<String> getIsTopic(String message) async {
      ipAddress = await getIpAddress();

      String basePath = kIsWeb
          ? 'http://127.0.0.1:9096'
          : Platform.isAndroid
              ? 'http://10.0.2.2:9096'
              : Platform.isIOS
                  ? 'http://localhost:9096'
                  : 'http://127.0.0.1:9096';
      String path = '/classify/topic';

      var url = Uri.parse('$basePath$path')
          .replace(queryParameters: {'text': message});

      response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "token": '$token',
          "X-Forwarded-For": ipAddress,
        },
      );

      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacementNamed("Login");
        return "";
      } else if (response.statusCode == 200) {
        data = response.body;
        return data;
      } else {
        throw Exception(response.body);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 165, 255),
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(image: AssetImage("images/twitter.png"), height: 30),
          SizedBox(width: 16),
          Text("Tweet Scope"),
          SizedBox(width: 16),
          Flexible(
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Test...',
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              String message = textEditingController.text;
              String result = await getIsAbusive(message);

              if (result == '"HateSpeech"' || result == '"Offensive"') {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.BOTTOMSLIDE,
                  title: result,
                  desc: "Offinsive model classified this as : " + result,
                  btnOkOnPress: () {},
                  btnOkColor: Colors.red,
                )..show();
              } else {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.SUCCES,
                  animType: AnimType.BOTTOMSLIDE,
                  title: result,
                  desc: "Offinsive model classified this as : " + result,
                  btnOkOnPress: () {},
                )..show();
              }
            },
            child: Text(
              "Check if Offinsive",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              String message = textEditingController.text;
              String result = await getIsTopic(message);
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.SUCCES,
                  animType: AnimType.BOTTOMSLIDE,
                  title: result,
                  desc: "Topics model classified this as : " + result,
                  btnOkOnPress: () {})
                ..show();
            },
            child: Text(
              "Check the Topic",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
              ));
            },
            child: Text(
              "Sign Out",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ]),
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
                  buildTopicsContainerForLoad(context),
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
                  Container(child: buildOffinsiveContainer(context))
                ],
              )),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildCountryDataContainer(context),
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
