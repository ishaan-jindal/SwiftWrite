import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:writer/core/services/theme_service.dart';
import 'package:writer/features/settings/bloc/settings_event.dart';
import 'package:writer/features/settings/bloc/settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._themeService)
    : super(
        SettingsState(
          isDarkModePreferred: _themeService.isDarkModePreferred,
          isFallModeActive: _themeService.isFallModeActive,
        ),
      ) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsThemeToggled>(_onThemeToggled);
    on<SettingsFallThemeToggled>(_onFallThemeToggled);
  }

  final ThemeService _themeService;

  Future<void> _onLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(
      SettingsState(
        isDarkModePreferred: _themeService.isDarkModePreferred,
        isFallModeActive: _themeService.isFallModeActive,
      ),
    );
  }

  Future<void> _onThemeToggled(
    SettingsThemeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final nextIsDarkMode = !state.isDarkModePreferred;
    _themeService.setDarkModePreferred(nextIsDarkMode);
    emit(state.copyWith(isDarkModePreferred: nextIsDarkMode));
  }

  Future<void> _onFallThemeToggled(
    SettingsFallThemeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final nextFallState = !state.isFallModeActive;
    _themeService.setFallModeActive(nextFallState);
    emit(state.copyWith(isFallModeActive: nextFallState));
  }
}
