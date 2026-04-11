import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final (token, failure) =
          await repository.login(event.phone, event.password);
      if (failure != null) {
        emit(AuthError(failure.message));
      } else {
        emit(AuthAuthenticated(token!));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final (userId, failure) =
          await repository.register(event.name, event.phone, event.password);
      if (failure != null) {
        emit(AuthError(failure.message));
      } else {
        emit(AuthAuthenticated(userId ?? ''));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoggedOut());
    });
  }
}
