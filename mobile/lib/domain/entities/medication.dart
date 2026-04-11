class Medication {
  final String id;
  final String name;
  final String? genericName;
  final String dosage;
  final String frequency;
  final List<Map<String, dynamic>> timing;
  final String startDate;
  final String? endDate;
  final String? instructions;
  final String? colorCode;
  final String? shape;
  final String? createdAt;

  Medication({
    required this.id,
    required this.name,
    this.genericName,
    required this.dosage,
    required this.frequency,
    required this.timing,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.colorCode,
    this.shape,
    this.createdAt,
  });
}

class MedicationLog {
  final String id;
  final String medicationId;
  final String status;
  final String takenAt;
  final String scheduledFor;
  final String? notes;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.status,
    required this.takenAt,
    required this.scheduledFor,
    this.notes,
  });
}
