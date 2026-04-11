import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
  MedicationModel({
    required String id,
    required String name,
    String? genericName,
    required String dosage,
    required String frequency,
    required List<Map<String, dynamic>> timing,
    required String startDate,
    String? endDate,
    String? instructions,
    String? colorCode,
    String? shape,
    String? createdAt,
  }) : super(
          id: id,
          name: name,
          genericName: genericName,
          dosage: dosage,
          frequency: frequency,
          timing: timing,
          startDate: startDate,
          endDate: endDate,
          instructions: instructions,
          colorCode: colorCode,
          shape: shape,
          createdAt: createdAt,
        );

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['generic_name'],
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      timing: (json['timing'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      instructions: json['instructions'],
      colorCode: json['color_code'],
      shape: json['shape'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'generic_name': genericName,
        'dosage': dosage,
        'frequency': frequency,
        'timing': timing,
        'start_date': startDate,
        'end_date': endDate,
        'instructions': instructions,
        'color_code': colorCode,
        'shape': shape,
      };
}

class MedicationLogModel extends MedicationLog {
  MedicationLogModel({
    required String id,
    required String medicationId,
    required String status,
    required String takenAt,
    required String scheduledFor,
    String? notes,
  }) : super(
          id: id,
          medicationId: medicationId,
          status: status,
          takenAt: takenAt,
          scheduledFor: scheduledFor,
          notes: notes,
        );

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    return MedicationLogModel(
      id: json['id'] ?? '',
      medicationId: json['medication_id'] ?? '',
      status: json['status'] ?? '',
      takenAt: json['taken_at'] ?? '',
      scheduledFor: json['scheduled_for'] ?? '',
      notes: json['notes'],
    );
  }
}
