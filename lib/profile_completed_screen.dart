import 'package:feeltemp_app/main.dart'; // MainScreen을 사용하기 위해 추가
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart'; // CupertinoDatePicker를 위해 추가
import 'package:intl/intl.dart'; // DateFormat을 위해 추가
import 'package:flutter/services.dart'; // FilteringTextInputFormatter를 위해 추가

class ProfileCompletedScreen extends StatefulWidget {
  final Function(Map<String, String>)? onCompleted;
  const ProfileCompletedScreen({super.key, this.onCompleted});

  @override
  State<ProfileCompletedScreen> createState() => _ProfileCompletedScreenState();
}

class _ProfileCompletedScreenState extends State<ProfileCompletedScreen> {
  final _formKey = GlobalKey<FormState>(); // Form Key 추가
  DateTime? _selectedDate; // 생일 선택을 위한 변수
  String? _selectedGender; // 성별 선택을 위한 변수
  final TextEditingController _nicknameController =
      TextEditingController(); // 닉네임 입력 컨트롤러
  final TextEditingController _heightController =
      TextEditingController(); // 키 입력 컨트롤러
  final TextEditingController _weightController =
      TextEditingController(); // 몸무게 입력 컨트롤러
  File? _profileImage; // 프로필 이미지 파일
  String? _heightErrorText; // 키 입력 오류 메시지
  String? _weightErrorText; // 몸무게 입력 오류 메시지

  Future<void> _selectDate(BuildContext context) async {
    DateTime? tempPickedDate = _selectedDate; // 임시로 선택된 날짜 저장

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate ?? DateTime.now(),
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
              // 확인 버튼 추가
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (tempPickedDate != null &&
                      tempPickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = tempPickedDate;
                    });
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenderPicker(BuildContext context) {
    final List<String> genders = ['남자', '여자'];
    String? tempSelectedGender = _selectedGender;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: genders.indexOf(tempSelectedGender ?? ''),
                  ),
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    tempSelectedGender = genders[index];
                  },
                  children: List<Widget>.generate(genders.length, (int index) {
                    return Center(
                      child: Text(
                        genders[index],
                        style: const TextStyle(
                          fontFamily: 'DoHyeon',
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (tempSelectedGender != null &&
                      tempSelectedGender != _selectedGender) {
                    setState(() {
                      _selectedGender = tempSelectedGender;
                    });
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _calculateBmi() {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return 'N/A';
    }

    final double bmi = weight / ((height / 100) * (height / 100));
    return bmi.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.65, // 배경 이미지 높이 65%로 변경
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // White Container for Profile Info
          Positioned(
            top: screenHeight * 0.10, // 사각형을 더 위로 올림
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: screenWidth * 0.9, // 좌우 패딩 효과를 위해 너비 조정
                height: screenHeight * 0.7, // 높이 조정 (이미지 걸치기 위해 0.7로 줄임)
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ), // 모든 모서리 둥글게
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: [
                            Transform.translate(
                              offset: Offset(0, -screenWidth * 0.1),
                              child: Container(
                                width: screenWidth * 0.3,
                                height: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                            'assets/profile_placeholder.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    _showImageSourceActionSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        _buildInputField(
                          context,
                          '닉네임',
                          '닉네임을 입력하세요',
                          controller: _nicknameController,
                        ),
                        SizedBox(height: 8),
                        _buildInputField(
                          context,
                          '생일',
                          _selectedDate == null
                              ? 'YYYY/MM/DD'
                              : DateFormat(
                                  'yyyy년 M월 d일',
                                  'ko_KR',
                                ).format(_selectedDate!),
                          onTap: () => _selectDate(context),
                          readOnly: true,
                          isDateSelected: _selectedDate != null,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInputField(
                          context,
                          '성별',
                          _selectedGender ?? '선택하세요',
                          onTap: () => _showGenderPicker(context),
                          readOnly: true,
                          isGenderSelected: _selectedGender != null,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                context,
                                '키 (cm)',
                                '',
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                errorText: _heightErrorText,
                                onChanged: (value) {
                                  final int? height = int.tryParse(value);
                                  setState(() {
                                    if (height != null && height > 200) {
                                      _heightErrorText = '200 이하로 입력해주세요.';
                                    } else {
                                      _heightErrorText = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildInputField(
                                context,
                                '몸무게 (kg)',
                                '',
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                errorText: _weightErrorText,
                                onChanged: (value) {
                                  final int? weight = int.tryParse(value);
                                  setState(() {
                                    if (weight != null && weight > 200) {
                                      _weightErrorText = '200 이하로 입력해주세요.';
                                    } else {
                                      _weightErrorText = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90, // Adjust as needed
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null &&
                      _selectedGender != null &&
                      _heightErrorText == null &&
                      _weightErrorText == null) {
                    final profileData = {
                      'nickname': _nicknameController.text,
                      'genderAge':
                          '${_selectedGender ?? ''}, ${_selectedDate != null ? '${DateTime.now().year - _selectedDate!.year}세' : ''}',
                      'height': _heightController.text,
                      'weight': _weightController.text,
                      'bmi': _calculateBmi(),
                      'profileImagePath': _profileImage?.path ?? '',
                    };
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MainScreen(profileData: profileData),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('모든 정보를 입력해주세요.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.2,
                    vertical: 15,
                  ),
                  elevation: 5,
                  shadowColor: Color.fromRGBO(0, 0, 0, 0.08),
                ),
                child: const Text(
                  '바로 시작하기',
                  style: TextStyle(
                    fontFamily: 'DoHyeon',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String label,
    String hintText, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    bool readOnly = false,
    bool isDateSelected = false,
    bool isGenderSelected = false, // 성별 선택 여부를 나타내는 새로운 매개변수
    Widget? suffixIcon, // 새로운 매개변수 추가
    String? errorText, // errorText 추가
    ValueChanged<String>? onChanged, // onChanged 추가
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DoHyeon',
            fontSize: 20,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged, // onChanged 적용
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null, // 숫자만 입력 가능하도록 추가
          maxLength: null, // maxLength 제거
          decoration: InputDecoration(
            errorText: errorText, // errorText 적용
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'DoHyeon',
              color: (isDateSelected || isGenderSelected)
                  ? const Color(0xFF000000)
                  : const Color(0xFFB0B3C7),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB0B3C7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB0B3C7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            suffixIcon: suffixIcon, // suffixIcon 추가
            counterText: "", // 카운터 텍스트 제거
          ),
          style: const TextStyle(
            fontFamily: 'DoHyeon',
            fontSize: 18,
            color: Color(0xFF000000),
          ),
        ),
      ],
    );
  }
}
