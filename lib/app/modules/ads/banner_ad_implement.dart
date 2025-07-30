import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ca-app-pub-4922359332193574~7103087012
// android:value="ca-app-pub-3940256099942544~3347511713"/>
class RefreshableBannerAdWidget extends StatefulWidget {
  const RefreshableBannerAdWidget({super.key});

  @override
  _RefreshableBannerAdWidgetState createState() =>
      _RefreshableBannerAdWidgetState();
}

class _RefreshableBannerAdWidgetState extends State<RefreshableBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  Timer? _adRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    // _startAdRefreshTimer();

    // Dispose ad when navigating away
    Get.routing.obs.listen((_) {
      if (!Get.currentRoute.contains('CenterPage')) {
        _disposeAd();
      }
    });
  }
  // }

  void _startAdRefreshTimer() {
    _adRefreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      // _reloadBannerAd();
    });
  }

  void _loadBannerAd() {
    if (_bannerAd != null) return; // Prevent multiple loads

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741', // Test Ad Unit ID
      // adUnitId: 'ca-app-pub-4922359332193574/1199490813', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _reloadBannerAd() {
    _disposeAd();
    _isAdLoaded = false;
    _loadBannerAd();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  @override
  void dispose() {
    _adRefreshTimer?.cancel();
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded && _bannerAd != null
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : SizedBox(); // Placeholder for loading
  }
}
