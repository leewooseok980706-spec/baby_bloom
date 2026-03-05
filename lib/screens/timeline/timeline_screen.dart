import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/providers/user_provider.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Text(
                '타임라인',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            if (profile == null)
              Expanded(
                child: Center(
                  child: Text(
                    '정보를 먼저 입력해 주세요.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _timelineItems(profile).length,
                  itemBuilder: (_, i) {
                    final items = _timelineItems(profile);
                    final item = items[i];
                    final isCurrent = item.value == profile.stageValue;
                    return _TimelineTile(
                      item: item,
                      isCurrent: isCurrent,
                      isLast: i == items.length - 1,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_TimelineItem> _timelineItems(UserProfile profile) {
    if (profile.stageType == StageType.pregnant) {
      return List.generate(
        40,
        (i) => _TimelineItem(label: '${i + 1}주차', value: i + 1),
      );
    } else if (profile.stageType == StageType.postpartum) {
      return List.generate(
        24,
        (i) => _TimelineItem(label: '${i + 1}개월', value: i + 1),
      );
    }
    return [const _TimelineItem(label: '임신 준비 중', value: 0)];
  }
}

class _TimelineItem {
  final String label;
  final int value;
  const _TimelineItem({required this.label, required this.value});
}

class _TimelineTile extends StatelessWidget {
  final _TimelineItem item;
  final bool isCurrent;
  final bool isLast;

  const _TimelineTile({
    required this.item,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 선 + 점
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 내용
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '현재',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
