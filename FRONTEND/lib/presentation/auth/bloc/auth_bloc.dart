import 'dart:async';
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
    super.on<AuthSurnameChanged>(
      (e, emit) => emit(state.copyWith(surname: e.surname, error: null)),
    );
    super.on<AuthPhoneChanged>(
      (e, emit) => emit(state.copyWith(phone: e.phone, error: null)),
    );

    super.on<AuthRequestCodePressed>(_onRequestCode);

    super.on<AuthOtpChanged>(
      (e, emit) => emit(state.copyWith(otp: e.otp, error: null)),
    );

    super.on<AuthVerifyPressed>(_onVerify);
    super.on<AuthResendCode>(_onResend);

    super.on<AuthResendTick>(_onResendTick);
    super.on<AuthEditPhone>(_onEditPhone);
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
        phone: state.phone,
        name: state.name.trim().isEmpty ? null : state.name.trim(),
        surname: state.surname.trim().isEmpty ? null : state.surname.trim(),
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
        phone: state.phone,
        name: state.name,
        surname: state.surname,
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
        phone: state.phone,
        requestId: state.requestId!,
        code: state.otp, // should be 6 digits (111111 in dev)
      );

      // Set token for subsequent requests
      dio.options.headers['Authorization'] = 'Bearer ${res.accessToken}';

      _timer?.cancel();
      emit(
        state.copyWith(
          loading: false,
          step: AuthStep.success,
          // You can add tokens/user to state if desired.
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Неверный код'));
    }
  }

  // Back to phone edit
  void _onEditPhone(AuthEditPhone e, Emitter<AuthState> emit) {
    _timer?.cancel();
    emit(
      state.copyWith(
        step: AuthStep.enterInfo,
        otp: '',
        error: null,
        resendIn: 0,
        requestId: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
