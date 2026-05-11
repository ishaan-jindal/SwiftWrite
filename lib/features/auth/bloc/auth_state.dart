import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({
    required this.isPreparing,
    required this.isSignedIn,
    this.email,
  });

  final bool isPreparing;
  final bool isSignedIn;
  final String? email;

  AuthState copyWith({bool? isPreparing, bool? isSignedIn, String? email}) {
    return AuthState(
      isPreparing: isPreparing ?? this.isPreparing,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [isPreparing, isSignedIn, email];
}
