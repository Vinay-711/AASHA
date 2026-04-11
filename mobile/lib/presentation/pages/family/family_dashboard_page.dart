import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class FamilyDashboardPage extends StatelessWidget {
  const FamilyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── App Header ──
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 16 : 36,
              bottom: 16,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AASHA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Your Health Guardian',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.iconGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Header Actions
                Row(
                  children: [
                    _HeaderIcon(icon: Icons.language_rounded, label: 'Language', iconColor: Colors.blueAccent),
                    const SizedBox(width: 16),
                    _HeaderIcon(icon: Icons.notifications_active_rounded, label: 'Alerts', iconColor: Colors.orange, hasBadge: true),
                    const SizedBox(width: 16),
                    _HeaderIcon(icon: Icons.settings_rounded, label: 'Settings', iconColor: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),

          // ── Scrollable Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Family Member Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.deepPurple, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Add Family Member',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Row(
                    children: const [
                      Text('🏆', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text(
                        'Guardian (Ram) Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Guardian Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // User info and points
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB5EAD7),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: Text('👴', style: TextStyle(fontSize: 28))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ramesh ji',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Text('🥈', style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Health Hero', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700, fontSize: 14)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: const [
                                  Text('520', style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900)),
                                  Text('Points', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Stats Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatBox(icon: '✅', number: '12', label: 'Verifications'),
                            _StatBox(icon: '🏥', number: '8', label: 'Pharmacies'),
                            _StatBox(icon: '🤝', number: '5', label: 'Helped'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Next Badge Widget
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF7F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(text: 'Next badge: 🥇 ', style: TextStyle(color: AppColors.textBody, fontSize: 13)),
                                    TextSpan(text: 'Community Guardian (480 more points)', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Progress bar
                              Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Container(
                                    height: 8,
                                    width: MediaQuery.of(context).size.width * 0.45,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Family Member: Priya
                  _FamilyMemberCard(
                    name: 'Priya',
                    relation: 'Daughter, 32 years',
                    avatarStr: '👩',
                    avatarColor: const Color(0xFFFFD1DC),
                    isSafe: true,
                    medIcon: '💊',
                    medTitle: 'No medicines',
                    medSubtitle: null,
                    locIcon: '📍',
                    locTitle: 'Office,\nBangalore',
                    locSubtitle: 'Just now',
                    btnPrimaryText: 'Call',
                    btnPrimaryIcon: Icons.phone_rounded,
                    btnSecondaryText: 'Remind',
                    btnSecondaryIcon: Icons.notifications_active_rounded,
                  ),

                  const SizedBox(height: 24),

                  // Family Member: Anjali
                  _FamilyMemberCard(
                    name: 'Anjali',
                    relation: 'Granddaughter, 24 years',
                    avatarStr: '👩‍🎓',
                    avatarColor: const Color(0xFFFADADD),
                    isSafe: true,
                    medIcon: '💊',
                    medTitle: 'Medicines:',
                    medSubtitle: '1/1 ✅',
                    locIcon: '📍',
                    locTitle: 'College\nLibrary',
                    locSubtitle: '20 min ago',
                    btnPrimaryText: 'Call',
                    btnPrimaryIcon: Icons.phone_rounded,
                    btnSecondaryText: 'Remind',
                    btnSecondaryIcon: Icons.notifications_active_rounded,
                  ),

                  const SizedBox(height: 48),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String number;
  final String label;

  const _StatBox({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final String name;
  final String relation;
  final String avatarStr;
  final Color avatarColor;
  final bool isSafe;
  
  final String medIcon;
  final String medTitle;
  final String? medSubtitle;
  
  final String locIcon;
  final String locTitle;
  final String locSubtitle;

  final String btnPrimaryText;
  final IconData btnPrimaryIcon;
  final String btnSecondaryText;
  final IconData btnSecondaryIcon;

  const _FamilyMemberCard({
    required this.name,
    required this.relation,
    required this.avatarStr,
    required this.avatarColor,
    required this.isSafe,
    required this.medIcon,
    required this.medTitle,
    this.medSubtitle,
    required this.locIcon,
    required this.locTitle,
    required this.locSubtitle,
    required this.btnPrimaryText,
    required this.btnPrimaryIcon,
    required this.btnSecondaryText,
    required this.btnSecondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(avatarStr, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relation,
                      style: const TextStyle(fontSize: 13, color: AppColors.textBody, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (isSafe)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_box_rounded, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text('Safe', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Info boxes
          Row(
            children: [
              // Meds box
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF7F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medIcon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(medTitle, style: const TextStyle(fontSize: 13, color: AppColors.textBody, fontWeight: FontWeight.w500)),
                            if (medSubtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(medSubtitle!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Loc box
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF7F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(locIcon, style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(locTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.3)),
                            const SizedBox(height: 6),
                            Text(locSubtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(btnPrimaryIcon, color: Colors.pinkAccent),
                      const SizedBox(width: 8),
                      Text(btnPrimaryText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(btnSecondaryIcon, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(btnSecondaryText, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool hasBadge;

  const _HeaderIcon({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (hasBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('2', style: TextStyle(fontSize: 6, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

