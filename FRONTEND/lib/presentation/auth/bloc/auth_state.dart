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
  });

  bool get canGetCode =>
      name.trim().isNotEmpty && phone.trim().isNotEmpty && !loading;

  bool get canVerify =>
      otp.trim().length >= 4 && !loading;

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
    );
  }

  @override
  List<Object?> get props =>
      [name, surname, phone, otp, step, loading, error, resendIn, codeSent];
}
