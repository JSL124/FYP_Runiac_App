import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RunControls extends StatelessWidget {
  const RunControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune),
                label: const Text('Setting'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: RuniacColors.white,
                  foregroundColor: RuniacColors.primaryBlue,
                  side: const BorderSide(color: RuniacColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size.fromHeight(48),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 96,
              height: 96,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Start'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.alt_route),
                label: const Text('Switch Route'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: RuniacColors.white,
                  foregroundColor: RuniacColors.primaryBlue,
                  side: const BorderSide(color: RuniacColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size.fromHeight(48),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
