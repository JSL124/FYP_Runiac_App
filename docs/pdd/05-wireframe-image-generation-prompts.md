# A5_WIRE Wireframe Image Generation Prompts

These prompts are for generating low-fidelity black-and-white web wireframe images for the Runiac PDD. They cover the Platform Administrator and Medical Trainer/Expert governance screens.

## 1. Admin Dashboard

**Role:** Platform Administrator

**Purpose:** Provides an overview of system status and pending administrative tasks.

**Final image-generation prompt:**

Create a low-fidelity black-and-white web admin dashboard wireframe for the Runiac PDD. The screen should use a clean academic project-documentation style, simple rectangular sections, readable labels, no colours, no gradients, and no decorative illustrations. Use a desktop web layout, not a mobile layout. Add a fixed left sidebar titled "Runiac Admin Panel" with navigation items: Dashboard, Users, Expert Plans, Plans, Shared Routes, Notifications, Reports, Settings. At the top of the main content area, add a header reading "Runiac Admin Panel - Admin Dashboard".

The main content should show eight rectangular overview cards arranged in a grid: Total Users, Premium Users, Active Basic Users, Pending Expert Plans, Published Expert Plans, Reported Routes, Pending Reports, Active Notifications. Below the overview cards, add a "Quick Actions" section with rectangular buttons: Manage Users, Review Expert Plans, Manage Plans, Manage Shared Routes, Send Notification, View Reports. Add a "Recent Activity" table below with columns: Time, Activity Type, Item, Performed By, Status. Use placeholder rows such as "Expert plan submitted", "Route report received", "User suspended", "Notification scheduled". The layout should be clear, spacious, and consistent with a university PDD wireframe.

**Important constraints:** Use only black, white, and grey wireframe styling. Platform Administrator access is controlled by `userRole`. Do not show mobile UI. Do not show XP editing or leaderboard manipulation controls.

## 2. User Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to search, view, and manage user accounts.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for a Runiac Platform Administrator screen. Use the header "Runiac Admin Panel - User Management" and the same left sidebar navigation as the admin dashboard. The design must be simple, rectangular, readable, and suitable for an academic PDD. At the top of the main area, place a wide search bar labelled "Search by name, email, or user ID".

Below the search bar, create a filter panel with dropdown or input placeholders for `subscriptionStatus`, `userRole`, `accountStatus`, joined date, and last active. Under the filters, show a large user table with columns: Name, Email, subscriptionStatus, userRole, Account Status, Last Active, Actions. Example row values should show Basic/Premium through `subscriptionStatus`, and operational roles through `userRole` such as User, Platform Administrator, and Medical Trainer/Expert. In the Actions column, place small wireframe buttons: View, Edit, Suspend. Keep all controls as plain rectangular placeholders. Add a small note under the table: "Basic/Premium is controlled by subscriptionStatus; governance access is controlled by userRole."

**Important constraints:** Do not represent Basic User and Premium User as separate account classes. Use `subscriptionStatus` for Basic/Premium. Use `userRole` for User, Platform Administrator, or Medical Trainer/Expert. Use Suspend as a soft governance action.

## 3. User Detail / Role Control

**Role:** Platform Administrator

**Purpose:** Allows the administrator to inspect one user and manage access or moderation status.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - User Detail / Role Control". Include the same left sidebar used across the admin screens. The main layout should use simple cards and tables. At the top, show a user profile summary card with placeholders for avatar box, name, email, user ID, joined date, and last active.

Create an "Access Information" card showing `subscriptionStatus`, `userRole`, and `accountStatus`. Create a "Running Summary" card or table with Total Activities, Total Distance, Level, Total XP, Current Streak, Registered Leaderboard Area, Rank, and Leaderboard Score. Mark Level, Total XP, Current Streak, Rank, Registered Leaderboard Area, and Leaderboard Score with a clear "Read-only / system-calculated" label. Add a "Moderation" section with Report Count, Account Warnings, and Admin Notes. Add an "Admin Actions" section with rectangular buttons or controls: Update userRole, Update accountStatus, Suspend, Reactivate, Add Admin Note, View Activity History. The page should clearly separate editable governance fields from read-only progression fields.

**Important constraints:** XP, level, streak, rank, and leaderboard score must be read-only. The admin must not directly edit XP, level, streak, rank, weekly XP, monthly XP, or leaderboard score. Use `subscriptionStatus` and `userRole` labels exactly.

## 4. Expert Plan Review

**Role:** Platform Administrator

**Purpose:** Allows the administrator to review expert-submitted plans before publication.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Expert Plan Review". Include the same admin sidebar. At the top of the content area, create a plan header panel with Plan Title, Goal Distance, Duration, Difficulty, Runs per Week, and Current Status. Use a status example such as "Pending Admin Review" or "Approved".

Below the header, create a provider information panel with Submitted By, Provider Type, Qualification Summary, and Submitted Date. Add a large weekly schedule table with columns: Week, Session, Distance/Duration, Intensity, Notes. Add a Safety Notes section with placeholder text rows for warm-up/cool-down notes, beginner suitability, injury prevention notes, and medical disclaimer. Add an Admin Review Checklist panel with checkbox rows such as "Beginner suitable", "Safe progression", "Clear rest days", "No medical diagnosis", "Consistent with Runiac standards". Add an Admin Comment text box. At the bottom, place decision buttons: Approve, Request Revision, Reject, Publish Approved Plan, Archive. Include a small label: "Review and publishing performed by Platform Administrator."

**Important constraints:** Medical Trainer/Expert does not publish. Platform Administrator publishes only after review and approval. Premium Users can only view/select approved and published expert plans. Use Archive or Reject rather than hard delete.

## 5. Plan Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to manage Runiac system goal plans and approved expert plans.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Plan Management". Use consistent sidebar navigation and a simple PDD-style wireframe layout. At the top of the main content, include a search and filter panel with fields for Plan Type, Goal Distance, Difficulty, Status, and Last Updated. Include a prominent rectangular button labelled "Create New System Goal Plan".

Below the filters, create a plan table with columns: Plan Title, Plan Type, Goal, Duration, Difficulty, Status, Last Updated, Actions. Show example plan types as "System Plan" and "Expert Plan". Show example statuses such as Submitted, Pending Review, Revision Requested, Approved, Published, Archived, and Rejected. In the Actions column, include View, Edit, and Archive buttons. Add a small explanatory note near the table: "System plans and expert plans are distinguishable. Expert plans become visible to Premium Users only after approval and publication."

**Important constraints:** Use `subscriptionStatus` for Premium access to expert plans. Premium expert plans must not create XP or leaderboard scoring advantages. Archive should be shown instead of hard delete.

## 6. Route Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to review and moderate shared routes.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Route Management". Include the same left sidebar. The main content should start with a search and filter panel labelled "Search shared routes" with fields for route name, location, creator, difficulty, and report status.

Create a large route table with columns: Route Name, Creator, Location, Distance, Difficulty, Visibility, Favourite Count, Report Count, Status, Actions. In the Actions column, include View, Hide, Archive, and Mark as Reviewed. To the right or below the table, add a map preview placeholder box labelled "Map Preview" with a simple route line placeholder. Add a "Report Detail Preview" panel showing reported item, reported by, reason, report date, status, and admin decision. Keep all sections rectangular and wireframe-like with no decorative maps or colours.

**Important constraints:** Route management is for moderation, safety, and privacy. It must not give Premium Users XP, rank, leaderboard score, or competitive advantages. Use Hide, Archive, and Mark as Reviewed as soft moderation actions.

## 7. Notification / Report Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to create system notifications and handle reports or moderation cases.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Notification / Report Management". Use a consistent admin sidebar and simple rectangular content areas. Split the main content into two large panels: "Notification Management" and "Report Management".

In the Notification Management panel, include a notification form with fields for Notification Title, Message Body, Target Audience, Notification Type, and Send Now / Schedule. Add simple buttons labelled Save Draft, Send Now, and Schedule. Below the form, add a Notification History table with columns: Title, Target Audience, Type, Scheduled Time, Sent Status, Created By. In the Report Management panel, add a report table with columns: Report Type, Reported Item, Reported By, Reason, Date, Status, Admin Decision, Actions. In the Actions column, include Resolve, Dismiss, Hide Route, Suspend User, and Archive Content.

**Important constraints:** Use soft moderation decisions. Reports should support auditability. Do not include hard delete. Notification targeting should be shown as an admin communication tool, not as a way to alter XP, streak, rank, or leaderboard score.

## 8. Expert Plan Submission Form

**Role:** Medical Trainer/Expert

**Purpose:** Allows Medical Trainer/Expert to prepare structured expert plan content for admin review.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Expert Plan Submission Portal - Expert Plan Submission Form". This must be a web portal layout, not a mobile app. Use simple rectangular form sections, clear readable text, no colour, no illustrations, and no high-fidelity styling. Include a top header labelled "Expert Plan Submission Portal" and a simple left sidebar with items: New Submission, Submitted Plans, Drafts, Profile.

The main form should contain an "Expert Information" section with fields for Expert Name, Qualification, Organisation, Experience Summary, and Contact Email. Add a "Plan Basic Information" section with Plan Title, Goal Distance, Duration, Difficulty, Target User Type, and Runs per Week. Add a Plan Description section with large text areas for Plan Description and Expected Outcome. Add a Weekly Plan Builder table with columns: Week, Run Session, Distance/Duration, Intensity, Rest Day Guidance, Notes. Add a Safety section with Beginner Suitability, Injury Prevention Notes, When to Stop Running, and Medical Disclaimer. At the bottom, include only two buttons: Save Draft and Submit for Admin Review.

**Important constraints:** Do not include a Publish Plan button. Do not imply direct publication to the live Premium plan catalogue or direct writing of published plans into Firebase. Submission goes to the Platform Administrator review queue.

## 9. Submitted Plan Status Page

**Role:** Medical Trainer/Expert

**Purpose:** Allows Medical Trainer/Expert to view the review status of submitted plans and respond to revision requests.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Expert Plan Submission Portal - Submitted Plan Status Page". Use the same Expert Plan Submission Portal header and sidebar as the submission form. The layout should be clean, rectangular, and suitable for a PDD wireframe.

At the top, add a small summary strip with counts for Draft, Submitted, Pending Admin Review, Revision Requested, Approved, Published, Rejected, and Archived. Below it, create a submitted plan list table with columns: Plan Title, Goal Distance, Submitted Date, Current Status, Admin Comment, Last Updated, Actions. Use visible status examples: Draft, Submitted, Pending Admin Review, Revision Requested, Approved, Published, Rejected, Archived. In the Actions column, include View Submission, Edit Draft, Respond to Revision, and Resubmit for Review. Add a right-side or bottom detail preview panel showing selected plan title, latest admin comment, required changes, and next allowed action.

**Important constraints:** Do not include a Publish button. Medical Trainer/Expert can view status and respond to revision requests, but cannot approve, publish, archive published plans, or directly write published plan records. Publication remains a Platform Administrator action.
