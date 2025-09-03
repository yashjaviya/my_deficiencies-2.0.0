import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdWidget extends StatefulWidget {
  final VoidCallback onAdRewarded; // Callback when reward is earned

  const RewardedAdWidget({super.key, required this.onAdRewarded});

  @override
  State<RewardedAdWidget> createState() => _RewardedAdWidgetState();
}

class _RewardedAdWidgetState extends State<RewardedAdWidget> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
  RewardedAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/5224354917',
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) {
        _rewardedAd = ad;
        _isAdLoaded = true;
        _showAd(); // 👈 Auto-show as soon as it's loaded
      },
      onAdFailedToLoad: (error) {
        print('Rewarded ad failed to load: $error');
      },
    ),
  );
}


  void _showAd() {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          widget.onAdRewarded(); // Call the callback when reward is earned
        },
      );
    } else {
      print('Ad not loaded yet');
      _loadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isAdLoaded ? _showAd : null,
      child: const Text('Load More Report'),
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}