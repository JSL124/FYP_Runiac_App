# Runiac — User Manual

**Version 1.1 · 6 August 2026**

Project: Runiac — a beginner-focused running app
Topic code: CSIT-26-S2-38

---

## Document Control

| Title | Document name | Owner | Current version | Last change on |
| --- | --- | --- | --- | --- |
| User Manual | Runiac User Manual, Version 1.1 | FYP-26-S2-38 | 1.1 | 6 August 2026 |

### Record of revision

| Revision date | Description | Section affected | Version after revision |
| --- | --- | --- | --- |
| 4 August 2026 | Initial user manual, captured from the running prototype | All | 1.0 |
| 6 August 2026 | Re-captured against the current build: **Watch & Health Apps** removed from the profile, **Delete account** documented, the website **Account Deletion** page re-shot now that it describes in-app deletion, the administration console re-shot after its page descriptions were removed, and an email-subscription walkthrough added for the unregistered visitor | 1.2, 1.3, 2.8, 2.9, Part 4, Appendix A | 1.1 |

---

## Introduction

This User Manual contains the information required to operate Runiac. It describes the
system's functions and capabilities and gives step-by-step instructions for using the mobile
app and the administration console.

Every screenshot in this manual was captured from the running prototype — the Flutter app on an
iPhone 17 simulator against the production Firebase project, and the web console against a
seeded local database. No screen was mocked up.

**Assumptions about the reader.** No prior knowledge of Runiac is assumed. Readers are expected
to be able to install an app on their phone and use a web browser.

## Scope and Purpose

This procedure explains how to operate Runiac for each type of user:

| Part | Audience | What it covers |
| --- | --- | --- |
| 1 | Unregistered visitor | Downloading and installing Runiac, the public website, subscribing to updates by email, signing up, and first-run setup |
| 2 | Registered user (Basic) | Everyday use — running, plans, feed, leaderboard, friends, challenges |
| 3 | Registered user (Premium) | The features Premium adds on top of Basic |
| 4 | Platform Administrator | The web administration console |

## Process Overview

Runiac is used through five bottom-navigation tabs — **Home**, **Feed**, **Run**, **Leaderboard**
and **You** — plus a **Menu** on the Home screen that opens Profile, Notifications, Friends,
Challenge, Settings and the app tour.

A new user downloads the app, creates an account, answers a short onboarding questionnaire, and
receives a generated beginner running plan. From then on the daily loop is: open Home to see
today's session, start a run from the Run tab, finish, and review the summary and XP earned.

**Two things the reader should understand up front.**

1. **Basic and Premium are a subscription status, not a role.** Premium adds coaching, analysis
   and presentation features. It never changes how XP, level, rank, streak or leaderboard score
   are calculated — those are owned by the server and are identical for both tiers.
2. **The Platform Administrator is a separate governance role.** Administrators work in a web
   console, not in the mobile app.

---

# Part 1 — Unregistered visitor

## 1.1 Downloading and installing Runiac

Runiac is distributed for **Android** as a direct APK download. iOS distribution is listed as
*Coming soon* on the download page and is not yet available to the public.

1. Open the Runiac website and choose **Download** in the navigation bar.

   ![Runiac download page](screenshots/00-download/01-download-page.png){ width=95% }

2. Under **Android**, press **Download APK**. The page notes the requirements: Android 8.0 or
   later, and that you may need to allow installs from your browser.

3. Follow the three steps shown on the page — download the APK, create your account, then start
   your first run. The **Before you install** section lists the system requirements.

   ![Install in three steps](screenshots/00-download/02-download-install-steps.png){ width=95% }

4. Open the downloaded file and confirm the install when Android asks. Runiac then appears in
   your app list.

> **Note.** Because the APK is installed directly rather than from an app store, Android asks for
> permission to install from an unknown source the first time. This is expected.

## 1.2 The public website

The website can be browsed without an account. These are the pages available from the top
navigation.

1. **Home** — what Runiac is, with an email sign-up for updates.

   ![Home](screenshots/01-unregistered/web/01-home-landing.png){ width=95% }

2. **Features**.

   ![Features](screenshots/01-unregistered/web/02-features.png){ width=95% }

3. **How it works**.

   ![How it works](screenshots/01-unregistered/web/03-how-it-works.png){ width=95% }

4. **Pricing** — Free and Premium compared.

   ![Pricing](screenshots/01-unregistered/web/04-pricing.png){ width=95% }

5. **FAQ**.

   ![FAQ](screenshots/01-unregistered/web/05-faq.png){ width=95% }

6. **Documents** — project documents, filterable by category.

   ![Documents](screenshots/01-unregistered/web/06-documents.png){ width=95% }

7. **Document detail** — preview or download a single document.

   ![Document detail](screenshots/01-unregistered/web/07-document-detail.png){ width=95% }

8. **About us**.

   ![About us](screenshots/01-unregistered/web/08-about-us.png){ width=95% }

9. **Sign in** — the entry point for administrators.

   ![Sign in](screenshots/01-unregistered/web/09-sign-in.png){ width=95% }

Four legal pages are linked from the footer.

**Privacy Policy**

![Privacy Policy](screenshots/01-unregistered/web/10-legal-privacy.png){ width=95% }

**Terms of Service**

![Terms of Service](screenshots/01-unregistered/web/11-legal-terms.png){ width=95% }

**Cookie Notice**

![Cookie Notice](screenshots/01-unregistered/web/12-legal-cookies.png){ width=95% }

**Account Deletion** — this page explains that deletion is done inside the app (section 2.9), what
is erased and what is kept, and it keeps an email route only for someone who can no longer sign in.

![Account Deletion](screenshots/01-unregistered/web/13-legal-account-deletion.png){ width=95% }

## 1.3 Subscribing to Runiac updates by email

You do not need an account to hear from Runiac. The home page carries an email sign-up, and
Runiac uses **double opt-in**: it will not add you to the list until you click a link in an email
sent to the address you typed. Nothing is sent to an address that has not confirmed itself.

1. On the home page, type your email address into the field beside **Notify Me**. The line
   underneath states what you are agreeing to and links to the Privacy Policy.

   ![Email sign-up](screenshots/01-unregistered/web/14-newsletter-signup.png){ width=95% }

2. Press **Notify Me**. The button reads *Submitting…* while the request is sent, then the page
   confirms: **Thanks. Check your inbox to confirm your subscription.** The field is cleared.

   ![Sign-up accepted](screenshots/01-unregistered/web/15-newsletter-signup-success.png){ width=95% }

3. Open your inbox. A confirmation email arrives with a single **Confirm my subscription** link.
   If you did not request it, you can ignore the email and nothing further happens — the address
   stays unconfirmed and receives nothing.

   ![Confirmation email](screenshots/01-unregistered/web/16-newsletter-confirmation-email.png){ width=95% }

4. Press **Confirm my subscription**. The link opens Runiac and confirms the address:
   **You're subscribed.**

   ![Subscription confirmed](screenshots/01-unregistered/web/17-newsletter-confirmed.png){ width=95% }

> **Note.** The confirmation link is valid for seven days. Every newsletter Runiac sends also
> carries an unsubscribe link, which removes the address immediately.

## 1.4 Creating an account

1. Open the app. The welcome screen offers **Sign up** and **Log in**, and links to the Terms and
   Privacy Policy.

   ![Welcome](screenshots/01-unregistered/app/01-welcome.png){ width=38% }

2. Press **Sign up**. Enter your email and a password, then press **Create account**. You may
   instead press **Continue with Google**.

   ![Create your account](screenshots/01-unregistered/app/02-sign-up.png){ width=38% }

3. If you already have an account, press **Log in** and enter your email and password.

   ![Welcome back](screenshots/01-unregistered/app/03-log-in.png){ width=38% }

4. If you have forgotten your password, press **Forgot password?**, enter your email and press
   **Send reset link**.

   ![Reset your password](screenshots/01-unregistered/app/04-forgot-password.png){ width=38% }

## 1.5 First-run setup

After creating an account, Runiac asks a short set of questions and builds your first plan. The
questionnaire is 16 steps; you can change any answer later.

1. **Welcome** — press **Start setup**.

   ![Onboarding welcome](screenshots/01-unregistered/app/onboarding-step-01.png){ width=38% }

2. **What would you like to work toward?** Choose the goal that fits best.

   ![Goal](screenshots/01-unregistered/app/onboarding-step-02.png){ width=38% }

3. **How consistently have you been running?**

   ![Consistency](screenshots/01-unregistered/app/onboarding-step-03.png){ width=38% }

4. **How often are you running right now?**

   ![Runs per week](screenshots/01-unregistered/app/onboarding-step-04.png){ width=38% }

5. **What is your longest comfortable recent run?**

   ![Longest recent run](screenshots/01-unregistered/app/onboarding-step-05.png){ width=38% }

6. **Where are you starting from?**

   ![Starting point](screenshots/01-unregistered/app/onboarding-step-06.png){ width=38% }

7. **How many days a week can you run?**

   ![Days per week](screenshots/01-unregistered/app/onboarding-step-07.png){ width=38% }

8. **Which days feel best?** Choose as many as the previous answer allows.

   ![Preferred days](screenshots/01-unregistered/app/onboarding-step-08.png){ width=38% }

9. **When do you usually prefer to run?**

   ![Time of day](screenshots/01-unregistered/app/onboarding-step-09.png){ width=38% }

10. **How long should each beginner session be?**

    ![Session length](screenshots/01-unregistered/app/onboarding-step-10.png){ width=38% }

11. **Where do you usually run?**

    ![Where you run](screenshots/01-unregistered/app/onboarding-step-11.png){ width=38% }

12. **What kind of support keeps you going?**

    ![Support](screenshots/01-unregistered/app/onboarding-step-12.png){ width=38% }

13. **Anything we should keep in mind?** — health and safety.

    ![Health](screenshots/01-unregistered/app/onboarding-step-13.png){ width=38% }

14. **During activity, do you ever notice any of these?**

    ![Symptoms](screenshots/01-unregistered/app/onboarding-step-14.png){ width=38% }

15. **How would you like your training plan to feel?**

    ![Plan style](screenshots/01-unregistered/app/onboarding-step-15.png){ width=38% }

16. **Your plan preview is ready.** Review the suggested plan and press **Continue with this
    plan**, or **Edit answers** to go back.

    ![Plan preview](screenshots/01-unregistered/app/onboarding-step-16.png){ width=38% }

Throughout setup your running buddy offers a short tip. Press **Dismiss** to close it.

![Guide overlay](screenshots/01-unregistered/app/onboarding-guide-overlay.png){ width=38% }

## 1.6 The app tour

The first time you reach the Home screen, a twelve-step tour introduces the app. Press **Next**
to advance or **Skip tour** to leave it. You can replay it later from **Menu → App tour**.

**Tour step 1**

![Tour step 1](screenshots/01-unregistered/app/app-tour-step-01.png){ width=38% }

**Tour step 2**

![Tour step 2](screenshots/01-unregistered/app/app-tour-step-02.png){ width=38% }

**Tour step 3**

![Tour step 3](screenshots/01-unregistered/app/app-tour-step-03.png){ width=38% }

**Tour step 4**

![Tour step 4](screenshots/01-unregistered/app/app-tour-step-04.png){ width=38% }

**Tour step 5**

![Tour step 5](screenshots/01-unregistered/app/app-tour-step-05.png){ width=38% }

**Tour step 6**

![Tour step 6](screenshots/01-unregistered/app/app-tour-step-06.png){ width=38% }

**Tour step 7**

![Tour step 7](screenshots/01-unregistered/app/app-tour-step-07.png){ width=38% }

**Tour step 8**

![Tour step 8](screenshots/01-unregistered/app/app-tour-step-08.png){ width=38% }

**Tour step 9**

![Tour step 9](screenshots/01-unregistered/app/app-tour-step-09.png){ width=38% }

**Tour step 10**

![Tour step 10](screenshots/01-unregistered/app/app-tour-step-10.png){ width=38% }

**Tour step 11**

![Tour step 11](screenshots/01-unregistered/app/app-tour-step-11.png){ width=38% }

**Tour step 12**

![Tour step 12](screenshots/01-unregistered/app/app-tour-step-12.png){ width=38% }

---

# Part 2 — Registered user (Basic)

Everything in this part is available to every registered user. Premium adds to it; it does not
replace it.

## 2.1 Home

Home is an illustrated stage map of your week. Each stepping stone is one day; your running
buddy stands on today.

![Home stage map](screenshots/02-registered-basic/home-stage-map.png){ width=38% }

Your buddy gives a short message about today's session. Press the **✕** to close it.

![Guide message](screenshots/02-registered-basic/home-stage-map-guide-bubble.png){ width=38% }

Press **Menu** (top right) to open the rest of the app: your profile and level, current streak,
notifications, Friends, Challenge, Settings and the app tour.

![Home menu](screenshots/02-registered-basic/home-menu-expanded.png){ width=38% }

Press the notification entry to see your inbox — challenge invitations, badges and results.

![Notifications](screenshots/02-registered-basic/notifications-inbox.png){ width=38% }

## 2.2 Going for a run

1. Press the **Run** tab. The map centres on your location and the sheet shows today's planned
   session and a **Start run** button. The pill at the top shows GPS status — here, **GPS ready**.

   ![Pre-run](screenshots/02-registered-basic/run-pre-run-setup.png){ width=38% }

2. Before your first run, press the **gear** icon to set spoken updates: language, distance
   interval, time interval, and what each announcement includes.

   ![Run settings](screenshots/02-registered-basic/run-voice-settings.png){ width=38% }

3. Press **Preview voices** to hear each announcement before you run.

   ![Voice preview](screenshots/02-registered-basic/run-voice-preview.png){ width=38% }

4. Press **Start run**. The first time, iOS asks for location access — choose **Allow While Using
   App**. Runiac cannot track a run without it.

   ![Location permission](screenshots/02-registered-basic/run-location-permission.png){ width=38% }

5. iOS then asks for Motion & Fitness access, used to detect stops and step rate. Press **Allow**.

   ![Motion permission](screenshots/02-registered-basic/run-motion-permission.png){ width=38% }

6. During the run the map follows you and the sheet shows distance, elapsed time and current
   pace. Press **Pause** to stop the timer.

   ![Live tracking](screenshots/02-registered-basic/run-tracking-live.png){ width=38% }

7. While paused, press **Resume** to continue, or press and hold **Hold to end run** for about a
   second and a half to finish. The hold is deliberate, so a run cannot be ended by accident.

   ![Paused](screenshots/02-registered-basic/run-paused.png){ width=38% }

> **Note.** After ending a run Runiac offers a guided cool-down (a slow walk followed by
> stretches) before showing the summary. You may also skip straight to the summary.

## 2.3 Your progress and plan

The **You** tab has two sections, **Progress** and **Plans**.

Progress shows your weekly distance graph, filterable by week, month, year or all time.

![Progress](screenshots/02-registered-basic/you-progress.png){ width=38% }

Below the graph, **Recent Running** lists your latest runs. Press **See all** for the full
history.

![Recent running](screenshots/02-registered-basic/you-recent-running.png){ width=38% }

**Activity History** lists every run, grouped by month and filterable by year and month.

![Activity history](screenshots/02-registered-basic/you-activity-history.png){ width=38% }

The **Plans** section shows your current plan and this week's sessions. Basic users also see an
**Unlock Runiac Premium** card here.

![Plans](screenshots/02-registered-basic/you-plans-with-premium-upsell.png){ width=38% }

Press **View Full Plan** to see every week of the plan.

![Plan detail](screenshots/02-registered-basic/you-plan-detail-run-walk-foundation.png){ width=38% }

Press any session to see its detail — duration, type, effort, and a breakdown of the session.

![Workout detail](screenshots/02-registered-basic/you-workout-detail.png){ width=38% }

To move a session, press **Edit schedule**, choose an open day and a time, then press **Save New
Schedule**. Days already used by the plan cannot be chosen.

![Edit schedule](screenshots/02-registered-basic/you-edit-schedule.png){ width=38% }

![Time picker](screenshots/02-registered-basic/you-edit-schedule-time-picker.png){ width=38% }

## 2.4 Feed

The Feed shows runs shared by you and the people you follow, each with its route, distance, pace
and time.

![Feed](screenshots/02-registered-basic/feed-timeline.png){ width=38% }

Press the comment icon to read and add comments.

![Comments](screenshots/02-registered-basic/feed-comment-sheet.png){ width=38% }

Press **…** on a post for further actions.

![Post options](screenshots/02-registered-basic/feed-post-options.png){ width=38% }

> **Caution.** **Report** submits immediately — there is no confirmation step and no way to undo
> it from inside the app. Only use it when you mean to.

## 2.5 Leaderboard

The Leaderboard ranks runners by monthly XP within their own planning region. Choose a region on
the map to preview its standings.

![Leaderboard](screenshots/02-registered-basic/leaderboard-region-map.png){ width=38% }

Press **View More Ranking** for the full list.

![Full ranking](screenshots/02-registered-basic/leaderboard-full-ranking.png){ width=38% }

Press any runner to see their public achievements. Only public information is shown.

![Runner profile](screenshots/02-registered-basic/leaderboard-runner-profile.png){ width=38% }

Press the leagues icon to see the ten leagues and the level range each covers.

![Leagues](screenshots/02-registered-basic/leaderboard-leagues.png){ width=38% }

Press the information icon for how ranking, monthly refresh and leagues work.

![Leaderboard tips](screenshots/02-registered-basic/leaderboard-info.png){ width=38% }

Press **Share My Rank** to produce a shareable rank card.

![Share my rank](screenshots/02-registered-basic/leaderboard-share-my-rank.png){ width=38% }

## 2.6 Friends

Open **Menu → Friends**. The screen has four tabs.

**Friends** — everyone you are connected to.

![Friends tab](screenshots/02-registered-basic/friends-list.png){ width=38% }

**Search** — find other runners by name or nickname.

![Search tab](screenshots/02-registered-basic/friends-search.png){ width=38% }

**Requests** — incoming and outgoing friend requests.

![Requests tab](screenshots/02-registered-basic/friends-requests.png){ width=38% }

**Blocked** — runners you have blocked.

![Blocked tab](screenshots/02-registered-basic/friends-blocked.png){ width=38% }

On the **Requests** tab, press **Accept** or **Decline**. Press **…** next to a friend to remove,
block or report them.

![Friend actions](screenshots/02-registered-basic/friends-action-sheet.png){ width=38% }

Press a friend's avatar to open their runner profile.

![Friend profile](screenshots/02-registered-basic/friends-runner-profile.png){ width=38% }

## 2.7 Challenges

Open **Menu → Challenge**. Nine distance tiers are offered from 10K to 1000K. Tiers marked
**Premium** require a Premium subscription.

![Challenge tiers](screenshots/02-registered-basic/challenge-explore.png){ width=38% }

Press a tier to see its rules — target distance, duration, participants, personal minimum, and
how the group goal works.

![Tier detail](screenshots/02-registered-basic/challenge-tier-detail-free.png){ width=38% }

Press **Create challenge** to open a lobby. You are the owner.

![Lobby](screenshots/02-registered-basic/challenge-lobby.png){ width=38% }

Press **Invite friends** and choose who to invite, up to the tier's limit.

![Friend picker](screenshots/02-registered-basic/challenge-friend-picker.png){ width=38% }

![Invited](screenshots/02-registered-basic/challenge-friend-picker-selected.png){ width=38% }

Press **Start challenge**. If nobody has joined yet, Runiac confirms that you will run it solo.

![Start confirmation](screenshots/02-registered-basic/challenge-start-confirm.png){ width=38% }

Invitations addressed to you appear under **Invitations**.

![Invitations](screenshots/02-registered-basic/challenge-invitations.png){ width=38% }

Press one to see the rules, then **Accept** or **Decline**.

![Invitation detail](screenshots/02-registered-basic/challenge-invitation-detail.png){ width=38% }

When a challenge finishes and you met the target, Runiac awards a badge.

![Badge earned](screenshots/02-registered-basic/challenge-result-badge-earned.png){ width=38% }

Past challenges are listed under **History**.

![History](screenshots/02-registered-basic/challenge-history.png){ width=38% }

## 2.8 Profile and settings

Open **Menu → Profile**. The profile shows your level and progress, max streak and total distance,
the chip beside your name showing your subscription — **BASIC** or **PREMIUM** — and, further
down, your challenge badge case and **YOUR TRAINING PROFILE**: the answers from onboarding that
your plan was built from.

![Training profile](screenshots/02-registered-basic/profile-training-and-manage.png){ width=38% }

Below that, the **MANAGE** section is the entry point to everything else.

![Manage](screenshots/02-registered-basic/profile-manage-rows.png){ width=38% }

**Edit profile** — change your name, nickname, date of birth, weight and region.

![Edit profile](screenshots/02-registered-basic/profile-edit-profile.png){ width=38% }

**Running buddy** — change your guide character. Bolt is available to everyone; Cap, Mila and Ivy
are Premium.

![Character selection](screenshots/02-registered-basic/character-selection.png){ width=38% }

**Privacy & Safety** — control whether your recent run totals personalise the guide.

![Privacy and safety](screenshots/02-registered-basic/settings-privacy-safety.png){ width=38% }

**Notifications** — reminder settings.

![Notification centre](screenshots/02-registered-basic/settings-notification-center.png){ width=38% }

**Feedback** — report a bug or make a suggestion.

![Feedback](screenshots/02-registered-basic/settings-feedback.png){ width=38% }

**About Runiac** — version and project information, with links to the legal pages and open-source
licences.

![About](screenshots/02-registered-basic/settings-about-runiac.png){ width=38% }

![Licences](screenshots/02-registered-basic/settings-licenses.png){ width=38% }

**Settings** is deliberately not in this list. App-level controls — distance units, private
profile, haptic feedback, and keeping the screen on during runs — sit with the other app-level
entries under **Menu → Settings** on the Home screen.

![Settings](screenshots/02-registered-basic/settings-app.png){ width=38% }

To start the questionnaire again, use **Edit profile → Retake onboarding**. Runiac warns you
first, because a new plan resets your consistency streak.

![Retake confirmation](screenshots/02-registered-basic/profile-retake-onboarding-confirm.png){ width=38% }

**Sign out** is the second-last row. Confirm with **Sign out**, or keep your session with **Stay
signed in**.

![Sign out](screenshots/02-registered-basic/profile-sign-out-confirm.png){ width=38% }

## 2.9 Deleting your account

**Delete account** is the last row, styled apart from the rest in red. It erases your Runiac
account from inside the app — no email to support, no waiting period.

> **Warning.** Deletion is immediate and irreversible. There is no grace period, nothing is
> archived for you, and signing in again does not bring anything back. Signing up with the same
> email afterwards creates a completely new, empty account.

1. Open **Menu → Profile** and press **Delete account** at the bottom of MANAGE.

2. Read what happens. **What is deleted** covers your profile, every run, route and activity
   summary, your plans, XP, level, streak and leaderboard standing, your friends, challenges,
   badges and notifications, and everything you posted to the Feed.

   **What is kept, without your name on it** covers reports you filed or that were filed about
   you, feedback you sent, and records of administrator actions. These are retained so that
   deleting an account cannot be used to erase a moderation record; your name and account are
   removed from them.

   ![Delete account](screenshots/02-registered-basic/profile-delete-account.png){ width=38% }

3. Type **DELETE** in the confirmation field. The button stays disabled until the word matches
   exactly, then turns red.

   ![Type DELETE](screenshots/02-registered-basic/profile-delete-account-typed.png){ width=38% }

4. Press **Delete my account**. Runiac asks once more. Press **Cancel** to stop, or **Delete now**
   to go ahead.

   ![Confirm deletion](screenshots/02-registered-basic/profile-delete-account-confirm.png){ width=38% }

5. On **Delete now** the account is erased and you are returned to the welcome screen, signed out.
   If anything goes wrong the screen stays open with an explanation, and you stay signed in so you
   can try again.

> **Note.** The steps above are the way to delete an account. The **Account Deletion** page in the
> website footer (see section 1.2) describes this same flow, and offers an email request only as a
> fallback for someone who can no longer sign in.

## 2.10 What Basic users see instead of Premium features

Premium features are never hidden — they are shown in a locked state so you can see what is on
offer.

Pressing a Premium feature opens the subscription sheet, where you can choose a monthly or yearly
plan.

**Yearly selected** (the default).

![Subscription sheet, yearly](screenshots/02-registered-basic/paywall-premium-sheet.png){ width=38% }

**Monthly selected.**

![Subscription sheet, monthly](screenshots/02-registered-basic/paywall-premium-sheet-monthly.png){ width=38% }

These are the points where a Basic user meets the subscription sheet.

1. **Challenge tiers from 100K upward.** The tile is marked **Premium**, and pressing **Create
   challenge** opens the sheet.

   ![Locked challenge tier](screenshots/02-registered-basic/challenge-tier-detail-premium-locked.png){ width=38% }

2. **Explain today's workout** on a planned session opens the sheet instead of the briefing.

   ![Workout briefing locked](screenshots/02-registered-basic/you-workout-briefing-paywall.png){ width=38% }

3. **Cap, Mila and Ivy** in the character picker are marked **Premium**; pressing one opens the
   sheet.

   ![Character locked](screenshots/02-registered-basic/character-selection-premium-paywall.png){ width=38% }

4. **You → Plans** shows the **Unlock Runiac Premium** card (see section 2.3).

---

# Part 3 — Registered user (Premium)

Premium users keep everything in Part 2. This part shows only what changes.

> **Premium never confers a competitive advantage.** XP, level, rank, streak and leaderboard
> score are calculated by the server under exactly the same rules for both tiers. Premium sells
> coaching, analysis and presentation.

Your profile shows a **PREMIUM** chip beside your name.

![Premium profile](screenshots/03-registered-premium/profile-overview-premium.png){ width=38% }

## 3.1 Post-run analysis

After a run, the summary shows distance, pace, time, splits and a pace graph.

![Summary](screenshots/03-registered-premium/run-summary-top.png){ width=38% }

Premium unlocks the **Coaching Summary** and **Next Focus** cards, which a Basic user sees in a
locked state.

![Coaching summary](screenshots/03-registered-premium/run-summary-analysis.png){ width=38% }

Press **More Details** for the Advanced Analysis screen — fastest and slowest pace, pace
stability, and pace over distance.

![Advanced analysis](screenshots/03-registered-premium/run-advanced-analysis.png){ width=38% }

## 3.2 AI activity feedback

Press the sparkle icon on the summary for AI feedback on the run, in four steps.

**Step 1 — Summary**

![Activity feedback, step 1](screenshots/03-registered-premium/run-activity-feedback-1.png){ width=38% }

**Step 2**

![Activity feedback, step 2](screenshots/03-registered-premium/run-activity-feedback-2.png){ width=38% }

**Step 3**

![Activity feedback, step 3](screenshots/03-registered-premium/run-activity-feedback-3.png){ width=38% }

**Step 4 — Next focus**

![Activity feedback, step 4](screenshots/03-registered-premium/run-activity-feedback-4.png){ width=38% }

## 3.3 AI workout briefing

On any planned session, press the sparkle icon to have the session explained before you run it.

**Step 1 — Today's session**

![Workout briefing, step 1](screenshots/03-registered-premium/you-workout-briefing-1.png){ width=38% }

**Step 2**

![Workout briefing, step 2](screenshots/03-registered-premium/you-workout-briefing-2.png){ width=38% }

**Step 3**

![Workout briefing, step 3](screenshots/03-registered-premium/you-workout-briefing-3.png){ width=38% }

**Step 4**

![Workout briefing, step 4](screenshots/03-registered-premium/you-workout-briefing-4.png){ width=38% }

## 3.4 Sharing

Press the share icon on the summary to produce an achievement card.

![Achievement card](screenshots/03-registered-premium/run-share-achievement-card.png){ width=38% }

Press **Share Route** to publish the run to the Feed. Review the card, then press **Post to
Feed**.

![Share route](screenshots/03-registered-premium/run-share-route-to-feed.png){ width=38% }

## 3.5 Challenges and characters

All nine challenge tiers are available, with no **Premium** marking.

![All tiers](screenshots/03-registered-premium/challenge-explore-all-unlocked.png){ width=38% }

![Premium tier](screenshots/03-registered-premium/challenge-tier-detail-premium-unlocked.png){ width=38% }

All four running buddies can be chosen.

![All characters](screenshots/03-registered-premium/character-selection-all-unlocked.png){ width=38% }

## 3.6 Plans

The **Plans** section no longer shows the upsell card.

![Plans without upsell](screenshots/03-registered-premium/you-plans-no-upsell.png){ width=38% }

![Plan detail](screenshots/03-registered-premium/you-plan-detail-10k-build.png){ width=38% }

---

# Part 4 — Platform Administrator

The Platform Administrator works in a **web console**, not the mobile app. Administration is
governed by `userRole`, which is separate from the Basic/Premium subscription status.

> **About these screenshots.** Part 4 was captured against a local Firebase emulator holding a
> seeded demo database, so that no real runner's personal data appears in this document. The seed
> populates users, reports, activities and the audit log; it does not populate feedback, project
> documents, newsletter subscribers, or a completed leaderboard period, so those pages are shown
> in their empty state. On a live database each of them lists real records.

## 4.1 Signing in

1. Open the Runiac website and press **Sign in**.
2. Enter the administrator email and password and press **Sign in**.

   ![Admin sign in](screenshots/04-platform-administrator/01-admin-sign-in.png){ width=95% }

3. An account whose `userRole` is `platformAdmin` is taken to the console. Any other account is
   returned to the public site.

## 4.2 Overview

The Overview is the control centre: unresolved reports, pending exception cases, registered users
by tier, runs recorded, app errors, failed backend jobs, an active-users trend, and system health.

![Overview](screenshots/04-platform-administrator/02-overview.jpg){ width=95% }

## 4.3 Exception Queue

Moderation and integrity cases — reported posts, users, routes and plans, plus suspicious XP
flagged by anomaly detection. Filter by type, severity and status, then resolve or dismiss.

![Exception queue](screenshots/04-platform-administrator/03-exception-queue.jpg){ width=95% }

## 4.4 Users & Roles

Search the user directory. Each row shows role, subscription, level, account state and join date.

![Users and roles](screenshots/04-platform-administrator/04-users-and-roles.jpg){ width=95% }

Press **View** to expand a user. From here you can change the role, suspend the account, set the
subscription, issue a moderation action, or clear an avatar. **Every action requires a reason and
is audited.**

![User operations](screenshots/04-platform-administrator/04b-user-operations-panel.jpg){ width=95% }

Recent administrator actions are listed at the bottom of the page.

![Admin action history](screenshots/04-platform-administrator/04c-admin-action-history.jpg){ width=95% }

## 4.5 XP & Gamification Rules

Publishes the rule configuration that Cloud Functions apply: XP per activity, per kilometre and
per active minute, plan-completion bonus, caps, cool-down band, level curve and streak rewards.

> This page **never edits a user's XP**. It publishes rules that apply from a user's next
> completed activity onward; XP already awarded is not recomputed.

![XP and gamification](screenshots/04-platform-administrator/05-xp-and-gamification.jpg){ width=95% }

## 4.6 Leaderboard Oversight

Monitor the aggregation job, review the current period, check coverage and eligibility, and
request a recalculation. Score calculation stays with the backend — the console never edits a
score.

![Leaderboard oversight](screenshots/04-platform-administrator/06-leaderboard-oversight.jpg){ width=95% }

## 4.7 App Paywall

Edits the upsell sheet Basic users see: title, badge, feature list, prices and the subscribe
button. This page publishes **display copy only** — it never grants Premium.

![App paywall](screenshots/04-platform-administrator/07-app-paywall.jpg){ width=95% }

## 4.8 Website Content

Edits the marketing site, tabbed by destination page (Home, Pricing, FAQ, Documents, Download,
About, Site-wide). Expand a section, edit it, then press **Save changes**.

![Website content](screenshots/04-platform-administrator/08-website-content.jpg){ width=95% }

## 4.9 Project Documents

Upload and manage the PDFs shown on the public Documents page. Give a title, category and
document date, choose the file, then press **Upload document**.

![Project documents](screenshots/04-platform-administrator/09-project-documents.jpg){ width=95% }

## 4.10 Feedback & Complaints

An inbox grouped by auto-classified category. Automation summarises and de-duplicates; the
administrator reviews what is escalated.

![Feedback](screenshots/04-platform-administrator/10-feedback-and-complaints.jpg){ width=95% }

## 4.11 Newsletter

Two tabs: **Subscribers** and **Campaigns**. Manage the subscriber list, and compose, test and
queue campaigns. Sending itself runs as a backend job.

![Newsletter](screenshots/04-platform-administrator/11-newsletter.jpg){ width=95% }

## 4.12 App Errors

Grouped error reports from the Flutter app and Cloud Functions, with severity and status. Reports
are sanitised server-side — no GPS routes, precise location, credentials or profile details.

![App errors](screenshots/04-platform-administrator/12-app-errors.jpg){ width=95% }

## 4.13 Automation & Policy Settings

Four saved configurations. **Feature access** sets the minimum tier for each gated feature;
**Challenge tier access** and **Character access** do the same for challenge tiers and guide
characters; **Moderation automation** sets auto-hide and escalation thresholds.

![Automation and policy](screenshots/04-platform-administrator/13-automation-and-policy.jpg){ width=95% }

## 4.14 Governance & Audit Log

A chronological record of administrator actions and system events — role changes, subscription
changes, plan publishes, rule activations and backend job outcomes. Entries attributed to
*system* are backend-generated.

![Governance and audit](screenshots/04-platform-administrator/14-governance-and-audit.jpg){ width=95% }

## 4.15 Signing out

Press **Sign out** at the bottom of the sidebar. You are returned to the public site.

---

## Appendix A — Capture conditions

So that the screenshots can be reproduced and their limits understood:

| Item | Detail |
| --- | --- |
| Mobile app | Flutter debug build on an **iPhone 17 simulator** (iOS 26.5), against the production Firebase project |
| Basic screens | Captured on a Basic account |
| Premium screens | Captured on a Premium account with real run history |
| Profile management and account deletion (2.8, 2.9) | Re-captured for version 1.1 on a Basic QA account (`qa-a5-001@runiacqa.dev`). These screens show no account-specific data, so no personal information appears. The confirmation dialog in 2.9 was dismissed with **Cancel** — no account was deleted |
| Leaderboard (Part 2.5) | Captured against a built-in mock dataset so the board is populated; no mock data was written to production |
| Social screens | Friends, requests, invitations and comments used temporary mock records, deleted afterwards |
| Admin console | Run against a local Firebase emulator with seeded demo data (1 administrator, 10 runners, 6 reports, 15 activities, 3 audit entries), so no real user's personal data appears |
| Public website | Production build of the marketing site |
| Email subscription (1.3) | Performed for real against the production site and the deployed newsletter backend. The confirmation email screenshot is cropped to the message body so that the recipient's address does not appear in this document |

### Known limitations of these screenshots

1. **The live-run screen shows `0.00 km`.** The iOS simulator's synthetic GPS fixes report an
   accuracy in the 25–100 m band, and the tracking session discards samples above its accepted
   accuracy threshold. The timer runs and the map follows, but no distance accrues. A screenshot
   of a run accumulating distance must be taken on a physical device.
2. **The cool-down screens are not included.** They appear only immediately after a run is
   completed and saved, which would have written a real activity to a live account.
3. **The XP & Streak Update screen is not included.** It is reachable only immediately after
   finishing a run — opening a past run from Activity History does not offer it.

### What version 1.1 re-captured, and what it did not

Version 1.1 re-shot only the screens the build had actually changed. Everything else is the
version 1.0 capture, deliberately kept so that the document is not churned for no reason.

**Re-captured**

| Screens | Why |
| --- | --- |
| Profile → MANAGE, sign-out, and the new Delete account flow (2.8, 2.9) | **Watch & Health Apps** and its screen were removed from the app, and **Delete account** was added. `settings-watch-health.png` was deleted with the feature |
| The website **Account Deletion** legal page (1.2) | The page used to tell the reader to email a deletion request. It now documents the in-app **Delete account** flow, keeping email only as a fallback for someone locked out of their account |
| All fifteen administration-console captures, covering its thirteen pages (Part 4) | Each console page carried a paragraph of description under its title; those were removed, so every previous capture showed a header that no longer exists |

**Added**

| Screens | Why |
| --- | --- |
| The email-subscription walkthrough (1.3), four images | The unregistered visitor could subscribe to updates, but the manual documented no part of it |

**Deliberately not re-captured**

The other twelve marketing-site pages in 1.2 — Home, Features, How it works, Pricing, FAQ,
Documents, Document detail, About us, Sign in, and the Privacy Policy, Terms of Service and Cookie
Notice legal pages — were **not** re-shot for version 1.1. No change to them was reported, and they
were not individually re-verified against the live site for this revision, so they remain the
version 1.0 captures and should be treated as dated 4 August 2026. The same applies to every Part 2 and Part 3 screen outside 2.8 and 2.9, and to the
administration console's sign-in page, which is the public website's sign-in page and was not
affected by the console change.

### Screens deliberately excluded

The following exist in the codebase but have no entry point in the current build, so they are not
documented: the Maps tab, Saved Routes, Shared Route Detail, and the Expert Plan list and detail
screens. Expert plan review likewise has no administrator interface yet.
