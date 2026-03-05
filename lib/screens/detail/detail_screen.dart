import 'package:flutter/material.dart';
import 'package:myapp/models/home_card.dart';

class DetailScreen extends StatelessWidget {
  final HomeCard card;

  const DetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const perspectiveLabels = {
      Perspective.action: '지금 할 일',
      Perspective.care: '정서 케어',
      Perspective.info: '알아두기',
    };

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leadingWidth: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 관점 태그
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                perspectiveLabels[card.perspective]!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 제목
            Text(
              card.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 요약 설명
            Text(
              card.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(),
            ),

            // 상세 내용
            Text(
              card.detailContent,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.8,
                color: theme.colorScheme.onSurface,
              ),
            ),

            // 광고 영역 (구조만 — 현재는 비어있음)
            if (card.isSponsored) ...[
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '스폰서 영역 (미구현)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
