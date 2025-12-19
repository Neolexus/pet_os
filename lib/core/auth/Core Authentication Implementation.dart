import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_health_companion/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:pet_health_companion/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:pet_health_companion/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:pet_health_companion/features/auth/domain/usecases/sign_in_with_apple.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;
  final FirebaseAuth firebaseAuth;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.firebaseAuth,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signInWithEmail.execute(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(firebaseAuth.currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Other event handlers...
}