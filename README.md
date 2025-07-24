# 🌡️ Feeltemp App

## 📋 프로젝트 소개

**Feeltemp App**은 사용자의 프로필(닉네임, 생년월일, 성별, 키, 몸무게, 프로필 사진 등) 정보를 입력받고, 위치 기반 서비스를 제공하는 Flutter 기반 모바일 애플리케이션입니다. 직관적인 UI와 다양한 설정 기능을 통해 사용자 맞춤형 경험을 제공합니다.

## 🎯 주요 기능

- **프로필 등록 및 관리**
  - 닉네임, 생년월일, 성별, 키, 몸무게, 프로필 사진 입력 및 수정
- **위치 기반 서비스**
  - 현재 위치 정보 자동 표시(행정구역, 동네 등)
- **설정 화면**
  - 알림 설정, 버전 정보, 문의하기, 개인정보 처리방침, 서비스 이용약관, 로그아웃, 회원 탈퇴 등 다양한 환경설정 제공
- **다국어 지원**
  - 한국어, 영어 지원 (Flutter Localizations)

## 🖼️ 주요 화면

- **프로필 등록/수정 화면**: 앱 최초 실행 시 또는 프로필 변경 시 사용자 정보 입력
- **메인 화면**: 등록된 프로필 정보와 현재 위치 정보 표시
- **설정 화면**: 앱 환경설정 및 계정 관리

## 🗂️ 폴더 구조

```plaintext
feeltemp_app/
├── android/                # Android 플랫폼 관련 파일
├── assets/                 # 앱에서 사용하는 이미지 및 아이콘
├── fonts/                  # 커스텀 폰트
├── ios/                    # iOS 플랫폼 관련 파일
├── lib/                    # Dart 소스 코드
│   ├── main.dart                   # 앱 진입점 및 라우팅
│   ├── profile_completed_screen.dart # 프로필 등록/수정 화면
│   └── setting_screen.dart          # 설정 화면
├── linux/                  # Linux 플랫폼 관련 파일
├── macos/                  # macOS 플랫폼 관련 파일
├── test/                   # 테스트 코드
├── web/                    # 웹 지원 관련 파일
├── windows/                # Windows 플랫폼 관련 파일
├── pubspec.yaml            # 프로젝트 메타정보 및 의존성
└── README.md               # 프로젝트 설명 파일
```

## 🛠️ 기술 스택

- **Flutter** 3.8.1 이상
- **Dart** SDK
- **주요 패키지**
  - image_picker (이미지 선택)
  - geolocator, geocoding (위치 정보)
  - intl, flutter_localizations (다국어 지원)
  - cupertino_icons (iOS 스타일 아이콘)

## 🔧 설치 및 실행 방법

1. 저장소 클론
   ```bash
   git clone https://github.com/JongHyun070105/FeelTemp_App.git
   cd feeltemp_app
   ```
2. 패키지 설치
   ```bash
   flutter pub get
   ```
3. 앱 실행
   ```bash
   flutter run
   ```
   (Android/iOS 에뮬레이터 또는 실제 기기 필요)

## 📱 사용 방법

1. 앱을 실행하면 프로필 등록 화면이 나타납니다.
2. 닉네임, 생년월일, 성별, 키, 몸무게, 프로필 사진을 입력 후 완료하세요.
3. 메인 화면에서 내 정보와 현재 위치를 확인할 수 있습니다.
4. 우측 상단 또는 메뉴에서 설정 화면에 진입하여 다양한 환경설정을 할 수 있습니다.

## 🖼️ 리소스 및 디자인

- 다양한 아이콘 및 배경 이미지(assets 폴더)
- 커스텀 폰트(DoHyeon) 적용

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.
