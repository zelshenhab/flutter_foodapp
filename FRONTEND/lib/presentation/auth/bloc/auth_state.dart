import 'package:equatable/equatable.dart';

enum AuthStep { enterInfo, verifyOtp, success, authorized }

class AuthState extends Equatable {
  final String name;
  final String email; // ✅ changed
  final String otp;

  final AuthStep step;
  final bool loading;
  final String? error;

  final int resendIn;
  final bool codeSent;

  final String? requestId;
  final String? devCode;

  const AuthState({
    this.name = '',
    this.email = '', // ✅ changed
    this.otp = '',
    this.step = AuthStep.enterInfo,
    this.loading = false,
    this.error,
    this.resendIn = 0,
    this.codeSent = false,
    this.requestId,
    this.devCode,
  });

  bool get hasValidEmail =>
      email.trim().isNotEmpty && email.contains('@');

  /// Email is enough to request OTP (name is optional for returning users).
  bool get canGetCode => hasValidEmail && !loading;

  bool get canVerify => otp.trim().length >= 6 && !loading;

  AuthState copyWith({
    String? name,
    String? email,
    String? otp,
    AuthStep? step,
    bool? loading,
    String? error,
    int? resendIn,
    bool? codeSent,
    String? requestId,
    String? devCode,
  }) {
    return AuthState(
      name: name ?? this.name,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error,
      resendIn: resendIn ?? this.resendIn,
      codeSent: codeSent ?? this.codeSent,
      requestId: requestId ?? this.requestId,
      devCode: devCode ?? this.devCode,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        otp,
        step,
        loading,
        error,
        resendIn,
        codeSent,
        requestId,
        devCode,
      ];
}
