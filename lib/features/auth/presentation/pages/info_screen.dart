import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';

/// Mô tả 1 tiện ích must-have (có icon + nhãn).
class _Amenity {
  final IconData icon;
  final String label;
  const _Amenity(this.icon, this.label);
}

/// Màn hình bổ sung thông tin / cá nhân hoá trải nghiệm (bước 2 / 2).
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  static const _styles = [
    'Luxury',
    'Business',
    'Wellness',
    'Adventure',
    'Family',
  ];
  static const _amenities = [
    _Amenity(Icons.wifi, 'High-speed Wi-Fi'),
    _Amenity(Icons.spa_outlined, 'Spa & Wellness'),
    _Amenity(Icons.restaurant, 'Fine Dining'),
    _Amenity(Icons.pool, 'Infinity Pool'),
    _Amenity(Icons.devices_other, 'Smart Room Control'),
  ];
  static const _budgets = ['Boutique', 'Premium', 'Ultra-Luxury'];

  String _selectedStyle = 'Luxury';
  final Set<String> _selectedAmenities = {'High-speed Wi-Fi', 'Infinity Pool'};
  int _budgetIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header với nút back + tiêu đề + Skip
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Personalize\nExperience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Thanh tiến trình bước 2/2
            Column(
              children: [
                const Text(
                  'Step 2 of 2',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.goldDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Help our AI curate the perfect stays for your '
                      'travel style.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _sectionTitle('TRAVEL STYLE'),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _styles.map((s) {
                        final selected = s == _selectedStyle;
                        return _Chip(
                          label: s,
                          selected: selected,
                          onTap: () => setState(() => _selectedStyle = s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle('MUST-HAVE AMENITIES'),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.7,
                      children: _amenities.map((a) {
                        final selected =
                            _selectedAmenities.contains(a.label);
                        return _AmenityCard(
                          amenity: a,
                          selected: selected,
                          onTap: () => setState(() {
                            if (selected) {
                              _selectedAmenities.remove(a.label);
                            } else {
                              _selectedAmenities.add(a.label);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle('BUDGET PREFERENCE'),
                    const SizedBox(height: 14),
                    _BudgetSelector(
                      options: _budgets,
                      selectedIndex: _budgetIndex,
                      onChanged: (i) => setState(() => _budgetIndex = i),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Avg. \$400 - \$800 / night',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            // Nút hoàn tất
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: _GoldButton(
                  label: 'Complete Profile',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile completed!')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDark : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.goldDark : AppColors.goldLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  const _AmenityCard({
    required this.amenity,
    required this.selected,
    required this.onTap,
  });

  final _Amenity amenity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.creamDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.goldLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              amenity.icon,
              color: selected ? AppColors.gold : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              amenity.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bộ chọn ngân sách dạng segmented.
class _BudgetSelector extends StatelessWidget {
  const _BudgetSelector({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Nút bấm nền gradient gold (bản dùng riêng cho màn info).
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.goldLight, AppColors.goldDark],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x338B6F3D),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
