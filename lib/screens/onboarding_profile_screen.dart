import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingProfileScreen extends StatefulWidget {
  final String firstName;
  final List<String> selectedGoals;

  const OnboardingProfileScreen({
    super.key,
    required this.firstName,
    required this.selectedGoals,
  });

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // BASE PROFILE
  int _age = 25;
  String? _sex;
  double _weight = 70;
  double _height = 170;
  double? _waist;
  String? _bloodGroup;

  // WEIGHT LOSS
  double _targetWeight = 65;
  String? _activityLevel;
  String? _diet;
  int _mealsPerDay = 3;
  bool? _cookYourself;
  String? _weightLossSpeed;

  // MUSCLE
  String? _muscleLevel;
  List<String> _equipment = [];
  int _trainingDays = 3;
  List<String> _muscleGroups = [];

  // WEIGHT GAIN
  String? _weightGainReason;
  String? _appetite;

  // SLEEP
  double _sleepHours = 7;
  String? _bedTime;
  String? _wakeTime;
  String? _nightWakeups;
  bool? _screensBeforeSleep;
  bool? _caffeineAfter14;
  int _stressBeforeSleep = 3;

  // STRESS
  List<String> _stressSources = [];
  int _workHours = 40;
  List<String> _stressSymptoms = [];
  List<String> _stressTechniques = [];

  // HEALTH
  bool _hasChronicDisease = false;
  Map<String, List<String>> _selectedDiseases = {};
  bool _hasTreatment = false;
  String? _expandedCategory;

  final Map<String, Map<String, dynamic>> _diseaseCategories = {
    'Métabolisme & Sucre': {
      'icon': '🩸',
      'color': const Color(0xFFEE5A24),
      'items': [
        'Diabète Type 1', 'Diabète Type 2', 'Prédiabète',
        'Diabète gestationnel', 'Cholestérol élevé',
        'Triglycérides élevés', 'Obésité'
      ],
    },
    'Cœur & Circulation': {
      'icon': '❤️',
      'color': const Color(0xFFE74C3C),
      'items': [
        'Hypertension stade 1', 'Hypertension stade 2',
        'Insuffisance cardiaque', 'Arythmie', 'Coronaropathie'
      ],
    },
    'Respiration': {
      'icon': '🫁',
      'color': const Color(0xFF2F80ED),
      'items': ['Asthme', 'BPCO'],
    },
    'Neurologie': {
      'icon': '🧠',
      'color': const Color(0xFF9B59B6),
      'items': ['Épilepsie', 'Migraine chronique'],
    },
    'Hormones & Organes': {
      'icon': '⚙️',
      'color': const Color(0xFF27AE60),
      'items': [
        'Hypothyroïdie', 'Hyperthyroïdie',
        'Maladie rénale chronique'
      ],
    },
    'Os & Articulations': {
      'icon': '🦴',
      'color': const Color(0xFFFF9F43),
      'items': ['Arthrite', 'Arthrose', 'Ostéoporose'],
    },
  };

  List<Map<String, dynamic>> get _pages {
    final pages = <Map<String, dynamic>>[];
    pages.add({'type': 'base', 'title': 'Profil de base', 'icon': '👤'});

    if (widget.selectedGoals.contains('weight_loss')) {
      pages.add({'type': 'weight_loss', 'title': 'Perte de poids', 'icon': '🏃'});
    }
    if (widget.selectedGoals.contains('muscle')) {
      pages.add({'type': 'muscle', 'title': 'Prise de muscle', 'icon': '💪'});
    }
    if (widget.selectedGoals.contains('weight_gain')) {
      pages.add({'type': 'weight_gain', 'title': 'Prise de poids', 'icon': '⚖️'});
    }
    if (widget.selectedGoals.contains('sleep')) {
      pages.add({'type': 'sleep', 'title': 'Sommeil', 'icon': '😴'});
    }
    if (widget.selectedGoals.contains('stress')) {
      pages.add({'type': 'stress', 'title': 'Gestion du stress', 'icon': '🧘'});
    }
    pages.add({'type': 'health', 'title': 'Votre santé', 'icon': '🏥'});
    return pages;
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _saveAndFinish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _saveAndFinish() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Données identité (séparées)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('base')
          .set({
        'age': _age,
        'sex': _sex,
        'weight': _weight,
        'height': _height,
        'waist': _waist,
        'bloodGroup': _bloodGroup,
        'goals': widget.selectedGoals,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Données médicales (séparées et sécurisées)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medical')
          .doc('health')
          .set({
        'hasChronicDisease': _hasChronicDisease,
        'diseases': _selectedDiseases,
        'hasTreatment': _hasTreatment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // TODO: Navigate to Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil créé avec succès ! 🎉'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  // Back + Progress
                  Row(
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: _back,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Étape ${_currentPage + 1} sur ${pages.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${((_currentPage + 1) / pages.length * 100).round()}%',
                                  style: const TextStyle(
                                    color: Color(0xFF2F80ED),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (_currentPage + 1) / pages.length,
                                backgroundColor: const Color(0xFFE5E7EB),
                                valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF2F80ED)),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pages[index]['icon'],
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pages[index]['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPageContent(pages[index]['type']),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentPage == pages.length - 1
                              ? 'Terminer 🎉'
                              : 'Continuer →',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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

  Widget _buildPageContent(String type) {
    switch (type) {
      case 'base':
        return _buildBasePage();
      case 'weight_loss':
        return _buildWeightLossPage();
      case 'muscle':
        return _buildMusclePage();
      case 'weight_gain':
        return _buildWeightGainPage();
      case 'sleep':
        return _buildSleepPage();
      case 'stress':
        return _buildStressPage();
      case 'health':
        return _buildHealthPage();
      default:
        return const SizedBox();
    }
  }

  // ==================== BASE PAGE ====================
  Widget _buildBasePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Age
        _buildSectionTitle('Âge', required: true),
        const SizedBox(height: 12),
        _buildWheel(
          value: _age.toDouble(),
          min: 10,
          max: 100,
          unit: 'ans',
          onChanged: (v) => setState(() => _age = v.round()),
        ),

        const SizedBox(height: 28),

        // Sex
        _buildSectionTitle('Sexe', required: true),
        const SizedBox(height: 12),
        Row(
          children: ['Homme', 'Femme', 'Autre'].map((s) =>
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildChip(s, _sex == s,
                  () => setState(() => _sex = s)),
            ),
          ).toList(),
        ),

        const SizedBox(height: 28),

        // Weight & Height
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Poids', required: true),
                  const SizedBox(height: 12),
                  _buildWheel(
                    value: _weight,
                    min: 30,
                    max: 250,
                    unit: 'kg',
                    onChanged: (v) => setState(() => _weight = v),
                    decimals: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Taille', required: true),
                  const SizedBox(height: 12),
                  _buildWheel(
                    value: _height,
                    min: 100,
                    max: 230,
                    unit: 'cm',
                    onChanged: (v) => setState(() => _height = v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Waist (optional)
        _buildSectionTitle('Tour de taille', required: false),
        const SizedBox(height: 4),
        const Text(
          'Indicateur de risque cardiovasculaire',
          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 12),
        _buildWheel(
          value: _waist ?? 80,
          min: 40,
          max: 180,
          unit: 'cm',
          onChanged: (v) => setState(() => _waist = v),
        ),

        const SizedBox(height: 28),

        // Blood group (optional)
        _buildSectionTitle('Groupe sanguin', required: false),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Je ne sais pas']
              .map((g) => _buildChip(g, _bloodGroup == g,
                  () => setState(() => _bloodGroup = g)))
              .toList(),
        ),
      ],
    );
  }

  // ==================== WEIGHT LOSS PAGE ====================
  Widget _buildWeightLossPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Poids cible', required: true),
        const SizedBox(height: 12),
        _buildWheel(
          value: _targetWeight,
          min: 30,
          max: 250,
          unit: 'kg',
          onChanged: (v) => setState(() => _targetWeight = v),
          decimals: true,
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Vitesse souhaitée', required: true),
        const SizedBox(height: 12),
        ...{
          'Doucement 🐢': 'slow',
          'Modérément 🚶': 'moderate',
          'Rapidement 🏃': 'fast',
        }.entries.map((e) => _buildRadioCard(
          e.key, _weightLossSpeed == e.value,
          () => setState(() => _weightLossSpeed = e.value),
        )),

        const SizedBox(height: 28),

        _buildSectionTitle('Niveau d\'activité actuel', required: true),
        const SizedBox(height: 12),
        ...{
          'Sédentaire 🪑': 'sedentary',
          'Légèrement actif 🚶': 'light',
          'Modérément actif 🚴': 'moderate',
          'Très actif 🏋️': 'active',
        }.entries.map((e) => _buildRadioCard(
          e.key, _activityLevel == e.value,
          () => setState(() => _activityLevel = e.value),
        )),

        const SizedBox(height: 28),

        _buildSectionTitle('Régime alimentaire', required: false),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Standard', 'Végétarien', 'Vegan', 'Sans gluten',
            'Sans lactose', 'Halal', 'Keto', 'Méditerranéen'
          ].map((d) => _buildChip(d, _diet == d,
              () => setState(() => _diet = d))).toList(),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Repas par jour', required: false),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (_mealsPerDay > 1) _mealsPerDay--;
              }),
              icon: const Icon(Icons.remove_circle_outline,
                  color: Color(0xFF2F80ED)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_mealsPerDay repas',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F80ED),
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                if (_mealsPerDay < 6) _mealsPerDay++;
              }),
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF2F80ED)),
            ),
          ],
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Cuisinez-vous vous-même ?', required: false),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip('Oui 👨‍🍳', _cookYourself == true,
                () => setState(() => _cookYourself = true)),
            const SizedBox(width: 10),
            _buildChip('Non 🍔', _cookYourself == false,
                () => setState(() => _cookYourself = false)),
          ],
        ),
      ],
    );
  }

  // ==================== MUSCLE PAGE ====================
  Widget _buildMusclePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Poids cible', required: false),
        const SizedBox(height: 12),
        _buildWheel(
          value: _targetWeight,
          min: 30,
          max: 250,
          unit: 'kg',
          onChanged: (v) => setState(() => _targetWeight = v),
          decimals: true,
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Niveau actuel', required: true),
        const SizedBox(height: 12),
        ...{
          'Débutant 🌱': 'beginner',
          'Intermédiaire 💪': 'intermediate',
          'Avancé 🏋️': 'advanced',
          'Athlète 🏆': 'athlete',
        }.entries.map((e) => _buildRadioCard(
          e.key, _muscleLevel == e.value,
          () => setState(() => _muscleLevel = e.value),
        )),

        const SizedBox(height: 28),

        _buildSectionTitle('Équipement disponible', required: true),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Aucun', 'Haltères', 'Barres & disques',
            'Bandes élastiques', 'Machines', 'Salle complète'
          ].map((e) {
            final selected = _equipment.contains(e);
            return _buildChip(e, selected, () => setState(() {
              selected ? _equipment.remove(e) : _equipment.add(e);
            }));
          }).toList(),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Jours d\'entraînement/semaine', required: true),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (_trainingDays > 1) _trainingDays--;
              }),
              icon: const Icon(Icons.remove_circle_outline,
                  color: Color(0xFF2F80ED)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_trainingDays jours',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F80ED),
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                if (_trainingDays < 7) _trainingDays++;
              }),
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF2F80ED)),
            ),
          ],
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Groupes musculaires prioritaires', required: false),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Pectoraux', 'Dos', 'Épaules', 'Bras',
            'Abdos', 'Jambes', 'Fessiers', 'Corps entier'
          ].map((g) {
            final selected = _muscleGroups.contains(g);
            return _buildChip(g, selected, () => setState(() {
              selected ? _muscleGroups.remove(g) : _muscleGroups.add(g);
            }));
          }).toList(),
        ),
      ],
    );
  }

  // ==================== WEIGHT GAIN PAGE ====================
  Widget _buildWeightGainPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Poids cible', required: true),
        const SizedBox(height: 12),
        _buildWheel(
          value: _targetWeight,
          min: 30,
          max: 250,
          unit: 'kg',
          onChanged: (v) => setState(() => _targetWeight = v),
          decimals: true,
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Raison de la prise de poids', required: true),
        const SizedBox(height: 12),
        ...{
          'Constitution naturellement mince 🧬': 'thin',
          'Récupération post-maladie 🏥': 'recovery',
          'Contexte médical 👨‍⚕️': 'medical',
          'Autre 💭': 'other',
        }.entries.map((e) => _buildRadioCard(
          e.key, _weightGainReason == e.value,
          () => setState(() => _weightGainReason = e.value),
        )),

        const SizedBox(height: 28),

        _buildSectionTitle('Appétit naturel', required: true),
        const SizedBox(height: 12),
        ...{
          'Faible 😔': 'low',
          'Normal 😊': 'normal',
          'Variable 🔄': 'variable',
        }.entries.map((e) => _buildRadioCard(
          e.key, _appetite == e.value,
          () => setState(() => _appetite = e.value),
        )),
      ],
    );
  }

  // ==================== SLEEP PAGE ====================
  Widget _buildSleepPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Heures de sommeil par nuit', required: true),
        const SizedBox(height: 12),
        _buildWheel(
          value: _sleepHours,
          min: 2,
          max: 12,
          unit: 'h',
          onChanged: (v) => setState(() => _sleepHours = v),
          decimals: true,
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Réveils nocturnes', required: true),
        const SizedBox(height: 12),
        ...{
          'Jamais 😴': 'never',
          'Parfois (1-2x/semaine) 🌙': 'sometimes',
          'Souvent (3x+/semaine) 😰': 'often',
          'Toutes les nuits 😩': 'always',
        }.entries.map((e) => _buildRadioCard(
          e.key, _nightWakeups == e.value,
          () => setState(() => _nightWakeups = e.value),
        )),

        const SizedBox(height: 28),

        _buildSectionTitle('Écrans avant de dormir ?', required: true),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip('Oui 📱', _screensBeforeSleep == true,
                () => setState(() => _screensBeforeSleep = true)),
            const SizedBox(width: 10),
            _buildChip('Non ✅', _screensBeforeSleep == false,
                () => setState(() => _screensBeforeSleep = false)),
          ],
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Café/thé après 14h ?', required: true),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip('Oui ☕', _caffeineAfter14 == true,
                () => setState(() => _caffeineAfter14 = true)),
            const SizedBox(width: 10),
            _buildChip('Non ✅', _caffeineAfter14 == false,
                () => setState(() => _caffeineAfter14 = false)),
          ],
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Niveau de stress avant de dormir', required: true),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('😌 Calme', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const Text('😰 Très stressé', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        ),
        Slider(
          value: _stressBeforeSleep.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: const Color(0xFF2F80ED),
          onChanged: (v) => setState(() => _stressBeforeSleep = v.round()),
        ),
        Center(
          child: Text(
            ['', '😌 Très calme', '🙂 Calme', '😐 Neutre',
             '😟 Stressé', '😰 Très stressé'][_stressBeforeSleep],
            style: const TextStyle(
              color: Color(0xFF2F80ED),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STRESS PAGE ====================
  Widget _buildStressPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sources de stress', required: true),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Travail 💼', 'Relations 💑', 'Finances 💰',
            'Santé 🏥', 'Avenir 🔮', 'Surcharge mentale 🧠', 'Isolement 😔'
          ].map((s) {
            final selected = _stressSources.contains(s);
            return _buildChip(s, selected, () => setState(() {
              selected ? _stressSources.remove(s) : _stressSources.add(s);
            }));
          }).toList(),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Heures de travail/semaine', required: false),
        const SizedBox(height: 12),
        _buildWheel(
          value: _workHours.toDouble(),
          min: 0,
          max: 80,
          unit: 'h/sem',
          onChanged: (v) => setState(() => _workHours = v.round()),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Manifestations physiques', required: false),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Maux de tête 🤕', 'Tensions musculaires 💪',
            'Troubles digestifs 🤢', 'Palpitations ❤️',
            'Troubles du sommeil 😴', 'Fatigue chronique 😩'
          ].map((s) {
            final selected = _stressSymptoms.contains(s);
            return _buildChip(s, selected, () => setState(() {
              selected ? _stressSymptoms.remove(s) : _stressSymptoms.add(s);
            }));
          }).toList(),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Techniques déjà essayées', required: false),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Méditation 🧘', 'Yoga 🤸', 'Sport 🏃',
            'Respiration 🌬️', 'Thérapie 🛋️',
            'Journaling 📝', 'Aucune 🚫'
          ].map((s) {
            final selected = _stressTechniques.contains(s);
            return _buildChip(s, selected, () => setState(() {
              selected ? _stressTechniques.remove(s) : _stressTechniques.add(s);
            }));
          }).toList(),
        ),
      ],
    );
  }

  // ==================== HEALTH PAGE ====================
  Widget _buildHealthPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Maladie chronique diagnostiquée ?', required: true),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip('Oui', _hasChronicDisease,
                () => setState(() => _hasChronicDisease = true)),
            const SizedBox(width: 10),
            _buildChip('Non', !_hasChronicDisease,
                () => setState(() {
                  _hasChronicDisease = false;
                  _selectedDiseases.clear();
                })),
          ],
        ),

        if (_hasChronicDisease) ...[
          const SizedBox(height: 20),
          _buildSectionTitle('Sélectionnez vos pathologies', required: true),
          const SizedBox(height: 12),

          // Catégories avec sous-types
          ..._diseaseCategories.entries.map((entry) {
            final isExpanded = _expandedCategory == entry.key;
            final selectedCount = (_selectedDiseases[entry.key] ?? []).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isExpanded
                    ? (entry.value['color'] as Color).withOpacity(0.05)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isExpanded || selectedCount > 0
                      ? entry.value['color'] as Color
                      : const Color(0xFFE5E7EB),
                  width: isExpanded || selectedCount > 0 ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => setState(() {
                      _expandedCategory = isExpanded ? null : entry.key;
                    }),
                    leading: Text(entry.value['icon'],
                        style: const TextStyle(fontSize: 24)),
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selectedCount > 0
                            ? entry.value['color'] as Color
                            : const Color(0xFF0D1B2A),
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: entry.value['color'] as Color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$selectedCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (entry.value['items'] as List<String>)
                            .map((disease) {
                          final isSelected = (_selectedDiseases[entry.key] ?? [])
                              .contains(disease);
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedDiseases[entry.key] ??= [];
                              isSelected
                                  ? _selectedDiseases[entry.key]!.remove(disease)
                                  : _selectedDiseases[entry.key]!.add(disease);
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (entry.value['color'] as Color)
                                        .withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? entry.value['color'] as Color
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                disease,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? entry.value['color'] as Color
                                      : const Color(0xFF374151),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 24),

        _buildSectionTitle('Traitement médical en cours ?', required: true),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChip('Oui 💊', _hasTreatment,
                () => setState(() => _hasTreatment = true)),
            const SizedBox(width: 10),
            _buildChip('Non ✅', !_hasTreatment,
                () => setState(() => _hasTreatment = false)),
          ],
        ),

        if (_hasTreatment) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFD8FF)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2F80ED), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous pourrez ajouter vos médicaments en détail dans votre profil après l\'inscription.',
                    style: TextStyle(
                      color: Color(0xFF2F80ED),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildWheel({
    required double value,
    required double min,
    required double max,
    required String unit,
    required Function(double) onChanged,
    bool decimals = false,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (value > min) {
                onChanged(decimals ? value - 0.5 : value - 1);
              }
            },
            icon: const Icon(Icons.remove_circle_outline,
                color: Color(0xFF2F80ED), size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                decimals
                    ? value.toStringAsFixed(1)
                    : value.round().toString(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              if (value < max) {
                onChanged(decimals ? value + 0.5 : value + 1);
              }
            },
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF2F80ED), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2F80ED).withOpacity(0.1)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF2F80ED)
                : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFF2F80ED)
                : const Color(0xFF374151),
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioCard(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2F80ED).withOpacity(0.08)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF2F80ED)
                : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2F80ED)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: selected
                    ? const Color(0xFF2F80ED)
                    : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.circle, size: 8, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF2F80ED)
                    : const Color(0xFF374151),
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool required}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B2A),
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 6),
        if (!required)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Optionnel',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
      ],
    );
  }
}