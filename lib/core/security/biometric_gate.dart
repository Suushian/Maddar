import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';
import 'package:madaar/core/utils/motion.dart';

/// قفل بیومتریک اختیاری؛ پیشفرض خاموش است و هیچ ثبتی را مسدود نمیکند.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _unlocked) {
      setState(() => _unlocked = false);
    }
  }

  Future<void> _authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      if (!await auth.isDeviceSupported()) {
        setState(() => _error = 'دستگاه از قفل بیومتریک پشتیبانی نمیکند');
        return;
      }
      final bool ok = await auth.authenticate(
        localizedReason: 'برای ورود به مدار هویت خود را تأیید کنید',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
        ),
      );
      await Haptics.success();
      if (mounted) {
        setState(() {
          _unlocked = ok;
          _error = ok ? null : 'تأیید نشد، دوباره تلاش کنید';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تأیید بیومتریک ممکن نشد');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SettingsRepository> repoAsync =
        ref.watch(settingsRepositoryProvider);
    return repoAsync.when(
      data: (SettingsRepository repo) => StreamBuilder<SettingsModel>(
        stream: repo.watch(),
        builder: (
          BuildContext context,
          AsyncSnapshot<SettingsModel> snapshot,
        ) {
          final bool enabled =
              snapshot.data?.biometricLockEnabled ?? false;
          if (!enabled || _unlocked) {
            return Motion.swap(
              context,
              widget.child,
              'gate-open-$enabled-$_unlocked',
            );
          }
          return Motion.swap(
            context,
            _LockScreen(error: _error, onUnlock: _authenticate),
            'gate-locked',
          );
        },
      ),
      loading: () => widget.child,
      error: (Object error, StackTrace stack) => widget.child,
    );
  }
}

class _LockScreen extends StatefulWidget {
  const _LockScreen({required this.onUnlock, this.error});

  final Future<void> Function() onUnlock;
  final String? error;

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onUnlock());
  }

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.brand(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Motion.pulse(
                context,
                Icon(Icons.fingerprint_rounded, size: 72, color: brand),
                id: 'lock-mark',
              ),
              const SizedBox(height: 20),
              Motion.entrance(
                context,
                Text(
                  'مدار قفل است',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                0,
                id: 'lock',
              ),
              const SizedBox(height: 8),
              Motion.entrance(
                context,
                const Text(
                  'برای دسترسی به دادههای روی دستگاه، هویت خود را تأیید کنید.',
                  textAlign: TextAlign.center,
                ),
                1,
                id: 'lock',
              ),
              if (widget.error != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  widget.error!,
                  style: TextStyle(color: AppColors.stone),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Motion.press(
                context,
                FilledButton.icon(
                  onPressed: widget.onUnlock,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('تأیید هویت'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
