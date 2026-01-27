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

  Future<void> init() async {
    developer.log('Initializing MobileAds...', name: 'ThoughtVault.Ads');
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  void loadRewardedAd() {
    if (_isRewardedAdLoading) return;
    _isRewardedAdLoading = true;

    developer.log(
      'Loading rewarded ad: $rewardedAdUnitId',
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
        },
        onAdFailedToLoad: (error) {
          developer.log(
            'RewardedAd failed to load: ${error.message} (Code: ${error.code})',
            name: 'ThoughtVault.Ads',
          );
          _rewardedAd = null;
          _isRewardedAdLoading = false;
        },
      ),
    );
  }

  void showRewardedAd({
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

        // Only call dismissed if reward wasn't already handled
        // or let the UI handle the state.
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
        onUserEarnedReward();
      },
    );
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
