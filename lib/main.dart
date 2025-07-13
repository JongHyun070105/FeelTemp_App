import 'dart:convert';

import 'package:feeltemp_app/profile_completed_screen.dart';
import 'package:feeltemp_app/setting_screen.dart'; // Import SettingScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feeltemp App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfileCompletedScreen(), // Start with ProfileCompletedScreen
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ko', 'KR'), // Korean
      ],
    );
  }
}

class MainScreen extends StatefulWidget {
  final Map<String, String> profileData; // Add profileData parameter

  const MainScreen({super.key, required this.profileData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentAddress = '위치 정보를 불러오는 중...';

  double _latitude = 0.0;
  double _longitude = 0.0;

  String _feelTemp = "-";
  String _realTemp = "-";
  String _humidity = "-";
  String _windSpeed = "-";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = '위치 서비스를 활성화해주세요.';
      });
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = '위치 권한이 거부되었습니다.';
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = '위치 권한이 영구적으로 거부되었습니다.';
      });
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.administrativeArea ?? ''} ${place.subLocality ?? ''}';
        _latitude = position.latitude;
        _longitude = position.longitude;
        _getFeelTemp();
        _getRealWeather();
      });
    } catch (e) {
      setState(() {
        _currentAddress = '위치 정보를 가져올 수 없습니다.';
      });
      print(e);
    }
  }

  Future<void> _getFeelTemp() async {
    var url = Uri.http('localhost:8000', 'predict');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // 추가 필요
        },
        body: jsonEncode({
          'gender': int.parse(widget.profileData['gender'].toString()),
          'age': int.parse(widget.profileData['age'].toString()),
          'bmi': double.parse(widget.profileData['bmi'].toString()),
          'latitude': double.parse('$_latitude'),
          'longitude': double.parse('$_longitude'),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() {
        _feelTemp = '${jsonDecode(response.body)['prediction']}';
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getRealWeather() async {
    var url = Uri.http('localhost:8000', 'weather');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // 추가 필요
        },
        body: jsonEncode({
          'latitude': double.parse('$_latitude'),
          'longitude': double.parse('$_longitude'),
        }),
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      setState(() {
        _realTemp = '${jsonDecode(response.body)['temperature']}';
        _humidity = '${jsonDecode(response.body)['humidity']}';
        _windSpeed = '${jsonDecode(response.body)['wind_speed']}';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 위치 + 설정 아이콘
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: const TextStyle(
                        fontFamily: 'DoHyeon',
                        fontSize: 28,
                        color: Color(0xFF616161),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SettingScreen(
                                nickname:
                                    widget.profileData['nickname'] ?? '사용자',
                                profileImagePath:
                                    widget.profileData['profileImagePath'],
                              ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.settings,
                      size: 30,
                      color: Color(0xFF616161),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 체감 온도 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE26363),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'yyyy년 M월 d일',
                                  ).format(DateTime.now()),
                                  style: const TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.profileData['nickname'] ?? '사용자'} 님의\n체감 온도',
                                  style: const TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '$_feelTemp°C',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.thermostat,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$_realTemp°C',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$_humidity%',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(
                                  Icons.wind_power,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$_windSpeed m/s',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 적정 에어컨 온도 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF80BFF0),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'yyyy년 M월 d일',
                                  ).format(DateTime.now()),
                                  style: const TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '적정 에어컨 온도',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '26.0°C',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.group,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '4 명',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: const [
                                Icon(
                                  Icons.savings,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '552원 절약',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: const [
                                Icon(
                                  Icons.power,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '16.2 kWh',
                                  style: TextStyle(
                                    fontFamily: 'DoHyeon',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 개인 정보 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFDBE0E7), width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '개인 정보',
                          style: TextStyle(
                            fontFamily: 'DoHyeon',
                            fontSize: 22,
                            color: Color(0xFF000000),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ProfileCompletedScreen(),
                              ),
                            );
                            if (result != null &&
                                result is Map<String, String>) {
                              // No need for setState here, as MainScreen will be rebuilt with new data
                            }
                          },
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 2행 2열 그리드
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '성별 / 나이',
                                style: TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.profileData['genderAge'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '키 (cm)',
                                style: TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 14,
                                  color: Color(0xFF757577),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.profileData['height'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BMI',
                                style: TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.profileData['bmi'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '몸무게 (kg)',
                                style: TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.profileData['weight'] ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
