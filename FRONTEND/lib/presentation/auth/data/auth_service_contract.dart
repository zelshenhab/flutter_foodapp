class RequestOtpResult {
  final String requestId;
  final int ttl;
  final String? devCode;
  RequestOtpResult({required this.requestId, required this.ttl, this.devCode});
}

class VerifyOtpResult {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;
  VerifyOtpResult({required this.accessToken, required this.refreshToken, required this.user});
}

abstract class IAuthService {
  Future<RequestOtpResult> requestCode({
    required String email,
    String? name,
  });

  Future<VerifyOtpResult> verifyCode({
    required String email,
    required String requestId,
    required String code,
  });
}

