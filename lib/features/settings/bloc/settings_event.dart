import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

class SettingsThemeToggled extends SettingsEvent {
  const SettingsThemeToggled();
}

class SettingsFallThemeToggled extends SettingsEvent {
  const SettingsFallThemeToggled();
}
