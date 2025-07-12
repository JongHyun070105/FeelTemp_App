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
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 전체 배경 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.7, // 화면 높이의 70%
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              // 상단 공간 (프로필 이미지 위치용)
              SizedBox(
                height: screenHeight * 0.2, // 0.25에서 0.2로 조정
                width: screenWidth,
              ),
              // 폼 영역
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ), // 좌우 하단 마진 추가
                  decoration: BoxDecoration(
                    color: Colors.white, // #fff 흰색
                    borderRadius: BorderRadius.circular(20), // 전체 모서리 둥글게
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40), // 프로필 이미지 공간 줄임
                          _buildInputField(
                            context,
                            '닉네임',
                            '닉네임을 입력하세요',
                            controller: _nicknameController,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
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
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            context,
                            '성별',
                            _selectedGender ?? '선택하세요',
                            onTap: () => _showGenderPicker(context),
                            readOnly: true,
                            isGenderSelected: _selectedGender != null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
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
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // 바로 시작하기 버튼
                          ElevatedButton(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              backgroundColor: const Color(0xFF000000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              '바로 시작하기',
                              style: TextStyle(
                                fontFamily: 'DoHyeon',
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // 하단 여백
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 프로필 이미지 - 별도 위젯으로 분리하여 최상단에 배치
          Positioned(
            top: screenHeight * 0.2 - 50, // 조정된 위치에 맞춰 수정
            left: screenWidth / 2 - 50,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/profile_placeholder.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF616161),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
  bool isGenderSelected = false,
  Widget? suffixIcon,
  String? errorText,
  ValueChanged<String>? onChanged,
  TextInputAction? textInputAction,
  ValueChanged<String>? onFieldSubmitted,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'DoHyeon',
          fontSize: 18,
          color: Color(0xFF000000),
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          errorText: errorText,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'DoHyeon',
            fontSize: 16,
            color: (isDateSelected || isGenderSelected)
                ? const Color(0xFF000000)
                : const Color(0xFFB0B3C7),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0B3C7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0B3C7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
          counterText: "",
        ),
        style: const TextStyle(
          fontFamily: 'DoHyeon',
          fontSize: 16,
          color: Color(0xFF000000),
        ),
        validator: (value) {
          if (label == '닉네임' && (value == null || value.isEmpty)) {
            return '닉네임을 입력해주세요.';
          }
          return null;
        },
      ),
    ],
  );
}
