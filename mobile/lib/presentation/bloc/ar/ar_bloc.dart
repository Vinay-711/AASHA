import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/remote/ar_remote_source.dart';
import '../../widgets/ar/ar_overlay_painter.dart';
import 'ar_event.dart';
import 'ar_state.dart';

class ARScanBloc extends Bloc<AREvent, ARState> {
  final ARRemoteSource remoteSource;

  ARScanBloc({required this.remoteSource}) : super(ARInitial()) {
    on<ScanRequested>((event, emit) async {
      emit(ARScanning());
      try {
        final result = await remoteSource.scanImage(event.image);
        final medicines = (result['medicines'] as List<dynamic>?) ?? [];
        final pills = medicines.map<DetectedPill>((m) {
          final overlay = m['ar_overlay'] ?? {};
          final pos = overlay['position'] ?? {};
          return DetectedPill(
            id: m['medicine_name'] ?? 'unknown',
            status: m['status'] ?? 'unknown',
            arOverlay: AROverlayInfo(
              position: ARPosition(
                x: (pos['x'] as num?)?.toDouble() ?? 0,
                y: (pos['y'] as num?)?.toDouble() ?? 0,
                width: (pos['width'] as num?)?.toDouble() ?? 50,
                height: (pos['height'] as num?)?.toDouble() ?? 50,
              ),
              animation: overlay['animation'] ?? 'static',
            ),
          );
        }).toList();
        emit(ARLoaded(pills));
      } catch (e) {
        emit(ARError('Scan failed — try again'));
      }
    });

    on<ClearScan>((event, emit) => emit(ARInitial()));
  }
}
