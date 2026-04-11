import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../di/injection.dart';
import '../../../domain/entities/medication.dart';
import '../../bloc/medication/medication_bloc.dart';
import '../../bloc/medication/medication_event.dart';
import '../../bloc/medication/medication_state.dart';

class MedicationListPage extends StatelessWidget {
  const MedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicationBloc>()..add(LoadMedications()),
      child: const _MedicationListView(),
    );
  }
}

class _MedicationListView extends StatelessWidget {
  const _MedicationListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Medications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addMedication),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<MedicationBloc, MedicationState>(
        listener: (context, state) {
          if (state is AdherenceLogged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Adherence logged ✓'),
                backgroundColor: Color(0xFF00C853),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is MedicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MedicationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MedicationsLoaded) {
            if (state.medications.isEmpty) {
              return _buildEmpty();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.medications.length,
              itemBuilder: (context, index) {
                return _MedicationCard(
                  medication: state.medications[index],
                );
              },
            );
          }
          return _buildEmpty();
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medication_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No medications yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap + to add your first medication',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  const _MedicationCard({required this.medication});

  Color get _color {
    if (medication.colorCode != null && medication.colorCode!.isNotEmpty) {
      try {
        return Color(
            int.parse(medication.colorCode!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return const Color(0xFF7B1FA2);
  }

  String get _nextTime {
    if (medication.timing.isNotEmpty) {
      return medication.timing.first['time'] ?? '--:--';
    }
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/medications/${medication.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication_rounded, color: _color, size: 26),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage} · ${medication.frequency}',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Next: $_nextTime',
                      style: TextStyle(
                          color: _color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Quick Take button
              ElevatedButton(
                onPressed: () {
                  context.read<MedicationBloc>().add(LogAdherence(
                        medicationId: medication.id,
                        status: 'taken',
                        scheduledFor: DateTime.now().toIso8601String(),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text('Take',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
