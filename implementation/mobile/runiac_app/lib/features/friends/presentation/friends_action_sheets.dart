import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_sheet_primitives.dart';
import '../../../core/widgets/runiac_sheet_scaffold.dart';
import '../../you/presentation/widgets/you_surface_primitives.dart';
import '../domain/models/friends_read_model.dart';

enum FriendAction { remove, block, report }

Future<FriendAction?> showFriendActionsSheet(
  BuildContext context,
  FriendUserReadModel user,
) {
  return showModalBottomSheet<FriendAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      final firstName = user.displayName.trim().split(RegExp(r'\s+')).first;
      return RuniacSheetScaffold(
        title: user.displayName,
        subtitle: 'Choose an action',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RuniacSheetActionTile(
              key: const ValueKey('friends-remove-action'),
              icon: Icons.person_remove_rounded,
              title: 'Remove Friend',
              caption: 'Remove $firstName from your friends',
              onTap: () => Navigator.of(context).pop(FriendAction.remove),
            ),
            const SizedBox(height: 10),
            RuniacSheetActionTile(
              key: const ValueKey('friends-block-action'),
              icon: Icons.block_rounded,
              tint: RuniacColors.errorRed,
              titleColor: RuniacColors.errorRed,
              title: 'Block',
              caption: 'Stop all contact both ways',
              onTap: () => Navigator.of(context).pop(FriendAction.block),
            ),
            const SizedBox(height: 10),
            RuniacSheetActionTile(
              key: const ValueKey('friends-report-action'),
              icon: Icons.flag_rounded,
              title: 'Report',
              caption: 'Tell us what went wrong',
              onTap: () => Navigator.of(context).pop(FriendAction.report),
            ),
            const SizedBox(height: 4),
            const RuniacSheetCancelButton(),
          ],
        ),
      );
    },
  );
}

Future<bool> showFriendActionConfirmation(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool isDestructive = true,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final tint = isDestructive ? RuniacColors.errorRed : RuniacColors.primaryBlue;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: RuniacColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        icon: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: tint, size: 28),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: YouTextStyles.cardTitle,
        ),
        content: Text(
          body,
          textAlign: TextAlign.center,
          style: YouTextStyles.body,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('friends-confirm-action'),
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive
                  ? RuniacColors.errorRed
                  : RuniacColors.primaryBlue,
              foregroundColor: RuniacColors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result == true;
}

String friendActionConfirmationBody(FriendAction action) {
  return switch (action) {
    FriendAction.remove =>
      'This removes the friendship. You can send a new friend request after 24 hours.',
    FriendAction.block =>
      'This removes the friendship and pending requests in both directions. '
          'You will no longer appear to each other in Friends, Search, or Feed.',
    // Report opens its own reason-picker sheet instead of this yes/no
    // confirmation dialog, so this body copy is never shown for it.
    FriendAction.report => '',
  };
}
