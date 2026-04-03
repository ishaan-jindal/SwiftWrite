import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writer/data/services/feature_gate_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _cloudEnabledDraft;
  late bool _initialCloudEnabled;
  late final FeatureGateService _featureGateService;

  @override
  void initState() {
    super.initState();
    _featureGateService = Get.find<FeatureGateService>();
    _initialCloudEnabled = _featureGateService.isCloudEnabledMode;
    _cloudEnabledDraft = _initialCloudEnabled;
  }

  bool get _hasChanges => _cloudEnabledDraft != _initialCloudEnabled;

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasChanges) {
      return true;
    }

    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved mode changes. Do you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep Editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    return discard == true;
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) {
      Get.back();
      return;
    }

    final targetMode = _cloudEnabledDraft
        ? AppMode.cloudEnabled
        : AppMode.offlineOnly;

    await _featureGateService.setAppMode(targetMode);
    _initialCloudEnabled = _cloudEnabledDraft;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cloudEnabledDraft
                ? 'Cloud-enabled mode saved.'
                : 'Offline-only mode saved.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Get.back();
  }

  Future<void> _onBackPressed() async {
    final bool canLeave = await _confirmDiscardChanges();
    if (canLeave && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _onBackPressed();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _onBackPressed,
            ),
            actions: [
              TextButton(
                onPressed: _hasChanges ? _saveChanges : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: _hasChanges ? colorScheme.primary : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Offline-only keeps everything local. Cloud-enabled adds sign-in, sync, and internet features.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Cloud Features'),
                        subtitle: Text(
                          _cloudEnabledDraft
                              ? 'Will be enabled when saved'
                              : 'Will stay disabled when saved',
                        ),
                        value: _cloudEnabledDraft,
                        onChanged: (value) {
                          setState(() {
                            _cloudEnabledDraft = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _featureGateService.isCloudEnabledMode
                            ? 'Cloud-enabled mode is active. Internet features are available.'
                            : 'Offline-only mode is active. Internet features are disabled.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _hasChanges
                    ? 'You have unsaved changes. Tap Save to apply them.'
                    : 'No changes to save.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _hasChanges ? _saveChanges : null,
                  child: const Text('Save Changes'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
