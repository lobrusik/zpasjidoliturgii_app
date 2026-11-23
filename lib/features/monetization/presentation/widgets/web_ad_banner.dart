import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class WebAdBanner extends StatefulWidget {
  const WebAdBanner({super.key});

  @override
  State<WebAdBanner> createState() => _WebAdBannerState();
}

class _WebAdBannerState extends State<WebAdBanner> {
  late final String _viewType;

  // PODMIEŃ NA SWOJE DANE Z PANELU GOOGLE ADSENSE:
  static const String _adClient = 'ca-pub-TWOJ_NUMER_ADSENSE';
  static const String _adSlot = 'TWOJ_NUMER_SLOTU';

  @override
  void initState() {
    super.initState();
    _viewType = 'adsense-banner-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = web.HTMLDivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center'
        ..style.overflow = 'hidden';

      final ins = web.document.createElement('ins') as web.HTMLElement
        ..className = 'adsbygoogle'
        ..style.display = 'inline-block'
        ..style.width = '100%'
        ..style.height = '60px';

      ins.setAttribute('data-ad-client', _adClient);
      ins.setAttribute('data-ad-slot', _adSlot);

      final script = web.document.createElement('script') as web.HTMLScriptElement
        ..text = '(adsbygoogle = window.adsbygoogle || []).push({});';

      container.appendChild(ins);
      container.appendChild(script);

      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}