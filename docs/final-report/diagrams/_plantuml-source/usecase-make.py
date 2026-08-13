from gen import build
U = "Registered User"
A = "Platform\nAdministrator"

specs = [
("figure-2-2-f1-usecase", "F1  Collect Running-Related Activity Data", [U], [
 ("Start a Run",0), ("Track Distance, Pace and Route",0), ("Pause and Resume the Run",0),
 ("End and Save the Run",0), ("Save the Run with Low Data",0), ("View the Run Summary",0)]),

("figure-2-5-f2-usecase", "F2  Estimate Running Effects and Provide Analysis", [U], [
 ("View the Run Summary",0), ("View Activity History",0), ("View Progress and Trend",0),
 ("View Advanced Analysis (Premium)",0), ("View the Subscription Paywall",0)]),

("figure-2-8-f3-usecase", "F3  Supply Running Advice and Schedule a Running Plan", [U], [
 ("Complete Onboarding",0), ("View the Weekly Plan",0), ("View Workout Detail",0),
 ("Edit the Plan Schedule",0), ("View the Designated Rest Days",0), ("Retake Onboarding",0)]),

("figure-2-11-f4-usecase", "F4  Remind the User of Running or Rest", [U], [
 ("Grant Notification Permission",0), ("Receive a Plan Reminder",0),
 ("Receive an Engagement Notification",0), ("View the Notification Inbox",0),
 ("Set Notification Preferences",0)]),

("figure-2-14-f5-usecase", "F5  Social Connection, Sharing and Competition", [U, A], [
 ("Publish an Activity to the Feed",0), ("View the Feed Timeline",0),
 ("Like and Comment on a Post",0), ("Search and Add a Friend",0),
 ("Accept or Decline a Friend Request",0), ("Block or Remove a Friend",0),
 ("Share an Achievement Card",0), ("Create a Distance Challenge",0),
 ("Invite Friends to a Challenge",0), ("View the Challenge Result",0),
 ("Report a Post or a User",0), ("Review Reported Content",1)]),

("figure-2-17-f6-usecase", "F6  Streak and Consistency Tracking", [U], [
 ("View the Current Streak",0), ("View the Longest Streak",0),
 ("View a Streak Milestone Reward",0), ("View Protected Rest Days",0)]),

("figure-2-20-f7-usecase", "F7  Community-Driven Route Sharing", [U, A], [
 ("Publish a Completed Run to the Activity Feed",0),
 ("Include the Route with the Post",0),
 ("View Routes Shared by Others",0),
 ("Open a Shared Run for its Detail",0),
 ("Report a Post with a Route",0),
 ("Review a Reported Post",1)]),

("figure-2-23-f8-usecase", "F8  Level-Based Territorial Leaderboard", [U, A], [
 ("View the Regional Ranking",0), ("Select a Region",0), ("View the League Division",0),
 ("View Own Rank and Neighbours",0), ("View Another Runner's Profile",0),
 ("Request a Leaderboard Recalculation",1)]),

("figure-2-26-f9-usecase", "F9  Runner Level and Experience Point Progression", [U, A], [
 ("View Experience and Level",0), ("View the Level-Up Result",0),
 ("View the League Division",0), ("View Progression History",0),
 ("Configure the Award Rules",1), ("Configure the Level Curve",1)]),

("figure-2-29-f10-usecase", "F10  AI-Assisted Guidance and Post-Run Reflection", [U], [
 ("View the AI Home Guide (Premium)",0), ("View AI Activity Feedback (Premium)",0),
 ("View the AI Workout Briefing (Premium)",0), ("View the Deterministic Summary",0),
 ("View the Subscription Paywall",0)]),
]
for name, title, actors, cases in specs:
    w,h = build(name, title, actors, cases)
    print(f"{name:32s} {w} x {h}")
