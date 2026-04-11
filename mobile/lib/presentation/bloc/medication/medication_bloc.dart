import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/medication_remote_source.dart';
import '../../../data/models/medication_model.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final MedicationRemoteSource remoteSource;

  MedicationBloc({required this.remoteSource}) : super(MedicationInitial()) {
    on<LoadMedications>((event, emit) async {
      emit(MedicationLoading());
      try {
        final results = await remoteSource.getMedications();
        final meds =
            results.map((r) => MedicationModel.fromJson(r)).toList();
        emit(MedicationsLoaded(meds));
      } catch (e) {
        emit(MedicationError('Failed to load medications'));
      }
    });

    on<AddMedication>((event, emit) async {
      emit(MedicationLoading());
      try {
        await remoteSource.addMedication(event.data);
        emit(MedicationAdded());
        // Reload the list
        add(LoadMedications());
      } catch (e) {
        emit(MedicationError('Failed to add medication'));
      }
    });

    on<LogAdherence>((event, emit) async {
      try {
        await remoteSource.logAdherence(
          event.medicationId,
          event.status,
          event.scheduledFor,
        );
        emit(AdherenceLogged());
        // Reload to update UI
        add(LoadMedications());
      } catch (e) {
        emit(MedicationError('Failed to log adherence'));
      }
    });
  }
}
