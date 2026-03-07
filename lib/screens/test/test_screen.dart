import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/providers/user_provider.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UI & Function Test Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Theme Colors'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorBox(label: 'Primary', color: Theme.of(context).colorScheme.primary),
                _ColorBox(label: 'Secondary', color: Theme.of(context).colorScheme.secondary),
                _ColorBox(label: 'Tertiary', color: Theme.of(context).colorScheme.tertiary),
                _ColorBox(label: 'Error', color: Theme.of(context).colorScheme.error),
                _ColorBox(label: 'Surface', color: Theme.of(context).colorScheme.surface, textColor: Colors.black),
              ],
            ),
            const Divider(height: 40),
            
            _SectionTitle('User Info (Provider)'),
            Text('UID: ${authService.currentUid ?? "Unknown"}'),
            Text('Name: ${userProvider.profile?.name ?? "No Name"}'),
            Text('Role: ${userProvider.profile?.role ?? "No Role"}'),
            Text('Stage: ${userProvider.profile?.stageType ?? "No Stage"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => userProvider.clearProfile(),
              child: const Text('Clear Profile Data (Local)'),
            ),
            const Divider(height: 40),

            _SectionTitle('Input Components'),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Default TextField',
                border: OutlineInputBorder(),
                hintText: 'Enter something...',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Filled TextField',
                filled: true,
                border: UnderlineInputBorder(),
              ),
            ),
            const Divider(height: 40),

            _SectionTitle('Buttons'),
            Row(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filled(onPressed: () {}, icon: const Icon(Icons.add)),
                const SizedBox(width: 8),
                IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                const SizedBox(width: 8),
                TextButton(onPressed: () {}, child: const Text('TextButton')),
              ],
            ),
            const Divider(height: 40),

            _SectionTitle('Snackbar & Feedback'),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This is a test snackbar!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Show Snackbar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _ColorBox({required this.label, required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
