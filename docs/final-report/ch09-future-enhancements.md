# Chapter 9: Future Enhancements

## 9.1 Approach

This chapter sets out the capabilities the team would build next, given more time or a continuation of the project beyond the academic timeline.

It is deliberately forward-looking. Work that is outstanding rather than new is stated in Chapter 10, alongside the assessment of what was delivered. That covers specified functionality not yet completed, verification not yet performed, and operational maturity deferred by choice. The present chapter can therefore be read as a roadmap rather than as a defect list.

Each enhancement below states what already exists in the delivered system, so that the size of the remaining work is visible rather than implied, and each was checked against the codebase before being described as a gap rather than as something partially built.

## 9.2 Machine-Learning GPS Gap-Filling

A concrete limitation observed in use: tracking degrades when a runner passes through a tunnel, an underpass or another location where the GPS signal is lost outright. Continuous location capture fails, and the recorded route and distance are affected for that segment.

This connects directly to risk R1 in the project's own register, whose stated mitigation was Kalman filtering and outlier rejection. Those techniques smooth noise around a signal that is still present; they do nothing for a signal that has disappeared. A predictive gap-filling model would interpolate a plausible path across the gap from entry heading, exit position, elapsed time and step cadence from the motion sensor. That is the natural step beyond that mitigation, and cadence is already captured natively on both platforms, so the input exists.

Verified against the codebase: no prediction or interpolation model exists, so this is genuine future work rather than something partially built. Interpolated segments must be distinguishable from measured ones before they are allowed to contribute to distance, experience or leaderboard score.

## 9.3 Cosmetic Marketplace for Runner Characters

The character system is delivered and working. It offers several runner variants with directional and idle sprite sets, chosen during onboarding and displayed on the home dashboard, with premium variants already gated. There is no way to unlock or acquire further variants.

A cosmetic marketplace layered on the existing system would let users unlock alternate costumes and skins, tied to experience milestones, challenge rewards or a small purchase. It extends a shipped feature rather than inventing a new one, and gives Premium a further status-expression avenue.

The important property is that it must remain **strictly cosmetic**. Runiac's central commercial and design claim is that Premium confers no competitive advantage, and a marketplace granting any experience, ranking or scoring effect would break that claim and with it the credibility of the leaderboard. A cosmetic-only marketplace is compatible with the fairness constraint.

## 9.4 A Standalone Route Library

F7 is delivered through the Activity Feed: a runner publishes a completed run and every other runner sees its route. What the earlier documents also described, and what was not built, is a separate library in which routes can be browsed, searched by region or difficulty, saved and followed. The `sharedRoutes` collection and its security rules exist, and so do the browsing screens, but the collection stores no coordinates and the screens are not wired into navigation.

Completing it needs three things: route geometry on the shared-route document, coarsened the same way the feed preview already is; a publication path that moves a route from draft to published, since the rules already describe the states; and a navigation entry point. The privacy work is already done, which is what makes this smaller than it looks. It would give a beginner a way to find a suitable route before setting out, rather than only seeing where others have already run.

## 9.5 Multi-Level and Multi-Region Leaderboards

The delivered leaderboard is single-level: Singapore planning areas, monthly. The original design described zooming from country through city to neighbourhood, and a weekly cadence alongside the monthly one. Both are extensions of the existing aggregation rather than redesigns. The aggregator already groups by region and division under a lease, so additional levels are additional groupings, and a weekly period is a second period key. Geographic expansion beyond Singapore requires a region model for the new territory, which is data rather than architecture.
