import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import 'auth_service_contract.dart';

class RealAuthService implements IAuthService {
  @override
  Future<RequestOtpResult> requestCode({required String phone, String? name, String? surname}) async {
    final res = await dio.post('/auth/otp/request', data: {
      'phone': phone,
      if (name != null && name.isNotEmpty) 'name': name,
      if (surname != null && surname.isNotEmpty) 'surname': surname,
    });

    debugPrint('OTP REQUEST -> ${res.data}');
    
    final d = res.data as Map<String, dynamic>;
    return RequestOtpResult(
      requestId: d['requestId'] as String,
      ttl: (d['ttl'] as num).toInt(),
      devCode: d['devCode'] as String?,
    );
  }

  @override
  Future<VerifyOtpResult> verifyCode({required String phone, required String requestId, required String code}) async {
    final res = await dio.post('/auth/otp/verify', data: {
      'phone': phone, 'requestId': requestId, 'code': code,
    });
    final d = res.data as Map<String, dynamic>;
    return VerifyOtpResult(
      accessToken: d['accessToken'] as String,
      refreshToken: d['refreshToken'] as String,
      user: Map<String, dynamic>.from(d['user'] as Map),
    );
  }
}
