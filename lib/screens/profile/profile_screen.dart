import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/screens/test/test_screen.dart';
import 'dart:developer' as developer;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditSheet(UserProfile currentProfile) {
    final nameController = TextEditingController(text: currentProfile.name);
    final ageController = TextEditingController(text: currentProfile.age?.toString() ?? '');
    final stageValueController = TextEditingController(text: currentProfile.stageValue.toString());
    UserRole selectedRole = currentProfile.role;
    StageType selectedStage = currentProfile.stageType;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '정보 수정',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '나이',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('역할', style: Theme.of(sheetContext).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleChip(
                          label: '아빠',
                          selected: selectedRole == UserRole.father,
                          onTap: () => setSheetState(() => selectedRole = UserRole.father),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleChip(
                          label: '엄마',
                          selected: selectedRole == UserRole.mother,
                          onTap: () => setSheetState(() => selectedRole = UserRole.mother),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('현재 시기', style: Theme.of(sheetContext).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('임신 준비'),
                        selected: selectedStage == StageType.trying,
                        onSelected: (val) => setSheetState(() => selectedStage = StageType.trying),
                      ),
                      ChoiceChip(
                        label: const Text('임신 중'),
                        selected: selectedStage == StageType.pregnant,
                        onSelected: (val) => setSheetState(() => selectedStage = StageType.pregnant),
                      ),
                      ChoiceChip(
                        label: const Text('출산 후'),
                        selected: selectedStage == StageType.postpartum,
                        onSelected: (val) => setSheetState(() => selectedStage = StageType.postpartum),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (selectedStage != StageType.trying)
                    TextField(
                      controller: stageValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: selectedStage == StageType.pregnant ? '임신 주차' : '출산 후 개월 수',
                        suffixText: selectedStage == StageType.pregnant ? '주' : '개월',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: isSaving ? null : () async {
                        if (nameController.text.trim().isEmpty) return;

                        setSheetState(() => isSaving = true);
                        try {
                          final updatedProfile = currentProfile.copyWith(
                            name: nameController.text.trim(),
                            age: int.tryParse(ageController.text),
                            role: selectedRole,
                            gender: selectedRole == UserRole.father ? Gender.male : Gender.female,
                            stageType: selectedStage,
                            stageValue: selectedStage == StageType.trying 
                                ? 0 
                                : (int.tryParse(stageValueController.text) ?? 0),
                          );

                          await context.read<UserProvider>().saveProfile(updatedProfile);
                          
                          if (!mounted) return;
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('정보가 수정되었습니다.')),
                          );
                        } catch (e, s) {
                          developer.log('Error saving profile', name: 'myapp.profile', error: e, stackTrace: s);
                          if (!mounted) return;
                          if (sheetContext.mounted) {
                            setSheetState(() => isSaving = false);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('오류가 발생했습니다: $e')),
                          );
                        }
                      },
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('수정 완료'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final profile = userProvider.profile;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '내 정보',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (profile != null)
                        TextButton.icon(
                          onPressed: () => _showEditSheet(profile),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('수정'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (profile == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          '아직 정보가 없어요.\n홈에서 정보를 입력해 주세요.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    _InfoCard(
                      children: [
                        _InfoRow(label: '이름', value: profile.name ?? '-'),
                        _InfoRow(
                            label: '나이',
                            value: profile.age != null ? '${profile.age}세' : '-'),
                        _InfoRow(
                          label: '역할',
                          value: profile.role == UserRole.father ? '아빠' : '엄마',
                        ),
                        _InfoRow(
                          label: '시기',
                          value: _stageLabel(profile.stageType, profile.stageValue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TestScreen()),
                          );
                        },
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('UI 테스트 페이지'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final authService = context.read<AuthService>();
                            final messenger = ScaffoldMessenger.of(context);
                            
                            await authService.signOut();
                            
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(content: Text('로그아웃 되었습니다.')),
                            );
                          } catch (e) {
                            developer.log('Logout error', name: 'myapp.profile', error: e);
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('로그아웃'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _stageLabel(StageType type, int value) {
    switch (type) {
      case StageType.trying: return '임신 준비 중';
      case StageType.pregnant: return '임신 $value주차';
      case StageType.postpartum: return '출산 후 $value개월';
    }
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? theme.colorScheme.primary : Colors.transparent, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children.expand((w) => [w, const Divider(height: 24)]).take(children.length * 2 - 1).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
