import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ca-app-pub-4922359332193574~7103087012
// android:value="ca-app-pub-3940256099942544~3347511713"/>
class RefreshableBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize size;

  const RefreshableBannerAdWidget({
    super.key,
    required this.adUnitId,
    this.size = AdSize.banner,
  });

  @override
  _RefreshableBannerAdWidgetState createState() =>
      _RefreshableBannerAdWidgetState();
}

class _RefreshableBannerAdWidgetState extends State<RefreshableBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
