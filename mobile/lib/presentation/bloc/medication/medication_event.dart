abstract class MedicationEvent {}

class LoadMedications extends MedicationEvent {}

class AddMedication extends MedicationEvent {
  final Map<String, dynamic> data;
  AddMedication(this.data);
}

class LogAdherence extends MedicationEvent {
  final String medicationId;
  final String status;
  final String scheduledFor;
  LogAdherence(
      {required this.medicationId,
      required this.status,
      required this.scheduledFor});
}
