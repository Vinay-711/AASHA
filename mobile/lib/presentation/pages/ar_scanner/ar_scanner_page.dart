import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../di/injection.dart';
import '../../bloc/ar/ar_bloc.dart';
import '../../bloc/ar/ar_event.dart';
import '../../bloc/ar/ar_state.dart';
import '../../widgets/ar/ar_overlay_painter.dart';

class ARScannerPage extends StatefulWidget {
  const ARScannerPage({super.key});
  @override
  State<ARScannerPage> createState() => _ARScannerPageState();
}

class _ARScannerPageState extends State<ARScannerPage>
    with TickerProviderStateMixin {
  CameraController? _camCtrl;
  late AnimationController _pulseCtrl;
  bool _permGranted = false;
  bool _camReady = false;
  String? _camError;
  late ARScanBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ARScanBloc>();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() => _permGranted = status.isGranted);
    if (_permGranted) _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _camError = 'No camera detected on this device');
        return;
      }
      _camCtrl = CameraController(cameras.first, ResolutionPreset.high);
      await _camCtrl!.initialize();
      if (mounted) setState(() => _camReady = true);
    } catch (e) {
      setState(() => _camError = 'Camera initialization failed');
    }
  }

  Future<void> _capture() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    try {
      final xFile = await _camCtrl!.takePicture();
      _bloc.add(ScanRequested(File(xFile.path)));
    } catch (_) {}
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    _pulseCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permGranted) return _buildPermissionDenied();
    if (_camError != null) return _buildError(_camError!);
    if (!_camReady) return _buildLoading();

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('AR Scanner'),
          backgroundColor: Colors.black87,
          elevation: 0,
        ),
        body: BlocConsumer<ARScanBloc, ARState>(
          listener: (context, state) {
            if (state is ARError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: _capture,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Camera preview
                ClipRRect(
                  child: CameraPreview(_camCtrl!),
                ),

                // Pill overlay
                if (state is ARLoaded)
                  CustomPaint(
                    painter: AROverlayPainter(
                      pills: state.pills,
                      animation: _pulseCtrl,
                    ),
                    size: Size.infinite,
                  ),

                // Scanning overlay
                if (state is ARScanning)
                  Container(
                    color: Colors.black38,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text('Analyzing medicine...',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                // Results sheet
                if (state is ARLoaded && state.pills.isNotEmpty)
                  _buildResultsSheet(state.pills),

                // Capture button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: state is ARScanning ? null : _capture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              state is ARScanning ? Colors.grey : Colors.white,
                          border: Border.all(color: Colors.white54, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          state is ARLoaded
                              ? Icons.refresh_rounded
                              : Icons.camera_alt_rounded,
                          size: 32,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsSheet(List<DetectedPill> pills) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: pills.length + 1, // +1 for drag handle
            itemBuilder: (context, index) {
              if (index == 0) {
                return Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }
              final pill = pills[index - 1];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _statusColor(pill.status).withOpacity(0.15),
                    child: Icon(Icons.medication_rounded,
                        color: _statusColor(pill.status)),
                  ),
                  title: Text(pill.id,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      pill.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                          color: _statusColor(pill.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  trailing: _statusBadge(pill.status),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'take_now':
        return const Color(0xFF00C853);
      case 'wait':
        return Colors.orange;
      case 'warning':
        return Colors.red;
      case 'taken':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == 'take_now' ? 'TAKE NOW' : status.toUpperCase(),
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('AR Scanner')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Camera Permission Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Grant camera access to scan medicine strips',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Scanner')),
      body: Center(child: Text(msg, style: const TextStyle(fontSize: 16))),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text('AR Scanner'), backgroundColor: Colors.black87),
      body: const Center(
          child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
