import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthNameChanged extends AuthEvent {
  final String name;
  const AuthNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}


class AuthEmailChanged extends AuthEvent {
  final String email;
  const AuthEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}


class AuthRequestCodePressed extends AuthEvent {}

class AuthOtpChanged extends AuthEvent {
  final String otp;
  const AuthOtpChanged(this.otp);
  @override
  List<Object?> get props => [otp];
}

class AuthVerifyPressed extends AuthEvent {}

class AuthResendCode extends AuthEvent {}

class AuthResendTick extends AuthEvent {
  const AuthResendTick();
}

class AuthLogoutRequested extends AuthEvent {}

class AuthDeleteAccountRequested extends AuthEvent {}
