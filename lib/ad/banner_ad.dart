import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidget();
}

class _BannerAdWidget extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: dotenv.env['BANNER_AD_UNIT_ID']!,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAdReady = false;
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: isBannerAdReady ? AdWidget(ad: _bannerAd) : const SizedBox(),
    );
  }
}