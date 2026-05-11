import 'package:equatable/equatable.dart';

abstract class CodeExecutionEvent extends Equatable {
  const CodeExecutionEvent();

  @override
  List<Object?> get props => [];
}

class CodeExecutionRequested extends CodeExecutionEvent {
  const CodeExecutionRequested({
    required this.code,
    required this.language,
    this.inputs = const [''],
  });

  final String code;
  final String language;
  final List<String> inputs;

  @override
  List<Object?> get props => [code, language, inputs];
}

class CodeExecutionReset extends CodeExecutionEvent {
  const CodeExecutionReset();
}
