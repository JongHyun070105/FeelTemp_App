import 'package:flutter/material.dart';
import 'dart:io'; // Add this import

class SettingScreen extends StatelessWidget {
  final String? nickname; // 닉네임 추가
  final String? profileImagePath; // 프로필 이미지 경로 추가

  const SettingScreen({super.key, this.nickname, this.profileImagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontFamily: 'DoHyeon',
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!)) as ImageProvider
                      : const AssetImage('assets/profile_placeholder.png'),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Text(
                  nickname ?? '사용자',
                  style: const TextStyle(
                    fontFamily: 'DoHyeon',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildSettingItem(context, '알림 설정', () {
            // Navigate to notification settings
          }),
          _buildSettingItem(context, '버전 정보', () {
            // Show version info dialog
          }),
          _buildSettingItem(context, '문의하기', () {
            // Navigate to contact us
          }),
          _buildSettingItem(context, '개인정보 처리방침', () {
            // Open privacy policy
          }),
          _buildSettingItem(context, '서비스 이용약관', () {
            // Open terms of service
          }),
          _buildSettingItem(context, '로그아웃', () {
            // Handle logout
          }),
          _buildSettingItem(context, '회원 탈퇴', () {
            // Handle account deletion
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'DoHyeon',
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.black,
          ),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          color: Color(0xFFE0E0E0),
        ), // Divider as per Figma
      ],
    );
  }
}
