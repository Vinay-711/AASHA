import '../../../domain/entities/medication.dart';

abstract class MedicationState {}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationsLoaded extends MedicationState {
  final List<Medication> medications;
  MedicationsLoaded(this.medications);
}

class MedicationAdded extends MedicationState {}

class AdherenceLogged extends MedicationState {}

class MedicationError extends MedicationState {
  final String message;
  MedicationError(this.message);
}
