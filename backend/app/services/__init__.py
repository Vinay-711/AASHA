"""Load service exports on demand so pharmacy work does not require ML models."""
from importlib import import_module

_EXPORTS = {
    "ARService": ("ar_service", "ARService"),
    "PillInference": ("pill_inference", "PillInference"),
    "YOLOv8Detector": ("pill_inference", "YOLOv8Detector"),
    "PharmacyService": ("pharmacy_service", "PharmacyService"),
    "check_health_status": ("health_service", "check_health_status"),
    "trigger_safety_protocol": ("safety_service", "trigger_safety_protocol"),
    "send_notification": ("notification_service", "send_notification"),
}
__all__ = list(_EXPORTS)


def __getattr__(name):
    if name not in _EXPORTS:
        raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
    module, attribute = _EXPORTS[name]
    value = getattr(import_module(f"{__name__}.{module}"), attribute)
    globals()[name] = value
    return value
