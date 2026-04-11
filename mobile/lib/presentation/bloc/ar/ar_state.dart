import '../../widgets/ar/ar_overlay_painter.dart';

abstract class ARState {}

class ARInitial extends ARState {}

class ARScanning extends ARState {}

class ARLoaded extends ARState {
  final List<DetectedPill> pills;
  ARLoaded(this.pills);
}

class ARError extends ARState {
  final String message;
  ARError(this.message);
}
