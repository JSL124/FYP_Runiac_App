# Runiac — Project Video Script & Live Demo Run-Sheet

**Project:** Runiac — a beginner-focused running app · CSIT-26-S2-38
**Prepared:** 11 August 2026 · *Part A rewritten as a feature showcase*
**Contains:** (A) ~30-minute project video — a systematic walkthrough of every delivered feature, narrated, with subtitle-ready cue lines · (B) 20-minute live demo run-sheet, app + admin console, run performed live on a physical device

---

## How to use this document

**Part A** is the project video. It is a **feature showcase**, not a story: it walks the system
module by module, in the order the software itself is structured, and says what each screen does.
No narrative arc, no problem-and-solution framing. If a feature exists in the build, it appears
here; if it does not, it is named in the limitations section and nowhere else.

Every line prefixed with `>` is *one subtitle cue* and *one spoken line*. They are written at
roughly 135 words per minute — the speed the timings assume. One `>` line = one SRT entry.

**Part B** is a run-sheet, not a script. It tells you what to press, in what order, what to say
while you press it, how long you have, and what to do when something fails. Print it.

Two conventions used throughout:

- **SCREEN** — what the viewer is looking at.
- **ACTION** — what is being pressed on the device.

---

## Screen inventory this was built from

Everything below maps to screens that exist in the shipped build (150 captures live in
`docs/user-manual/screenshots/`). The app shell is five tabs, in this order:

| # | Tab | Icon | What it holds |
|---|-----|------|---------------|
| 0 | Home | house | Illustrated weekly stage map, guide bubble, Menu (profile, streak, notifications, Friends, Challenge, Settings, App tour) |
| 1 | Feed | stacked cards | Shared runs with route, distance, pace, comments |
| 2 | Run | runner | Pre-run sheet, GPS status pill, voice settings, live tracking, pause / hold-to-end |
| 3 | Leaderboard | podium | Region map, monthly XP ranking, ten leagues, share rank card |
| 4 | You | person | Progress graph, activity history, plans, workout detail, edit schedule |

Off-tab, behind **Menu**: Profile (level, streak, badge case, training profile, MANAGE), Friends
(4 tabs), Challenge (9 tiers, lobby, invitations, history), Settings, Notifications, App tour.

Separately: a **Next.js marketing site** (17 public routes) and a **13-section admin console**.

---
---

# PART A — Project Video (~30 minutes, feature showcase)

## Design of this cut

- **Order = system order.** Website → install → account → onboarding → shell → each tab in tab
  order → off-tab modules → Premium overlay → admin console → engineering. A marker can follow it
  against the user manual page by page.
- **Every segment answers three things in this order:** what the screen is, what you can do on it,
  and what the backend does about it. Nothing else.
- **No cold open, no montage, no emotional beats.** The title card is at 0:00 and the contents card
  is at 0:15, so a viewer knows the whole shape of the video within 45 seconds.
- **Feature counts are spoken** where they exist, because a showcase is a claim of coverage and
  numbers are how coverage is checked.

## Structure at a glance

| # | Segment | In | Out | Run |
|---|---------|----|-----|-----|
| 1 | Title & contents | 00:00 | 00:45 | 0:45 |
| 2 | System overview | 00:45 | 02:00 | 1:15 |
| 3 | Public website *(3a home feature panels · 3b Features page · 3c rest)* | 02:00 | 05:35 | 3:35 |
| 4 | Install & account creation | 05:35 | 06:20 | 0:45 |
| 5 | Onboarding — 16 steps & plan generation | 06:20 | 08:35 | 2:15 |
| 6 | App tour & navigation shell | 08:35 | 09:20 | 0:45 |
| 7 | Tab 0 — Home | 09:20 | 10:35 | 1:15 |
| 8 | Tab 2 — Run tracking | 10:35 | 13:35 | 3:00 |
| 9 | Post-run — summary, XP & streak | 13:35 | 15:05 | 1:30 |
| 10 | Tab 4 — You: progress & plans *(incl. 10b Runiac AI on a past run)* | 15:05 | 18:40 | 3:35 |
| 11 | Tab 1 — Feed | 18:40 | 19:25 | 0:45 |
| 12 | Tab 3 — Leaderboard | 19:25 | 21:10 | 1:45 |
| 13 | Menu — Friends | 21:10 | 21:55 | 0:45 |
| 14 | Menu — Challenges | 21:55 | 23:40 | 1:45 |
| 15 | Menu — Profile, settings, deletion | 23:40 | 25:40 | 2:00 |
| 16 | Premium — entitlement & AI features *(incl. 16b Advanced Analysis)* | 25:40 | 29:00 | 3:20 |
| 17 | Admin console — 13 sections | 29:00 | 32:15 | 3:15 |
| 18 | Engineering, testing & limitations | 32:15 | 33:15 | 1:00 |
| 19 | Close | 33:15 | 33:45 | 0:30 |

**Look:** 1920×1080. Phone capture in a device frame, centred, app sky-blue as the surround.
**Lower-third label on every segment** — e.g. `2.5 · Leaderboard` — matching the user manual's
section numbers, so the video and the manual are navigable against each other. Leave it up for the
whole segment; in a showcase the label is doing real work.
**Music:** one quiet bed at low level throughout. No swells.

---

## Segment 1 — Title & contents (00:00 – 00:45)

**SCREEN 00:00–00:15** — Title card over the Runiac stage-map artwork.

**[00:00]**
> Runiac. A beginner-focused running app for Singapore.
> Final Year Project, topic code C-S-I-T twenty-six, S two, thirty-eight.
> This video is a walkthrough of the delivered system, feature by feature.

**SCREEN 00:15–00:45** — Contents card. Nine lines, building on one at a time as they are named,
each with its timecode on the right.

**[00:15]**
> In order: the public website.
> Account creation and the setup questionnaire.
> The five tabs of the app — home, feed, run tracking, leaderboard, progress.
> Friends and group challenges.
> Profile, settings and account deletion.
> The Premium tier and its A-I features.
> The thirteen-section administration console.
> And finally, how it is tested, and what it does not do.

---

## Segment 2 — System overview (00:45 – 02:00)

**SCREEN 00:45–01:15** — Three-box diagram, built up as narrated: phone → Firebase → web. Keep it
to three boxes and the arrows. Do not reuse Figure 2.1 or 3.1 from the report.

**[00:45]**
> Runiac is three systems.
> A Flutter application on the phone.
> A Firebase backend, entirely in the Asia-Southeast-One region.
> And a Next.js website that serves both the public site
> and the administration console.

**SCREEN 01:15–01:40** — Counts appear as clean type beside each box.

**[01:15]**
> The client is about six hundred and forty Dart files,
> nineteen feature modules, roughly eighty-five screens.
> Each module splits into presentation, domain and data.
> No state-management package and no routing package —
> nineteen change-notifiers behind ten inherited scopes,
> and one MaterialApp.
> The backend is sixty-four Cloud Functions in TypeScript:
> forty-three callable, thirteen document triggers,
> six scheduled, two H-T-T-P endpoints.

**SCREEN 01:40–02:00** — Split panel: "client may write" (short) vs "backend-owned" (long). Then the
rules file scrolling to its closing deny.

**[01:40]**
> One rule shapes everything that follows.
> The phone cannot write anything that can be gamed.
> A hundred field names are backend-owned.
> Experience points, levels, streaks, leaderboard standing and badges
> are all computed server-side after a run is validated.
> The Firestore rules run past twelve hundred lines and end in a deny.

---

## Segment 3 — Public website (02:00 – 05:35)

> **Timing note.** This segment was 1:45 in the first cut and is now 3:35, because it walks the
> **five feature-highlight panels on the home page** (3a) as well as the Features page (3b).
> Every timecode from Segment 4 onward has been shifted accordingly, so the numbers in this
> document are internally consistent and the video as written runs to **31:50**. The trim table at
> the end of 3b takes it back under 30:00.

> **Where the feature story actually lives.** The five stacked panels on the **home page** —
> adventure map, personalised plan, progression, territorial leaderboard, post-run summary — are the
> real feature showcase, and each shows an app screenshot beside the copy. The separate `/features`
> page is the proposal-era feature catalogue with F-codes. They overlap, so 3a carries the weight
> and 3b runs short.

---

### 3a — Home page and the five feature panels (02:00 – 03:30)

**Lower third:** `1.2 · Home page`

**SCREEN 02:00–02:15** — Desktop browser. Home hero, then scroll through the problem section, the
testimonials, and the solution section. Keep moving; these are context, not content.

**[02:00]**
> The public site is seventeen routes.
> The home page opens on the positioning statement,
> the problem Runiac is addressing,
> and an email sign-up for updates.

**SCREEN 02:15–02:40** — The **adventure map** panel. Headline "Every run moves you along the map.",
body text, and the phone showing the real stage-map screen. Let the screenshot be readable.

**[02:15]**
> It then walks the five core features,
> each as a panel with the app screen beside it.
> First, the adventure map.
> Runiac turns the week into a map,
> and each day is a stepping stone.
> Finish a run and the character moves forward,
> the streak flame stays alight,
> and today's session is stated in plain words.

**SCREEN 02:40–02:55** — The **personalised plan** panel.

**[02:40]**
> Second, the personalised plan.
> Goal, fitness level, running experience and recent activity
> produce a weekly plan
> that balances running days, rest days and progression.

**SCREEN 02:55–03:07** — The **progression system** panel.

**[02:55]**
> Third, the progression system.
> Every valid run earns experience points.
> Consistency becomes levels, progress bars and achievements.

**SCREEN 03:07–03:20** — The **territorial leaderboard** panel.

**[03:07]**
> Fourth, the territorial leaderboard.
> Local boards across Singapore,
> compared within your own area and level division
> rather than against advanced athletes worldwide.
> In the delivered app the ranking period is monthly.

**SCREEN 03:20–03:30** — The **post-run summary** panel, with its four bullets and the
"Beginner-friendly feedback" pill.

**[03:20]**
> Fifth, the post-run summary.
> Pace, distance and consistency become plain feedback —
> what went well, and a safe next focus,
> connected back to the streak and the points.

---

#### ⚠ Production notes for 3a — check these before you record

**1. Four of the five panels may be showing illustrations, not screenshots.**
These sections come from `website/src/lib/site-highlight.ts` and
`site-personalized-plan.ts`. Each has an `imageSrc` field; when it is empty the component renders a
**built-in stylised illustration** instead of a real screen. In code, only the adventure map has a
default set (`/home-stagemap-screenshot.png`) — the other four default to `""`.

The real assets already exist in `website/public/`:

| Panel | Asset to point at |
|---|---|
| Adventure map | `/home-stagemap-screenshot.png` *(already the default)* |
| Personalised plan | `/plan-screenshot.png` |
| Progression system | `/xp-update-screenshot.png` |
| Territorial leaderboard | `/leaderboard-screenshot.png` or `/leaderboard-regions-screenshot.png` |
| Post-run summary | `/run-summary-screenshot.png` |

**This is an admin-console fix, not a code change** — Website Content → the relevant section →
set the screenshot source. Do it before recording. A video where four of five feature panels show
drawings is materially weaker than one where they show the actual product, and the assets are
sitting there already.

**2. "Weekly XP" on the territorial panel is wrong.**
The copy reads "compare your weekly XP with runners in your area". The delivered leaderboard is
**monthly**, refreshed monthly, with no weekly ranking (weekly ranking and zoom-driven re-scoping
are both unbuilt). The narration above corrects this on camera with one line —
*"In the delivered app the ranking period is monthly."* Better still: fix the copy in the admin
console first and delete that line.

**3. Two panels describe Premium features without saying so.**
"Shareable achievements" (progression panel) and the plain-language post-run feedback are behind the
`shareCards` and `activityFeedback` entitlements. The site presents them as general features. Not
worth a correction line in the video — Segment 16 makes the boundary explicit — but do not be
surprised if a marker asks.

**4. These panels are explicitly marketing depictions.**
The source comment says so directly: *"these are marketing depictions of the app, fully decoupled
from the real Flutter app screens they illustrate. Editing them never changes the app."* If asked,
say that plainly. It is a defensible design — the marketing surface is admin-editable and cannot
alter product behaviour — and it reads badly only if you get caught claiming otherwise.

---

### 3b — The Features page (03:30 – 04:20)

**Lower third:** `1.2 · Features page`

The home page has already carried the feature story, so this runs short. Its job is to show that a
requirement-coded catalogue exists and to reconcile its Phase 2 list against what shipped.

**SCREEN 03:30–04:20** — Scroll the Features page continuously: hero → habit loop (8 cards) → MVP
features (6 F-coded cards) → three UI previews → free-versus-premium → **hold on Phase 2** → trust
section → comparison table.

**[03:30]**
> The Features page is the requirement-coded catalogue.
> A beginner habit loop in eight steps —
> onboarding, first run, feedback, weekly plan,
> reminder, streak, experience points, next run.
> Six M-V-P features, each with its code —
> F1 activity tracking, F2 running analysis,
> F3 the weekly plan, F4 reminders,
> F6 streaks, and F9 level progression.
> Three interface previews,
> and the free-versus-premium split,
> stating that Premium buys no competitive advantage.
> A phase-two section lists four more.
> Three of those four were in fact delivered —
> F5 sharing, F8 the territorial leaderboard,
> and F10 A-I summaries.
> F7, community route sharing, is the one that was not.
> Then a trust section naming Firebase authentication,
> Firestore, server-side validation and push reminders,
> and a comparison against conventional running apps.

---

#### ⚠ Caveat box — the Features page contradicts the build

`website/src/app/features/page.tsx` is **hard-coded** and is *not* covered by the admin console's
Website Content editor (that editor handles Home, Pricing, FAQ, Documents, Download, About and
Site-wide). It can only be corrected in code and redeployed.

| On the page | Actually |
|---|---|
| **F5 Social Sharing** listed as "Phase 2 / future" | **Delivered** — achievement cards, share route to feed |
| **F8 Territorial Leaderboard** listed as Phase 2 | **Delivered** — region map, 37 planning areas, 10 leagues |
| **F10 AI-assisted Summary** listed as Phase 2 | **Delivered** — 4-step activity feedback, workout briefing |
| **F7 Community Route Sharing** listed as Phase 2 | **Not delivered** — `sharedRoutes` stores no geometry, Maps tab has no entry point |
| Premium list: "Advanced route filters", "Profile frames and badge styles" | **Not in the entitlement catalogue.** The six real keys are `advancedAnalysis`, `aiHomeCoach`, `activityFeedback`, `workoutBriefing`, `shareRouteToFeed`, `shareCards` |
| Premium list: "Goal preparation for 5K, 10K, 21K, 42K" | Plans exist, but the 21K and 42K goal tracks are not what the generator produces for a beginner profile — verify before claiming it on camera |

The F-code numbering itself is fine and matches the PRD; only the MVP-versus-Phase-2 placement is
stale.

**Pick one before you record:** narrate the reconciliation as written above (costs 6 seconds, turns
a defect into evidence you know your own system), **or** fix the page — move F5, F8 and F10 into the
MVP section, leave F7 in Phase 2, correct the Premium bullets to the seven entitlement keys — and
delete the reconciliation lines. Do **not** narrate the page as written without the reconciliation.
A marker who cross-checks the Phase 2 list against the demo will conclude the site is stale, and
will then doubt every other claim in the video.

---

#### Where to reclaim the 1:50 that Segment 3 now costs

Three expansions have grown the cut past its target: **Segment 3** went 1:45 → 3:35 (the home
feature panels plus the Features page), **Segment 10** went 2:15 → 3:35 (10b, the AI coach called
from Activity History), and **Segment 16** went 2:45 → 3:20 (16b, the Advanced Analysis walkthrough,
partly offset by moving the AI explanation out of it). The video as written now runs to **33:45**.
Every timecode printed in this document already reflects all three.

To bring it back under 30:00 you need to find 3:50. These nine trims total **3:57**:

| Segment | Trim | Saves |
|---|---|---|
| 3a · Home hero / problem / solution intro | 8 s instead of 15 s | 0:07 |
| 3b · Features page | Drop the habit-loop and MVP card recitation; keep the Phase 2 reconciliation | 0:25 |
| 5 · Onboarding steps 2–12 | 4 s per step instead of 5 s | 0:20 |
| 6 · App tour | Show 2 tour steps, not 4 | 0:15 |
| 12 · Leaderboard | Cut the runner-profile and info-sheet shots | 0:20 |
| 15 · Profile MANAGE rows | Name them over one continuous scroll instead of opening each | 0:20 |
| 16b · Advanced Analysis badges | Name the catalogue count and two rules; drop the full 13-badge list | 0:25 |
| 17 · Admin console | 4 s per page in the fast-cut block, and trim XP-rules scrolling | 0:45 |
| 19 · Close | Drop to 0:15 and let the end card carry it | 0:15 |
| 10b · AI validation list | Name three rejected categories instead of reading the reasoning | 0:15 |
| 8 · Live run | 15 s of silent running instead of 20 s, and tighten the pre-run sheet | 0:30 |

Applying all of them lands at **29:48**.

**If you would rather not trim:** the brief said "no hard limit, around 30 minutes". 33:45 is over
that, and at some point the honest answer is that this is a 34-minute showcase of a system with
~85 screens, a 13-section console and three AI surfaces — not a padded 30-minute one. Everything
added was substance. If you must hit a round number, take the trims above rather than deleting a
feature section outright; a showcase that skips a delivered feature is worse than a long one.

---

### 3c — The remaining routes (04:20 – 05:35)

**SCREEN 04:20–04:40** — Pricing, then FAQ.

**[04:20]**
> Pricing shows two tiers side by side.
> Core is free and is a complete running app.
> Premium adds coaching, analysis and sharing.
> Nothing competitive sits behind the paywall.
> Then a frequently-asked-questions page.

**SCREEN 04:40–04:55** — Documents index with its category filter, then a document detail page with
preview and download.

**[04:40]**
> A documents library, filterable by category,
> where each entry opens to a preview and a download.
> These are administrator-uploaded and change without a deployment.

**SCREEN 04:55–05:10** — About us, then Sign in, then the four legal pages in quick succession.

**[04:55]**
> An about page.
> A sign-in page, which is the administrator's entry point.
> And four legal pages in the footer —
> privacy policy, terms of service, cookie notice,
> and an account-deletion policy.

**SCREEN 05:10–05:35** — The newsletter sequence, four shots: type an address → "Thanks. Check your
inbox to confirm your subscription." → the confirmation email → "You're subscribed."

**[05:10]**
> Email subscription is double opt-in.
> The site confirms that a message has been sent, not that you are subscribed.
> Nothing is delivered to the address until the link in that email is clicked.
> An address that never confirms receives nothing.
> Sending itself runs as a scheduled backend job, not from the page.

---


## Segment 4 — Install & account creation (05:35 – 06:20)

**Lower third:** `1.1, 1.4 · Install and sign-up`

**SCREEN 05:35–05:55** — Download page: the Android card, "Download APK", the requirements block,
the three-step strip. Then the Android install prompt and the icon appearing.

**[05:35]**
> Distribution is a direct Android package download.
> Android eight or later.
> iOS is marked coming soon and is not publicly distributed.

**SCREEN 05:55–06:20** — Phone. Welcome → Sign up → email and password → Create account. Show the
Google button. Then back out to Log in and Forgot password.

**[05:55]**
> The welcome screen links the terms and privacy policy
> before either button is pressed.
> Sign-up is email and password, or Google.
> Apple sign-in is not delivered.
> Returning users log in, and a forgotten password
> is reset by an emailed link.

---

## Segment 5 — Onboarding: 16 steps & plan generation (06:20 – 08:35)

**Lower third:** `1.5 · First-run setup`

**SCREEN 06:20–06:35** — Onboarding welcome, "Start setup".

**[06:20]**
> Setup is a sixteen-step questionnaire.
> Every answer can be changed later,
> and the whole thing can be retaken.

**SCREEN 06:35–07:45** — Steps 2 through 12. Show each screen for about 5 seconds; the narration
names them in the same order they appear, so a viewer can follow along without pausing.

**[06:35]**
> Step two — what you are working toward.
> Three — how consistently you have been running.
> Four — how often you run right now.
> Five — your longest comfortable recent run.
> Six — where you are starting from.
> Seven — how many days a week you can run.
> Eight — which days, limited by that answer.
> Nine — your preferred time of day.
> Ten — how long each session should be.
> Eleven — where you usually run.
> Twelve — what kind of support keeps you going.

**SCREEN 07:45–08:05** — Steps 13 and 14, held longer so the text is readable.

**[07:45]**
> Thirteen and fourteen are the health screening.
> Anything to keep in mind,
> and whether you notice chest discomfort, dizziness
> or breathlessness during activity.
> These answers constrain the plan's intensity.
> Runiac is not a medical device and gives no medical advice.

**SCREEN 08:05–08:35** — Step 15, then step 16 — the plan preview, scrolled slowly. Show "Continue
with this plan" and "Edit answers". Then the guide overlay bubble.

**[08:05]**
> Fifteen — how the plan should feel.
> And sixteen is the output: a generated plan preview.
> Weeks, sessions, assigned days,
> built from the sixteen answers rather than selected from templates.
> Accept it, or go back and change any answer.
> Throughout setup a guide character offers a one-line tip,
> dismissible at any point.

---

## Segment 6 — App tour & navigation shell (08:35 – 09:20)

**Lower third:** `1.6 · App tour and shell`

**SCREEN 08:35–09:00** — App tour steps 1, 4, 8, 12 — four of the twelve, enough to show the
pattern. Show "Skip tour".

**[08:35]**
> A twelve-step tour runs once on first arrival at the home screen.
> Each step points at one part of the interface and explains it.
> It can be skipped, and replayed later from Menu, App tour.

**SCREEN 09:00–09:20** — Tap through the five tabs in order, roughly 2 seconds each, then open Menu
and hold on the expanded panel.

**[09:00]**
> The shell is five tabs.
> Home. Feed. Run. Leaderboard. You.
> Everything not on a tab is behind Menu —
> profile and level, current streak, notifications,
> friends, challenges, settings, and the tour.

---

## Segment 7 — Tab 0: Home (09:20 – 10:35)

**Lower third:** `2.1 · Home`

**SCREEN 09:20–09:55** — Home stage map. Slow pan up the path. Point out a completed stone, today's
stone with the character on it, and a faded future stone.

**[09:20]**
> Home is an illustrated stage map of the current week.
> Each stepping stone is one day.
> Completed days are rendered solid, future days faded,
> and your guide character stands on today.
> The character is the one chosen in the profile —
> it changes the presentation, not the training.

**SCREEN 09:55–10:15** — The guide bubble. Close it with the ✕. Reopen by tapping the character.

**[09:55]**
> The guide bubble states today's session in one line,
> generated from the plan, and is dismissible.

**SCREEN 10:15–10:35** — Menu expanded, then the notifications inbox scrolled.

**[10:15]**
> Menu opens the rest of the application.
> It shows your level and current streak inline.
> The notifications entry opens an inbox —
> challenge invitations, badges awarded, challenge results,
> and friend requests.
> Notifications are dispatched by a scheduled backend job
> that runs every ten minutes.

---

## Segment 8 — Tab 2: Run tracking (10:35 – 13:35)

**Lower third:** `2.2 · Going for a run`

**SCREEN 10:35–11:00** — Run tab, pre-run state. Point at the GPS pill, the map centring, and the
sheet showing today's planned session and "Start run".

**[10:35]**
> The Run tab centres the map on your location.
> The sheet below shows the session the plan scheduled for today
> and a start button.
> The pill at the top reports G-P-S status.
> It will not read ready until the fix meets the accuracy
> the tracking session requires.

**SCREEN 11:00–11:40** — Voice settings, every control shown: language, distance interval, time
interval, announcement contents. Then "Preview voices" with one announcement audible.

**[11:00]**
> The gear icon opens spoken updates.
> Language.
> How often to announce by distance.
> How often by time.
> And which values each announcement includes.
> Preview plays each announcement before you leave.

*(Let one previewed line play clean, no narration over it.)*

**SCREEN 11:40–11:55** — Location permission dialog → Allow While Using App. Motion & Fitness →
Allow.

**[11:40]**
> Two permissions are requested at the point of first use.
> Location, without which a run cannot be recorded.
> Motion and fitness, used to detect stops and step rate.
> Both are asked with the reason on screen.

**SCREEN 11:55–13:00** — **Live run, physical device, outdoor.** Cut between the phone screen and
the runner. Show the route line drawing, distance climbing, pace and elapsed time changing, and one
spoken update firing.

**[11:55]**
> During a run the map follows you and the route draws behind you.
> The sheet shows distance, elapsed time and current pace.

*(20 seconds, no narration. Let the tracking run.)*

**[12:25]**
> Low-accuracy fixes are discarded rather than accumulated,
> so distance under-reads in poor conditions rather than over-reads.
> On Android the session runs as a foreground service
> so tracking survives the screen locking;
> on iOS it drives a live activity.
> Cadence comes from a phone-motion platform channel.

**SCREEN 13:00–13:35** — Pause. Show the paused sheet with Resume and "Hold to end run". Perform the
hold and let the progress fill on camera.

**[13:00]**
> Pause stops the timer and holds the session.
> Resume continues it.
> Ending requires a press and hold of about a second and a half —
> a deliberate gesture, so a long run cannot be ended by accident.

---

## Segment 9 — Post-run: summary, XP & streak (13:35 – 15:05)

**Lower third:** `2.2, 3.1 · Run summary`

**SCREEN 13:35–13:55** — A brief validation graphic while the summary loads: three checks listed.

**[13:35]**
> The completed run is submitted to the backend and validated
> before any result is returned.
> Distance is checked against duration,
> pace against a minimum plausible value,
> and the recorded track against what is physically achievable.
> A run that fails validation earns nothing.

**SCREEN 13:55–14:25** — Summary screen: the finished route on the map, distance headline, average
pace, time, then scroll to splits and pace over time. Note the heart-rate field reading `--`.

**[13:55]**
> The summary shows the route, total distance,
> average pace and elapsed time,
> then per-kilometre splits and pace across the run.
> Heart rate and estimated calories are present as fields
> but carry no value — there is no wearable data source in this build,
> and that limitation is stated again at the end of this video.

**SCREEN 14:25–15:05** — The XP and streak screen. Let the numbers count up. Then the level bar, then
a milestone award if one is available.

**[14:25]**
> Then the progression award, computed server-side.
> Twenty points for completing an activity.
> Ten for every whole kilometre.
> Five for every whole ten minutes of active time.
> Twenty more if the run matched a planned session.
> Capped at one hundred per activity
> and two hundred per Singapore calendar day.
> Streak milestones at three, seven, fourteen and thirty days
> pay thirty, ninety, two hundred and twenty, and six hundred,
> and are exempt from both caps.
> The level curve runs to level one hundred
> at fifty-three thousand six hundred points.

---

## Segment 10 — Tab 4: You — progress & plans (15:05 – 18:40)

**Lower third:** `2.3 · Progress and plan`

**SCREEN 15:05–15:40** — You tab, Progress. Weekly distance graph. Cycle the filter: week → month →
year → all time.

**[15:05]**
> The You tab has two sections, Progress and Plans.
> Progress opens on a distance graph,
> filterable by week, month, year, or all time.

**SCREEN 15:40–16:05** — Recent Running list → "See all" → Activity History grouped by month with
year and month filters. Open one past run and show it reopening the full summary.

**[15:40]**
> Below it, recent runs, and the full activity history —
> every recorded run, grouped by month,
> filterable by year and by month.
> Any past run reopens its own summary,
> with its route and splits intact.

---

### 10b — Runiac AI on a past run (16:05 – 17:25)

**Lower third:** `3.2 · AI activity feedback`

> **This sub-segment carries the full explanation of how the AI coach works**, because Activity
> History is the honest place to show it — it proves the feature is not a one-shot animation bolted
> onto the finish of a run. Segment 16 therefore only *names* it. Do not explain the mechanism twice.

**SCREEN 16:05–16:20** — Still in Activity History. Scroll back to a run from a few weeks ago and
open it. Its summary loads with the stored route and splits. Then press the **sparkle** icon and let
the "Analysing your run…" state be visible.

**[16:05]**
> Runiac's A-I coach is not limited to the run you just finished.
> Any activity in the history can be opened and analysed.
> This one is three weeks old.
> The sparkle icon calls it.

**SCREEN 16:20–16:40** — Hold on the loading state while the mechanism is described. Overlay a
simple diagram: phone → callable function → model, with "API key" pinned to the server side.

**[16:20]**
> The request goes to a callable Cloud Function in Singapore.
> The entitlement is checked on the server, not in the interface,
> and the A-P-I key is a deployment secret that never reaches the phone.
> What is sent is derived metrics only —
> distance, duration, average pace, the splits,
> the run-quality label, and whether heart rate was available.
> No route name, no polyline, no coordinates.

**SCREEN 16:40–16:55** — The four steps, paged through with the next arrow. Hold each long enough
to be read.

**[16:40]**
> What comes back is exactly four sections.
> A summary of the run.
> What went well.
> What to improve.
> And the next focus.

**SCREEN 16:55–17:15** — Stay on the last step. Overlay the rejected-content categories as short
type, one per line, as they are named.

**[16:55]**
> The output is validated before the phone sees it.
> Links and formatting are rejected.
> So is anything reading as a medical claim.
> So is shaming language.
> And so is any promise of points, ranking or league position —
> the coach must not appear to hand out competitive rewards.
> If the model fails, or times out at ten seconds,
> a fixed fallback of the same four sections is shown.
> There is no error state, and no unvalidated text.

**SCREEN 17:15–17:25** — Close the overlay, then reopen it on the same run. It returns instantly.

**[17:15]**
> Calls are capped at five per Singapore day.
> And generated feedback is cached on the device —
> reopening this run costs nothing.

---

#### Production notes for 10b

- **Shoot the instant-reopen at the end.** Closing and reopening the overlay and having it return
  with no spinner is the whole cache claim, on camera, in three seconds. It is the cheapest piece of
  evidence in the video.
- **Do not cut the loading state.** It is roughly two to four seconds and it is the proof that a real
  call is happening. Cutting to the finished result makes it look pre-rendered.
- **The quota is real and you will hit it.** Five calls per Singapore day, enforced in a Firestore
  transaction. Rehearsing this shot four times exhausts the account. Use a different account for
  rehearsal than for the take, or shoot it first.
- **Do not claim the model receives the plan or the training history.** It does not. That is the
  home-guide agent, which is a different function. The activity-feedback payload is metrics derived
  from the single activity. An earlier draft of Segment 16 got this wrong; it has been corrected.
- **Have a fallback clip.** This is a live model call over the network in front of a fixed edit. If
  the take times out you will see the fallback text, which is correct behaviour but reads as a dud
  on screen.

---

**SCREEN 17:25–18:00** — Plans section. Current plan and this week's sessions. The "Unlock Runiac
Premium" card on a Basic account. "View Full Plan" → every week. Tap a session → workout detail.

**[17:25]**
> Plans shows the active plan and the current week.
> On a free account an upgrade card sits here.
> View full plan opens every week of the schedule.
> Any session opens to its detail —
> duration, session type, target effort,
> and the structure of the session itself,
> so an interval session reads differently from an easy walk.

**SCREEN 18:00–18:40** — Edit schedule: the day selector with plan-occupied days disabled, the time
picker, "Save New Schedule". Show the disabled state clearly.

**[18:00]**
> Sessions can be rescheduled.
> Edit schedule offers the open days and a time picker.
> Days the plan already uses cannot be selected,
> so the week cannot be double-booked.
> The plan document is the same one the backend reads
> when awarding the planned-session bonus
> and when identifying protected rest days.

---

## Segment 11 — Tab 1: Feed (18:40 – 19:25)

**Lower third:** `2.4 · Feed`

**SCREEN 18:40–19:05** — Feed timeline scrolled. Hold on one post showing route, distance, pace and
time.

**[18:40]**
> The Feed shows runs published by you and the people you follow.
> Each post carries the route, distance, pace and time.
> Posting is not automatic — a run reaches the feed
> only when it is explicitly shared.

**SCREEN 19:05–19:25** — Comment sheet opened, a comment added. Then the post "…" options showing
report and hide.

**[19:05]**
> Comments open in a sheet.
> The post menu carries report and hide.
> A report does not disappear —
> it enters a moderation queue that an administrator works,
> shown later in this video.

---

## Segment 12 — Tab 3: Leaderboard (19:25 – 21:10)

**Lower third:** `2.5 · Leaderboard`

**SCREEN 19:25–19:55** — Leaderboard tab. The map, a Singapore planning area selected, the standings
sheet with the refresh countdown, the top three, and the "My Rank Preview" row.

**[19:25]**
> The Leaderboard ranks by monthly experience points
> within a Singapore planning area, not globally.
> Choosing a region on the map previews its standings.
> The countdown shows when the period refreshes.
> Your own rank is always shown, whatever it is.

**SCREEN 19:55–20:20** — "View More Ranking" → the full list, scrolled. Tap a runner → their public
profile.

**[19:55]**
> View more ranking opens the full board.
> Any runner opens to a public profile —
> level, achievements and badges.
> Only public information is exposed;
> a private profile is respected here.

**SCREEN 20:20–20:45** — Leagues sheet with all ten tiers and their level bands. Then the info sheet
explaining ranking and refresh.

**[20:20]**
> Ten leagues sit over the ranking,
> from Iron through to Challenger,
> each covering a band of levels,
> so runners compete within their own stage of progression.
> An information sheet inside the app explains
> how ranking, the monthly refresh and the leagues work.

**SCREEN 20:45–21:10** — "Share My Rank" → the generated card. Then a short cut to the aggregation
concept: a clock and the hourly job.

**[20:45]**
> Share my rank generates a card for sharing outside the app.
> Standings are produced by a scheduled aggregation job
> that runs every sixty minutes.
> Nothing on this screen is computed on the phone.

---

## Segment 13 — Menu: Friends (21:10 – 21:55)

**Lower third:** `2.6 · Friends`

**SCREEN 21:10–21:35** — Friends module, all four tabs in order: Friends, Search, Requests, Blocked.

**[21:10]**
> Friends has four tabs.
> Friends lists your existing connections.
> Search finds runners by name or nickname.
> Requests holds incoming and outgoing requests —
> a connection requires both sides to agree.
> Blocked lists runners you have blocked.

**SCREEN 21:35–21:55** — Accept a request. Open the "…" action sheet showing remove, block, report.
Then a friend's runner profile.

**[21:35]**
> Requests are accepted or declined from the same row.
> The action menu beside any friend
> offers remove, block and report at the same depth.
> A friend's avatar opens their runner profile.
> Request rates are limited server-side
> to prevent bulk friend spam.

---

## Segment 14 — Menu: Challenges (21:55 – 23:40)

**Lower third:** `2.7 · Challenges`

**SCREEN 21:55–22:20** — Challenge explore. All nine tiers visible, Premium markings on the upper
ones. Tap a free tier → its rules.

**[21:55]**
> Challenges offer nine distance tiers,
> from ten kilometres up to one thousand.
> Tiers from one hundred kilometres upward require Premium.
> Opening a tier shows its rules before any commitment —
> target distance, duration, participant limit,
> the personal minimum each member must contribute,
> and how the group goal is counted.

**SCREEN 22:20–22:55** — "Create challenge" → lobby → "Invite friends" → picker → selected state →
"Start challenge" → the solo confirmation dialog.

**[22:20]**
> Creating a challenge opens a lobby, owned by the creator.
> Friends are invited from a picker, up to the tier's limit.
> Starting with nobody joined prompts a confirmation
> that the challenge will be run solo.

**SCREEN 22:55–23:20** — Invitations list → an invitation detail with rules → Accept.

**[22:55]**
> Invitations arrive in their own list,
> and each opens to the same rules
> before it is accepted or declined.

**SCREEN 23:20–23:40** — Challenge result with badge earned. Then the badge case in the profile.
Then challenge history.

**[23:20]**
> On completion, a challenge that met its target awards a badge,
> which is added to the badge case on your profile.
> Settlement runs as a scheduled backend job every minute,
> so a result does not wait on any participant opening the app.
> Past challenges are listed under history.

---

## Segment 15 — Menu: Profile, settings, deletion (23:40 – 25:40)

**Lower third:** `2.8, 2.9 · Profile and settings`

**SCREEN 23:40–24:05** — Profile: level and progress bar, max streak, total distance, the BASIC or
PREMIUM chip, the badge case, then "YOUR TRAINING PROFILE" showing the onboarding answers.

**[23:40]**
> The profile shows level and progress to the next level,
> longest streak, total distance,
> and a chip stating the subscription tier.
> Below it, the challenge badge case,
> and the training profile —
> the onboarding answers the current plan was generated from,
> shown back to the user rather than hidden.

**SCREEN 24:05–24:45** — MANAGE section, then each row opened in turn and closed: Edit profile ·
Running buddy (character picker, Bolt free, three Premium) · Privacy & Safety · Notifications ·
Feedback · About Runiac · Licences.

**[24:05]**
> The manage section is the entry point to everything else.
> Edit profile — name, nickname, date of birth, weight and region.
> Running buddy — the guide character.
> Bolt is available to everyone; Cap, Mila and Ivy are Premium.
> Privacy and safety controls whether recent run totals
> are used to personalise the guide.
> Notifications sets reminders.
> Feedback reports a bug or a suggestion,
> and lands in an administrator inbox.
> About Runiac carries version and project information,
> links to the legal pages, and open-source licences.

**SCREEN 24:45–25:05** — Menu → Settings: distance units, private profile, haptic feedback, keep
screen on during runs. Then Edit profile → Retake onboarding with its warning dialog. Then sign-out
confirmation.

**[24:45]**
> App-level settings sit separately, under Menu, Settings —
> distance units, private profile, haptic feedback,
> and keeping the screen awake during a run.
> The questionnaire can be retaken from edit profile,
> with a warning first, because a new plan resets the streak.
> Sign-out asks for confirmation.

**SCREEN 25:05–25:40** — Delete account: the disclosure screen with both lists, typing DELETE, the
button enabling, the final confirmation dialog. **Cancel it on camera.**

**[25:05]**
> Account deletion is performed in the app —
> no support request and no waiting period.
> The screen states what is erased:
> profile, every run and route, plans, points, level,
> streak, leaderboard standing, friends, challenges,
> badges, notifications and feed posts.
> And what is kept without your name attached:
> moderation reports, submitted feedback,
> and records of administrator actions —
> so deletion cannot be used to erase a moderation history.
> The confirmation requires the word to be typed exactly,
> then asks once more.
> Thirty-eight erase steps run behind it.

---

## Segment 16 — Premium: entitlement & AI features (25:40 – 29:00)

**Lower third:** `2.10, 3.x · Premium`

**SCREEN 25:40–26:10** — Basic account. The four paywall entry points in sequence: workout briefing
→ sheet; locked challenge tier; locked character; the plans upsell card. Show the sheet with yearly
selected, then monthly.

**[25:40]**
> Premium features are shown in a locked state rather than hidden.
> There are four places a free user meets the subscription sheet.
> The workout briefing on a planned session.
> Challenge tiers from one hundred kilometres upward.
> The three Premium guide characters.
> And an upgrade card in the plans section.
> The sheet offers monthly or yearly, with yearly selected by default.

**[26:05]**
> There is no payment integration in this build.
> Premium is granted administratively.
> The entitlement system is real and enforced;
> the billing is not implemented.

**SCREEN 26:10–26:35** — The feature-access catalogue as clean type: the six gated keys listed,
and beside them the ungated systems named.

**[26:15]**
> Entitlement is a catalogue of six keys —
> advanced analysis, the home A-I coach, activity feedback,
> workout briefing, route sharing, and share cards.
> Run tracking, progression, the leaderboard, friends
> and challenge participation are deliberately absent from it.
> Premium does not earn points faster
> and is neither weighted in nor excluded from the leaderboard.
> That is two configuration flags, not a statement of intent.

**SCREEN 26:35–26:55** — Premium account. Post-run summary with the Coaching Summary and Next Focus
cards unlocked. Then press **More Details**.

**[26:35]**
> On Premium the run summary gains two cards —
> a coaching summary of the run,
> and a next-focus recommendation.
> More details opens the Advanced Analysis screen.

### 16b — Advanced Analysis, section by section (26:55 – 28:10)

**Lower third:** `3.1 · Advanced Analysis`

**SCREEN 26:55–27:20** — The **Run Quality** block at the top: the score ring, the verdict headline,
the paragraph beneath it, the confidence chip, and the achievement badge row. Hold long enough for
the paragraph to be read.

**[26:55]**
> Advanced Analysis has five sections.
> It opens on Run Quality —
> a single score out of one hundred,
> a plain-language verdict,
> and the reason for both.
> The verdict is one of four —
> more data needed, building consistency,
> steady effort, or good foundation run.
> Beside the score, a chip states what the score was computed from:
> phone data, wearable-backed, or mixed.
> Runiac reports the confidence rather than hiding it.

**[27:15]**
> And one design decision worth stating out loud.
> A run without wearable data is not marked down for it.
> The screen says so in as many words —
> missing wearable data does not lower this overview.
> A beginner with only a phone
> should not be told their run scored badly
> because of hardware they do not own.

**SCREEN 27:20–27:32** — Push in on the badge row, then tap "More" to expand the full set.

**[27:25]**
> Below the score, achievement badges.
> Thirteen exist —
> first step, stable pace, good consistency,
> good endurance, strong finish, negative split,
> even split, controlled heart rate, easy effort,
> recovery run, consistent cadence, smooth rhythm,
> and hill steady.
> Each has a rule.
> Stable pace needs a pace-stability score of seventy-five or better.
> Good endurance needs twenty minutes or three kilometres.
> They are earned by the run, not handed out for opening the screen.

**SCREEN 27:32–27:48** — **Pace Analysis**: the four figures, then the Pace Over Distance chart, then
the splits table.

**[27:35]**
> Second, pace analysis.
> Average pace, fastest kilometre, slowest kilometre,
> and a pace-stability percentage.
> Then pace plotted over distance rather than over time —
> the view that shows a beginner they started too fast.
> And the per-kilometre splits underneath.

**SCREEN 27:48–27:58** — **Heart Rate Analysis**, showing the unavailable state.

**[27:48]**
> Third, heart-rate analysis —
> average and maximum heart rate,
> target zone, time in zone, and zone distribution.
> This section is built and has no data source.
> A Runiac G-P-S run carries no heart rate,
> so it reports honestly that heart rate was not recorded.
> Zone analysis unlocks only when a run arrives with samples good enough for it,
> which requires the wearable import that was not delivered.

**SCREEN 27:58–28:10** — **Elevation Analysis**, then **Running Form / Cadence**.

**[27:58]**
> Fourth, elevation — total gain,
> highest and lowest point, the trend,
> and a route-difficulty reading.
> And fifth, running form:
> average cadence and its trend,
> taken from the phone's own motion sensor
> rather than from a watch.
> Every section degrades to a stated reason when its input is missing,
> instead of showing a zero.

---

#### Production notes for 16b

- **Shoot this on a real outdoor run with enough distance.** In the manual's capture the *Pace Over
  Distance* chart renders `--` because the run was too short for the series to build. A chart that
  reads "more run data needed" undercuts the section it is illustrating. Use a run of at least 3 km.
- **Do not hide the Heart Rate section.** Cutting it would be the wrong instinct. A built section
  that states why it has no data is stronger evidence of engineering judgement than a section
  quietly removed — and Segment 18 declares the missing wearable import anyway, so a marker who
  noticed the omission would read it as concealment.
- **Badges vary per run.** Which chips appear depends on the run you record. Do not narrate a
  specific badge as guaranteed; the script names the catalogue and two of the rules, which is true
  regardless of what the take produces.
- **The confidence chip will read "Phone data"** on any run recorded in this build. "Wearable-backed"
  and "Mixed" are reachable only through imported workouts, which are not delivered. Do not stage a
  demo snapshot to make it say otherwise — `advanced_analysis_demo_snapshots.dart` exists for
  development and its scores are labelled "Demo data" on screen.

---

**SCREEN 27:40–27:50** — AI activity feedback, the sparkle icon. Page the four steps quickly;
they were explained in full at 16:05.

**[27:40]**
> The sparkle icon runs the same A-I activity feedback
> shown earlier on a past run —
> four sections, generated server-side, validated before display.

**SCREEN 28:20–29:00** — Workout briefing, four steps, on a planned session. Then the achievement
card, then Share Route to Feed with its preview and "Post to Feed". Then all-unlocked tiers and
characters.

**[28:20]**
> The same mechanism runs forwards as a workout briefing —
> what today's session is, why the plan placed it here,
> how it should feel, and what to do if it goes wrong.
> Premium also opens sharing:
> an achievement card for outside the app,
> and publishing a route to the feed, previewed before posting.
> All nine challenge tiers and all four guide characters
> become available.
> Access entitlement is checked server-side on every call —
> not only in the interface.

---

## Segment 17 — Administration console, 13 sections (29:00 – 32:15)

**Lower third:** `4.x · Administration console`

**SCREEN 29:00–29:20** — Browser. Sign in → console loads on Overview. Pan the thirteen-item sidebar
slowly enough to read every entry.

**[29:00]**
> The administration console is part of the same website.
> Admission depends on the account's role being platform administrator;
> any other account is returned to the public site.
> The session is an I-D token exchanged for a five-day cookie.
> Thirteen sections.

**SCREEN 29:20–29:40** — Overview: six stat cards, active-users graph, system health panel with its
Operational and Degraded chips.

**[29:20]**
> Overview reports unresolved reports, pending exception cases,
> registered users split by tier, runs recorded,
> app errors, and failed backend jobs,
> with an active-user trend and per-component system health.

**SCREEN 29:40–30:00** — Exception Queue: filters by type, severity, status. Open a case, resolve
with a reason.

**[29:40]**
> The exception queue holds moderation and integrity cases —
> reported posts, users, routes and plans,
> and point patterns flagged by anomaly detection.
> Filter by type, severity and status, then resolve or dismiss.
> Automation triages; a human closes every case.

**SCREEN 30:00–30:30** — Users & Roles: the directory, "View" expanding a user, the operations panel,
then the recent admin actions list at the bottom.

**[30:00]**
> Users and roles is the directory —
> role, subscription, level, account state and join date.
> Expanding a user opens the operations panel:
> change role, suspend the account, set the subscription,
> issue a moderation action, or clear an avatar.
> Every action requires a stated reason and is audited.
> This is also where Premium is granted,
> since there is no payment path.

**SCREEN 30:30–30:55** — XP & Gamification, scrolling the full rule set. Then Leaderboard Oversight:
job state, coverage, eligibility, recalculate.

**[30:30]**
> Experience-point and gamification rules are published here,
> not compiled in —
> points per activity, per kilometre and per active minute,
> the plan bonus, both caps, the cool-down band,
> the level curve and the streak rewards.
> Leaderboard oversight monitors the aggregation job,
> checks coverage and eligibility,
> and can request a recalculation.
> It cannot edit a score; no such control exists.

**SCREEN 30:55–31:20** — Automation & Policy: the four saved configurations, with Feature access
expanded. Then App Paywall.

**[30:55]**
> Automation and policy holds four configurations.
> Feature access sets the minimum tier per gated feature.
> Challenge tier access and character access do the same
> for challenge tiers and guide characters.
> Moderation automation sets the auto-hide
> and escalation thresholds.
> The app paywall page edits what the subscription sheet displays —
> title, badge, feature list, prices and button.
> It publishes display copy only and grants nobody anything.

**SCREEN 31:20–31:55** — Website Content tabs · Project Documents upload form · Feedback inbox ·
Newsletter subscribers and campaigns · App Errors. About 6 seconds each.

**[31:20]**
> Website content edits the marketing site,
> tabbed by destination page.
> Project documents uploads and manages the public P-D-F library.
> Feedback is an inbox grouped by auto-classified category,
> summarised and de-duplicated before a human sees it.
> Newsletter manages subscribers and composes campaigns;
> sending runs as a backend job.
> App errors groups reports from both the app and the functions,
> sanitised server-side —
> no routes, no precise location, no credentials.

**SCREEN 31:55–32:15** — Governance & Audit, scrolled, showing both administrator and *system*
entries.

**[31:55]**
> Governance and audit is the chronological record —
> role changes, subscription changes, plan publishes,
> rule activations and backend job outcomes.
> Entries attributed to system are backend-generated.
> This log is the reason every control in this console
> demands a reason before it acts.

---

## Segment 18 — Engineering, testing & limitations (32:15 – 33:15)

**SCREEN 32:15–32:35** — CI pipeline green. Test counts as clean type.

**[32:15]**
> Testing: two hundred and seventy-four Flutter test files,
> eighty-four for the Cloud Functions,
> and thirteen written against the Firestore security rules —
> five hundred and sixty-nine assertions,
> all wired into continuous integration.
> The rules are tested as rules rather than assumed.

**SCREEN 32:35–33:15** — Four plain title cards, one limitation each, held long enough to read.

**[32:35]**
> Four things this build does not do.
> One. No payment integration. Premium is administrator-granted.

**[32:45]**
> Two. Wearable and Apple Health import is not delivered.
> The entitlement and the client repository exist;
> the native handler was never written.
> This is why heart rate reads as a dash.

**[32:57]**
> Three. The leaderboard covers thirty-seven
> of Singapore's fifty-five planning areas.

**[33:05]**
> Four. The habit mechanics are implemented but not validated.
> There is no longitudinal or usability study behind them.

---

## Segment 19 — Close (33:15 – 33:45)

**SCREEN 33:15–33:45** — A four-up grid: phone home screen, run tracking, leaderboard, admin
console. Then the end card.

**[33:15]**
> Runiac: a Flutter client, sixty-four Cloud Functions in Singapore,
> a public site and a thirteen-section administration console.
> Everything shown in this video is in the delivered build.

**END CARD:** `Runiac` · `CSIT-26-S2-38` · team names · supervisor · date. Hold 8 seconds, silent.

---

## Subtitle production notes

- **Cue length.** Every `>` line is under about 14 words. Do not merge two into one cue.
- **Two lines maximum**, bottom-centre, safe margin 10 % from the bottom edge — the app's own bottom
  navigation bar lives there, and anything lower collides with the UI in phone shots.
- **Numbers.** Narration spells numbers out for the voice ("sixty-four Cloud Functions"). Subtitles
  should use digits ("64 Cloud Functions"). This is the only place the two tracks differ, and in a
  showcase cut it matters more than usual — the marker is scanning for figures.
- **Terminology.** Subtitle "XP", narrate "experience points". Subtitle "Asia-Southeast-1", narrate
  "Asia-Southeast-One". Subtitle "AI", narrate "A-I".
- **Silent passages** — 11:55–12:25 (the run) and the voice preview at ~11:35 — take a descriptive
  caption rather than nothing: `[spoken update: "1 kilometre. 6 minutes 42 per kilometre."]`
- **Lower-third section labels** are graphics, not subtitles. Do not duplicate them in the subtitle
  track.

---

## Capture checklist

| Segment | Capture | Source / device |
|---|---|---|
| 2 | Architecture animation | Build fresh — Figures 2.1 and 3.1 in the report are flagged unreadable |
| 3, 4 | Website, download, newsletter | Desktop browser, production site, 1920×1080 |
| 5–7, 10–16 | App screens | Physical device screen recording. Clean status bar, notifications off, brightness fixed |
| 8, 9 | Live run and summary | **Physical device outdoors only.** The simulator discards its own synthetic GPS fixes and records 0.00 km |
| 16 | AI feedback and briefing | Record two takes — the model call latency varies and you want the shorter one |
| 17 | Admin console | Local emulator with seeded demo data. Never production user data on camera |
| 18 | CI run | Screen recording of a green pipeline |

**Continuity to watch:** the run captured in Segment 8 must be the same run whose summary appears in
Segment 9, the same activity that appears at the top of Activity History in Segment 10, and the same
one that receives AI feedback in Segment 16. Shoot Segments 8, 9, 10 and 16 in one session on one
account, or the distances will not match and it will be visible.

---
---

# PART B — Live Demo Run-Sheet (20 minutes)

**Scope agreed:** mobile app and admin console in depth; marketing site as a rough flyby only.
**Run:** performed live, on a physical device, in the room.

---

## The three moments that win this demo

Everything else is supporting material. Protect these:

1. **The live run** (minute 5–9). A real device, real GPS, distance actually climbing. This is the
   one thing a video cannot prove and a slide cannot fake.
2. **The cross-system grant** (minute 15). Grant Premium in the admin console on the laptop, pull to
   refresh on the phone, and a locked feature unlocks in front of them. Two systems, one action,
   live.
3. **The report round-trip** (minute 13 → 16). Report a feed post on the phone early, then show that
   exact case sitting in the admin exception queue later. Nothing else demonstrates that the
   moderation pipeline is real.

If you fall behind, cut depth from the You tab and the marketing site. Never cut these three.

---

## Pre-flight — done 30 minutes before, not 5

**Hardware**

- [ ] Phone A — **Premium** account, real run history, friends, at least one finished challenge with a badge. Screen mirroring tested *in the actual room*, on the actual cable/dongle.
- [ ] Phone B — **Basic** account, fresh-ish, used for the paywall and the grant. Keep it on the table, unlocked, screen timeout off.
- [ ] Laptop — admin console open and **already signed in**, on the Overview tab. Second tab: marketing site home. Third tab: nothing. Close everything else.
- [ ] Both phones: Do Not Disturb **on**, brightness **max**, auto-lock **never**, battery above 60 %, mobile data on (do not rely on venue Wi-Fi for the run).
- [ ] Charger for phone A. GPS drains it.

**Accounts and data**

- [ ] Phone A account has: ≥5 past runs, a plan mid-week, ≥2 friends, ≥1 badge, level ≥10 so the leaderboard row is not empty.
- [ ] A pending friend request waiting to be accepted on camera.
- [ ] A pending challenge invitation waiting in the inbox.
- [ ] Admin console seeded: ≥3 unresolved reports, ≥1 escalated exception case, ≥10 users, audit entries present.
- [ ] Phone B account is **Basic** and stays Basic until minute 15.

**Environment**

- [ ] Walk the run route the day before. You need ~90 seconds of movement with sky visible. A corridor with windows is not enough — an outdoor doorway, balcony, or the walk to and from the room is.
- [ ] Get a GPS fix **before** you present. Open the Run tab 10 minutes early, let it lock, then background it. A cold fix in front of an audience takes 40 seconds and feels like 4 minutes.
- [ ] Test the audio route for the spoken update. If the room's sound is going through the laptop, the phone's voice line will not be heard — decide now whether to hold the phone to the mic or skip it.

**Fallbacks — have these ready, do not improvise**

- [ ] `fallback-live-run.mp4` — a 90-second screen recording of a successful run, cued and ready in a background window. If GPS will not lock in 45 seconds, play it and say so: *"GPS is not cooperating indoors — here is the same thing recorded this morning."* Do not apologise twice.
- [ ] `fallback-ai-feedback.mp4` — the AI coach is a live model call and can be slow or fail. 30 seconds of recording.
- [ ] A screenshot deck of the 13 admin pages, in case the emulator dies.
- [ ] Know your one-sentence recovery line and use it once: *"That's a live system doing a live thing — let me show you the recorded version and come back to it."*

**Reconcile before you speak a price**

The report was hand-edited to **S$4.99/month**, but `site-pricing.ts` and the paywall config both
default to **S$5.99/month · S$49.99/year**, which is what will be on the screen. Fix one or the
other before the demo, or simply do not say a number out loud — point at the sheet and let it speak.

---

## Minute-by-minute

### 0:00 – 0:45 · Frame it (0:45)

**SCREEN:** Phone A home stage map, mirrored. Nothing else.

> "Runiac is a running app for people who are not runners yet. In twenty minutes I'll take you
> through it as three people: someone who just installed it, someone who uses it every day, and the
> administrator who keeps it honest. I'm going to run — actually run, on this phone, outside that
> door — about five minutes in. Everything you see is live except where I say otherwise."

Set the expectation of a live run *now*. It buys you patience later if the fix is slow, and it makes
the moment land when it works.

---

### 0:45 – 1:30 · Marketing site flyby (0:45) — *rough, keep moving*

**SCREEN:** Laptop, browser tab 2.

**ACTION:** Home → scroll once → Pricing → Download. Three pages, do not linger.

> "Public site: what it is, what it costs, and where to get it. Two tiers — free is a complete
> running app, Premium adds coaching. Android APK, direct download; iOS is built but not publicly
> distributed, and we say so rather than implying a store listing. Every word on this site is
> editable from the admin console, which you'll see at the end."

**Hard cut at 1:30.** If you are still on the website at 1:40 you will lose the run.

---

### 1:30 – 4:00 · New runner: sign-up and setup (2:30)

**SCREEN:** Phone B (Basic), mirrored. Sign out first if needed — or better, have a third throwaway
account ready so you are not risking Phone B's state.

**ACTION 1:30–1:55** — Welcome → Sign up → email + password → Create account.

> "Email and password, or Google. Terms and privacy linked before you touch either button."

**ACTION 1:55–3:20** — The 16-step questionnaire. **Do not read the questions aloud.** Tap through
briskly — about 4 seconds a step — and narrate the shape of it over the top.

> "Sixteen questions, and they're building something, not profiling you. Goal. Current consistency.
> How far you can comfortably run today. How many days a week, which days, what time. Session length,
> where you run, what kind of encouragement works on you."

Slow down at steps 13 and 14 and actually let them read:

> "And two most running apps don't ask. Anything about your health we should know. And during
> activity, do you notice chest discomfort, dizziness, breathlessness. Runiac is not a medical
> device and doesn't give medical advice — what it does is hold the plan back, keep sessions
> shorter, and tell you it's doing that."

**ACTION 3:20–3:50** — Step 16, plan preview. Stop. Scroll it slowly. This is the payoff.

> "And this is what those sixteen answers were for. A plan — weeks, sessions, days — built from what
> this person said about themselves. Not a template with a name in it. It's a preview: they can go
> back and change any answer, and retake the whole thing later."

**ACTION 3:50–4:00** — Accept → Home → **skip the app tour** (say you are skipping it).

> "There's a twelve-step tour here, skippable and replayable. Skipping it."

---

### 4:00 – 5:00 · Home and the shell (1:00)

**SCREEN:** Switch to **Phone A** (the loaded Premium account). Say you are switching and why.

> "Switching to a lived-in account so there's actual data."

**ACTION** — Pan the stage map. Close the guide bubble. Open Menu, show it, close it. Tap through
the five tabs once, fast, then return Home.

> "Your week is a path. Each stone is a day — behind you is done, ahead is faded. Your buddy is
> standing on today and tells you what today is, in one sentence. Not a dashboard, a place you're
> standing in. Five tabs: Home, Feed, Run, Leaderboard, You. Everything else is behind Menu —
> profile, streak, notifications, friends, challenges, settings."

**At 4:50, start moving toward the door if the run is outside.** Talk while you walk.

---

### 5:00 – 9:00 · THE LIVE RUN (4:00) — *the centrepiece*

**ACTION 5:00–5:40** — Run tab. Point at the GPS pill.

> "The pill won't say ready until the fix is good enough to record. It's telling the truth about
> itself, which matters in a minute."

Open the gear. Show voice settings. Tap **Preview voices** and let one line play out loud.

> "Spoken updates — language, how often by distance, how often by time, what's in each announcement.
> And you can hear them before you leave the house."

**ACTION 5:40–5:55** — Tap **Start run**. If permission dialogs appear, let them.

> "Two permissions, asked when they're needed with the reason on screen. Location, because a run
> can't be recorded without it. Motion, for stops and step rate."

**ACTION 5:55–7:30** — **Run.** Actually move. Ninety seconds minimum. Hold the phone so the mirror
shows the map and the metrics. Stop narrating for the first 20 seconds and let them watch the line
draw.

Then, while moving:

> "Distance, elapsed time, current pace, route drawing behind me. It's throwing away low-accuracy
> fixes rather than inflating distance with them — so between buildings it locks slower, it doesn't
> reward you faster."

If a spoken update fires, stop talking and let it be heard.

**ACTION 7:30–7:50** — **Pause.** Show the paused state. Then press and hold **Hold to end run** and
narrate the hold as it happens.

> "Pause stops the timer. Ending is deliberately harder — press and hold, a second and a half. A run
> that took forty minutes shouldn't end because a thumb brushed the screen."

**ACTION 7:50–9:00** — The summary assembles. Let it. Then the XP and streak screen.

> "That run just went to the backend and was validated before any of this came back — distance
> against duration, pace against a floor, path against what's physically possible. A run the server
> doesn't believe earns nothing."

> "Twenty points for showing up. Ten per full kilometre. Five per ten active minutes. Twenty more if
> it was the session the plan asked for. Capped, so one huge run can't buy a level. Streaks — three,
> seven, fourteen, thirty days — pay separately and outside the cap, because consistency is what
> we're actually trying to buy."

**Recovery:** no lock by 6:20 → fallback video, one sentence, move on. Do not retry twice.

---

### 9:00 – 10:15 · Post-run analysis, Premium (1:15)

**ACTION** — On the run you just did: scroll the summary → splits → pace over time. Then the
**Coaching Summary** and **Next Focus** cards. Then **More Details** → Advanced Analysis.

> "On Premium the same summary carries two more cards — what that run was, and the one thing to
> change next time. More details gives fastest and slowest kilometre, pace stability, and pace over
> distance, which is the view that shows a beginner they're starting far too fast."

**ACTION** — Tap the **sparkle** icon → AI activity feedback, all four steps.

> "This is a language model, called server-side. The key never touches the phone. It gets this run,
> your plan and your recent history, and it's constrained to talk about training — ask it a medical
> question and it tells you to see a professional."

**If it hangs past 8 seconds:** talk over the spinner once, then cut to `fallback-ai-feedback.mp4`.

---

### 10:15 – 11:45 · You tab: progress and the plan (1:30)

**ACTION 10:15–10:45** — You → Progress. Point at the run you just did, newly present.

> "And there's the run from four minutes ago. Weekly distance, same graph over a month, a year, all
> time. For a beginner this graph is the whole argument — six weeks ago that bar was two kilometres."

Recent Running → See all → Activity History, scroll.

**ACTION 10:45–11:20** — Plans → View Full Plan → tap a session → workout detail.

> "This week, then every week. Open a session and it says what it's for — how long, what type, how
> hard it should feel, and the structure inside it. An easy walk isn't the same instruction as
> intervals, and a beginner shouldn't have to already know that."

**ACTION 11:20–11:45** — Tap the **sparkle** on a planned session → workout briefing (2 steps is
enough, then back). Then **Edit schedule** → pick a day → time picker → Save.

> "Same coach, running forwards: what today is, why the plan put it here, how it should feel, what
> to do if it goes wrong. And weeks move, so the plan moves — days the plan already uses can't be
> double-booked. That constraint matters more than it sounds: the alternative for most beginners
> isn't moving the session, it's skipping it."

---

### 11:45 – 13:45 · Competition and company (2:00)

**ACTION 11:45–12:25** — Leaderboard tab. Region map → your area → standings → **My Rank Preview**.

> "You're not ranked against everyone — you're ranked inside your own planning area of Singapore.
> Thirty-seven areas, refreshed monthly, so a bad month is a month and not a permanent position. And
> your own rank is always shown, even when it's eighteenth. Hiding it would be kinder and would work
> less well."

View More Ranking → tap a runner → leagues icon → info sheet → **Share My Rank**.

> "Ten leagues over the top, banded by level. How it's all computed is written inside the app,
> because a ranking you can't explain is a ranking nobody trusts."

**ACTION 12:25–12:55** — Menu → Friends. Four tabs. **Accept the pending request live.** Open the
"…" sheet.

> "Search, request, and they have to agree — nobody's added without saying yes. And the same sheet
> that adds someone lets you remove, block or report them, in the same number of taps. Safety
> controls three menus deep are decorative."

**ACTION 12:55–13:25** — Menu → Challenge. Nine tiers. Open one → rules. Create challenge → lobby →
Invite friends → invite one. Then the invitation inbox and a badge in the profile badge case.

> "Nine tiers, ten K to a thousand. The rules are shown before you commit — group target, duration,
> participants, and a personal minimum so nobody's carried. Settlement runs on the backend every
> minute; nobody's badge waits on someone else opening the app."

**ACTION 13:25–13:45** — Feed tab. Scroll. Open comments. Then **"…" on a post → Report** and
actually file it.

> "And the feed. Runs, routes, comments — no metrics arms race. I'm going to report this post, for
> real, right now. Remember it. It's going to reappear in about three minutes on the other side of
> the system."

---

### 13:45 – 14:45 · The Premium boundary (1:00)

**SCREEN:** **Phone B** (Basic).

**ACTION** — Tap "Explain today's workout" → subscription sheet. Show yearly, then monthly. Back.
Then the locked challenge tier and the locked characters, fast.

> "On a free account nothing is hidden — locked features are visible in a locked state, so you can
> see what you're choosing about. There are exactly four places you meet this sheet: the briefing,
> the bigger challenge tiers, three of the four buddies, and a card on the plans page. Four. Never
> mid-run."

Then say the honest part before anyone asks it:

> "There's no payment integration in this build. Premium is granted administratively. The
> entitlement boundary is real and enforced; the billing isn't built, and I'm not going to pretend
> it is. Which is convenient, because that's exactly what I'm about to do next."

---

### 14:45 – 18:30 · The administrator (3:45)

**SCREEN:** Laptop, admin console.

**ACTION 14:45–15:00** — Overview. Six stat cards, active-users graph, system health.

> "Same website, different door — you're admitted only if your role says platform administrator.
> Thirteen sections. This is the morning screen: what needs a human, who's here, what the system
> did, and component health, which reports degraded when it is degraded."

**ACTION 15:00–15:45 — THE GRANT. This is the moment. Slow down.**

Users & Roles → search Phone B's account → **View** → operations panel → set subscription to
Premium → type a reason → save.

> "Users and roles. Role, subscription, level, state. Expand one, and this panel is where authority
> lives — change a role, suspend an account, set a subscription, issue a moderation action. Every one
> of them requires a typed reason. I'm granting Premium to the account on this phone, and I'm typing
> why."

**Now pick up Phone B in front of them.** Pull to refresh / reopen the workout briefing.

> "And that's the same feature, thirty seconds later, on the same phone."

*(If the client caches, background and reopen the app. Rehearse this exact sequence — know whether
your build needs a cold start.)*

**ACTION 15:45–16:20 — THE REPORT ROUND-TRIP.** Exception Queue. Filter to reports. Find the case
you filed at 13:25. Open it. Resolve with a reason.

> "And here's the post I reported three minutes ago, from the phone, on the other side of the
> system. Reported posts, users, routes and plans — plus integrity cases, XP patterns the anomaly
> detection flagged as implausible. Automation triages; it does not decide. A human closes every
> case, and the close is recorded."

**ACTION 16:20–16:55** — XP & Gamification. Scroll the rule set. Then Leaderboard Oversight.

> "The gamification rules are configuration, not code — points per activity, per kilometre, per
> active minute, the caps, the level curve, the streak rewards. All published from here and applied
> by Cloud Functions. Changed without a deployment, and every change is dated and attributed.
> Leaderboard oversight monitors the aggregation job and can request a recalculation. It cannot edit
> a score — there's no button for that anywhere in this console."

**ACTION 16:55–17:35** — Automation & Policy → open **Feature access**.

> "This is the one I actually want you to look at. Feature access sets the minimum tier per gated
> feature. Seven features are listed. Run tracking is not one of them. Neither is progression, the
> leaderboard, or friends. They're absent because they were never gateable — Premium cannot buy a
> competitive advantage, and that's not an intention in a document, it's the contents of this list."

Then App Paywall, briefly:

> "And the paywall page edits what that subscription sheet says. Copy only. Saving it grants nobody
> anything."

**ACTION 17:35–18:10** — Fast: Website Content → Project Documents → Feedback → Newsletter → App
Errors. About 6 seconds each, do not stop.

> "The rest is operations. Site copy tab by tab. Public documents. A feedback inbox, auto-classified
> and de-duplicated. Newsletter subscribers and campaigns. And grouped app errors — sanitised
> server-side, no routes, no precise location, no credentials."

**ACTION 18:10–18:30** — Governance & Audit. Scroll it. Point at your own two actions from minutes
15 and 16.

> "And everything lands here. Every administrator action, every system event, in order, attributed,
> permanent. Including the two I did in front of you four minutes ago. Records like these survive a
> user deleting their own account — deleting yourself doesn't erase a moderation history."

---

### 18:30 – 19:15 · Deletion and the honest limits (0:45)

**SCREEN:** Phone B or a QA account.

**ACTION** — Profile → Delete account → disclosure screen → type DELETE → **Cancel at the final
dialog**. Say clearly that you are cancelling.

> "And a beginner can leave. It's in the app, not an email to support. It says what's erased and
> what's kept without your name on it, makes you type the word, and asks once more. Thirty-eight
> erase steps behind that button. I'm cancelling."

Then the limits, flat and fast:

> "Four things it doesn't do. No payment integration — Premium is admin-granted, as you saw. No
> wearable or Apple Health import: the entitlement and the client repository exist, the native
> handler was never written, which is why heart rate reads as a dash. The leaderboard covers
> thirty-seven of fifty-five planning areas. And the habit mechanics are implemented and not
> validated — no longitudinal study. We believe they work. We haven't proved it."

---

### 19:15 – 20:00 · Close (0:45)

**SCREEN:** Back to the Home stage map.

> "Two hundred and seventy-four Flutter test files, eighty-four for Cloud Functions, and thirteen
> written against the Firestore security rules themselves — five hundred and sixty-nine assertions,
> all in CI. The rules are tested as rules, not assumed."

> "We didn't set out to build a better running app. We set out to build the first six weeks — the
> part nobody makes for beginners, because beginners are the least profitable people to build for
> and the most likely to leave. Structure, so you know what today is. Feedback, so you know whether
> it went well. Progression, so tomorrow is worth something. Company, so you're not doing it alone.
> Happy to take questions."

---

## If you are running behind — cut in this order

1. Marketing site flyby (0:45) → replace with one sentence over the Overview page.
2. Activity History and Progress filters (0:30) → show the graph once, move on.
3. Workout briefing (0:25) → you already showed the AI on the post-run feedback.
4. Website Content / Documents / Newsletter / App Errors (0:35) → name them over the sidebar.
5. Deletion flow (0:30) → describe it instead of performing it.

**Never cut:** the live run, the Premium grant round-trip, the report round-trip, the feature-access
list, or the honest-limits paragraph. The last one especially — a marker who finds a gap you didn't
mention distrusts everything you did.

---

## Questions you will be asked, and the short answers

| Question | Answer |
|---|---|
| "How do you stop someone faking a run?" | Server-side validation on submission — distance against duration, pace against a minimum-plausible floor, plausibility of the path. XP is computed by the backend, never sent by the client. 100 fields are backend-owned and unwritable from the app. It is not unspoofable; it is not trivially spoofable. *(Do not quote a single floor number out loud: `validateRunScalarFields.ts` uses 120 s/km and `validateRunSummaryDetails.ts` uses 150 s/km. Reconcile the two, or answer without a figure.)* |
| "Isn't the plan client-writable?" | Yes, and it is our best-known weakness. The generated plan lives client-side and the backend reads protected rest dates and the plan-bonus match from it. It is in the report's limitations table, same class as GPS spoofing. |
| "Why no state-management library?" | Deliberate. 19 ChangeNotifiers behind 10 InheritedNotifier scopes. Fewer dependencies, and nothing in the codebase we could not account for at review. |
| "Why is there no payment?" | Out of scope for the FYP. The entitlement system that a payment would drive is fully built and enforced; only the billing integration is absent. |
| "Why Singapore only?" | Region labels are validated at the schema level, and the leaderboard is scoped to Singapore planning areas. It is a deliberate constraint, not an oversight — territorial ranking only means something at a real geographic scale. |
| "Is the AI giving medical advice?" | No. It is constrained to training guidance and refers medical questions to a professional. The onboarding health questions gate plan intensity; they are not diagnostic. |
| "What happens to my data if I delete?" | 38 erase steps. Everything personal goes. Moderation records and audit entries are retained with your identity stripped, so deletion cannot erase a moderation history. |

---

## One-page card — tear this off and hold it

```
0:00  Frame it — "I'm going to run, live, at minute 5"
0:45  Website: home / pricing / download          [CUT AT 1:30]
1:30  Sign-up → 16 questions (fast) → PLAN PREVIEW (slow)
4:00  Switch to Phone A · stage map · 5 tabs · Menu
5:00  RUN TAB · GPS pill · voice preview · START
5:55  ***RUN. MOVE. 90 SECONDS.***
7:30  Pause → HOLD to end → summary → XP & STREAK
9:00  Coaching cards → Advanced Analysis → SPARKLE (AI)
10:15 You: progress · history · plan · briefing · edit schedule
11:45 Leaderboard: region · leagues · share rank
12:25 Friends: accept request live · report/block sheet
12:55 Challenge: tiers · lobby · invite · badge
13:25 Feed → ***REPORT A POST (remember it)***
13:45 Phone B: paywall · "no payment integration, admin-granted"
14:45 Admin: Overview
15:00 ***GRANT PREMIUM → pick up Phone B → unlocked***
15:45 ***EXCEPTION QUEUE → the post you reported***
16:20 XP rules · Leaderboard oversight ("cannot edit a score")
16:55 Automation & Policy → FEATURE ACCESS list
17:35 Content / Docs / Feedback / Newsletter / Errors (fast)
18:10 Governance & Audit → your own two actions
18:30 Delete account → type DELETE → CANCEL · four limits
19:15 Tests · closing statement · questions
```
