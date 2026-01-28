import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/views/main_screen.dart';
import '../../../../core/services/force_update_service.dart';
import '../../../../core/widgets/force_update_view.dart';
import '../views/login_view.dart';
import '../views/splash_view.dart';
import '../views/introduction_view.dart';
import '../providers/onboarding_provider.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  UpdateStatus _updateStatus = UpdateStatus.latest;
  bool _isLoadingVersion = true;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    final results = await Future.wait([
      ForceUpdateService().checkVersion(),
      Future.delayed(const Duration(seconds: 5)),
    ]);
    final status = results.first as UpdateStatus;

    if (mounted) {
      setState(() {
        _updateStatus = status;
        _isLoadingVersion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingVersion) {
      // Keep showing splash while checking version + auth
      return const SplashView();
    }

    if (_updateStatus == UpdateStatus.updateRequired) {
      return const ForceUpdateView();
    }

    if (_updateStatus == UpdateStatus.optionalUpdate) {
      return ForceUpdateView(
        allowSkip: true,
        onSkip: () {
          setState(() {
            _updateStatus = UpdateStatus.latest;
          });
        },
      );
    }

    final hasSeenOnboarding = ref.watch(onboardingProvider);

    if (!hasSeenOnboarding) {
      return const IntroductionView();
    }

    return StreamBuilder<User?>(
      stream: AuthService().onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        return const LoginView();
      },
    );
  }
}
