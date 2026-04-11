import time
import logging
import numpy as np
from typing import List, Optional, Dict, Any
from uuid import UUID, uuid4

# In a standard pipeline, uncomment this to enable raw image buffer manipulation natively
import cv2 

from app.schemas.ar import ARScanResponse, DetectedMedicine, AROverlay
from app.services.pill_inference import PillInference, Detection

logger = logging.getLogger("aasha.ar_service")

# ---------------------------------------------------------
# Internal Typing Stubs (ML Pipeline Geometries)
# ---------------------------------------------------------
class BoundingBox:
    def __init__(self, x: int, y: int, w: int, h: int, confidence: float, class_name: str = ""):
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.confidence = confidence
        self.class_name = class_name

class PillSegment:
    def __init__(self, pill_img: np.ndarray, bbox: BoundingBox):
        self.pill_img = pill_img
        self.bbox = bbox

class PillFeatures:
    def __init__(self, color: str, shape: str, imprint: Optional[str] = None):
        self.color = color
        self.shape = shape
        self.imprint = imprint

class MedicineMatch:
    def __init__(self, medicine_id: str, name: str, generic_name: str, confidence: float, dosage: str):
        self.medicine_id = medicine_id
        self.name = name
        self.generic_name = generic_name
        self.confidence = confidence
        self.dosage = dosage

class DosageStatus:
    def __init__(self, status: str, schedule: dict, warnings: List[str] = None, interactions: List[str] = None):
        self.status = status # Enum limits natively: "take_now", "wait", "taken", "not_today", "warning"
        self.schedule = schedule
        self.warnings = warnings or []
        self.interactions = interactions or []

# ---------------------------------------------------------
# Medicine Database (mock mapping for detected COCO/custom classes → medicine info)
# In production, this would be a real database lookup
# ---------------------------------------------------------
MEDICINE_CLASS_MAP = {
    # COCO class mappings (for demo with pretrained model)
    "bottle": {"name": "Cough Syrup", "generic": "Dextromethorphan", "dosage": "10ml", "id": "med_syrup_001"},
    "cup": {"name": "Oral Rehydration", "generic": "ORS Powder", "dosage": "1 sachet", "id": "med_ors_001"},
    "cell phone": {"name": "Health Monitor", "generic": "Digital Tracker", "dosage": "N/A", "id": "med_monitor_001"},
    
    # Custom pill model mappings (when custom model is trained)
    "pill_strip": {"name": "Cardivas 25mg", "generic": "Carvedilol", "dosage": "25mg", "id": "med_cardivas_025"},
    "individual_pill": {"name": "Paracetamol 500mg", "generic": "Acetaminophen", "dosage": "500mg", "id": "med_pcm_500"},
    
    # Fallback for any detected object
    "_default": {"name": "Unknown Medicine", "generic": "Unidentified", "dosage": "Consult Doctor", "id": "med_unknown"},
}

# ---------------------------------------------------------
# AR Service Core Framework
# ---------------------------------------------------------
class ARService:
    def __init__(self):
        """Bootstraps the ML pipeline engines with real YOLOv8 model."""
        logger.info("Initializing ARService with YOLOv8 detection engine...")
        
        # Initialize real YOLOv8 pill detector
        self.pill_inference = PillInference()
        
        self.medicine_db = self._load_medicine_database()
        
        if self.pill_inference.yolo_detector:
            logger.info("ARService ready with LIVE YOLOv8 detection engine")
        else:
            logger.warning("ARService running in MOCK mode (no YOLOv8 model)")

    def _load_medicine_database(self):
        """Load medicine lookup database."""
        return MEDICINE_CLASS_MAP

    async def process_scan(
        self, 
        image_bytes: bytes, 
        user_id: UUID, 
        location: Optional[dict]
    ) -> ARScanResponse:
        """
        Process incoming medicine strip image through YOLOv8 detection pipeline.
        Returns AR overlay data with detected objects and dosage recommendations.
        """
        start_time = time.perf_counter()
        logger.info(f"Processing AR scan for user ID: {user_id}")
        
        try:
            # 1. Decode image from bytes
            image = self._preprocess_image(image_bytes)
            
            # 2. Run YOLOv8 detection (REAL inference)
            detections = self.pill_inference.detect(image, conf_threshold=0.30)
            
            detected_medicines: List[DetectedMedicine] = []
            unrecognized_pills = 0
            
            for det in detections:
                if det.confidence < 0.40:
                    unrecognized_pills += 1
                    continue
                
                # 3. Map detected class to medicine info
                match = self._map_detection_to_medicine(det)
                
                # 4. Calculate dosage status
                dosage_status = self._calculate_dosage_status(match.medicine_id, user_id)
                
                # 5. Generate AR overlay coordinates
                overlay = self._generate_ar_overlay_from_detection(det, dosage_status)
                
                detected_medicines.append(
                    DetectedMedicine(
                        id=match.medicine_id,
                        name=match.name,
                        generic_name=match.generic_name,
                        confidence=det.confidence,
                        status=dosage_status.status,
                        dosage=match.dosage,
                        schedule=dosage_status.schedule,
                        ar_overlay=overlay,
                        warnings=dosage_status.warnings,
                        interactions=dosage_status.interactions
                    )
                )

            processing_time_ms = int((time.perf_counter() - start_time) * 1000)
            
            return ARScanResponse(
                scan_id=uuid4(),
                processing_time_ms=processing_time_ms,
                medicines=detected_medicines,
                unrecognized_pills=unrecognized_pills,
                confidence_threshold_met=(unrecognized_pills == 0),
                suggestions=["Try scanning in brighter lighting for better results."] if unrecognized_pills > 0 else None
            )

        except Exception as e:
            logger.error(f"AR scanning pipeline failed: {str(e)}", exc_info=True)
            raise e

    async def process_scan_url(self, image_url: str, user_id: UUID) -> ARScanResponse:
        """
        Process an image from URL through YOLOv8 detection.
        Useful for testing with remote images.
        """
        start_time = time.perf_counter()
        logger.info(f"Processing AR scan from URL for user: {user_id}")
        
        detections = self.pill_inference.detect_from_url(image_url, conf_threshold=0.30)
        
        detected_medicines: List[DetectedMedicine] = []
        unrecognized_pills = 0
        
        for det in detections:
            if det.confidence < 0.40:
                unrecognized_pills += 1
                continue
            
            match = self._map_detection_to_medicine(det)
            dosage_status = self._calculate_dosage_status(match.medicine_id, user_id)
            overlay = self._generate_ar_overlay_from_detection(det, dosage_status)
            
            detected_medicines.append(
                DetectedMedicine(
                    id=match.medicine_id,
                    name=match.name,
                    generic_name=match.generic_name,
                    confidence=det.confidence,
                    status=dosage_status.status,
                    dosage=match.dosage,
                    schedule=dosage_status.schedule,
                    ar_overlay=overlay,
                    warnings=dosage_status.warnings,
                    interactions=dosage_status.interactions
                )
            )
        
        processing_time_ms = int((time.perf_counter() - start_time) * 1000)
        
        return ARScanResponse(
            scan_id=uuid4(),
            processing_time_ms=processing_time_ms,
            medicines=detected_medicines,
            unrecognized_pills=unrecognized_pills,
            confidence_threshold_met=(unrecognized_pills == 0),
            suggestions=None
        )

    # ---------------------------------------------------------
    # Pipeline Helpers
    # ---------------------------------------------------------
    def _preprocess_image(self, image_bytes: bytes) -> np.ndarray:
        """Decode raw bytes into a BGR numpy array using OpenCV."""
        np_arr = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        
        if image is None:
            logger.error("Failed to decode image bytes")
            raise ValueError("Invalid image data — could not decode")
        
        # Resize to standard inference size if too large
        h, w = image.shape[:2]
        if max(h, w) > 1280:
            scale = 1280 / max(h, w)
            image = cv2.resize(image, (int(w * scale), int(h * scale)))
        
        logger.info(f"Image preprocessed: {image.shape[1]}x{image.shape[0]}")
        return image

    def _map_detection_to_medicine(self, detection: Detection) -> MedicineMatch:
        """Map a YOLOv8 detection class to a medicine entry."""
        class_name = detection.class_name.lower()
        
        # Look up in medicine database
        med_info = self.medicine_db.get(class_name, self.medicine_db["_default"])
        
        return MedicineMatch(
            medicine_id=med_info["id"],
            name=med_info["name"],
            generic_name=med_info["generic"],
            confidence=detection.confidence,
            dosage=med_info["dosage"]
        )

    def _calculate_dosage_status(self, medicine_id: str, user_id: UUID) -> DosageStatus:
        """Calculate dosage status based on user's medication schedule."""
        # In production, this queries the user's medication log
        return DosageStatus(
            status="take_now",
            schedule={"today_taken": 0, "today_total": 2, "next_dose": "2026-04-10T20:00:00Z"},
            warnings=["Take with warm water."],
            interactions=[]
        )

    def _generate_ar_overlay_from_detection(self, detection: Detection, status: DosageStatus) -> AROverlay:
        """Generate AR overlay data directly from YOLOv8 bounding box coordinates."""
        color_map = {
            "take_now": "#00C853",  # Safe Green
            "wait": "#FFB300",      # Safety Amber
            "warning": "#D50000",   # Alert Red
            "taken": "#1565C0",     # Disabled Blue
            "not_today": "#FFFFFF", # White
        }
        
        x, y, w, h = detection.bbox
        
        return AROverlay(
            color=color_map.get(status.status, "#FFFFFF"),
            position={"x": x, "y": y, "z": 0},
            size={"width": w, "height": h},
            animation="pulse" if status.status == "take_now" else "static"
        )
