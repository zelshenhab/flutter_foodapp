class MockAuthService {
  // بيرجع true لو إرسال الكود نجح (هنعتبره دايمًا ناجح هنا)
  Future<bool> sendCodeToPhone(String phone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // تحقّق الكود — خليه 1234 أو 0000
  Future<bool> verifyCode(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return code == '1234';
  }
}
