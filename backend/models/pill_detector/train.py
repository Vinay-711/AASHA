import os
import yaml
from pathlib import Path
from ultralytics import YOLO

# ---------------------------------------------------------
# Training Pipeline: AASHA Pill Detection Models
# ---------------------------------------------------------

def setup_data_yaml(data_dir: str, class_names: list) -> str:
    """
    Scaffolds dynamic data.yaml mapping structurally bridging dataset 
    folders effectively mapping COCO equivalents natively into Ultralytics targets.
    """
    yaml_path = os.path.join(data_dir, "data.yaml")
    
    config = {
        "path": os.path.abspath(data_dir),
        # Default YOLO structure bindings mapped dynamically internally
        "train": "images/train",
        "val": "images/val", 
        "test": "images/test", 
        "nc": len(class_names),
        "names": class_names
    }
    
    with open(yaml_path, "w") as f:
        yaml.dump(config, f)
        
    return yaml_path

def main():
    root_dir = Path(__file__).parent
    
    # Assumes dataset explicitly positioned securely 
    # data/pill_images/ natively formatted matching labels mappings correctly prior to runtime
    data_dir = os.path.abspath(os.path.join(root_dir, "../../../data/pill_images"))
    output_dir = os.path.join(root_dir, "runs")
    
    os.makedirs(data_dir, exist_ok=True)
    
    # 1. Construct Schema Configuration explicitly
    class_names = ["pill_strip", "individual_pill"]
    data_yaml_path = setup_data_yaml(data_dir, class_names)
    
    print("--> Bootstrapping YOLOv8n (nano) inference mappings for Edge deployments...")
    # 2. Model Architecture
    model = YOLO("yolov8n.pt")
    
    # 3. Training Logic mapped structurally 
    # (Vis tracking, Checkpointing, and Augmentations execute natively via Ultralytics engine!)
    print("--> Trigerring Heavy Training Matrix (100 Epochs, BS 16, lr 0.001, AdamW)...")
    results = model.train(
        data=data_yaml_path,
        epochs=100,
        imgsz=640,
        batch=16,
        lr0=0.001,
        optimizer='AdamW',
        patience=10,        # Explicitly maps early stopping checks implicitly
        # Augmentation metrics statically locked
        fliplr=0.5,         # Random flip implementation dynamically
        mosaic=1.0,         # Mosaic scaling structurally natively 
        mixup=0.1,          # Mixup scaling explicitly internally limiting mapping
        project=output_dir, 
        name="pill_train",
        val=True            # Triggers mAP loop validation natively dynamically!
    )
    
    # Resolves internal model results mapped accurately to generic constraints
    best_map50 = results.box.map50
    best_map50_95 = results.box.map
    print(f"--> [Results] Native mAP@0.5: {best_map50:.3f} | Native mAP@0.5:0.95: {best_map50_95:.3f}")
    
    # Extract structural best.pt binding securely mirroring baseline
    best_model_path = os.path.join(output_dir, "pill_train", "weights", "best.pt")
    target_deploy_path = os.path.join(root_dir, 'best.pt')
    os.system(f"cp {best_model_path} {target_deploy_path}")
    print(f"--> Exported primary weights to baseline explicitly: {target_deploy_path}")
    
    # 4. Edge Payload generation
    # Exports securely dropping explicit structural formats actively inside pipeline logic natively
    print("--> Transcoding explicit ONNX structural formats dynamically...")
    model.export(format="onnx", imgsz=640)
    
    print("--> Transcoding target TensorFlow Lite (TFLite) parameters mapping edge architectures natively...")
    model.export(format="tflite", imgsz=640)
    
    print("--> ML Pipeline Cascade complete!")

if __name__ == "__main__":
    main()
