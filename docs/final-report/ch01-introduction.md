# Chapter 1: Introduction

## 1.1 Team Structure

The Runiac project required mobile development, backend logic, database design, interface design, testing and project management to be handled in a coordinated way. The team structure was arranged so that each member had a clear main responsibility while still being able to support other members when needed.

### 1.1.1 Roles and Responsibilities

| Role | Member | UOW ID | Primary responsibilities |
| --- | --- | --- | --- |
| Project Manager | Lee Jinseo | 9096978 | Overall project planning and scheduling; sprint coordination and stand-up facilitation; risk monitoring and mitigation; documentation quality control; integration point across all functional roles |
| Mobile Frontend Developer | Kaif Lim Er | 7906742 | Flutter application implementation; interface assembly from design specifications; GPS and sensor integration; map rendering and leaderboard visualisation; local state management and offline behaviour |
| Backend Developer | Kenji Yeo | 7906833 | Cloud Functions and callable API design on Firebase; authentication and session management; server-side aggregation for the location-based leaderboard; push notification orchestration; third-party API integration |
| Database and Data Engineer | Liu Zhihui | 9182123 | Firestore data model and security rules; regional aggregation for leaderboard and progression; time-series storage of activity data; aggregation jobs; backup and migration strategy |
| UI/UX Designer and QA Lead | Konada Obadiah Nahshon | 10266652 | Beginner-focused interface design and user flow definition; wireframes, mock-ups and design system maintenance; usability testing; test plan authoring, manual QA execution and defect tracking; accessibility review |

*Table 1.1: Team roles and responsibilities*

## 1.2 Current Market Survey

Before Runiac's features were defined, the team reviewed several existing running and fitness applications to understand what is already available and where the main gaps lie. The comparison focuses on Strava, Nike Run Club, Runkeeper, Whoop and Garmin Connect because these represent different types of users, from casual runners to more serious athletes.

### 1.2.1 Available Software in the Market

The applications surveyed represent three distinct positioning strategies: social-first activity tracking (Strava), guided coaching for newer runners (Nike Run Club, Runkeeper), and physiological optimisation for serious athletes (Whoop, Garmin Connect).

| Application | Primary function | Target user segment | Pricing | Strengths | Weakness / limitations |
| --- | --- | --- | --- | --- | --- |
| Strava | Activity tracking with social network | Intermediate to advanced runners and cyclists | Freemium | Strong community and competition features | Some advanced analytics locked behind paid subscription |
| Nike Run Club | Guided running and coaching plans | Beginner to intermediate runners | Free | Beginner-friendly and free coaching content | Less advanced community competition than Strava |
| Runkeeper | GPS tracking with basic coaching | Entry-level to intermediate runners | Freemium | Simple and easy to use | Premium needed for advanced plans and insights |
| Whoop | Recovery, strain and sleep optimisation | Serious athletes and health-focused users | Subscription | Advanced recovery analytics and personalised health insights | Subscription required, no display, limited social features |
| Garmin Connect | Comprehensive fitness data hub paired with Garmin wearables | Endurance athletes and Garmin device owners | Free plus premium tier | Strong data analytics and wearable integration | Requires Garmin devices for full value |

*Table 1.2: Surveyed running and fitness applications*

### 1.2.2 How the Market Works

All five applications collect the same raw material and differ in what they do with it. Distance, pace, elevation and route come from GPS, either from the phone or from a paired watch, and heart rate from an optical wrist sensor or a chest strap. Whoop is the outlier: its band carries no GPS and depends on the paired phone for location, spending its hardware budget on continuous physiological monitoring instead. Raw samples are uploaded and processed server-side into derived metrics such as average pace, calorie estimates, heart-rate zones, training load and recovery scores. Strava and Garmin present those per activity; Whoop presents them as longitudinal trends across weeks.

Coaching separates the market more sharply than tracking does. Nike Run Club provides audio-guided runs, and Runkeeper offers fixed beginner programmes such as a multi-week 5 km plan. Garmin Coach and Whoop give more advanced guidance, but both depend on wearable-derived metrics and assume a user who is already comfortable reading performance data. Strava offers almost no native coaching. A beginner is therefore left choosing between a static plan that never interprets itself and an advanced system that is too data-heavy to be useful in the first month.

Motivation is delivered through three mechanisms across the whole market: badges and achievements, social comparison through friend feeds and leaderboards, and time-bound challenges. Strava's segments, where users compete over the same stretch of road, are the most game-like mechanic in mainstream use, and they remain a thin layer on top of conventional tracking. Everything else is shared baseline: activity history, training plans, wearable synchronisation and activity sharing appear in all five. That baseline supports tracking, analysis and light engagement well. It does not address sustaining a habit through the weeks in which a beginner is most likely to stop.

### 1.2.3 Detailed Feature Comparison

The matrix below compares the surveyed incumbents against Runiac. A check mark indicates the feature is present and well supported; "limited" indicates it exists but is restricted in scope or accessibility.

| Feature | NRC | Runkeeper | Strava | Whoop | Garmin | Runiac |
| --- | --- | --- | --- | --- | --- | --- |
| User account and login required | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Profile creation and editing | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Beginner-targeted onboarding flow | ✓ | | | | | ✓ |
| In-app tutorial / first-run guide | ✓ | ✓ | | ✓ | | ✓ |
| GPS-based activity tracking | ✓ | ✓ | ✓ | | ✓ | ✓ |
| Calorie estimation | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Manual activity entry | ✓ | ✓ | ✓ | | ✓ | ✓ |
| F1 Collect running activity data | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| F2 Estimate running effects and provide analysis | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| F3 Supply running advice and schedule a plan | ✓ | ✓ | | ✓ | ✓ | ✓ |
| Personalised training plans | ✓ | ✓ | | ✓ | ✓ | ✓ |
| F4 Remind user of running or rest | ✓ | ✓ | limited | ✓ | ✓ | ✓ |
| F5 Social connection, sharing and competition | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| F6 Streak and consistency tracking | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| F7 Community-driven route sharing | | limited | ✓ | | limited | ✓ |
| F8 Level-based territorial leaderboard | | | | | | ✓ |
| Beginner-tiered metric presentation | ✓ | limited | | | | ✓ |
| F9 Runner level and XP progression | | | | | | ✓ |
| Challenges and competitions | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Achievement badges and milestones | ✓ | ✓ | ✓ | | ✓ | ✓ |
| Leaderboards and segment racing | limited | | ✓ | | limited | ✓ |
| F10 AI-assisted post-run summary | | | | | | ✓ |
| Smartphone-only operation (no wearable required) | ✓ | ✓ | ✓ | | limited | ✓ |

*Table 1.3: Feature comparison against the delivered Runiac system*

### 1.2.4 Gaps and Runiac's Position

Beginners are the segment most likely to abandon a running application, and the highest dropout falls within the first four weeks. That is precisely the period the incumbents serve least well. Six gaps follow from the survey, each stated with what Runiac does about it.

| Gap in the current market | How Runiac addresses it, as delivered |
| --- | --- |
| Beginner onboarding is shallow; most applications assume an existing running habit. | A sixteen-step onboarding flow captures goal, experience level, availability, preferred days and times, session length, environment, motivation style and health considerations, resolving them into a safety band that shapes the generated plan. A twelve-screen tour then runs automatically on the first visit to the dashboard. |
| Applications provide plans and reminders but do not sufficiently support day-to-day habit maintenance once motivation drops. | F6 tracks streaks and rewards milestones, and treats the plan's own rest days as protected so that following the plan preserves the streak rather than breaking it. F4 supplies the behavioural trigger through push and device-local reminders. |
| Gamification across the market is limited to badges, streaks and segment leaderboards. No persistent progression exists. | F9 converts completed runs, distance, active duration, plan adherence and streak milestones into experience points, levels and league divisions, all computed server-side. |
| Global rankings feel unattainable and disconnected from a beginner's daily environment. | F8 ranks users within their own geographic region and within their own league division, so that competition is against peers at a comparable stage rather than against the whole population. |
| Post-run data is presented as raw metrics; beginners lack the knowledge to interpret pace, cadence or zone breakdowns. | F10 translates run data into plain-language reflection, with language-model generation for Premium users and deterministic template copy for Basic users, constrained by safety validators. |
| Whoop and Garmin require expensive proprietary hardware, excluding cost-sensitive beginners. | Smartphone-first design. Every delivered feature operates on the phone's own GPS and motion sensors, with no wearable required. |

*Table 1.4: Market gaps and Runiac's delivered response*

No mainstream application is purpose-built for the journey from beginner to committed runner. Casual and social applications are easy to start with but carry weak retention mechanics; athlete tools are analytically powerful but need expensive hardware and prior knowledge. Runiac targets the gap between them.

## 1.3 Project Scope

### 1.3.1 Problem Statement

The mobile fitness market is saturated with running applications, yet the fundamental problem of beginner retention remains unsolved. Industry observation consistently shows that most new users who download a running application abandon it within the first four weeks. That is the exact window in which habit formation either succeeds or fails.

The analysis of the current market in Section 1.2 reveals a structural gap: existing applications are designed for users who already run. Strava and Garmin Connect optimise for athletes tracking their performance. Whoop targets users already invested in physiological optimisation. Even beginner-oriented applications such as Nike Run Club and Runkeeper assume the user has the intrinsic motivation required to follow a structured plan. None of these applications is built for the most difficult problem in fitness software: converting a non-runner into a consistent runner.

Traditional running applications focus on tracking. Runiac focuses on behaviour change. This distinction shaped every feature, technical decision and design choice in the project. Tracking is treated as a baseline requirement that any modern running application must provide, while the application's true value is delivered through two pillars: habit formation support, which helps beginners remain consistent during the critical early weeks, and gamified motivation, which supplies the engagement that traditional running applications lack.

A second consideration follows from the first and became more prominent as the project progressed. Running places direct physical demands on the body, and the system cannot assume that all users share a fitness level, running experience, injury history or health condition. A beginner with no exercise background should not receive the same plan as a more experienced runner. The delivered application therefore collects health and readiness information during onboarding and resolves it into a safety band that constrains both the starting point and the rate of progression.

### 1.3.2 Target Users and User Roles

Runiac is aimed at people attempting to establish a running habit, and secondarily at those who have established one and are working toward a first distance milestone.

| Role | User type | Main access and responsibilities |
| --- | --- | --- |
| Unregistered User | A visitor with no authenticated session | Browse the public website (home, features, how-it-works, pricing, frequently asked questions, project documents, about and legal pages); subscribe to the newsletter; download the application. Within the application, reach the welcome, sign-up, log-in and password-reset screens, and step through the twelve-screen application tour. No running data is accessible. |
| Registered User (Basic) | A general runner who uses the application to record and manage running activities | GPS run tracking, activity history and summaries, the generated weekly plan, reminders, streak and consistency tracking, experience points and level progression, friends, the social feed, distance challenges below the premium tiers, publishing runs and routes to the Activity Feed, and full and equal participation in the leaderboard |
| Registered User (Premium) | A runner ready to pursue the next milestone or to understand their running in more depth | Everything available to Basic, plus advanced run analysis, AI activity feedback and workout briefings, premium sharing presentation, premium characters, and the higher challenge tiers |
| Platform Administrator | A system-level user responsible for managing the application platform | User, role, subscription and account-status management; content moderation and report handling; application error triage; progression, paywall, feature-access, challenge-access and automation configuration; leaderboard oversight and recalculation; publication of project documents; website content management; newsletter campaigns; governance audit log |

*Table 1.5: Target users and user roles*

Basic and Premium are deliberately not modelled as two different kinds of user. The distinction is carried by a single subscription field on the user record and enforced on the server, so a subscription changes only what a user can see. The Platform Administrator role is exercised entirely through the web console under a server-verified session and is not exposed anywhere in the mobile application.

### 1.3.3 Features

The proposal described the feature set in general exercise terminology. The delivered system is running-specific throughout, and the feature names below reflect that. Two features changed materially between the proposal and delivery, and both are noted where they occur.

**F1. Collect running activity data.** The application collects running activity through the smartphone's GPS and motion sensors. Distance, pace, duration, active and paused time, and the route are recorded during each run. This collected data serves as the foundation for all subsequent analysis, planning and personalised features. During onboarding the system additionally collects running experience, fitness level, personal goals and health-related considerations.

**F2. Estimate running effects and provide analysis.** Based on the collected data, the system analyses short-term and long-term running performance, including calories burned, average pace, distance totals and activity trends over time. These insights help users understand their progress and provide input to plan generation and adaptation. Advanced analysis, including a cadence series and split-level detail, is a Premium capability.

**F3. Supply running advice and schedule a running plan.** Using the onboarding profile, user-defined goals and analysed activity data, the system generates a weekly running plan tailored to the user's condition and recent performance. The plan considers experience, current level, availability, session length and health considerations to determine an appropriate starting level and progression rate, and schedules running and rest days for the coming week.

**F4. Remind the user of running or rest.** The system sends timely reminders that encourage users to follow their plans or take breaks when necessary, delivered through push notification and device-local scheduling, with an in-application inbox and per-category preferences.

**F5. Social connection, sharing and competition.** The application enables users to share running achievements and post-run summaries to an in-application social feed with likes and comments, and outward to external platforms through the operating system share sheet. It supports a friends graph with search, requests and blocking, and direct competition through distance challenges: a user creates or joins a lobby at a chosen distance tier, invites friends, and contributes distance from validated runs toward the goal, earning a badge on completion. F5 provides the social and direct-competition layer; the ranking mechanism is F8.

**F6. Streak and consistency tracking.** This feature tracks running consistency by monitoring consecutive qualifying days and overall activity patterns. Streak counts are maintained server-side, milestones at three, seven, fourteen and thirty days are rewarded, and the plan's designated rest days are treated as protected so that resting as planned does not break a streak. The home dashboard provides visual feedback on progress.

**F7. Community-driven route sharing.** A runner publishes a completed run to the Activity Feed with its route included. The backend coarsens the coordinates, renders a route preview and writes the post, and every other runner sees that route in their timeline with the run's distance and pace. Publication is open to every registered user. The separate route library the earlier documents described, with browsing, searching and saving, is not delivered.

**F8. Level-based territorial leaderboard.** This feature ranks users within a geographic region and within a league division determined by accumulated experience, so that beginners compete against others at a comparable progression stage rather than against all runners. Rankings are computed by scheduled server-side aggregation from validated activity and served from pre-aggregated records.

**F9. Runner level and XP progression system.** Completed runs, distance, active duration, plan adherence and streak milestones convert into experience points, which determine the user's level and league division. All calculation is server-owned. The league division supplies the fairness dimension of F8.

**F10. AI-assisted post-run summary.** The system provides AI-assisted reflection after each run, translating distance, pace, duration and recent activity patterns into clear, beginner-friendly insight rather than raw metrics, and offering constructive feedback for the next run. Basic users receive deterministic template-generated copy; Premium users receive language-model-generated summaries with historical comparison, subject to safety validation, daily quotas and caching. The same machinery additionally provides a home dashboard guide and pre-session workout briefings.

## 1.4 Project Development Methodology

Choosing a suitable development methodology mattered because the project faced three realities: a fixed academic deadline, a small five-person team, and a product whose central differentiator, gamification, required iterative tuning based on user response.

### 1.4.1 Comparison of Methodologies

| Methodology | Strengths | Weaknesses | Fit for Runiac |
| --- | --- | --- | --- |
| Waterfall | Clear sequential phases; strong upfront documentation; easy to plan when requirements are stable | Inflexible to change; late discovery of issues; poor fit when the product depends on user feedback | Poor: Runiac's gamification mechanics require iterative tuning |
| Scrum | Iterative sprints with frequent feedback; built-in planning, review and retrospective; strong support for evolving requirements | Requires discipline; ceremony overhead for very small teams; unstable early velocity | Strong: matches the need to refine behaviour-change features |
| Kanban | Continuous flow with no fixed iteration boundaries; visual work-in-progress limits; low ceremony overhead | Less structure for milestone planning; harder to align with academic deadlines | Moderate: good for maintenance, weak on milestone structure |
| Hybrid (Scrumban) | Combines Scrum cadence with Kanban flow; allows selective adoption | Risk of inconsistent application; requires team maturity | Possible: could be considered if Scrum overhead proved excessive |

*Table 1.6: Methodology comparison*

### 1.4.2 Selected Methodology: Scrum

The team selected Scrum. Scrum's iterative structure aligns closely with the nature of Runiac, where the value of the application depends not only on whether features are implemented correctly but on how engaging they are to real users. Gamification elements such as the territorial competition and habit-forming mechanics required continuous refinement based on user interaction rather than a one-time design decision.

Scrum was selected over the alternatives for four reasons. First, its iterative nature directly supports the continuous testing and refinement required for behaviour-change features, which cannot be effectively addressed using a linear approach such as Waterfall. Second, Scrum aligns with the MVP-first delivery strategy, allowing core features to be prioritised while less critical ones were deferred, reducing the risk of incomplete delivery within the academic timeline. Third, the fixed sprint cadence provides clear structure for tracking progress against milestone deadlines. Fourth, Scrum promotes collaboration and structured communication, which benefits a student team still developing teamwork and coordination skills.

The methodology proved its worth where it was expected to. The territorial game concept described in the proposal was reassessed during implementation and redesigned into the ranking leaderboard described in Section 1.3.3, a change that a Waterfall approach would have made far more costly to absorb.

### 1.4.3 Scrum Implementation

| Sprint | Scope | Focus | Features |
| --- | --- | --- | --- |
| Sprint 0 | Project setup | Development environment and project management setup | Flutter, Firebase, version control, backlog |
| Sprint 1 | Core foundation | Basic user flow and run tracking prototype | Authentication, profile, onboarding, F1 |
| Sprint 2 | Core support | Running analysis, training guidance and reminders | F2, F3, F4 |
| Sprint 3 | Habit and progression | Habit formation and visible progression mechanics | F6, F9 |
| Integration | Stabilisation | Integration, testing and refinement of core features | F1, F2, F3, F4, F6, F9 |
| Sprint 4 | Social and routes | Activity Feed, friends, challenges and route sharing | F5, F7 |
| Sprint 5 | Advanced gamification and AI | Leaderboard and post-run feedback | F8, F10 |
| Final integration | Delivery | Full system testing, documentation and final preparation | All features |

*Table 1.7: Sprint structure*

Jira was used as the main Scrum project management tool, carrying the product backlog, sprint backlog, task assignment and progress tracking. At the start of each sprint, selected backlog items were moved into the sprint backlog, broken down into smaller tasks, and assigned by role.

### 1.4.4 Project Timeline

| Phase | Period | Deliverable |
| --- | --- | --- |
| Proposal and market research | 4 Apr – 24 Apr 2026 | Feature proposal, competitor survey, project proposal |
| Requirements | 24 Apr – 9 May 2026 | Project Requirements Document, submitted 9 May 2026 |
| Design | 10 May – 23 May 2026 | Class, component and physical architecture diagrams, wireframes; Project Design Document submitted 23 May 2026 |
| Sprint 0 | 8 Jun – 9 Jun 2026 | Environment, Firebase project, version control, backlog |
| Sprint 1 | 8 Jun – 21 Jun 2026 | Authentication, profile, onboarding, run tracking |
| Midterm assessment | 20 Jun 2026 | Midterm deliverable |
| Sprint 2 | 22 Jun – 5 Jul 2026 | Analysis, plan generation, reminders |
| Sprint 3 | 29 Jun – 12 Jul 2026 | Streaks, experience points, level progression |
| Integration and validation | 6 Jul – 17 Jul 2026 | Core workflow integration |
| Sprint 4 | 13 Jul – 26 Jul 2026 | Activity Feed, friends and route sharing |
| Sprint 5 | 20 Jul – 2 Aug 2026 | Territorial leaderboard and AI-assisted feedback |
| System integration | 27 Jul – 7 Aug 2026 | Full system integration and stabilisation |
| Final preparation | 9 Aug – 22 Aug 2026 | Documentation, testing evidence, demonstration materials |
| Final presentation | 22 Aug 2026 | Presentation and demonstration |
| Final submission | 29 Aug 2026 | Final deliverables |

*Table 1.8: Project timeline*

## 1.5 Operating System Platform

Two questions had to be answered: which mobile operating systems the application should support, and which framework should be used to build the client.

### 1.5.1 Comparison of Platform Approaches

| Platform approach | Strengths | Weaknesses | Fit for Runiac |
| --- | --- | --- | --- |
| iOS only (native, Swift) | Best-in-class performance and platform integration; strong Apple Watch and HealthKit support; cleaner sensor APIs | Excludes Android users, who represent the majority of the global market | Poor: excludes a large share of the target user base |
| Android only (native, Kotlin) | Largest global market share; strong Google Maps and Fit integration; open ecosystem | Excludes iOS users; wearable integration fragmented across vendors | Poor: excludes the Apple Watch segment |
| Native iOS and Android in parallel | Highest-quality experience on both; full access to platform-specific features | Doubles development effort; requires two specialists | Poor: resource cost incompatible with a five-person team |
| Cross-platform (Flutter) | Single codebase compiles to both; strong rendering performance for animated interfaces; mature ecosystem of map, GPS and sensor packages | Some platform-specific features require native plugins; slightly larger binaries | Strong: best balance of coverage and effort |
| Cross-platform (React Native) | Large developer community; transferable JavaScript skills; strong third-party library ecosystem | Performance can suffer for animation-heavy or map-intensive interfaces; bridge overhead for native modules | Moderate: Flutter has the edge for map rendering |

*Table 1.9: Platform comparison*

### 1.5.2 Selected Approach: Cross-Platform with Flutter

Runiac was developed as a cross-platform mobile application targeting both iOS and Android using Flutter, and the delivered client is a single Dart codebase of roughly 640 source files.

Supporting both platforms was essential because the application targets beginner users, who are highly sensitive to barriers to entry. Flutter was selected for three reasons: a single codebase for both platforms, which was critical given the size of the team; strong rendering performance through its own graphics engine, well suited to the map-based visualisation the project depends on; and clean integration with Firebase, the selected backend platform.

React Native was considered and not selected because its bridge-based architecture can introduce performance overhead in map-heavy and animation-intensive applications.

Distribution for this project is by Android application package served from the project website, with iOS builds produced from the same source.

### 1.5.3 Platform Considerations

The proposal identified four platform-specific concerns that cross-platform development would not eliminate. Three proved accurate and one became moot.

**Background location permissions.** iOS and Android have different policies for background GPS tracking. The delivered application implements a foreground location provider with a dedicated permission service and a wake-lock scoped to the active session, and requests location and motion permission explicitly with an explanation of why each is needed.

**Push notification systems.** The delivered system uses Firebase Cloud Messaging with a per-user device token registry, complemented by device-local scheduling through a platform method channel for plan reminders, with a ledger that prevents duplicate scheduling.

**Battery optimisation.** Background activity and GPS restrictions differ across devices, particularly on Android. This is addressed through foreground session design rather than background tracking.

One further consideration emerged that the proposal did not anticipate: Apple Sign-In. It is specified in the project's requirements and is a prerequisite for App Store submission, and it was not implemented.

## 1.6 Database

The data layer had to support three distinct workloads: storage of activity data including GPS tracks and performance metrics, mapping of activities to regions for leaderboard aggregation, and efficient retrieval of pre-aggregated rankings. The choice also had to be operationally manageable by a five-person student team without dedicated operations support.

### 1.6.1 Comparison of Database Options

| Database | Strengths | Weaknesses | Fit for Runiac |
| --- | --- | --- | --- |
| MySQL | Mature relational database; strong tooling and operational knowledge; free and widely supported | Requires a dedicated server and administration effort; geospatial support functional but not best-in-class | Moderate: operational overhead disproportionate to team size |
| PostgreSQL with PostGIS | Strongest open-source geospatial support; mature SQL with rich query capabilities; suitable for advanced geospatial queries and regional aggregation | Requires server provisioning, backup management and migration discipline; no built-in real-time sync | Strong technically, operationally heavy for a student team |
| MongoDB | Flexible document model; good for evolving schemas; supports geospatial queries | Real-time updates require additional infrastructure; eventual consistency may affect aggregation accuracy | Moderate: no major advantage over Firestore for this use case |
| Cloud Firestore | Serverless; real-time updates out of the box; built-in authentication, security rules and offline support; first-class Flutter integration | Per-document pricing can become expensive at scale; limited support for complex relational queries; aggregation handled at the function level | Strong: eliminates infrastructure burden and accelerates development |

*Table 1.10: Database comparison*

### 1.6.2 Selected Database: Cloud Firestore

Cloud Firestore was selected and delivered. It integrates natively with Firebase Authentication, Cloud Functions, Cloud Storage and Cloud Messaging; it synchronises in real time, which suits activity summaries and social features; its document structure suits per-activity records; and as a fully managed service it eliminates server provisioning, scaling and maintenance entirely.

The design decision that mattered most was to keep heavy computation off the client. Computing rankings, experience awards and validation on the device would have been both inefficient and trivially manipulable. Instead, activities are validated, mapped to regions and converted into experience records by Cloud Functions, and rankings are computed and stored as pre-aggregated data. This ensures efficient querying and consistent performance. It also produces results that a client cannot forge, which matters most for a competitive feature.

## 1.7 Application Development Languages

The language choices follow from the technology stack and needed to support mobile development and server-side processing without adding unnecessary complexity.

| Layer | Selected language | Alternatives considered | Justification |
| --- | --- | --- | --- |
| Mobile client | Dart on Flutter | Kotlin and Swift; JavaScript on React Native | Required by the chosen framework; mature, type-safe, ahead-of-time compiled, with strong asynchronous support for sensor and network operations |
| Backend serverless functions | TypeScript on Node.js | Python, Go | Officially supported by Firebase Cloud Functions; type safety reduces runtime error; large ecosystem of date, time and geospatial libraries |
| Web tier and administrator console | TypeScript on Next.js and React | Plain React; server-rendered templates | Shares language and type definitions with the backend; server actions keep administrative mutations off the client |

*Table 1.11: Languages by layer*

The proposal also nominated Python for data analysis. No Python analysis component was built; the analysis that exists is computed in TypeScript within Cloud Functions, which avoided introducing a third runtime for a workload that proved modest.

## 1.8 Software Architecture

### 1.8.1 Architectural Options Considered

| Architecture | Strengths | Weaknesses | Fit for Runiac |
| --- | --- | --- | --- |
| Standalone application | No backend required; maximum privacy; works fully offline | No multi-user features; no cross-device sync; no social or competitive functionality | Poor: incompatible with the region-based leaderboard and social features |
| Client–server with REST API | Well-understood pattern; wide tooling; stateless servers scale horizontally | No real-time updates without additional infrastructure; higher operational burden | Possible, but real-time updates would require infrastructure beyond REST |
| Web-based application | Universal browser access; no app store distribution | Background GPS unreliable in mobile browsers; limited sensor access | Poor: unsuitable for a running application |
| Backend-as-a-Service with a mobile client | Real-time updates built in; managed infrastructure; built-in authentication and security rules; fast development velocity | Vendor lock-in; constrained query capabilities; usage-based pricing | Strong: aligns with the Firebase platform selected in Section 1.6 |

*Table 1.12: Architecture comparison*

### 1.8.2 Selected Architecture: Mobile Client with Backend-as-a-Service

Runiac is implemented as a Flutter mobile client communicating with a Firebase Backend-as-a-Service layer, with a Next.js web tier alongside.

The proposal described two tiers. The delivered system has three. The third tier carries real weight: the Platform Administrator console is where every operational capability of the system lives, and the public site is how the application is distributed and how its project documents are published.

### 1.8.3 Logical Architecture

**Mobile client (Flutter).** Owns user interaction, screen rendering, GPS-based tracking, map display and local session state. During a run it samples location and motion, maintains distance and timing independently, renders the route live, optionally speaks progress announcements, and holds session data locally so that connectivity loss does not end the run. It also renders plans, history, analysis, feed, friends, challenges, leaderboard and settings, and caches settings, tour state, character selection and onboarding drafts locally.

**Firebase backend.** Firebase Authentication manages identity. Cloud Firestore stores user profiles, activities, plans, progression records, leaderboard artefacts, social content and summaries. Cloud Functions execute server-side logic across roughly 184 TypeScript source files, exposing thirty-two callable functions, six scheduled functions and seven event-triggered functions. That logic covers activity validation, experience calculation, streak evaluation, leaderboard aggregation, entitlement enforcement, feed publication, challenge settlement, moderation automation, notification dispatch, newsletter delivery and account deletion. Cloud Messaging delivers notifications. Cloud Storage holds avatars, feed thumbnails, share cards and project documents.

**Web tier (Next.js).** Serves the public marketing site and the Platform Administrator console. It authenticates administrators against a revocation-checked session cookie, re-verifies authorisation inside every mutating action, performs writes through the Admin SDK, and appends every administrative mutation to an audit log.

**Third-party services.** Mapbox provides map rendering and route visualisation. OpenAI provides the language model behind the AI-assisted features. The proposal named "Google Maps / Mapbox"; Mapbox was chosen, with its access token supplied at runtime and never committed to the repository.

### 1.8.4 Data Flow Overview

The proposal described a flow built around grid tiles: the client converting GPS coordinates into tile identifiers, the backend deduplicating visited tiles, resolving territorial ownership through transactions, and maintaining pre-aggregated tile counts for the heatmap. None of that was built. The delivered flow is as follows.

During a run the client samples GPS and motion and maintains the session locally, so that tracking continues uninterrupted in offline conditions. On completion the client submits the activity to a callable function, which rejects any field outside an allowed list and any server-owned field outright, then validates scalar bounds, internal timing consistency, implied pace against reported pace, and timestamp freshness. Submission is made idempotent through a deterministic document identifier and a payload fingerprint, so a retry cannot award twice.

If validation passes, the function writes the activity, generates a run summary, computes the experience award and any streak transition, writes an entry to the progression audit ledger, updates the user profile within the same transaction, and writes a leaderboard contribution for the current monthly period and the region in which the run occurred.

Scheduled aggregation then recomputes rankings from those contributions on an hourly cadence, under a lease document that prevents concurrent aggregation, and publishes snapshots, per-user rank documents and current-view documents. Updated data is synchronised to clients in real time through Firestore listeners.

### 1.8.5 Justification

The Backend-as-a-Service architecture was selected for three reasons, all of which held. It provides real-time synchronisation out of the box, avoiding a separate socket-based infrastructure. It eliminates most server provisioning and operational overhead, allowing a small team to focus on product features. It also integrates cleanly with Flutter, reducing integration complexity and development risk.

The team acknowledged the trade-offs. Vendor lock-in to the Google Cloud ecosystem is accepted in exchange for faster development within a single-semester project, and the data model is designed to minimise unnecessary read and write operations to control usage-based cost.

A secondary benefit emerged that the proposal did not anticipate. Because security rules and server-owned fields are declarative and centralised, the fairness and anti-tampering properties the project cares about most can be verified by inspection and by automated test.

## 1.9 Risk List

This section identifies the principal risks the project faced, classified by category, with the mitigation proposed and the outcome as delivered. Risks were scored on likelihood and impact using a three-level scale.

### 1.9.1 Risk Categories

Risks are grouped into six categories reflecting their source: **technical** risks arising from the technologies and platforms the project depends on; **user safety** risks arising from how users may behave in response to the application's design; **privacy and data** risks arising from the sensitive nature of location and health data; **project management** risks arising from the constraints of the academic timeline and team composition; **user adoption** risks arising from the possibility that a technically successful product fails to engage real users; and **external** risks arising from third-party services and platforms outside the team's control.

### 1.9.2 Identified Risks, Mitigations and Outcomes

| ID | Risk | Category | L | I | Mitigation proposed | Outcome as delivered |
| --- | --- | --- | --- | --- | --- | --- |
| R1 | GPS accuracy degrades in dense urban areas, distorting distance and pace | Technical | H | M | Kalman filtering and outlier rejection on raw samples; confidence indicator; validate against a reference device | Partially mitigated. Server-side validation checks pace plausibility and timing consistency; geometric filtering and the confidence indicator were not implemented |
| R2 | Background GPS tracking drains battery faster than acceptable | Technical | H | H | Adaptive sampling by movement state; battery guidance in onboarding; test across devices | Mitigated through foreground session design and wake-lock scoped to the active run |
| R3 | Wearable device APIs change behaviour across OS versions | Technical | M | M | Pin minimum OS versions; abstract wearable access behind a single interface | Did not arise. An Apple HealthKit import path was built behind a single repository interface, then removed before release because the chain was never completed and the app was advertising a capability it could not deliver. No wearable or health-platform API is called in the delivered system, so the risk has no surface. The mitigation is recorded as untested rather than effective |
| R4 | Firestore read costs grow disproportionately as usage scales | Technical | M | M | Pre-aggregate via scheduled functions; budget alerts; cap features if usage approaches limits | Mitigated. Rankings are pre-aggregated, query limits are enforced in the security rules, AI output is cached per user per day |
| R5 | Real-time competitive logic is exploitable from the client, for example through spoofed GPS | Technical | M | H | Server-side validation of submitted activity so rankings cannot be manipulated | Substantially mitigated. Server-owned fields are rejected on submission, awards are computed server-side, submissions are idempotent, suspended accounts are refused. GPS spoofing specifically is not detected |
| R6 | Users run in unsafe locations to improve their standing | User safety | M | H | Safety guidance in onboarding; suppress competitive prompts in unsafe zones | Mitigated by reward design. Rewards favour adherence and consistency, and protected rest days mean resting as planned does not break a streak |
| R7 | Users with no prior running experience injure themselves attempting too much too soon | User safety | M | H | Training plan system enforces conservative ramp-up for new users | Mitigated. Onboarding health answers resolve into a safety band that constrains the generated plan |
| R8 | Location data exposes home, workplace or daily routines | Privacy and data | H | H | Privacy zones masking route start and end; private profile by default; clear consent before sharing | Partially mitigated. Profiles are private by default, sharing is explicit, and shared coordinates are coarsened to roughly 100 m; user-defined privacy zones were not implemented |
| R9 | User data is breached or accessed without authorisation | Privacy and data | L | H | Per-user security rules; no client-side admin paths; periodic rule review | Mitigated. Rules deny by default with a catch-all, administrative work runs through the Admin SDK, admin sessions are revocation-checked and re-verified per mutation |
| R10 | MVP scope cannot be completed within the semester | Project management | M | H | Strict MVP scope; sprint reviews flag slippage; Phase 2 held in reserve | Mitigated. All ten feature slots were delivered, with F8 redesigned and F9 reassigned as described in Section 1.3.3 |
| R11 | A team member becomes unavailable due to illness, exams or other commitments | Project management | M | M | Documentation per module; code review so at least two members understand each module | Mitigated, reinforced by the repository governance practice the team adopted |
| R12 | Dependencies introduce breaking changes during the project | External | L | M | Lock versions in lockfiles; defer non-essential upgrades until after MVP | Mitigated through lockfiles |
| R13 | Beta testers do not provide enough feedback to validate engagement claims | User adoption | M | M | Recruit at least eight testers; embed in-app feedback prompts; structured mid-trial interviews | Partially addressed. An in-application feedback channel and administrative triage were built; structured beta interviews remain outstanding |
| R14 | The gamification mechanics prove less engaging in practice than predicted | User adoption | M | H | Focused usability test before the full beta; be prepared to adjust mechanics rather than treat the design as fixed | Addressed structurally, and exercised. The territorial game was redesigned during implementation, and progression values are configuration rather than code, so they can be retuned without a release |
| R15 | Map API provider changes pricing or rate limits | External | L | M | Prefer providers with generous free tiers; abstract API access so providers can be swapped | Mitigated. Mapbox with runtime token injection |
| R16 | App store review rejects the application or delays release | External | L | M | Review platform guidelines before submission; submit early | Outstanding. Apple Sign-In, a store requirement, is not implemented |
| R17 | The territorial game may be too complex to implement within the timeline if based on geometric area calculations | External | H | H | Adopt a grid-based tile model instead of polygon-based computation to simplify implementation | **Realised, and resolved by redesign.** Even the tile model proved more than the timeline could absorb alongside the rest of the feature set. F8 was reduced from a territorial ownership game to a level-based regional ranking leaderboard, which preserved the motivational intent of localised, achievable competition at a fraction of the implementation cost. F9, the heatmap, depended on the same tile data and was replaced by the experience progression system |
| R18 | AI-generated summaries may produce inaccurate or misleading feedback for beginner users | Technical | M | M | Use rule-based summaries initially; limit AI output to simple, interpretable insight | Mitigated in depth, and the scope was expanded rather than restricted. Language-model generation was delivered with prompt constraints forbidding medical language, a prompt-injection defence, schema-constrained output, post-generation validators, and deterministic fallback. Basic users receive the rule-based copy the proposal described |

*Table 1.13: Risks, mitigations and delivered outcomes*
