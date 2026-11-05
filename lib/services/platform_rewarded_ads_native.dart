import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'rewarded_ad_session.dart';
import 'rewarded_ads.dart';

RewardedAdSource? createPlatformRewardedAds(RewardIdFactory ids) =>
    Platform.isAndroid ? GoogleTestRewardedAds(ids) : null;

/// Android spike adapter: Google sample IDs only, never a live ad unit.
class GoogleTestRewardedAds implements RewardedAdSource {
  GoogleTestRewardedAds(this._ids) {
    // UMP requires a fresh consent update on each app launch. Keep this single
    // future so tapping the ad cannot start a second request or show a second
    // form while the launch request is still in progress.
    if (kDebugMode) {
      _launchConsent = _requestConsent().onError(
        (_, _) async => ConsentInformation.instance.canRequestAds(),
      );
    }
  }

  static const testUnitId = 'ca-app-pub-3940256099942544/5224354917';
  final RewardIdFactory _ids;
  Future<bool>? _launchConsent;
  bool _busy = false;
  RewardedAd? _ad;

  @override
  AdPhase phase = AdPhase.idle;
  @override
  double get progress => 0;

  @override
  Future<AdOutcome> show(
    Future<void> Function(String rewardId) onEarned,
  ) async {
    if (_busy) return AdOutcome.busy;
    // Release builds must be configured with an owned app and unit before ads.
    if (!kDebugMode) return AdOutcome.error;
    _busy = true;
    phase = AdPhase.loading;
    try {
      final permitted = await (_launchConsent ?? _requestConsent());
      if (!permitted) return AdOutcome.error;
      await MobileAds.instance.initialize();
      final loaded = Completer<RewardedAd>();
      RewardedAd.load(
        adUnitId: testUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: loaded.complete,
          onAdFailedToLoad: (error) => loaded.completeError(error),
        ),
      );
      final ad = await loaded.future;
      _ad = ad;
      final session = RewardedAdSession(_ids.nextId(), onEarned);
      ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _ad = null;
          session.dismiss();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _ad = null;
          session.fail();
        },
      );
      phase = AdPhase.showing;
      ad.show(onUserEarnedReward: (ad, reward) => session.earn());
      final outcome = await session.result;
      phase = switch (outcome) {
        AdOutcome.earned => AdPhase.earned,
        AdOutcome.cancelled => AdPhase.cancelled,
        _ => AdPhase.error,
      };
      return outcome;
    } catch (_) {
      _ad?.dispose();
      _ad = null;
      phase = AdPhase.error;
      return AdOutcome.error;
    } finally {
      _busy = false;
    }
  }

  Future<bool> _requestConsent() async {
    final updated = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      updated.complete,
      (error) => updated.completeError(error),
    );
    await updated.future;
    final form = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error == null) {
        form.complete();
      } else {
        form.completeError(error);
      }
    });
    await form.future;
    return ConsentInformation.instance.canRequestAds();
  }

  @override
  void cancel() {
    // A shown native ad cannot be closed programmatically. Lifecycle inactive
    // may be caused by its fullscreen Activity; SDK callbacks decide reward.
  }
}
