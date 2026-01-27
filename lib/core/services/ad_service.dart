import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  void loadRewardedAd() {
    if (_isRewardedAdLoading) return;
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
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
      debugPrint('Warning: Rewarded ad not ready. Proceeding without ad.');
      onUserEarnedReward();
      loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
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
