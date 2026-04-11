import uuid
import logging
from typing import Optional

from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse

from app.services.ar_service import ARService
from app.services.pill_inference import PillInference

router = APIRouter()
logger = logging.getLogger("aasha.api.ar")

# ---------------------------------------------------------
# Service Singletons (initialized once on first request)
# ---------------------------------------------------------
_ar_service: Optional[ARService] = None
_pill_inference: Optional[PillInference] = None


def get_ar_service() -> ARService:
    """Lazy-load the AR service with YOLOv8 model."""
    global _ar_service
    if _ar_service is None:
        logger.info("Initializing ARService singleton with YOLOv8...")
        _ar_service = ARService()
    return _ar_service


def get_pill_inference() -> PillInference:
    """Lazy-load the pill inference engine."""
    global _pill_inference
    if _pill_inference is None:
        logger.info("Initializing PillInference singleton with YOLOv8...")
        _pill_inference = PillInference()
    return _pill_inference


# Placeholder for JWT Authentication dependency
def get_current_user():
    # TODO: Implement actual JWT validation
    return {"user_id": str(uuid.uuid4()), "username": "demo_user"}


# ---------------------------------------------------------
# AR Scan Endpoints
# ---------------------------------------------------------
@router.post("/scan")
async def process_ar_scan(
    image: UploadFile = File(...),
    current_user: dict = Depends(get_current_user)
):
    """
    Process an uploaded image for AR pill/object detection using YOLOv8.
    
    - Accepts: multipart/form-data with an image file
    - Returns: Detected objects with AR overlay coordinates, confidence scores, and dosage info
    """
    try:
        # Read the uploaded image bytes
        image_bytes = await image.read()
        
        if not image_bytes:
            raise HTTPException(status_code=400, detail="Empty image file uploaded")
        
        # Get AR service and process scan
        ar_service = get_ar_service()
        user_id = uuid.UUID(current_user["user_id"])
        
        result = await ar_service.process_scan(
            image_bytes=image_bytes,
            user_id=user_id,
            location=None
        )
        
        return result
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"AR scan failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"AR scan processing error: {str(e)}")


@router.post("/scan/url")
async def process_ar_scan_url(
    image_url: str = Form(...),
    current_user: dict = Depends(get_current_user)
):
    """
    Process an image from URL for AR detection using YOLOv8.
    
    Useful for testing with remote images, e.g.:
    - http://images.cocodataset.org/val2017/000000039769.jpg
    """
    try:
        ar_service = get_ar_service()
        user_id = uuid.UUID(current_user["user_id"])
        
        result = await ar_service.process_scan_url(
            image_url=image_url,
            user_id=user_id
        )
        
        return result
        
    except Exception as e:
        logger.error(f"AR URL scan failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"AR URL scan error: {str(e)}")


@router.post("/detect")
async def detect_objects(
    image: UploadFile = File(...),
    confidence: float = 0.25
):
    """
    Raw YOLOv8 object detection endpoint (no AR overlay mapping).
    Returns raw bounding boxes, class names, and confidence scores.
    
    Useful for debugging and testing the ML model directly.
    """
    try:
        image_bytes = await image.read()
        
        if not image_bytes:
            raise HTTPException(status_code=400, detail="Empty image file")
        
        import numpy as np
        import cv2
        
        # Decode image
        np_arr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image format")
        
        # Run YOLOv8 detection
        pill_inference = get_pill_inference()
        detections = pill_inference.detect(img, conf_threshold=confidence)
        
        return {
            "total_detections": len(detections),
            "image_size": {"width": img.shape[1], "height": img.shape[0]},
            "detections": [
                {
                    "class_name": d.class_name,
                    "class_id": d.class_id,
                    "confidence": round(d.confidence, 4),
                    "bbox": {
                        "x": d.bbox[0],
                        "y": d.bbox[1],
                        "width": d.bbox[2],
                        "height": d.bbox[3]
                    }
                }
                for d in detections
            ]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Detection failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Detection error: {str(e)}")


@router.get("/model/info")
async def get_model_info():
    """
    Returns information about the currently loaded YOLOv8 model.
    """
    pill_inference = get_pill_inference()
    
    if pill_inference.yolo_detector:
        model = pill_inference.yolo_detector.model
        return {
            "status": "loaded",
            "model_type": "YOLOv8",
            "model_name": str(model.model_name) if hasattr(model, 'model_name') else "yolov8n.pt",
            "num_classes": len(model.names),
            "class_names": model.names,
            "device": str(model.device) if hasattr(model, 'device') else "cpu"
        }
    else:
        return {
            "status": "mock_mode",
            "model_type": "None",
            "message": "No YOLOv8 model loaded. Install ultralytics: pip install ultralytics"
        }
