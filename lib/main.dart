import 'package:feeltemp_app/profile_completed_screen.dart';
import 'package:feeltemp_app/setting_screen.dart'; // Import SettingScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      setState(() {
        _currentAddress = '위치 서비스를 활성화해주세요.';
      });
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        setState(() {
          _currentAddress = '위치 권한이 거부되었습니다.';
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _currentAddress = '위치 권한이 영구적으로 거부되었습니다.';
      });
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
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
        _currentAddress = '${place.locality ?? ''} ${place.thoroughfare ?? ''}';
      });
    } catch (e) {
      setState(() {
        _currentAddress = '위치 정보를 가져올 수 없습니다.';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 80.0,
          ), // Increased vertical padding
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
                        fontSize: 32,
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
                          builder: (context) => SettingScreen(
                            nickname: widget.profileData['nickname'] ?? '사용자',
                            profileImagePath:
                                widget.profileData['profileImagePath'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: const Icon(Icons.settings, color: Colors.black),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy년 M월 d일').format(DateTime.now()),
                      style: const TextStyle(
                        fontFamily: 'DoHyeon',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.profileData['nickname'] ?? '사용자'}님의 체감 온도',
                      style: TextStyle(
                        fontFamily: 'DoHyeon',
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '31°C',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 60,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.thermostat,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '34°C',
                              style: TextStyle(
                                fontFamily: 'DoHyeon',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '68%',
                              style: TextStyle(
                                fontFamily: 'DoHyeon',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.wind_power,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '2.1 m/s',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 개인 정보 카드
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFDBE0E7), width: 1),
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
                                builder: (context) =>
                                    const ProfileCompletedScreen(),
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
                                  color: Color(0xFF757575),
                                ),
                              ),
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
                    const SizedBox(height: 8),
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
              const SizedBox(height: 24),
              // 하단 두 개의 기능 버튼
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 실내 체감 온도 찾기 기능 연결
                      },
                      child: Container(
                        height: 170, // Increased height
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFDBE0E7),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Expanded(
                              child: Text(
                                '실내 체감 온도 찾기',
                                style: TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF141B34),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 적정 에어컨 온도 찾기 기능 연결
                      },
                      child: Container(
                        height: 170, // Increased height
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFDBE0E7),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Expanded(
                              child: Text(
                                '적정 에어컨 온도 찾기',
                                style: TextStyle(
                                  fontFamily: 'DoHyeon',
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF141B34),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
