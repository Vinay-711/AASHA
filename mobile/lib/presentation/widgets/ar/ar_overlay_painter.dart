import 'package:flutter/material.dart';

// ---------------------------------------------------------
// ML Data Hooks (Mapped resolving backend AR Scan Arrays!)
// ---------------------------------------------------------
class ARPosition {
  final double x;
  final double y;
  final double width;
  final double height;
  ARPosition({required this.x, required this.y, required this.width, required this.height});
}

class AROverlayInfo {
  final ARPosition position;
  final String animation;
  AROverlayInfo({required this.position, required this.animation});
}

class DetectedPill {
  final String id;
  final String status;
  final AROverlayInfo arOverlay;
  
  DetectedPill({required this.id, required this.status, required this.arOverlay});
}

// ---------------------------------------------------------
// Native AR Painter Canvas Logic
// ---------------------------------------------------------
class AROverlayPainter extends CustomPainter {
  final List<DetectedPill> pills;
  final Animation<double> animation;
  final Size originalImageSize; // Tracks native CV input ratios explicitly (e.g. 640x640)
  
  AROverlayPainter({
    required this.pills, 
    required this.animation,
    this.originalImageSize = const Size(640, 640)
  }) : super(repaint: animation); // Recursively routes triggers intrinsically on animated loops
  
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate global scaling bounds tracking device constraints properly underneath the explicit original constraints bounds natively!
    final double scaleX = size.width / originalImageSize.width;
    final double scaleY = size.height / originalImageSize.height;

    for (var pill in pills) {
      final Color baseColor = _getStatusColor(pill.status);
      final ARPosition pos = pill.arOverlay.position;
      
      // Spatial coordinates securely mathematically remapping internal Keras loops into Flutter matrices safely!
      final double scaledX = pos.x * scaleX;
      final double scaledY = pos.y * scaleY;
      final double scaledWidth = pos.width * scaleX;
      final double scaledHeight = pos.height * scaleY;
      
      final Rect rect = Rect.fromLTWH(scaledX, scaledY, scaledWidth, scaledHeight);
      
      final bool isPulse = pill.status == 'take_now' || pill.arOverlay.animation == 'pulse';
      
      // Calculate dynamic matrix scaling safely underneath constraints bounding limits correctly natively
      final double opacity = isPulse ? (0.7 + 0.3 * animation.value) : 0.85;
      final double glowSpread = isPulse ? (8.0 * animation.value) : 1.0;
      
      // 1. Render Heavy Halo Effect correctly mapping blur arrays natively inside bounds natively
      final Paint shadowPaint = Paint()
        ..color = baseColor.withOpacity(opacity * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSpread + 3.0)
        ..style = PaintingStyle.fill;
        
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), 
        shadowPaint
      );
      
      // 2. Render Deep Outer Stroke Limits mapping parameters properly resolving limits tracking limits
      final Paint borderPaint = Paint()
        ..color = baseColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
        
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), 
        borderPaint
      );
      
      // 3. Render Center Background shading properly filling explicitly implicitly tracking
      final Paint fillPaint = Paint()
        ..color = baseColor.withOpacity(opacity * 0.15)
        ..style = PaintingStyle.fill;
        
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), 
        fillPaint
      );
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'take_now': return Colors.greenAccent;
      case 'wait': return Colors.orangeAccent;
      case 'warning': return Colors.redAccent;
      case 'taken': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
  
  @override
  bool shouldRepaint(covariant AROverlayPainter oldDelegate) {
    // Triggers repainting routines explicitly updating bounds intrinsically dynamically mapping parameter mutations cleanly!
    return oldDelegate.pills != pills || oldDelegate.animation != animation;
  }
}
