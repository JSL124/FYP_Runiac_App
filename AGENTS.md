# Runiac PDD Agent Instructions

## Project Context
Runiac is a beginner-focused running app for a Final Year Project.
The product focuses on beginner runner retention through personalised plans, running habit support, XP, leaderboards, route exploration, and post-run feedback.

## Current Stage
PRD and wireframes are completed.
The current goal is to prepare the Project Design Document (PDD), not to implement code.

## Required PDD Deliverables
The PDD only needs:
1. Application Architecture
2. Physical Architecture
3. Component Diagram
4. Class Diagram
5. Wireframe descriptions

## Technology Assumptions
- Mobile app: Flutter
- Backend: Firebase
- Authentication: Firebase Authentication
- Database: Cloud Firestore
- Server-side logic: Cloud Functions
- Notifications: Firebase Cloud Messaging
- Storage: Firebase Cloud Storage if needed
- Map provider: Google Maps / Mapbox APIs

## Runiac Architecture Rules
- Flutter client handles UI, navigation, GPS tracking UI, and local interaction.
- Firebase Authentication handles identity.
- Firestore stores users, plans, activities, routes, XP summaries, and leaderboard data.
- Cloud Functions handle XP calculation, activity validation, streak update, level update, rank update, and leaderboard aggregation.
- Client must not directly calculate or write XP, level, rank, streak, or leaderboard score.
- Premium features must not rely only on hiding UI.
- Premium users must not receive XP, rank, leaderboard score, or competitive advantages.
- Basic/Premium feature access must be controlled through subscriptionStatus.
- Operational and governance access must be controlled through userRole.
- Basic User and Premium User must not be modelled as separate subclasses in the class diagram.
- Platform Administrator may view XP, level, streak, rank, and leaderboard data, but these must be read-only system-calculated fields.
- Medical Trainer/Expert acts as an expert plan content provider only in the MVP.
- Medical Trainer/Expert must not directly publish training plans into the Runiac mobile app or database in the MVP.
- Medical Trainer/Expert must not directly write published expert plans into Firebase.
- Platform Administrator reviews expert plan content for safety, completeness, beginner suitability, and consistency with Runiac standards.
- Only Platform Administrator can enter, approve, publish, update, or archive expert plans in the system.
- Premium User can only view and select approved/published expert plans.
- A future Expert Dashboard may allow verified experts to submit draft plan content, but admin approval is still required before publishing.
- Keep MVP realistic for a university FYP.

## Documentation Rules
- Do not write implementation code unless explicitly asked.
- Produce PDD-ready explanation.
- Use clear academic wording but avoid overcomplicated enterprise architecture.
- Keep terminology consistent: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert.
- Use Platform Administrator instead of Platform Manager.
- Use Medical Trainer/Expert instead of only Medical Expert.
- Separate MVP features from possible future extensions.
- Flag assumptions clearly.
- Use grep instead of rg because rg is not installed.

## Agent Responsibilities

### A0_ORCH — PDD Orchestrator Agent
A0_ORCH is responsible for maintaining overall consistency across the Runiac PDD. It must ensure that the application architecture, physical architecture, component diagram, class diagram, and wireframe descriptions follow the same design assumptions.

A0_ORCH should be used when:
- The task affects overall PDD direction.
- A design change may affect multiple PDD sections.
- The user is unsure whether a change affects architecture, diagrams, classes, or wireframes.
- Final integration across PDD files is needed.

For the Platform Administrator and Medical Trainer/Expert design, A0_ORCH must ensure that:
- Platform Administrator is represented as the main governance and CRUDS role.
- Medical Trainer/Expert is represented as an expert plan content provider only in the MVP.
- Medical Trainer/Expert does not directly publish expert plans or directly write published expert plans into Firebase.
- Platform Administrator owns expert plan review, approval, publishing, updating, and archiving.
- Premium Users only access approved and published expert plans.
- Basic/Premium feature access is controlled through subscriptionStatus.
- Operational and governance access is controlled through userRole.
- Basic User and Premium User are not modelled as separate subclasses.

### A1_APP — Application Architecture Agent
A1_APP is responsible for the application architecture section and application architecture diagram.

A1_APP should be used when:
- The application layer design changes.
- The relationship between Flutter, Firebase, Cloud Functions, Firestore, FCM, Storage, map provider, or external AI service needs to be updated.
- The application architecture diagram or explanation has an inconsistency.

A1_APP must preserve:
- Flutter client handles UI and interaction.
- Cloud Functions handles server-side XP, streak, level, rank, and leaderboard logic.
- Platform Administrator governance must not be client-side only.
- Medical Trainer/Expert must not directly publish plans.

### A2_PHYS — Physical Architecture Agent
A2_PHYS is responsible for the physical architecture section and physical deployment diagram.

A2_PHYS should be used when:
- Deployment structure changes.
- Device, Firebase, external service, or network boundary needs to be updated.
- Physical architecture diagram needs correction.

A2_PHYS must preserve:
- User mobile device is separate from Firebase backend.
- Firebase/Google Cloud hosts Auth, Firestore, Cloud Functions, FCM, and Storage.
- Map provider is an external service.
- Optional admin dashboard uses restricted access through Firebase Authentication and Cloud Functions.
- No Kubernetes, custom server, or unnecessary microservice complexity unless explicitly required.

### A3_COMP — Component Diagram Agent
A3_COMP is responsible for the component diagram and component responsibility descriptions.

A3_COMP should be used when:
- Component responsibilities change.
- Service boundaries are unclear.
- Component diagram structure needs to be updated.

A3_COMP must preserve:
- XP and Level Service is backend/server-side.
- Streak Service is backend/server-side.
- Leaderboard Aggregation Service is backend/server-side.
- Expert Plan Management is controlled by Platform Administrator.
- Medical Trainer/Expert is content provider only.
- Premium features must not create XP or leaderboard advantages.

### A4_CLASS — Class Diagram Agent
A4_CLASS is responsible for the class diagram and data model/class responsibility descriptions.

A4_CLASS should be used when:
- Class structure, attributes, relationships, subscriptionStatus, userRole, or expert plan lifecycle modelling needs to change.
- Class diagram becomes inconsistent with the PDD design rules.

A4_CLASS must preserve:
- Basic User and Premium User are not separate subclasses.
- Use User.subscriptionStatus for Basic/Premium access.
- Use User.userRole for operational/governance roles.
- Expert plan lifecycle includes states such as Draft, Submitted, Pending Review, Revision Requested, Approved, Published, Archived, and Rejected.
- XP, level, streak, rank, and leaderboard score are authoritative server-calculated values.
- Admin may view but not directly edit XP, level, streak, rank, or leaderboard score.

### A5_WIRE — Wireframe Documentation Agent
A5_WIRE is responsible for maintaining the PDD wireframe descriptions and wireframe image-generation prompts. It should document user-facing, admin-facing, and expert-facing wireframes at PDD level without writing implementation code.

A5_WIRE should be used when:
- Wireframe descriptions need to be written or updated.
- Screen content, user flow, admin screen, or expert submission screen needs to be documented.
- Image-generation prompts for wireframes need to be created.

A5_WIRE must document the following Platform Administrator wireframes:
1. Admin Dashboard
2. User Management
3. User Detail / Role Control
4. Expert Plan Review
5. Plan Management
6. Route Management
7. Notification / Report Management

A5_WIRE must document the following Medical Trainer/Expert wireframes:
1. Expert Plan Submission Form
2. Submitted Plan Status Page

A5_WIRE must explain Platform Administrator CRUDS as:
- Create
- Read
- Update
- Delete/Archive/Suspend
- Search

In Runiac, destructive actions should normally be represented as Archive, Hide, Suspend, Deactivate, Reject, or Dismiss rather than hard delete.

A5_WIRE must document the expert plan governance flow:
Medical Trainer/Expert submits plan content → plan enters admin review queue → Platform Administrator reviews → approve/request revision/reject → Platform Administrator publishes approved plans → Premium User can view/select published expert plans.

A5_WIRE must ensure:
- Medical Trainer/Expert screens do not include a Publish button.
- Expert Plan Submission Form uses Save Draft and Submit for Admin Review.
- Submitted Plan Status Page does not include a Publish button.
- Admin screens show XP, level, streak, rank, and leaderboard data as read-only where shown.
- Platform Administrator screens use web/admin dashboard style.
- Medical Trainer/Expert screens use controlled web submission portal style.

### A6_REVIEW — Consistency Review Agent
A6_REVIEW is responsible for checking that the PDD remains consistent after each meaningful update.

A6_REVIEW should be used:
- After any meaningful documentation update.
- After any diagram update.
- Before committing PDD changes.
- When the user asks whether the PDD is consistent.

For the Platform Administrator and Medical Trainer/Expert wireframe update, A6_REVIEW must check that:
- Medical Trainer/Expert is not described as directly publishing expert plans.
- Medical Trainer/Expert is not described as directly writing published expert plans into Firebase.
- Platform Administrator owns review, approval, publishing, update, and archive actions.
- Premium Users only access approved and published expert plans.
- Basic/Premium access is represented through subscriptionStatus.
- Operational and governance access is represented through userRole.
- Basic User and Premium User are not represented as separate subclasses.
- Admin CRUDS does not allow direct editing of XP, level, streak, rank, or leaderboard score.
- XP calculation, streak update, level update, rank update, and leaderboard aggregation remain server-side.
- Premium features do not create XP or leaderboard advantages.
- Delete actions are safely described as Archive, Hide, Suspend, Deactivate, Reject, or Dismiss where appropriate.
- Wireframe descriptions remain PDD-level and do not become implementation code.

### A7_AGENT_ROUTER — Agent Routing and Switching Agent
A7_AGENT_ROUTER is responsible for deciding which PDD agent should handle the current task and when the workflow should switch to another agent.

A7_AGENT_ROUTER should be used when:
- The user is unsure which agent should handle the next task.
- The user asks when to switch agents.
- A task may affect multiple PDD sections.
- A design change may require architecture, component, class, or wireframe updates.
- A task has been completed and the next validation or documentation step must be chosen.
- The workflow needs to decide whether A0_ORCH, A1_APP, A2_PHYS, A3_COMP, A4_CLASS, A5_WIRE, A6_REVIEW, or A8_OUTPUT_CHECKER should be used next.

A7_AGENT_ROUTER responsibilities:
1. Recommend the current agent.
2. Explain why that agent is appropriate.
3. Decide whether the current agent should continue or switch.
4. Identify the exact switching point.
5. Recommend the next agent after completion.
6. Identify likely affected files.
7. Decide whether A6_REVIEW is required before commit.
8. Decide whether A1_APP, A2_PHYS, A3_COMP, and A4_CLASS should remain inactive.

Agent routing rules:
- Use A0_ORCH when the task affects overall PDD consistency or multiple PDD sections.
- Use A1_APP when the application architecture description or application architecture diagram needs to change.
- Use A2_PHYS when the physical architecture, deployment structure, or infrastructure diagram needs to change.
- Use A3_COMP when component responsibilities, service boundaries, or component diagram structure need to change.
- Use A4_CLASS when class structure, attributes, relationships, subscriptionStatus, userRole, or expert plan lifecycle modelling need to change.
- Use A5_WIRE when wireframe descriptions, screen content, user flows, admin screens, expert submission screens, or wireframe image prompts need to be written or updated.
- Use A6_REVIEW after any meaningful documentation or diagram update to check consistency before committing.
- Use A8_OUTPUT_CHECKER when a generated output needs to be checked against a deliverable checklist.
- Do not involve A1_APP, A2_PHYS, A3_COMP, or A4_CLASS unless there is a clear architecture, physical architecture, component, or class diagram impact.
- If the task is only wording cleanup or wireframe-description-only work, route to A5_WIRE or A0_ORCH instead of diagram agents.
- If the update is complete, route to A6_REVIEW before committing.
- If an output artifact such as a prompt set or diagram set is generated, route to A8_OUTPUT_CHECKER before using it.

Agent switching rules:
- Continue with the current agent if the task is still within the same responsibility area.
- Switch from A0_ORCH to A5_WIRE when the overall scope has been clarified and the remaining work is mainly wireframe documentation.
- Switch from A5_WIRE to A6_REVIEW when the wireframe documentation has been written or meaningfully updated.
- Switch from A6_REVIEW back to A5_WIRE if the issue is limited to wording, missing wireframe content, unclear screen description, or wireframe documentation detail.
- Switch from A6_REVIEW back to A0_ORCH if the issue affects multiple PDD sections or overall design consistency.
- Switch to A1_APP only if the application architecture description or diagram needs to change.
- Switch to A2_PHYS only if the physical architecture or deployment structure needs to change.
- Switch to A3_COMP only if component responsibilities, service boundaries, or component diagram structure need to change.
- Switch to A4_CLASS only if class structure, attributes, relationships, subscriptionStatus, userRole, or expert plan lifecycle modelling needs to change.
- Switch to A8_OUTPUT_CHECKER when a deliverable has been generated and needs completeness checking.
- Switch to A6_REVIEW before committing after any meaningful documentation or diagram update.
- Do not switch to diagram agents A1_APP, A2_PHYS, A3_COMP, or A4_CLASS for wording-only or wireframe-description-only changes.

For the current Runiac admin/expert wireframe work:
- If the current task is Platform Administrator CRUDS wireframe documentation or Medical Trainer/Expert submission wireframe documentation, A7_AGENT_ROUTER should recommend A5_WIRE first.
- After A5_WIRE updates the wireframe documentation, A7_AGENT_ROUTER should recommend switching to A6_REVIEW.
- After a wireframe image-generation prompt set is created, A7_AGENT_ROUTER should recommend switching to A8_OUTPUT_CHECKER.
- A1_APP, A2_PHYS, A3_COMP, and A4_CLASS should remain inactive unless a diagram-level inconsistency is found.

A7_AGENT_ROUTER should output the following every time it is used:
1. Recommended current agent
2. Reason
3. Continue or switch decision
4. Switching point
5. Next agent
6. Files likely affected
7. Whether A6_REVIEW is required
8. Whether A1~A4 diagram agents should remain inactive

Routing reference table:

Task Type | Recommended Agent | Next Agent
Overall PDD direction or multi-section impact | A0_ORCH | A6_REVIEW
Application Architecture update | A1_APP | A6_REVIEW
Physical Architecture update | A2_PHYS | A6_REVIEW
Component Diagram update | A3_COMP | A6_REVIEW
Class Diagram update | A4_CLASS | A6_REVIEW
Wireframe descriptions or screen content | A5_WIRE | A6_REVIEW
Wireframe image-generation prompts | A5_WIRE | A8_OUTPUT_CHECKER
Output completeness check | A8_OUTPUT_CHECKER | A6_REVIEW or image generation
Consistency check | A6_REVIEW | A0_ORCH or relevant correction agent if issues are found
Agent selection or workflow handoff | A7_AGENT_ROUTER | Selected agent
Minor wording cleanup | A0_ORCH or A5_WIRE | A6_REVIEW if meaningful
Diagram visual or structural issue | Relevant A1~A4 | A6_REVIEW
Expert plan governance wording | A0_ORCH or A5_WIRE | A6_REVIEW
Admin/Expert wireframe planning | A5_WIRE | A6_REVIEW

### A8_OUTPUT_CHECKER — Output Completeness and Deliverable Checker
A8_OUTPUT_CHECKER is responsible for checking whether generated PDD outputs are complete and satisfy the required deliverable checklist.

A8_OUTPUT_CHECKER is different from A6_REVIEW:
- A6_REVIEW checks design consistency across the PDD.
- A8_OUTPUT_CHECKER checks output completeness and deliverable readiness.

A8_OUTPUT_CHECKER should be used when:
- A file, diagram, wireframe prompt set, or documentation section has been generated.
- The user wants to confirm that all required items are present.
- A checklist must be verified before image generation, PDD insertion, or commit.

For wireframe image-generation prompt sets, A8_OUTPUT_CHECKER must check that:
- All 9 screen prompts are present.
- Admin Dashboard is present.
- User Management is present.
- User Detail / Role Control is present.
- Expert Plan Review is present.
- Plan Management is present.
- Route Management is present.
- Notification / Report Management is present.
- Expert Plan Submission Form is present.
- Submitted Plan Status Page is present.
- Medical Trainer/Expert screens do not include a Publish button.
- Expert Plan Submission Form includes Save Draft and Submit for Admin Review.
- Submitted Plan Status Page does not include a Publish button.
- XP, level, streak, rank, and leaderboard-related fields are read-only where shown.
- subscriptionStatus is used for Basic/Premium access.
- userRole is used for operational/governance access.
- Premium users are not given XP, rank, leaderboard score, or competitive advantages.
- The prompts are low-fidelity black-and-white wireframe prompts.
- Platform Administrator screens use web/admin dashboard style.
- Medical Trainer/Expert screens use controlled web submission portal style.
- The prompts are suitable for PDD image generation.

A8_OUTPUT_CHECKER should output:
1. Checked file or output
2. Checklist table
3. Pass/fail result for each item
4. Issues found
5. Required corrections, if any
6. Recommended next agent
7. Final output status

Final output status should be one of:
- Pass — ready to use
- Minor fixes needed
- Major fixes needed
- Blocked

Routing rule:
- If missing or unclear wireframe prompt content is found, route back to A5_WIRE.
- If design consistency problems are found, route to A6_REVIEW.
- If diagram-level problems are found, route to the relevant A1~A4 agent.
- If the output passes the checklist, the next step can be image generation or commit.
