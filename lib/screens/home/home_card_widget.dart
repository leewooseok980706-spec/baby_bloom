import 'package:flutter/material.dart';
import 'package:myapp/models/home_card.dart';

class HomeCardWidget extends StatelessWidget {
  final HomeCard card;
  final bool isDone;
  final VoidCallback onDone;
  final VoidCallback onDetail;

  const HomeCardWidget({
    super.key,
    required this.card,
    required this.isDone,
    required this.onDone,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 관점 태그
            _PerspectiveTag(perspective: card.perspective),
            const SizedBox(height: 16),

            // 제목 (최대 2줄)
            Text(
              card.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),

            // 설명 (최대 3줄)
            Text(
              card.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // 버튼 2개
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isDone ? null : onDone,
                    child: Text(isDone ? '완료됨' : '완료했어요'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onDetail,
                    child: const Text('자세히 보기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerspectiveTag extends StatelessWidget {
  final Perspective perspective;

  const _PerspectiveTag({required this.perspective});

  @override
  Widget build(BuildContext context) {
    final labels = {
      Perspective.action: '지금 할 일',
      Perspective.care: '정서 케어',
      Perspective.info: '알아두기',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[perspective]!,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}