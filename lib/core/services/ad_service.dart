import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad Unit IDs from Google documentation
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }

    // PRODUCTION IDs - Replace these with your actual Ad Unit IDs from the AdMob console
    if (Platform.isAndroid) {
      // TODO: Paste your real Android Banner Ad Unit ID below
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
      return 'ca-app-pub-2099964887845802/1795101155'; // Real Android Banner ID
    } else if (Platform.isIOS) {
      // TODO: Paste your real iOS Banner Ad Unit ID below
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
      return 'ca-app-pub-3940256099942544/2934735716'; // CURRENTLY USING TEST ID - Replace this!
    }

    return '';
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }

    // PRODUCTION IDs - Replace these with your actual Ad Unit IDs from the AdMob console
    if (Platform.isAndroid) {
      return 'ca-app-pub-2099964887845802/5411569078'; // Real Android Rewarded ID
    } else if (Platform.isIOS) {
      // TODO: Paste your real iOS Rewarded Ad Unit ID below
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
      return 'ca-app-pub-3940256099942544/1712485313'; // CURRENTLY USING TEST ID - Replace this!
    }

    return '';
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;
  bool _isAdShowing = false;
  int _rewardedRetryAttempt = 0;

  BannerAd? _preloadedBannerAd;
  bool _isPreloadingBanner = false;

  Future<void> init() async {
    developer.log('Initializing MobileAds...', name: 'ThoughtVault.Ads');
    await MobileAds.instance.initialize();
    loadRewardedAd();
    preLoadBannerAd();
  }

  void loadRewardedAd() {
    if (_isRewardedAdLoading || (_rewardedAd != null)) return;
    _isRewardedAdLoading = true;

    developer.log(
      'Loading rewarded ad: $rewardedAdUnitId (Attempt: ${_rewardedRetryAttempt + 1})',
      name: 'ThoughtVault.Ads',
    );

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log(
            'RewardedAd loaded successfully',
            name: 'ThoughtVault.Ads',
          );
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _rewardedRetryAttempt = 0;
        },
        onAdFailedToLoad: (error) {
          developer.log(
            'RewardedAd failed to load: ${error.message} (Code: ${error.code})',
            name: 'ThoughtVault.Ads',
          );
          _rewardedAd = null;
          _isRewardedAdLoading = false;

          // Exponential backoff for retries
          _rewardedRetryAttempt++;
          final retryDelay = Duration(
            seconds: (1 << _rewardedRetryAttempt).clamp(2, 60),
          );
          developer.log(
            'Retrying rewarded ad load in ${retryDelay.inSeconds}s',
            name: 'ThoughtVault.Ads',
          );
          Future.delayed(retryDelay, loadRewardedAd);
        },
      ),
    );
  }

  void preLoadBannerAd() {
    if (_isPreloadingBanner || _preloadedBannerAd != null) return;
    _isPreloadingBanner = true;

    developer.log('Pre-loading banner ad...', name: 'ThoughtVault.Ads');
    _preloadedBannerAd = createBannerAd(
      onAdLoaded: (ad) {
        developer.log('Pre-loaded banner ad ready', name: 'ThoughtVault.Ads');
        _isPreloadingBanner = false;
      },
      onAdFailedToLoad: (ad, error) {
        developer.log(
          'Pre-loaded banner ad failed: ${error.message}',
          name: 'ThoughtVault.Ads',
        );
        _isPreloadingBanner = false;
        _preloadedBannerAd = null;
      },
    )..load();
  }

  BannerAd? getPreloadedBannerAd() {
    final ad = _preloadedBannerAd;
    _preloadedBannerAd = null; // Consume the ad
    preLoadBannerAd(); // Start pre-loading the next one
    return ad;
  }

  void showRewardedAd({
    BuildContext? context,
    required VoidCallback onAdDismissed,
    required VoidCallback onUserEarnedReward,
  }) {
    if (_rewardedAd == null) {
      developer.log(
        'Warning: Rewarded ad not ready.',
        name: 'ThoughtVault.Ads',
      );
      onUserEarnedReward();
      loadRewardedAd();
      return;
    }

    if (_isAdShowing) {
      developer.log(
        'Warning: Ad is already showing.',
        name: 'ThoughtVault.Ads',
      );
      return;
    }

    // Optional user feedback before ad starts
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading Ad... Please wait a moment'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    _isAdShowing = true;
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        developer.log(
          'RewardedAd showed successfully',
          name: 'ThoughtVault.Ads',
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log('RewardedAd dismissed', name: 'ThoughtVault.Ads');
        ad.dispose();
        _rewardedAd = null;
        _isAdShowing = false;

        if (!rewardEarned) {
          onAdDismissed();
        }
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log(
          'RewardedAd failed to show: ${error.message}',
          name: 'ThoughtVault.Ads',
        );
        ad.dispose();
        _rewardedAd = null;
        _isAdShowing = false;
        onAdDismissed();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        developer.log(
          'User earned reward: ${reward.amount} ${reward.type}',
          name: 'ThoughtVault.Ads',
        );
        rewardEarned = true;

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reward Granted! You can now close the ad.'),
              backgroundColor: Colors.green,
            ),
          );
        }

        onUserEarnedReward();
      },
    );

    // Safety reset in case fullScreenContentCallback is never called (edge case)
    Future.delayed(const Duration(seconds: 60), () {
      if (_isAdShowing) {
        developer.log(
          'Safety reset: Ad was hanging.',
          name: 'ThoughtVault.Ads',
        );
        _isAdShowing = false;
      }
    });
  }

  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    );
  }
}
