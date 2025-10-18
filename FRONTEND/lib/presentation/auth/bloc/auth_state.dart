import 'package:equatable/equatable.dart';

enum AuthStep { enterInfo, verifyOtp, success, authorized }

class AuthState extends Equatable {
  final String name;
  final String surname;
  final String phone;
  final String otp;

  final AuthStep step;

  final bool loading;
  final String? error;

  final int resendIn; // ثواني حتى إعادة الإرسال
  final bool codeSent;

  // 🆕 added for backend OTP flow
  final String? requestId;
  final String? devCode;

  const AuthState({
    this.name = '',
    this.surname = '',
    this.phone = '',
    this.otp = '',
    this.step = AuthStep.enterInfo,
    this.loading = false,
    this.error,
    this.resendIn = 0,
    this.codeSent = false,
    this.requestId,
    this.devCode,
  });

  bool get canGetCode =>
      name.trim().isNotEmpty && phone.trim().isNotEmpty && !loading;

  bool get canVerify => otp.trim().length >= 6 && !loading;

  AuthState copyWith({
    String? name,
    String? surname,
    String? phone,
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
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
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
        surname,
        phone,
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
