import 'auth_service_contract.dart';

class MockAuthService implements IAuthService {
  @override // بيرجع true لو إرسال الكود نجح (هنعتبره دايمًا ناجح هنا)
  Future<RequestOtpResult> requestCode({required String phone, String? name, String? surname}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return RequestOtpResult(requestId: 'mock-id', ttl: 120, devCode: '111111');
  }

@override
  // تحقّق الكود — خليه 1234 أو 0000
  Future<VerifyOtpResult> verifyCode({required String phone, required String requestId, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return VerifyOtpResult(accessToken: 'MOCK_TOKEN', refreshToken: 'MOCK_REFRESH', user: {'id': 1, 'phone': phone});
  }
}
