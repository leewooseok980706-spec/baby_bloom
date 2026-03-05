import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/providers/home_card_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/screens/detail/detail_screen.dart';
import 'package:myapp/screens/home/home_card_widget.dart';
import 'package:myapp/utils/db_seeder.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  final Set<int> _doneCards = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final uid = context.read<AuthService>().currentUid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();
    await userProvider.loadProfile(uid);

    if (userProvider.profile == null) {
      // 프로필 없으면 입력 유도 — 카드 로드 생략
      return;
    }
    await _loadCards();
  }

  Future<void> _loadCards() async {
    final profile = context.read<UserProvider>().profile;
    if (profile == null) return;

    try {
      await context.read<HomeCardProvider>().fetchRecommendedCards(
            role: profile.role,
            stageType: profile.stageType,
            stageValue: profile.stageValue,
          );
    } catch (e) {
      if (!mounted) return;
      _showError('카드를 불러오지 못했어요.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // BottomSheet — StatefulBuilder로 내부 상태(Radio) 독립 관리
  void _showInfoInputSheet() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final stageValueController = TextEditingController(text: '12');
    UserRole selectedRole = UserRole.father;
    StageType selectedStage = StageType.pregnant;
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
                    '나의 정보 입력',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 이름
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 나이
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '나이',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 역할 선택
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

                  // 시기 선택
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

                  // 주차/개월 입력 (준비 중일 때는 숨김)
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

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty) {
                                _showError('이름을 입력해 주세요.');
                                return;
                              }

                              setSheetState(() => isSaving = true);
                              try {
                                final authService = Provider.of<AuthService>(context, listen: false);
                                final uid = authService.currentUid;
                                if (uid == null) throw Exception('인증 정보 없음');

                                final newProfile = UserProfile(
                                  uid: uid,
                                  name: nameController.text.trim(),
                                  age: int.tryParse(ageController.text),
                                  gender: selectedRole == UserRole.father ? Gender.male : Gender.female,
                                  role: selectedRole,
                                  stageType: selectedStage,
                                  stageValue: selectedStage == StageType.trying 
                                      ? 0 
                                      : (int.tryParse(stageValueController.text) ?? 0),
                                  createdAt: DateTime.now(),
                                );

                                await context.read<UserProvider>().saveProfile(newProfile);
                                DBSeeder().seedInitialData().catchError((e) => developer.log('Seeding error: $e'));

                                if (!sheetContext.mounted) return;
                                Navigator.of(sheetContext).pop();
                                await _loadCards();
                              } catch (e) {
                                if (sheetContext.mounted) {
                                  setSheetState(() => isSaving = false);
                                  _showError('저장 실패: $e');
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('저장하고 시작하기'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Consumer<UserProvider>(
                builder: (_, userProvider, __) {
                  final name = userProvider.profile?.name ?? '당신';
                  return Text(
                    '$name에게 필요한 것들',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // 카드 영역
            Expanded(
              child: Consumer<HomeCardProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.cards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 64,
                            color: theme.colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '나의 정보를 먼저 입력해 주세요.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _showInfoInputSheet,
                            icon: const Icon(Icons.edit),
                            label: const Text('나의 정보 입력'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // 페이지 인디케이터
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          provider.cards.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 스와이프 카드
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: provider.cards.length,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          itemBuilder: (_, index) {
                            final card = provider.cards[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: HomeCardWidget(
                                card: card,
                                isDone: _doneCards.contains(index),
                                onDone: () {
                                  setState(() => _doneCards.add(index));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('잘 하셨어요! 😊'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                onDetail: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(card: card),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 역할 선택 칩 위젯
class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
