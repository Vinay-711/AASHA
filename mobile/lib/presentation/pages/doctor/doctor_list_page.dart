import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  static const _doctors = [
    _DoctorData('Dr. Priya Sharma', 'Cardiologiest', 'AIIMS Delhi', 4.8, 460),
    _DoctorData('Dr. Rahul Verma', 'Orthopedics', 'Fortis Hospital', 4.7, 312),
    _DoctorData('Dr. Anjali Gupta', 'Pediatrics', 'Apollo Hospital', 4.9, 589),
    _DoctorData('Dr. Arjun Singh', 'Neurologist', 'Max Healthcare', 4.6, 245),
    _DoctorData('Dr. Meera Reddy', 'Dermatologist', 'Medanta Hospital', 4.8, 382),
    _DoctorData('Dr. Vikram Patel', 'General', 'City Clinic', 4.5, 198),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Top Doctors'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: AppColors.iconGrey, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search doctor...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter Chips ──
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'General'),
                _FilterChip(label: 'Cardiologist'),
                _FilterChip(label: 'Orthopedics'),
                _FilterChip(label: 'Neurologist'),
                _FilterChip(label: 'Pediatrics'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Doctor List ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: _doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = _doctors[index];
                return _DoctorTile(data: doc);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => AppUi.showToast(context, 'Filter applied'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final _DoctorData data;

  const _DoctorTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.doctorDetail),
      child: Container(
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.specialty,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 3),
                    Text(
                      '${data.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${data.reviews} Reviews)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _DoctorData {
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviews;

  const _DoctorData(this.name, this.specialty, this.hospital, this.rating, this.reviews);
}
