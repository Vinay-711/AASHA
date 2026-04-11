import 'package:flutter/material.dart';
import '../../../data/datasources/remote/medication_remote_source.dart';
import '../../../data/models/medication_model.dart';
import '../../../di/injection.dart';
import '../../../domain/entities/medication.dart';

class MedicationDetailPage extends StatefulWidget {
  final String medicationId;
  const MedicationDetailPage({super.key, required this.medicationId});

  @override
  State<MedicationDetailPage> createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  Medication? _medication;
  List<MedicationLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final source = getIt<MedicationRemoteSource>();
    try {
      // Load medication details
      final meds = await source.getMedications();
      final match = meds.firstWhere(
        (m) => m['id'] == widget.medicationId,
        orElse: () => <String, dynamic>{},
      );
      if (match.isNotEmpty) {
        _medication = MedicationModel.fromJson(match);
      }

      // Load logs
      final logData = await source.getMedicationLogs(widget.medicationId);
      _logs = logData.map((l) => MedicationLogModel.fromJson(l)).toList();
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logAction(String status) async {
    final source = getIt<MedicationRemoteSource>();
    try {
      await source.logAdherence(
        widget.medicationId,
        status,
        DateTime.now().toIso8601String(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${status[0].toUpperCase()}${status.substring(1)} logged ✓'),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadData(); // Refresh logs
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to log adherence'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color get _medColor {
    if (_medication?.colorCode != null && _medication!.colorCode!.isNotEmpty) {
      try {
        return Color(
            int.parse(_medication!.colorCode!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return const Color(0xFF7B1FA2);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medication')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_medication == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medication')),
        body: const Center(child: Text('Medication not found')),
      );
    }

    final med = _medication!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _medColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.medication_rounded,
                              color: _medColor, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(med.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              if (med.genericName != null)
                                Text(med.genericName!,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    _infoRow(Icons.science_rounded, 'Dosage', med.dosage),
                    _infoRow(Icons.repeat_rounded, 'Frequency', med.frequency),
                    _infoRow(Icons.calendar_today_rounded, 'Since',
                        med.startDate),
                    if (med.endDate != null)
                      _infoRow(
                          Icons.event_rounded, 'Until', med.endDate!),
                    if (med.shape != null)
                      _infoRow(Icons.circle_outlined, 'Shape', med.shape!),
                    if (med.instructions != null) ...[
                      const SizedBox(height: 12),
                      Text('Instructions',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(med.instructions!,
                          style: const TextStyle(fontSize: 14)),
                    ],
                    const SizedBox(height: 16),
                    const Text('Schedule',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: med.timing.map((t) {
                        return Chip(
                          avatar: Icon(Icons.access_time_rounded,
                              size: 18, color: _medColor),
                          label: Text(
                            '${t['time']}${t['with_food'] == true ? ' (with food)' : ''}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          backgroundColor: _medColor.withOpacity(0.08),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            const Text('Log Adherence',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionButton('Taken', const Color(0xFF00C853),
                      Icons.check_circle_rounded, () => _logAction('taken')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton('Missed', Colors.red,
                      Icons.cancel_rounded, () => _logAction('missed')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton('Skipped', Colors.grey,
                      Icons.skip_next_rounded, () => _logAction('skipped')),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Log history
            Text('Recent History (${_logs.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),

            if (_logs.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                      child: Text('No adherence logs yet',
                          style: TextStyle(color: Colors.grey))),
                ),
              )
            else
              ..._logs.reversed.take(20).map((log) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _logColor(log.status).withOpacity(0.15),
                        child: Icon(_logIcon(log.status),
                            color: _logColor(log.status), size: 20),
                      ),
                      title: Text(
                        log.status[0].toUpperCase() + log.status.substring(1),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _logColor(log.status)),
                      ),
                      subtitle: Text(log.takenAt,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          Text('$label: ',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      String label, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _logColor(String status) {
    switch (status) {
      case 'taken':
        return const Color(0xFF00C853);
      case 'missed':
        return Colors.red;
      case 'skipped':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _logIcon(String status) {
    switch (status) {
      case 'taken':
        return Icons.check_circle_rounded;
      case 'missed':
        return Icons.cancel_rounded;
      case 'skipped':
        return Icons.skip_next_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
