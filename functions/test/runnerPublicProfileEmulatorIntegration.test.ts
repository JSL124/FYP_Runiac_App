import assert from "node:assert/strict";
import { after, before, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { createRunnerPublicProfilePorts } from "../src/profile/publicProfile/callable.js";
import { getRunnerPublicProfile } from "../src/profile/publicProfile/core.js";

/**
 * Integration coverage for `getRunnerPublicProfile` against the Firestore
 * emulator, through the REAL ports the deployed callable uses.
 *
 * The core unit test fakes the ports, so it can only prove the decision
 * rules. This proves the wiring the unit test cannot: that the ports read
 * `userProfiles/{uid}`, `users/{uid}`, `users/{uid}/challengeBadges`, and
 * `users/{a}/blockedUsers/{b}` — the exact paths the rest of the app writes.
 */
const viewer = "rpp-viewer";
const runner = "rpp-runner";
const blocker = "rpp-blocker";
const suspended = "rpp-suspended";
const seededUids = [viewer, runner, blocker, suspended] as const;
const snapshotId = "monthly_jurong-east_tier_03_2026-07";
const buildId = "build-2026-07-26T09";
const entry = (rankLabel: string, build: string = buildId) => ({ snapshotId, rankLabel, buildId: build });
const rankIds = ["rpp-rank-runner", "rpp-rank-blocker", "rpp-rank-suspended", "rpp-rank-viewer", "rpp-rank-duplicate"] as const;

if (getApps().length === 0) initializeApp();
const db = getFirestore();
const ports = createRunnerPublicProfilePorts(db);

before(async () => {
  // Fail closed: this suite writes real documents, so it must never run
  // against anything but the emulator.
  assert.notEqual(process.env["FIRESTORE_EMULATOR_HOST"], undefined, "FIRESTORE_EMULATOR_HOST must be set");
  await clearFixture();
  await db.doc(`userProfiles/${runner}`).set({
    displayName: "Jinseo",
    nickname: "Jinseo_main",
    avatarInitials: "JI",
    locationLabel: "Jurong East, Singapore",
    levelLabel: "Level 8",
    level: 8,
    levelProgressPercent: 97.5,
    totalXp: 780,
    nextLevelXp: 800,
    xpToNextLevel: 20,
    divisionKey: "tier_03",
    divisionLabel: "Silver League",
    longestStreakLabel: "4 days",
    totalDistanceLabel: "69.8 km",
    // Private half of the same document; must never reach a viewer.
    fullName: "Jinseo Lee",
    dateOfBirth: "2000-01-01",
    ageYears: 26,
    weightKg: 68.5,
  });
  await db.doc(`users/${runner}`).set({ subscriptionStatus: "premium" });
  await db.doc(`users/${runner}/challengeBadges/10K`).set({ tierId: "10K" });
  await db.doc(`users/${runner}/challengeBadges/250K`).set({ tierId: "250K" });
  await db.doc(`userProfiles/${viewer}`).set({ displayName: "Viewer", avatarInitials: "VI", locationLabel: "Bedok, Singapore" });
  await db.doc(`userProfiles/${blocker}`).set({ displayName: "Blocker", avatarInitials: "BL", locationLabel: "Bedok, Singapore" });
  await db.doc(`users/${blocker}/blockedUsers/${viewer}`).set({ createdAt: new Date(0) });
  await db.doc(`userProfiles/${suspended}`).set({ displayName: "Suspended", avatarInitials: "SU", locationLabel: "Bedok, Singapore" });
  await db.doc(`users/${suspended}`).set({ accountStatus: "suspended" });
  // The backend-written rank projection: the only place a leaderboard entry
  // maps back to a uid. Shaped exactly like `monthlyLeaderboardWriter` writes it.
  await db.doc("leaderboardUserRanks/rpp-rank-runner").set({ ownerUid: runner, snapshotId, buildId, rankLabel: "#3", periodKey: "2026-07", regionId: "jurong-east", divisionKey: "tier_03" });
  await db.doc("leaderboardUserRanks/rpp-rank-blocker").set({ ownerUid: blocker, snapshotId, buildId, rankLabel: "#4", periodKey: "2026-07", regionId: "jurong-east", divisionKey: "tier_03" });
  await db.doc("leaderboardUserRanks/rpp-rank-suspended").set({ ownerUid: suspended, snapshotId, buildId, rankLabel: "#5", periodKey: "2026-07", regionId: "jurong-east", divisionKey: "tier_03" });
  await db.doc("leaderboardUserRanks/rpp-rank-viewer").set({ ownerUid: viewer, snapshotId, buildId, rankLabel: "#6", periodKey: "2026-07", regionId: "jurong-east", divisionKey: "tier_03" });
});

after(async () => {
  await clearFixture();
});

describe("Runner public profile emulator integration", () => {
  it("projects a real runner document, account tier, and earned badges", async () => {
    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#3") }, ports);

    assert.equal(profile.displayName, "Jinseo_main");
    assert.equal(profile.avatarInitials, "JI");
    assert.equal(profile.regionLabel, "Jurong East, Singapore");
    assert.equal(profile.level, 8);
    assert.equal(profile.levelProgressPercent, 97.5);
    assert.equal(profile.xpToNextLevel, 20);
    assert.equal(profile.longestStreakLabel, "4 days");
    assert.equal(profile.totalDistanceLabel, "69.8 km");
    assert.equal(profile.subscriptionStatusLabel, "Premium");
    assert.deepEqual([...profile.ownedBadgeTierIds].sort(), ["10K", "250K"]);
  });

  it("leaves the private half of the stored document behind", async () => {
    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#3") }, ports);
    const serialized = JSON.stringify(profile);

    for (const privateValue of ["Jinseo Lee", "2000-01-01", "68.5", "26"]) {
      assert.equal(serialized.includes(privateValue), false, `${privateValue} must not be projected`);
    }
    for (const privateKey of ["fullName", "dateOfBirth", "ageYears", "weightKg"]) {
      assert.equal(privateKey in profile, false, `${privateKey} must not be projected`);
    }
  });

  it("serves a runner with no badge documents as owning none", async () => {
    const profile = await getRunnerPublicProfile({ auth: { uid: runner }, data: entry("#6") }, ports);

    assert.deepEqual(profile.ownedBadgeTierIds, []);
    assert.equal(profile.subscriptionStatusLabel, "Basic");
  });

  it("hides a runner who blocked the viewer", async () => {
    await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#4") }, ports), "permission-denied");
  });

  it("hides a suspended runner", async () => {
    await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#5") }, ports), "permission-denied");
  });

  it("resolves a leaderboard entry through the real rank projection", async () => {
    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#3") }, ports);

    assert.equal(profile.displayName, "Jinseo_main");
    assert.equal(profile.totalDistanceLabel, "69.8 km");
    assert.deepEqual([...profile.ownedBadgeTierIds].sort(), ["10K", "250K"]);
  });

  it("hides a leaderboard entry whose owner blocked the viewer", async () => {
    await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#4") }, ports), "permission-denied");
  });

  it("fails closed when two rank projections claim the same rank", async () => {
    await db.doc("leaderboardUserRanks/rpp-rank-duplicate").set({ ownerUid: suspended, snapshotId, buildId, rankLabel: "#3", periodKey: "2026-07" });
    try {
      await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#3") }, ports), "not-found");
    } finally {
      await db.doc("leaderboardUserRanks/rpp-rank-duplicate").delete();
    }
  });

  it("reports an unranked position as not found", async () => {
    await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#99") }, ports), "not-found");
  });

  it("refuses an entry from a superseded board build", async () => {
    // The refresh job reuses the monthly snapshot id and reassigns ranks, so a
    // stale row must never resolve to whoever holds that rank now.
    await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#3", "build-older") }, ports), "not-found");
  });

  it("reports an unknown entry as not found", async () => {
    await assertRejects(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: entry("#404") }, ports), "not-found");
  });
});

async function assertRejects(run: () => Promise<unknown>, code: string): Promise<void> {
  await assert.rejects(run, (error: unknown) => typeof error === "object" && error !== null && "code" in error && error["code"] === code);
}

async function clearFixture(): Promise<void> {
  await Promise.all(rankIds.map((rankId) => db.doc(`leaderboardUserRanks/${rankId}`).delete()));
  for (const uid of seededUids) {
    const badges = await db.collection(`users/${uid}/challengeBadges`).get();
    const blocks = await db.collection(`users/${uid}/blockedUsers`).get();
    await Promise.all([...badges.docs, ...blocks.docs].map((document) => document.ref.delete()));
    await Promise.all([db.doc(`users/${uid}`).delete(), db.doc(`userProfiles/${uid}`).delete()]);
  }
}
