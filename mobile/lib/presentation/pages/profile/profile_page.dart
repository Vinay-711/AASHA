import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Profile Avatar ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ramesh Kumar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '+91 98765 43210',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            // ── Profile Menu ──
            _ProfileSection(
              children: [
                _ProfileTile(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.categoryPink,
                  title: 'My Saved',
                  onTap: () => AppUi.showToast(context, 'Coming Soon'),
                ),
                _ProfileTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.categoryBlue,
                  title: 'Appointment',
                  onTap: () => AppUi.showToast(context, 'Coming Soon'),
                ),
                _ProfileTile(
                  icon: Icons.payment_rounded,
                  iconColor: AppColors.categoryOrange,
                  title: 'Payment Method',
                  onTap: () => AppUi.showToast(context, 'Coming Soon'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _ProfileSection(
              children: [
                _ProfileTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.categoryPurple,
                  title: 'FAQs',
                  onTap: () => AppUi.showToast(context, 'Coming Soon'),
                ),
                _ProfileTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.categoryBlue,
                  title: 'About Us',
                  onTap: () => AppUi.showToast(context, 'Coming Soon'),
                ),
                _ProfileTile(
                  icon: Icons.settings_rounded,
                  iconColor: AppColors.textSecondary,
                  title: 'Settings',
                  onTap: () => AppUi.showToast(context, 'Coming Soon'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _ProfileSection(
              children: [
                _ProfileTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  title: 'Logout',
                  showArrow: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Are you sure to log out of\nyour account?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        actions: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Log Out'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final List<Widget> children;

  const _ProfileSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) const Divider(height: 0, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: title == 'Logout' ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: showArrow
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.iconGrey)
          : null,
    );
  }
}
