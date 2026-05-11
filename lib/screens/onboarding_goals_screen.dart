import 'package:flutter/material.dart';
import 'onboarding_profile_screen.dart';

class OnboardingGoalsScreen extends StatefulWidget {
  final String firstName;
  const OnboardingGoalsScreen({super.key, required this.firstName});

  @override
  State<OnboardingGoalsScreen> createState() => _OnboardingGoalsScreenState();
}

class _OnboardingGoalsScreenState extends State<OnboardingGoalsScreen> {
  final List<String> _selectedGoals = [];

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'weight_loss',
      'icon': '🏃',
      'title': 'Perdre du poids',
      'subtitle': 'Réduire ma masse corporelle sainement',
      'color': const Color(0xFF00C9A7),
    },
    {
      'id': 'muscle',
      'icon': '💪',
      'title': 'Prendre du muscle',
      'subtitle': 'Développer ma masse musculaire',
      'color': const Color(0xFF2F80ED),
    },
    {
      'id': 'weight_gain',
      'icon': '⚖️',
      'title': 'Prendre du poids',
      'subtitle': 'Augmenter ma masse corporelle',
      'color': const Color(0xFFFF9F43),
    },
    {
      'id': 'treatment',
      'icon': '💊',
      'title': 'Suivre mon traitement',
      'subtitle': 'Gérer mes médicaments au quotidien',
      'color': const Color(0xFFEE5A24),
    },
    {
      'id': 'chronic',
      'icon': '🏥',
      'title': 'Gérer ma maladie chronique',
      'subtitle': 'Diabète, hypertension, cholestérol...',
      'color': const Color(0xFF9B59B6),
    },
    {
      'id': 'sleep',
      'icon': '😴',
      'title': 'Améliorer mon sommeil',
      'subtitle': 'Mieux dormir, récupérer efficacement',
      'color': const Color(0xFF1B4F72),
    },
    {
      'id': 'stress',
      'icon': '🧘',
      'title': 'Réduire mon stress',
      'subtitle': 'Anxiété, surcharge mentale, relaxation',
      'color': const Color(0xFF27AE60),
    },
  ];

  void _toggleGoal(String id) {
    setState(() {
      if (_selectedGoals.contains(id)) {
        _selectedGoals.remove(id);
      } else {
        _selectedGoals.add(id);
      }
    });
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingProfileScreen(
          firstName: widget.firstName,
          selectedGoals: _selectedGoals,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStepIndicator(2),
                    const SizedBox(height: 32),
                    Text(
                      'Bonjour ${widget.firstName} 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quels sont vos objectifs de santé ?\nVous pouvez en choisir plusieurs.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(_goals.length, (index) {
                      final goal = _goals[index];
                      final isSelected = _selectedGoals.contains(goal['id']);
                      return GestureDetector(
                        onTap: () => _toggleGoal(goal['id']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (goal['color'] as Color).withOpacity(0.08)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? goal['color'] as Color
                                  : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: (goal['color'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    goal['icon'],
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal['title'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? goal['color'] as Color
                                            : const Color(0xFF0D1B2A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      goal['subtitle'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? goal['color'] as Color
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? goal['color'] as Color
                                        : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGoals.isEmpty ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedGoals.isEmpty
                        ? 'Sélectionnez au moins un objectif'
                        : 'Continuer →',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _selectedGoals.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive || isDone
                      ? const Color(0xFF2F80ED)
                      : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '$step',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone
                        ? const Color(0xFF2F80ED)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}