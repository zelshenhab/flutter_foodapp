import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import 'auth_service_contract.dart';

class RealAuthService implements IAuthService {
  @override
  Future<RequestOtpResult> requestCode({
    required String email,
    String? name,
  }) async {
    final res = await dio.post('/auth/otp/request', data: {
      'email': email,
      if (name != null && name.isNotEmpty) 'name': name,
    });

    final d = res.data as Map<String, dynamic>;

    return RequestOtpResult(
      requestId: d['requestId'],
      ttl: d['ttl'],
      devCode: d['devCode'],
    );
  }

  @override
  Future<VerifyOtpResult> verifyCode({
    required String email,
    required String requestId,
    required String code,
  }) async {
    final res = await dio.post('/auth/otp/verify', data: {
      'email': email,
      'requestId': requestId,
      'code': code,
    });

    final d = res.data as Map<String, dynamic>;

    return VerifyOtpResult(
      accessToken: d['accessToken'],
      refreshToken: d['refreshToken'],
      user: Map<String, dynamic>.from(d['user']),
    );
  }
}
