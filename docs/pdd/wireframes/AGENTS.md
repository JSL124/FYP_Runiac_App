# Runiac PDD Wireframe Instructions

## Scope
- Applies to PDD wireframe descriptions, wireframe prompt sets, figure insertion text, and admin/expert wireframe assets.
- Keep wireframes PDD-level and explanatory.
- Do not add implementation code.

## Required Platform Administrator Wireframes
- Admin Dashboard
- User Management
- User Detail / Role Control
- Expert Plan Review
- Plan Management
- Route Management
- Notification / Report Management

## Required Medical Trainer/Expert Wireframes
- Expert Plan Submission Form
- Submitted Plan Status Page

## Wireframe Rules
- Medical Trainer/Expert screens must not include a Publish button.
- Expert Plan Submission Form uses Save Draft and Submit for Admin Review.
- Submitted Plan Status Page does not include a Publish button.
- Platform Administrator screens use web/admin dashboard style.
- Medical Trainer/Expert screens use controlled web submission portal style.
- Admin-visible XP, level, streak, rank, and leaderboard data must be read-only.
- Destructive actions should normally be Archive, Hide, Suspend, Deactivate, Reject, or Dismiss rather than hard delete.
- Basic/Premium access uses `subscriptionStatus`.
- Operational/governance access uses `userRole`.
- Premium users must not receive XP, rank, leaderboard score, or competitive advantages.
- Wireframe image prompts should be low-fidelity black-and-white prompts suitable for PDD image generation.

## Expert Plan Governance Flow
Medical Trainer/Expert submits plan content -> plan enters admin review queue -> Platform Administrator reviews -> approve / request revision / reject -> Platform Administrator publishes approved plans -> Premium User can view/select published expert plans.

## Privacy Guidance
- Treat GPS route data, activity history, profile data, and running metrics as sensitive user data.
- Avoid exposing exact private route history unless the user explicitly shares it.
- Do not include precise private location data in screenshots, logs, test evidence, or public documentation.
- Route sharing should use user-controlled visibility.
