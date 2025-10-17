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

class AuthSurnameChanged extends AuthEvent {
  final String surname;
  const AuthSurnameChanged(this.surname);
  @override
  List<Object?> get props => [surname];
}

class AuthPhoneChanged extends AuthEvent {
  final String phone;
  const AuthPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
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

class AuthEditPhone extends AuthEvent {}

class AuthResendTick extends AuthEvent {
  const AuthResendTick();
}
