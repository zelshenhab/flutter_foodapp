import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

// Use the shared contract + real/mock services
import '../data/auth_service_contract.dart';
import '../../../core/api_client.dart'; // global dio to set Authorization header

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService service;
  Timer? _timer;

  AuthBloc(this.service) : super(const AuthState()) {
    super.on<AuthStarted>((e, emit) => emit(const AuthState()));

    super.on<AuthNameChanged>(
      (e, emit) => emit(state.copyWith(name: e.name, error: null)),
    );
    super.on<AuthEmailChanged>(
      (e, emit) => emit(state.copyWith(email: e.email, error: null)),
    );

    super.on<AuthRequestCodePressed>(_onRequestCode);

    super.on<AuthOtpChanged>(
      (e, emit) => emit(state.copyWith(otp: e.otp, error: null)),
    );

    super.on<AuthVerifyPressed>(_onVerify);
    super.on<AuthResendCode>(_onResend);

    super.on<AuthResendTick>(_onResendTick);
  }

  // Request OTP
  Future<void> _onRequestCode(
    AuthRequestCodePressed e,
    Emitter<AuthState> emit,
  ) async {
    if (!state.canGetCode) return;

    emit(state.copyWith(loading: true, error: null));
    
    try {
      final res = await service.requestCode(
        email: state.email,
        name: state.name.trim().isEmpty ? null : state.name.trim(),
      );

      emit(
        state.copyWith(
          loading: false,
          step: AuthStep.verifyOtp,
          codeSent: true,
          resendIn: 60,
          requestId: res.requestId, // required for /verify
          devCode: res.devCode, // handy in dev; ignore in prod UI
        ),
      );

      _startTimer();
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось отправить код'));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(AuthResendTick());
    });
  }

  void _onResendTick(AuthResendTick e, Emitter<AuthState> emit) {
    final current = state.resendIn;
    if (current <= 0) {
      _timer?.cancel();
      emit(state.copyWith(resendIn: 0));
      return;
    }
    final next = current - 1;
    if (next == 0) _timer?.cancel();
    emit(state.copyWith(resendIn: next));
  }

  // Resend OTP
  Future<void> _onResend(AuthResendCode e, Emitter<AuthState> emit) async {
    if (state.resendIn > 0 || state.loading) return;

    emit(state.copyWith(loading: true, error: null));
    try {
      final res = await service.requestCode(
        email: state.email,
        name: state.name,
      );

      emit(
        state.copyWith(
          loading: false,
          codeSent: true,
          resendIn: 60,
          requestId: res.requestId,
          devCode: res.devCode,
        ),
      );

      _startTimer();
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          codeSent: false,
          error: 'Не удалось отправить код',
        ),
      );
    }
  }

  // Verify OTP
Future<void> _onVerify(AuthVerifyPressed e, Emitter<AuthState> emit) async {
    if (!state.canVerify) return;
    if (state.requestId == null || state.requestId!.isEmpty) {
      emit(state.copyWith(error: 'Нет requestId. Получите код заново.'));
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final res = await service.verifyCode(
        email: state.email,
        requestId: state.requestId!,
        code: state.otp,
      );

      // ✅ Save tokens securely for future API calls
      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: res.accessToken);
      await storage.write(key: 'refresh_token', value: res.refreshToken);
      await storage.write(key: 'user_email', value: state.email);

      // ✅ Set Authorization header for the global dio instance (for immediate use)
      dio.options.headers['Authorization'] = 'Bearer ${res.accessToken}';

      debugPrint('✅ Token saved: ${res.accessToken.substring(0, 20)}...');

      _timer?.cancel();
      emit(
        state.copyWith(
          loading: false,
          step: AuthStep.success,
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: 'Неверный код'));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
