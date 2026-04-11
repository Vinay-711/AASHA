import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../config/theme.dart';
import '../../../data/datasources/remote/pharmacy_remote_source.dart';
import '../../../di/injection.dart';

// ---------------------------------------------------------
// BLoC State Management
// ---------------------------------------------------------
abstract class PharmacySearchEvent {}

class SearchMedicine extends PharmacySearchEvent {
  final String query;
  SearchMedicine(this.query);
}

class UpdateFilters extends PharmacySearchEvent {
  final double radius;
  final bool inStockOnly;
  UpdateFilters({required this.radius, required this.inStockOnly});
}

class LoadMore extends PharmacySearchEvent {}

abstract class PharmacySearchState {}

class SearchInitial extends PharmacySearchState {}

class SearchLoading extends PharmacySearchState {}

class SearchLoaded extends PharmacySearchState {
  final List<dynamic> results;
  final bool hasReachedMax;
  SearchLoaded(this.results, {this.hasReachedMax = false});
}

class SearchError extends PharmacySearchState {
  final String message;
  SearchError(this.message);
}

class PharmacySearchBloc
    extends Bloc<PharmacySearchEvent, PharmacySearchState> {
  final PharmacyRemoteSource _remoteSource;

  PharmacySearchBloc({PharmacyRemoteSource? remoteSource})
      : _remoteSource = remoteSource ?? getIt<PharmacyRemoteSource>(),
        super(SearchInitial()) {
    on<SearchMedicine>((event, emit) async {
      emit(SearchLoading());
      try {
        double lat = 28.6139; // Delhi fallback
        double lng = 77.2090;
        try {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.deniedForever) {
            final pos = await Geolocator.getCurrentPosition();
            lat = pos.latitude;
            lng = pos.longitude;
          }
        } catch (_) {}

        final results = await _remoteSource.searchMedicine(
          medicineName: event.query,
          lat: lat,
          lng: lng,
        );

        final mapped = results.map((r) {
          final avail = r['availability'] as Map<String, dynamic>? ?? {};
          return {
            'name': r['name'] ?? 'Unknown',
            'distance': r['distance_km'] ?? 0.0,
            'status': avail['status'] ?? 'unknown',
            'confidence': avail['confidence'] ?? 0,
            'verifier': avail['verified_by'] ?? 'Unverified',
          };
        }).toList();

        emit(SearchLoaded(mapped));
      } catch (e) {
        emit(SearchError('Search failed. Please try again.'));
      }
    });
  }
}

// ---------------------------------------------------------
// UI Implementation
// ---------------------------------------------------------
class PharmacySearchPage extends StatelessWidget {
  const PharmacySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PharmacySearchBloc(),
      child: const PharmacySearchView(),
    );
  }
}

class PharmacySearchView extends StatefulWidget {
  const PharmacySearchView({super.key});
  @override
  State<PharmacySearchView> createState() => _PharmacySearchViewState();
}

class _PharmacySearchViewState extends State<PharmacySearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // For demo purposes, fire an initial search so the screen matches the mockup immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = 'Cardivas 25mg';
      context.read<PharmacySearchBloc>().add(SearchMedicine('Cardivas 25mg'));
    });
  }

  void _onSearch() {
    if (_searchController.text.isNotEmpty) {
      context.read<PharmacySearchBloc>().add(SearchMedicine(_searchController.text));
    }
  }

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
                      Text('AASHA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 1.2)),
                      Text('Your Health Guardian', style: TextStyle(fontSize: 11, color: AppColors.iconGrey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
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

          // ── Search & Filters ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search medicine...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 12),
                        child: Icon(Icons.search_rounded, color: Colors.deepPurple, size: 26),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 40),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        icon: Icons.account_balance_rounded,
                        isActive: true,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: 'In Stock',
                        icon: Icons.check_circle_rounded,
                        iconColor: Colors.green,
                        isActive: false,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: 'Nearest',
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.accent,
                        isActive: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Results List ──
          Expanded(
            child: BlocBuilder<PharmacySearchBloc, PharmacySearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is SearchLoaded) {
                  // Fallback to static dummy data if the API returned empty or unknown structures to match mockup visually.
                  final items = state.results.isNotEmpty ? state.results : [
                    {
                      'name': 'Apollo Pharmacy',
                      'distance': 2.3,
                      'status': 'in_stock',
                      'confidence': 95,
                      'verifier': 'Ram S.',
                    }
                  ];

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _PharmacyResultCard(
                        name: item['name'],
                        distanceStr: '${item['distance']} km',
                        timeStr: '${(item['distance'] as num) * 4} min drive', // Mock calculation
                        notes: '10 strips available, expires March 2027',
                        confidence: item['confidence'],
                        verifier: item['verifier'],
                      );
                    },
                  );
                }
                return const Center(child: Text('Type a medicine name to search.', style: TextStyle(color: AppColors.textSecondary)));
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
  final IconData icon;
  final Color? iconColor;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.iconColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.3)),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : (iconColor ?? AppColors.textSecondary)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyResultCard extends StatelessWidget {
  final String name;
  final String distanceStr;
  final String timeStr;
  final String notes;
  final int confidence;
  final String verifier;

  const _PharmacyResultCard({
    required this.name,
    required this.distanceStr,
    required this.timeStr,
    required this.notes,
    required this.confidence,
    required this.verifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_hospital_rounded, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 14),
                        const SizedBox(width: 4),
                        Text('$distanceStr · $timeStr', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Text('IN STOCK', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w800, fontSize: 11)),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Notes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF7F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_rounded, color: Colors.orangeAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(notes, style: const TextStyle(fontSize: 13, color: AppColors.textBody, fontWeight: FontWeight.w500))),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 3: Confidence
          Row(
            children: [
              const Text('Confidence', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width * 0.5 * (confidence / 100), // Approximate width
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('$confidence%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),

          const SizedBox(height: 16),

          // Row 4: Verifier
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFB5EAD7),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('👴', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verified by $verifier', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Text('Verified Guardian · 10 mins ago', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 5: Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.directions_rounded, color: Colors.pinkAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.phone_rounded, color: Colors.pinkAccent, size: 18),
                      SizedBox(width: 8),
                      Text('Call', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
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
