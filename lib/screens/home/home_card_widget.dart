import 'package:flutter/material.dart';
import 'package:myapp/models/home_card.dart';

class HomeCardWidget extends StatelessWidget {
  final HomeCard card;

  const HomeCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Perspective Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getPerspectiveColor(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(_getPerspectiveIcon(), color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  _getPerspectiveLabel(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (card.isSponsored)
                  const Text('AD', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Show specific tips if available
                if (card.actionTip != null) ...[
                  const SizedBox(height: 12),
                  _buildTipBox(context, '오늘의 팁', card.actionTip!, Icons.lightbulb_outline),
                ],
                
                if (card.perspective == Perspective.expert && card.checklist != null) ...[
                  const SizedBox(height: 12),
                  _buildTipBox(context, '체크리스트', card.checklist!, Icons.check_circle_outline),
                ],

                if (card.perspective == Perspective.mission && card.whyItMatters != null) ...[
                  const SizedBox(height: 12),
                  _buildTipBox(context, '이유', card.whyItMatters!, Icons.favorite_border),
                ],
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showDetail(context),
                    child: const Text('자세히 보기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox(BuildContext context, String label, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPerspectiveColor(BuildContext context) {
    switch (card.perspective) {
      case Perspective.action:
        return Colors.orangeAccent;
      case Perspective.care:
        return Colors.pinkAccent;
      case Perspective.info:
        return Colors.blueAccent;
      case Perspective.expert:
        return Colors.teal;
      case Perspective.mission:
        return Colors.indigoAccent;
    }
  }

  IconData _getPerspectiveIcon() {
    switch (card.perspective) {
      case Perspective.action:
        return Icons.play_arrow;
      case Perspective.care:
        return Icons.favorite;
      case Perspective.info:
        return Icons.info_outline;
      case Perspective.expert:
        return Icons.medical_services_outlined;
      case Perspective.mission:
        return Icons.assignment_outlined;
    }
  }

  String _getPerspectiveLabel() {
    switch (card.perspective) {
      case Perspective.action:
        return '데일리 액션';
      case Perspective.care:
        return '셀프 케어';
      case Perspective.info:
        return '꿀팁 정보';
      case Perspective.expert:
        return '전문의 조언';
      case Perspective.mission:
        return '아빠 미션';
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.detailContent,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              if (card.doctorTip != null) ...[
                const SizedBox(height: 24),
                _buildSection(context, '전문의 팁', card.doctorTip!),
              ],
              if (card.bodyChanges != null) ...[
                const SizedBox(height: 24),
                _buildSection(context, '신체 변화', card.bodyChanges!),
              ],
              if (card.checklist != null) ...[
                const SizedBox(height: 24),
                _buildSection(context, '체크리스트', card.checklist!),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
      ],
    );
  }
}
