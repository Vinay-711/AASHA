abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  LoginRequested({required this.phone, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String phone;
  final String password;
  RegisterRequested(
      {required this.name, required this.phone, required this.password});
}

class LogoutRequested extends AuthEvent {}
