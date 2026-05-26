import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class MapsTopOverlay extends StatelessWidget {
  const MapsTopOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _MapsSearchField()),
        SizedBox(width: 10),
        _SavedRoutesButton(),
      ],
    );
  }
}

class _MapsSearchField extends StatelessWidget {
  const _MapsSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RuniacColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14172033),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: RuniacColors.textPrimary, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search routes or area',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedRoutesButton extends StatelessWidget {
  const _SavedRoutesButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332F50C7),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, color: RuniacColors.white, size: 20),
          SizedBox(width: 7),
          Text(
            'Saved',
            style: TextStyle(
              color: RuniacColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
