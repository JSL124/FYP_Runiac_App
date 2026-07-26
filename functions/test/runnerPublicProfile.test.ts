import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { getRunnerPublicProfile, type BlockEdges, type RunnerPublicProfilePorts } from "../src/profile/publicProfile/core.js";

const viewer = "viewer-a";
const runner = "runner-a";
const snapshotId = "monthly_jurong-east_tier_03_2026-07";

function rankKey(snapshot: string, rankLabel: string): string {
  return `${snapshot}::${rankLabel}`;
}

describe("Runner public profile core", () => {
  it("projects the backend-owned profile fields for a signed-in viewer", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, {
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
    });
    ports.accounts.set(runner, { subscriptionStatus: "premium" });
    ports.badges.set(runner, ["250K"]);

    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports);

    assert.deepEqual(profile, {
      uid: runner,
      displayName: "Jinseo_main",
      avatarInitials: "JI",
      regionLabel: "Jurong East, Singapore",
      levelLabel: "Level 8",
      level: 8,
      levelProgressPercent: 97.5,
      totalXp: 780,
      nextLevelXp: 800,
      xpToNextLevel: 20,
      isMaxLevel: false,
      divisionKey: "tier_03",
      divisionLabel: "Silver League",
      longestStreakLabel: "4 days",
      totalDistanceLabel: "69.8 km",
      subscriptionStatusLabel: "Premium",
      ownedBadgeTierIds: ["250K"],
    });
  });

  it("never leaks the private half of the profile document", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, {
      displayName: "Jinseo",
      avatarInitials: "JI",
      locationLabel: "Jurong East, Singapore",
      fullName: "Jinseo Lee",
      dateOfBirth: "2000-01-01",
      ageYears: 26,
      weightKg: 68.5,
      email: "runner@example.com",
    });

    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports);

    for (const privateKey of ["fullName", "dateOfBirth", "ageYears", "weightKg", "email"]) {
      assert.equal(privateKey in profile, false, `${privateKey} must not be projected`);
    }
    assert.equal(profile.displayName, "Jinseo");
  });

  it("falls back to Basic for a missing or unrecognised subscription status", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East, Singapore" });
    ports.accounts.set(runner, { subscriptionStatus: "PLATINUM" });

    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports);

    assert.equal(profile.subscriptionStatusLabel, "Basic");
  });

  it("reports max level only when the backend published an explicit null", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East", xpToNextLevel: null });
    const atMaxLevel = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports);
    assert.equal(atMaxLevel.isMaxLevel, true);
    assert.equal(atMaxLevel.xpToNextLevel, null);

    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    const unpublished = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports);
    assert.equal(unpublished.isMaxLevel, false);
  });

  it("clamps a stored progress percent into 0..100", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East", levelProgressPercent: 140 });
    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports);
    assert.equal(profile.levelProgressPercent, 100);
  });

  it("serves the caller their own profile without reading block edges", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: viewer } }, ports);
    assert.equal(profile.uid, viewer);
    assert.equal(ports.blockEdgeCalls.length, 0);
  });

  it("hides the profile when the viewer blocked the runner", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    ports.blockedByCaller.add(runner);
    await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports), "permission-denied");
  });

  it("hides the profile when the runner blocked the viewer", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    ports.blockedCaller.add(runner);
    await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports), "permission-denied");
  });

  it("hides the profile of a suspended runner", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    ports.accounts.set(runner, { accountStatus: "suspended" });
    await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports), "permission-denied");
  });

  it("rejects an unauthenticated caller", async () => {
    const ports = fakePorts();
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    await assertHttpsError(() => getRunnerPublicProfile({ data: { uid: runner } }, ports), "unauthenticated");
  });

  it("rejects a malformed request payload", async () => {
    const ports = fakePorts();
    for (const data of [undefined, {}, { uid: "" }, { uid: 7 }, { uid: runner, extra: 1 }, { uid: "users/other" }, { uid: "../other" }]) {
      await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data }, ports), "invalid-argument");
    }
  });

  it("reports a runner with no profile document as not found", async () => {
    const ports = fakePorts();
    await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: { uid: runner } }, ports), "not-found");
  });

  it("resolves a leaderboard entry to its owner without the viewer ever holding a uid", async () => {
    const ports = fakePorts();
    ports.rankOwners.set(rankKey(snapshotId, "#3"), runner);
    ports.profiles.set(runner, { displayName: "Jinseo", nickname: "Jinseo_main", avatarInitials: "JI", locationLabel: "Jurong East, Singapore", level: 8 });
    ports.badges.set(runner, ["10K"]);

    const profile = await getRunnerPublicProfile({ auth: { uid: viewer }, data: { snapshotId, rankLabel: "#3" } }, ports);

    assert.equal(profile.uid, runner);
    assert.equal(profile.displayName, "Jinseo_main");
    assert.deepEqual(profile.ownedBadgeTierIds, ["10K"]);
  });

  it("applies the same block rule to a leaderboard entry as to a uid", async () => {
    const ports = fakePorts();
    ports.rankOwners.set(rankKey(snapshotId, "#3"), runner);
    ports.profiles.set(runner, { displayName: "Jinseo", avatarInitials: "JI", locationLabel: "Jurong East" });
    ports.blockedCaller.add(runner);
    await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: { snapshotId, rankLabel: "#3" } }, ports), "permission-denied");
  });

  it("hides an entry whose rank resolves to no owner", async () => {
    const ports = fakePorts();
    await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data: { snapshotId, rankLabel: "#9" } }, ports), "not-found");
  });

  it("rejects a mixed or partial leaderboard entry payload", async () => {
    const ports = fakePorts();
    for (const data of [
      { snapshotId },
      { rankLabel: "#3" },
      { uid: runner, snapshotId, rankLabel: "#3" },
      { snapshotId, rankLabel: "" },
      { snapshotId: "leaderboardUserRanks/x", rankLabel: "#3" },
      { snapshotId: "../other", rankLabel: "#3" },
    ]) {
      await assertHttpsError(() => getRunnerPublicProfile({ auth: { uid: viewer }, data }, ports), "invalid-argument");
    }
  });
});

async function assertHttpsError(run: () => Promise<unknown>, code: string): Promise<void> {
  await assert.rejects(run, (error: unknown) => typeof error === "object" && error !== null && "code" in error && error["code"] === code);
}

type FakePorts = RunnerPublicProfilePorts & {
  /** snapshotId + NUL + rankLabel -> ownerUid, i.e. the leaderboardUserRanks projection. */
  readonly rankOwners: Map<string, string>;
  readonly profiles: Map<string, Record<string, unknown>>;
  readonly accounts: Map<string, Record<string, unknown>>;
  readonly badges: Map<string, readonly string[]>;
  readonly blockedByCaller: Set<string>;
  readonly blockedCaller: Set<string>;
  readonly blockEdgeCalls: string[];
};

function fakePorts(): FakePorts {
  const rankOwners = new Map<string, string>();
  const profiles = new Map<string, Record<string, unknown>>();
  const accounts = new Map<string, Record<string, unknown>>();
  const badges = new Map<string, readonly string[]>();
  const blockedByCaller = new Set<string>();
  const blockedCaller = new Set<string>();
  const blockEdgeCalls: string[] = [];
  return {
    rankOwners,
    profiles,
    accounts,
    badges,
    blockedByCaller,
    blockedCaller,
    blockEdgeCalls,
    async readBlockEdges(_callerUid: string, targetUid: string): Promise<BlockEdges> {
      blockEdgeCalls.push(targetUid);
      return { callerBlockedTarget: blockedByCaller.has(targetUid), targetBlockedCaller: blockedCaller.has(targetUid) };
    },
    async readProfile(uid: string) {
      return profiles.get(uid);
    },
    async readAccount(uid: string) {
      return accounts.get(uid);
    },
    async readOwnedBadgeTierIds(uid: string) {
      return badges.get(uid) ?? [];
    },
    async resolveLeaderboardEntryOwner(snapshotId: string, rankLabel: string) {
      return rankOwners.get(rankKey(snapshotId, rankLabel));
    },
  };
}
