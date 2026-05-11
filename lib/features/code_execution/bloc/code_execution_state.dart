import 'package:equatable/equatable.dart';

enum CodeExecutionStatus { initial, loading, success, failure }

class CodeExecutionState extends Equatable {
  const CodeExecutionState({
    this.status = CodeExecutionStatus.initial,
    this.result,
    this.errorMessage,
    this.code,
    this.language,
  });

  final CodeExecutionStatus status;
  final Map<String, dynamic>? result;
  final String? errorMessage;
  final String? code;
  final String? language;

  bool get isLoading => status == CodeExecutionStatus.loading;

  CodeExecutionState copyWith({
    CodeExecutionStatus? status,
    Map<String, dynamic>? result,
    String? errorMessage,
    String? code,
    String? language,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CodeExecutionState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      code: code ?? this.code,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage, code, language];
}
