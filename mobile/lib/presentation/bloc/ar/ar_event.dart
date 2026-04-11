import 'dart:io';

abstract class AREvent {}

class ScanRequested extends AREvent {
  final File image;
  ScanRequested(this.image);
}

class ClearScan extends AREvent {}
