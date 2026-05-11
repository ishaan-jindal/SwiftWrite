import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:writer/core/services/code_execution_service.dart';
import 'package:writer/features/code_execution/bloc/code_execution_event.dart';
import 'package:writer/features/code_execution/bloc/code_execution_state.dart';

@injectable
class CodeExecutionBloc extends Bloc<CodeExecutionEvent, CodeExecutionState> {
  CodeExecutionBloc() : super(const CodeExecutionState()) {
    on<CodeExecutionRequested>(_onRequested);
    on<CodeExecutionReset>(_onReset);
  }

  final CodeExecutionService _service = CodeExecutionService();

  Future<void> _onRequested(
    CodeExecutionRequested event,
    Emitter<CodeExecutionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CodeExecutionStatus.loading,
        clearResult: true,
        clearError: true,
        code: event.code,
        language: event.language,
      ),
    );

    try {
      final result = await _service.executeCode(
        code: event.code,
        language: event.language,
        inputs: event.inputs,
      );

      emit(
        state.copyWith(
          status: CodeExecutionStatus.success,
          result: result,
          code: event.code,
          language: event.language,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CodeExecutionStatus.failure,
          errorMessage: error.toString(),
          clearResult: true,
          code: event.code,
          language: event.language,
        ),
      );
    }
  }

  Future<void> _onReset(
    CodeExecutionReset event,
    Emitter<CodeExecutionState> emit,
  ) async {
    emit(const CodeExecutionState());
  }
}
