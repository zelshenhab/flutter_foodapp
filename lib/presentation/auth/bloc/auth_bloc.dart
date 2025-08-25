import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/mock_auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockAuthService service;
  Timer? _timer;

  AuthBloc(this.service) : super(const AuthState()) {
    on<AuthStarted>((e, emit) => emit(const AuthState()));
    on<AuthNameChanged>((e, emit) => emit(state.copyWith(name: e.name, error: null)));
    on<AuthSurnameChanged>((e, emit) => emit(state.copyWith(surname: e.surname, error: null)));
    on<AuthPhoneChanged>((e, emit) => emit(state.copyWith(phone: e.phone, error: null)));
    on<AuthRequestCodePressed>(_onRequestCode);
    on<AuthOtpChanged>((e, emit) => emit(state.copyWith(otp: e.otp, error: null)));
    on<AuthVerifyPressed>(_onVerify);
    on<AuthResendCode>(_onResend);
    on<AuthEditPhone>(_onEditPhone);
  }

  Future<void> _onRequestCode(AuthRequestCodePressed e, Emitter<AuthState> emit) async {
    if (!state.canGetCode) return;
    emit(state.copyWith(loading: true, error: null));
    final ok = await service.sendCodeToPhone(state.phone);
    if (!ok) {
      emit(state.copyWith(loading: false, error: 'Не удалось отправить код'));
      return;
    }
    emit(state.copyWith(
      loading: false,
      step: AuthStep.verifyOtp,
      codeSent: true,
      resendIn: 60,
    ));
    _startTimer(emit);
  }

  void _startTimer(Emitter<AuthState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final v = state.resendIn - 1;
      if (v <= 0) {
        t.cancel();
        emit(state.copyWith(resendIn: 0));
      } else {
        emit(state.copyWith(resendIn: v));
      }
    });
  }

  Future<void> _onResend(AuthResendCode e, Emitter<AuthState> emit) async {
    if (state.resendIn > 0 || state.loading) return;
    emit(state.copyWith(loading: true, error: null));
    final ok = await service.sendCodeToPhone(state.phone);
    emit(state.copyWith(
      loading: false,
      codeSent: ok,
      resendIn: ok ? 60 : 0,
      error: ok ? null : 'Не удалось отправить код',
    ));
    if (ok) _startTimer(emit);
  }

  Future<void> _onVerify(AuthVerifyPressed e, Emitter<AuthState> emit) async {
    if (!state.canVerify) return;
    emit(state.copyWith(loading: true, error: null));
    final ok = await service.verifyCode(state.phone, state.otp);
    if (!ok) {
      emit(state.copyWith(loading: false, error: 'Неверный код'));
      return;
    }
    emit(state.copyWith(loading: false, step: AuthStep.success));
  }

  void _onEditPhone(AuthEditPhone e, Emitter<AuthState> emit) {
    emit(state.copyWith(step: AuthStep.enterInfo, otp: '', error: null));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
