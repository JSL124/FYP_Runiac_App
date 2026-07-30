import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/notifications/domain/services/notification_registration_service.dart';

import 'support/fake_notification_services.dart';

void main() {
  group('NotificationRegistrationService', () {
    test(
      'requests permission and waits for Apple APNs token before registering FCM token',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: 'apns-token',
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
          applePushRegistrationEnabled: true,
        );

        await service.registerCurrentDevice();

        expect(client.permissionRequests, 1);
        expect(client.apnsTokenRequests, 1);
        expect(client.tokenRequests, 1);
        expect(callable.registerCalls, [
          const RegisterNotificationDeviceRequest(
            uid: 'runner-1',
            token: 'fcm-token',
            platform: PushNotificationPlatform.apple,
          ),
        ]);
      },
    );

    test(
      'does not request FCM token when Apple APNs token is unavailable',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: null,
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
          applePushRegistrationEnabled: true,
        );

        await service.registerCurrentDevice();

        expect(client.apnsTokenRequests, 1);
        expect(client.tokenRequests, 0);
        expect(callable.registerCalls, isEmpty);
      },
    );

    test(
      'skips Apple push registration when Apple push is not available for the build',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: 'apns-token',
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
        );

        final registered = await service.registerCurrentDevice();

        expect(registered, isFalse);
        expect(client.permissionRequests, 0);
        expect(client.apnsTokenRequests, 0);
        expect(client.tokenRequests, 0);
        expect(callable.registerCalls, isEmpty);
      },
    );

    test(
      'does not mark start complete when registration returns before token registration',
      () async {
        final client = FakePushNotificationClient(
          platform: PushNotificationPlatform.apple,
          permissionStatus: PushNotificationPermissionStatus.authorized,
          apnsToken: null,
          token: 'fcm-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
          applePushRegistrationEnabled: true,
        );

        await service.start();
        client.apnsToken = 'apns-token';
        await service.start();

        expect(client.apnsTokenRequests, 2);
        expect(client.tokenRequests, 1);
        expect(callable.registerCalls, [
          const RegisterNotificationDeviceRequest(
            uid: 'runner-1',
            token: 'fcm-token',
            platform: PushNotificationPlatform.apple,
          ),
        ]);
        await service.dispose();
      },
    );

    test(
      'registers refreshed tokens and unregisters the current token',
      () async {
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'initial-token',
        );
        final callable = FakeNotificationDeviceCallable();
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => 'runner-1',
          applePushRegistrationEnabled: true,
        );

        await service.start();
        client.emitTokenRefresh('refreshed-token');
        await pumpEventQueue();
        await service.unregisterCurrentDevice();

        expect(callable.registerCalls.map((call) => call.token), [
          'initial-token',
          'refreshed-token',
        ]);
        expect(callable.unregisterCalls, [
          const UnregisterNotificationDeviceRequest(
            uid: 'runner-1',
            token: 'refreshed-token',
          ),
        ]);
        await service.dispose();
      },
    );

    test('can register again after unregistering current device', () async {
      final client = FakePushNotificationClient(
        permissionStatus: PushNotificationPermissionStatus.authorized,
        token: 'initial-token',
      );
      final callable = FakeNotificationDeviceCallable();
      var uid = 'runner-1';
      final service = NotificationRegistrationService(
        client: client,
        callable: callable,
        ownerUidProvider: () => uid,
      );

      await service.start();
      await service.unregisterCurrentDevice();
      uid = 'runner-2';
      client.token = 'next-token';
      await service.start();

      expect(
        callable.registerCalls.map((call) => '${call.uid}:${call.token}'),
        ['runner-1:initial-token', 'runner-2:next-token'],
      );
      expect(callable.unregisterCalls, [
        const UnregisterNotificationDeviceRequest(
          uid: 'runner-1',
          token: 'initial-token',
        ),
      ]);
      await service.dispose();
    });

    test(
      'isolates the device from the previous owner even when the remote '
      'unregister fails',
      () async {
        // A sign-out while offline throws here. Before the local teardown was
        // moved ahead of the remote call, the previous owner's message
        // subscriptions stayed live with `_started` still true, so the next
        // sign-in reattached to that stream and the previous account's pushes
        // were written into the new account's inbox.
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'initial-token',
        );
        final callable = FakeNotificationDeviceCallable(unregisterFails: true);
        var uid = 'runner-1';
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => uid,
        );
        final received = <String>[];
        final subscription = service.messages.listen(
          (message) => received.add(message.id),
        );

        await service.start();
        await expectLater(service.unregisterCurrentDevice(), throwsStateError);

        // The previous owner's stream is detached: a late push for runner-1
        // never reaches a listener.
        client.emitForegroundMessage(
          const PushNotificationMessage(id: 'late-for-runner-1'),
        );
        await pumpEventQueue();
        expect(received, isEmpty);

        // And the next owner registers normally rather than being silently
        // skipped by an already-started service.
        uid = 'runner-2';
        client.token = 'next-token';
        await service.start();

        expect(
          callable.registerCalls.map((call) => '${call.uid}:${call.token}'),
          ['runner-1:initial-token', 'runner-2:next-token'],
        );
        await subscription.cancel();
        await service.dispose();
      },
    );

    test(
      'does not unregister the next runner when the account switches first',
      () async {
        // The callable sends only the token; the server resolves the owner from
        // request.auth.uid. An FCM token is per-device, so once runner-2 is
        // signed in this call would disable THEIR device row, not runner-1's.
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'shared-device-token',
        );
        final callable = FakeNotificationDeviceCallable();
        var uid = 'runner-1';
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => uid,
        );

        await service.start();
        // The switch lands while the sign-out is being processed.
        uid = 'runner-2';
        await service.unregisterCurrentDevice();

        expect(callable.unregisterCalls, isEmpty);
        // And runner-2 can still register: teardown left no stale started flag.
        await service.start();
        expect(
          callable.registerCalls.map((call) => '${call.uid}:${call.token}'),
          ['runner-1:shared-device-token', 'runner-2:shared-device-token'],
        );
        await service.dispose();
      },
    );

    test(
      'an in-flight start cannot resurrect a session torn down mid-registration',
      () async {
        // start() awaits permission, token, and the register callable. A
        // sign-out inside that window used to be undone by the slower start()
        // completing afterwards and re-arming _started plus the previous
        // owner's message subscriptions.
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'initial-token',
        );
        final callable = FakeNotificationDeviceCallable();
        String? uid = 'runner-1';
        final service = NotificationRegistrationService(
          client: client,
          callable: callable,
          ownerUidProvider: () => uid,
        );
        final received = <String>[];
        final subscription = service.messages.listen(
          (message) => received.add(message.id),
        );

        // Sign out while start() is still awaiting registration.
        final starting = service.start();
        uid = null;
        await service.unregisterCurrentDevice();
        await starting;

        client.emitForegroundMessage(
          const PushNotificationMessage(id: 'late-for-runner-1'),
        );
        await pumpEventQueue();

        expect(received, isEmpty);
        await subscription.cancel();
        await service.dispose();
      },
    );

    test(
      'forwards foreground, opened, and initial messages through stream seam',
      () async {
        final client = FakePushNotificationClient(
          permissionStatus: PushNotificationPermissionStatus.authorized,
          token: 'initial-token',
          initialMessage: const PushNotificationMessage(
            id: 'initial',
            title: 'Initial',
            body: 'Opened from terminated state',
            data: {'itemId': 'initial'},
          ),
        );
        final service = NotificationRegistrationService(
          client: client,
          callable: FakeNotificationDeviceCallable(),
          ownerUidProvider: () => 'runner-1',
        );
        final messages = <PushNotificationMessage>[];
        final subscription = service.messages.listen(messages.add);

        await service.start();
        client.emitForegroundMessage(
          const PushNotificationMessage(id: 'foreground', title: 'Foreground'),
        );
        client.emitOpenedMessage(
          const PushNotificationMessage(id: 'opened', title: 'Opened'),
        );
        await pumpEventQueue();

        expect(messages.map((message) => message.id), [
          'initial',
          'foreground',
          'opened',
        ]);
        await subscription.cancel();
        await service.dispose();
      },
    );

    test('iOS entitlements do not require Apple Push Notifications', () {
      final entitlement = File(
        'ios/Runner/Runner.entitlements',
      ).readAsStringSync();

      expect(entitlement, isNot(contains('aps-environment')));
    });
  });
}
