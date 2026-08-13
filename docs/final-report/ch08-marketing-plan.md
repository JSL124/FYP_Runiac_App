# Chapter 8: Marketing Plan

*This chapter is the second version of the business model material from Section 4 of the Project Requirements Document and Sections 2.6 to 2.8 of the Preliminary Technical Document. Pricing and tier allocation are stated as configured in the delivered system rather than as proposed.*

## 8.1 Product Positioning

Runiac is positioned at a point in the running journey that the market serves thinly: the weeks between deciding to run and actually being a runner. The competitive analysis in Chapter 1 found the category split cleanly in two. Casual and social applications (Strava, Nike Run Club, Runkeeper) are easy to start with, but they offer weak retention mechanics for someone with no established habit. Data-driven athlete tools such as Whoop and Garmin Connect offer powerful analysis. They also require expensive hardware and presuppose a user who already knows how to read that analysis.

Tracking is table stakes, so the proposition is not "a better running tracker". The claim Runiac makes is that the application is built around behaviour change, and that everything in it is designed for a person who has not yet formed the habit.

Five characteristics carry that positioning, and all five are delivered rather than aspirational.

**Competition a beginner can actually win.** The level-based territorial leaderboard ranks a runner within their own planning area and their own league division, so the comparison is against people at a similar stage in a familiar place, rather than against the whole population. A beginner therefore sees a rank they could plausibly improve.

**Progress made visible before it is physically visible.** The experience and level system converts showing up (completing a run, following the plan, maintaining a streak) into something that moves. This matters most in the first month, precisely when fitness gains are too small to feel.

**Metrics translated rather than displayed.** Post-run feedback is written in plain language rather than presented as a table of numbers, so a user with no training background learns something from each run instead of scrolling past figures they cannot interpret.

**Safety built into the plan rather than bolted on.** Onboarding collects health and readiness information and resolves it into a safety band that constrains the generated plan. A beginner who declares a health consideration receives a more conservative progression than one who does not.

**Smartphone-first, with no hardware requirement.** Every core feature works on the phone alone. This is a direct answer to the cost barrier that excludes price-sensitive beginners from Whoop and Garmin. The absence of a hardware requirement is a deliberate positioning choice rather than a limitation.

## 8.2 Target Market

The primary market is people attempting to establish a running habit: beginners with little or no running background, and returning runners rebuilding after a break. What characterises these users is the fragility of their motivation rather than their fitness level. They are the segment most likely to stop within four weeks.

The secondary market is runners who have established consistency and are working toward a first distance milestone: a 5 km, 10 km, half marathon or marathon. This segment is where the paid tier finds most of its value, because a concrete goal creates willingness to pay for structured support.

The initial geography is Singapore. This is not incidental: the leaderboard's regional model is built on Singapore planning areas, so the competitive feature is only meaningful within that market at launch. Expanding geographically requires a region model for the new territory, which Chapter 9 records as future work.

## 8.3 Business Model

Runiac adopts a **freemium subscription model**. The free tier carries the complete beginner running experience and all core habit-building functionality; the paid tier adds interpretation, goal preparation, AI-assisted guidance and presentation value.

The model follows from the product's purpose. Runiac's objective is to help non-runners become consistent runners. Placing activity tracking, reminders, streaks, experience progression or leaderboard participation behind a paywall would work directly against that objective. It would price out the users the product exists to serve, at exactly the moment they are most likely to quit. Those features therefore remain free permanently, not as a trial.

Revenue comes instead from value that does not compromise the mission: deeper interpretation for users ready for it, milestone-oriented plans for users with a goal, AI-assisted feedback, and presentation features.

## 8.4 Pricing

### 8.4.1 Price as currently configured

The prices below are those configured in the delivered system. They appear on the public pricing page and in the in-application paywall, which read from the same configuration values so that the two cannot drift apart.

| Tier | Name | Price | Positioning |
| --- | --- | --- | --- |
| Free | Core | **S$0** | "Start building consistency" |
| Premium (monthly) | More guidance | **S$5.99 / month** | Full guidance tier, cancel any time |
| Premium (annual) | More guidance | **S$49.99 / year** | About S$4.17 per month (roughly 30% saving) |

*Table 8.1: Pricing as configured in the delivered system*

The sections below derive a price from first principles and check the configured figure against it. The derivation is done two ways: bottom-up from what a Premium user actually costs to serve, and top-down against competitor anchors. Either method alone is misleading for a pre-launch product.

### 8.4.2 Competitor price anchors

| Competitor | Pricing | Where Runiac differs |
| --- | --- | --- |
| Strava | Freemium, paid tier approximately US$8–12 / month | Strava's competitive layer of segments and global leaderboards is intimidating for a true beginner. Runiac's region-and-division leaderboard is designed to feel winnable instead |
| Nike Run Club | Free | Strong beginner coaching content but a weak competitive and community layer. Runiac adds progression and localised competition on top of guided coaching |
| Runkeeper | Freemium, Go tier approximately US$9.99 / month | Comparable entry point. Runiac differentiates on AI-assisted post-run interpretation and on fairness-preserving competition |
| Whoop | Subscription, approximately US$30 / month, hardware bundled | Requires proprietary hardware. Runiac is smartphone-first with wearable data optional |
| Garmin Connect | Free with a premium tier, requires Garmin hardware | The same hardware dependency as Whoop |

*Table 8.2: Competitor pricing anchors*

The positioning argument follows directly. Runiac claims the accessible middle ground between casual applications and expensive athlete platforms, and a price at parity with Strava or Runkeeper would contradict that claim. The correct position is below both.

### 8.4.3 Fixed platform costs

| Item | Cost |
| --- | --- |
| Google Play developer registration | US$25, one-time |
| Apple Developer Program | US$99 / year |

*Table 8.3: Fixed platform costs*

### 8.4.4 Store commission

Selling through native in-app purchase makes the store the merchant of record and the payment processor together, so the store commission *is* the payment processing cost rather than an additional line on top of it.

Apple charges 30% as standard in year one, but 15% under the App Store Small Business Program, for which Runiac qualifies while proceeds remain under US$1 million per year. Google Play is 15% effective for subscriptions (a 10% service fee plus a 5% billing fee), flat, with no year-two or small-developer variation. This chapter therefore uses **15% on both platforms** as the working assumption.

### 8.4.5 Marginal cost per Premium user

| Cost driver | Basis | Estimate per user / month |
| --- | --- | --- |
| OpenAI (`gpt-4o-mini`, at the deployed quotas) | Two premium quota-bearing agents at five generations per user per Singapore day. Approximately 360 output tokens at US$0.60 per million and 500–1,000 input tokens at US$0.15 per million, giving roughly US$0.00033 per call. Typical usage of 15–30 calls per month against a theoretical ceiling of about 300 | US$0.005 – US$0.10 |
| Firebase (Firestore and Cloud Functions) | Reads and writes beyond the free tier for an active user | US$0.01 – US$0.02 |
| Mapbox | Free to 25,000 monthly active users, then US$4.00 per 1,000 | US$0 – US$0.004 |
| **Total marginal cost** | | **≈ US$0.02 – US$0.13** |

*Table 8.4: Marginal cost per Premium user per month*

Three notes on scope. This estimate **includes** the workout briefing agent: it is quota-bearing at five generations per user per day and is wired into the client from the weekly workout detail screen, so it is a live cost driver rather than a future one. The newsletter's mail infrastructure is marketing-site cost rather than per-subscriber cost, so it is excluded. And the AI home guide is **excluded from this table**, for the reason set out immediately below.

### 8.4.6 Fixed maintenance cost and its sensitivity

Ongoing maintenance after the team graduates covers bug fixes, dependency and operating-system updates, support and monitoring. It is a fixed monthly cost rather than a per-user one, so its impact per user depends entirely on subscriber count. Using an illustrative and adjustable placeholder of US$1,000 per month, roughly a ten-hour-per-week part-time maintainer:

| Premium subscribers | Maintenance per user | Plus marginal cost | Price for a 20% margin after the 15% store cut |
| --- | --- | --- | --- |
| 200 | US$5.00 | US$5.10 | ≈ US$7.85 / month |
| 500 | US$2.00 | US$2.10 | ≈ US$3.23 / month |
| 1,000 | US$1.00 | US$1.10 | ≈ US$1.69 / month |
| 2,000 | US$0.50 | US$0.60 | ≈ US$0.92 / month |

*Table 8.5: Cost-plus price by subscriber count*

The formula is that a price P must satisfy 0.85P − cost = 0.20P, hence P = cost ÷ 0.65: the store takes 15% off the top, and 20% of the original price must remain as profit once cost is covered from the remaining 85%.

The table shows why no real subscription product prices purely on cost-plus. At low subscriber counts the fixed maintenance cost dominates and the implied price is absurd; at scale the marginal cost dominates and the implied price approaches zero. The band that matters is the realistic early milestone of roughly 300 to 500 Premium subscribers, where cost-plus lands at approximately **US$3–5 per month**.

## 8.5 Free and Premium Feature Allocation

The allocation below is as deployed, taken from the feature-access configuration rather than from the earlier design documents.

| Feature | Free tier | Premium tier |
| --- | --- | --- |
| F1 Activity collection | Full GPS tracking, distance, pace, duration, cadence, route recording and storage | Same |
| F2 Analysis | Per-run summary, activity history, weekly totals, progress trend | Advanced analysis: cadence series and split detail |
| F3 Plan | Generated weekly plan from the onboarding profile, with adaptation and schedule editing | AI workout briefing on a planned session |
| F4 Reminders | Full access to run, rest, missed-session and streak reminders | Same |
| F5 Social and challenges | Feed publication including route publication, likes, comments, friends, share cards, challenge tiers below 100 km | Premium share presentation, challenge tiers of 100 km and above |
| F6 Streak and consistency | Full access, including milestone rewards | Same |
| F7 Route sharing | Publish a completed run with its route to the Activity Feed; see routes other runners have published | Same |
| F8 Leaderboard | Full and equal participation | Identical ranking. Premium visual presentation only. **No scoring advantage of any kind** |
| F9 Experience and levels | Full access to every experience source and level progression | **Identical formula** |
| F10 AI guidance | Deterministic post-run summaries, **plus the language-model home guide** | Language-model activity feedback and workout briefings |

*Table 8.6: Free and Premium allocation as deployed*

## 8.6 Go-to-Market

Distribution and acquisition are built around the channels the project actually delivered.

**The public website** is the front door. It carries the product story across home, features and how-it-works pages, the pricing page, a frequently asked questions page, an about page introducing the team, and the legal pages. It serves the Android application package directly for download, which removes app-store friction for an initial release and for assessment.

**The newsletter** is the delivered lead-capture mechanism. It uses double opt-in with confirmation and unsubscribe handling, rate limiting against abuse, and administrator-composed campaigns with per-subscriber delivery records. This gives the project a way to keep interested visitors engaged before the application is on the stores.

**In-product social sharing** is the organic growth channel. Achievement cards and route posts can be shared to external platforms through the system share sheet, and on iOS directly to an Instagram Story. Every share carries the product into a runner's own network, which is the most credible channel available to a product with no advertising budget.

**Challenges are the referral mechanism.** A challenge is created by one user and joined by friends they invite, so the feature that drives engagement is also the feature that brings new users in. This is more valuable than a conventional referral scheme because the invitation carries a reason to accept rather than a discount code.

Five further channels are proposed for launch. They are drafted options rather than committed decisions, and each is chosen because it reaches the beginner segment specifically rather than runners in general.

| Channel | Rationale |
| --- | --- |
| App store optimisation | The primary discovery route for a running application. Target "beginner running app", "couch to 5K" and similar low-competition, high-intent terms rather than competing on "running app", where the incumbents are unassailable |
| Campus and student-community launch | As a student project, an initial beta through campus running and fitness clubs reaches the exact beginner segment at almost no cost, and doubles as the beta-tester recruitment that risk R13 in the project's own register calls for |
| Content marketing | Short-form video and written content built on the same behaviour-change positioning as the product, such as "why most people quit running in the first month", which draws the target user in through the problem rather than the feature list |
| Referral through the sharing loop | Achievement and route sharing already carries the product into a user's network. A referral incentive layered on top, such as a free month for both parties, converts existing organic sharing into measurable acquisition |
| Running-club and local-run-group partnerships | The leaderboard needs local density to be motivating. Partnering with beginner-oriented run clubs seeds specific planning areas rather than launching into an empty board everywhere at once |

*Table 8.7: Proposed marketing channels*

The last of these deserves emphasis because it addresses a genuine cold-start problem. A regional, division-scoped leaderboard is only motivating if there are other runners in the region and division. Launching city-wide with a thin user base produces empty boards, which is worse than no leaderboard at all. Seeding a small number of planning areas through partnerships is the practical answer.

## 8.7 Acquisition and Retention

For a product whose thesis is retention, the marketing plan cannot stop at acquisition. The whole argument is that competitors acquire adequately and retain badly.

Acquisition rests on the channels above, with the beginner positioning as the differentiator in a crowded category. The message is deliberately narrow. Every competitor says "track your runs"; Runiac says "still running in eight weeks", which none of them claim.

Retention is the product itself. Streaks with protected rest days, reminders timed to the plan, visible experience progression, achievable regional competition, distance challenges with friends, and AI-assisted encouragement are all retention mechanics rather than features in the conventional sense. The conversion path to Premium follows the same logic: a user becomes a candidate for the paid tier at the point where they set a distance goal, which is a moment the product can detect and address.

## 8.8 Risks to the Business Model

| Risk | Effect | Response |
| --- | --- | --- |
| Free tier is generous enough that few users convert | Revenue below viability | The free tier is deliberately complete; conversion depends on the goal-setting moment rather than on frustration. Monitor conversion at the point a distance goal is set, and adjust what sits in the premium tier through configuration rather than by degrading the free experience |
| Language-model cost scales with premium usage | Margin erosion as the paid base grows | Already mitigated in the delivered system: generation is premium-gated, capped at five per feature per user per day, and cached per user per day against a context fingerprint |
| Incumbents copy the beginner positioning | Loss of differentiation | The defensible part is the mechanics rather than the positioning. Level-based regional grouping, protected rest days and server-owned fairness form a system rather than a feature to be added |
| Singapore-only region model limits the market | Growth ceiling | Region models are data rather than architecture; a new territory requires a planning-area equivalent, not a redesign |
| Platform commission on store billing | 15–30% of revenue | Anticipated in pricing; the annual tier improves the net position per user |

*Table 8.8: Business model risks*
