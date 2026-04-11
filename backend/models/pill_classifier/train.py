import os
import json
import numpy as np
import tensorflow as tf
from pathlib import Path
from sklearn.utils.class_weight import compute_class_weight
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns

from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.optimizers.schedules import CosineDecay
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping
from tensorflow.keras.metrics import CategoricalAccuracy, TopKCategoricalAccuracy

# ---------------------------------------------------------
# Training Pipeline: AASHA Pill Classification CNN
# ---------------------------------------------------------

# Explicit execution constraints natively locking constants
EPOCHS = 50
BATCH_SIZE = 32
INITIAL_LR = 0.0001
IMG_SIZE = (224, 224) # Standard bounds dictating EfficientNet local architecture matrices

def build_model(num_classes: int) -> Model:
    """
    Construct architectural endpoints binding the standard EfficientNetB0 ImageNet backbone 
    dynamically mapped underneath highly targeted custom heads resolving class mappings explicitly.
    """
    # 2. Model Architecture
    base_model = EfficientNetB0(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
    
    # Unfreeze bounds generally or apply fine-tuning natively
    # base_model.trainable = False 
    
    x = base_model.output
    # Custom targeted ML head processing logic specifically outlined internally
    x = GlobalAveragePooling2D()(x)
    x = Dense(512, activation='relu')(x)
    x = Dropout(0.5)(x)
    predictions = Dense(num_classes, activation='softmax')(x)
    
    model = Model(inputs=base_model.input, outputs=predictions)
    return model

def setup_data(data_dir: str):
    """
    Deploy strict native ImageDataGenerators manipulating data explicitly via targeted bounding Augmentations.
    EfficientNetB0 natively inherently limits scaling inputs so Rescale handles locally dynamically.
    """
    # 4. Data Augmentation natively dictating parameters securely
    train_datagen = tf.keras.preprocessing.image.ImageDataGenerator(
        rotation_range=30,           # ±30° degree sweeps
        zoom_range=[0.8, 1.2],       # Scaling bounds 0.8 to 1.2 natively
        brightness_range=[0.8, 1.2], # Brightness variations mapping natively
        horizontal_flip=True,        # Flip implementation mapping natively explicitly
        validation_split=0.2         # Separate loops natively allocating testing structures explicitly!
    )

    val_datagen = tf.keras.preprocessing.image.ImageDataGenerator(validation_split=0.2)

    # Note: Keras dynamically builds 500+ class bounds dictating targets based purely heavily on nested structures
    train_gen = train_datagen.flow_from_directory(
        data_dir,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training',
        shuffle=True
    )

    val_gen = val_datagen.flow_from_directory(
        data_dir,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation',
        shuffle=False
    )
    
    return train_gen, val_gen

def generate_confusion_matrix(model, val_gen, class_names, output_dir):
    """
    Build structured mapping arrays translating validation data explicit limits resolving graphically.
    """
    print("--> Generating generic validation Confusion Matrix mappings internally natively...")
    # Resets the validation generator sequence dictating targets properly
    val_gen.reset()
    
    # Calculate native validation targets mapping locally internally
    y_pred = model.predict(val_gen)
    y_pred_classes = np.argmax(y_pred, axis=1)
    y_true = val_gen.classes

    cm = confusion_matrix(y_true, y_pred_classes)
    
    # Scale graphical rendering structures cleanly based explicitly heavily upon sizes scaling
    plt.figure(figsize=(24, 24))
    sns.heatmap(cm, cmap='Blues')
    plt.title('Confusion Matrix: Classifier Mappings Native Resolution Constraints')
    plt.ylabel('True Class Extracted Label')
    plt.xlabel('Algorithm Predicted Output Mapping Label')
    
    out_img = os.path.join(output_dir, 'confusion_matrix_final.png')
    plt.savefig(out_img)
    plt.close()
    print(f"--> Saved native mapping visualizations directly securely: {out_img}")

def main():
    root_dir = Path(__file__).parent
    
    # Assumed structural repository mapping internal structures explicitly:
    data_dir = os.path.abspath(os.path.join(root_dir, "../../../data/pill_classification"))
    output_dir = os.path.join(root_dir, "saved_models")
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(data_dir, exist_ok=True) 
    
    # 1. Dataset parsing natively dictating dynamic allocations implicitly based on raw directory definitions!
    try:
        print("--> Scanning internal arrays dictating raw classification configurations natively...")
        train_gen, val_gen = setup_data(data_dir)
        num_classes = train_gen.num_classes
        class_names = list(train_gen.class_indices.keys())
    except Exception as e:
        print(f"--> WARNING: Native data directories unreadable structurally. (Needs generic internal datasets): {e}")
        return 
        
    if num_classes == 0:
        print("--> WARNING: Data directories generated but natively empty. Please inject classification targets securely.")
        return

    # Native bounds scaling Class-Imbalance mapping directly
    print("--> Generating automated explicit Class Weights addressing arbitrary dataset imbalances locally...")
    class_weights = compute_class_weight(
        class_weight='balanced',
        classes=np.unique(train_gen.classes),
        y=train_gen.classes
    )
    weight_dict = dict(enumerate(class_weights))
    
    # Initializing Architectural Bindings constraints locally natively
    model = build_model(num_classes)
    
    # 3. Training config mapping strict bounding behaviors natively scaling 
    decay_steps = (train_gen.samples // BATCH_SIZE) * EPOCHS
    lr_schedule = CosineDecay(initial_learning_rate=INITIAL_LR, decay_steps=decay_steps)
    
    model.compile(
        optimizer=Adam(learning_rate=lr_schedule),
        loss='categorical_crossentropy',
        metrics=[CategoricalAccuracy(name='accuracy'), TopKCategoricalAccuracy(k=5, name='top_5_accuracy')]
    )
    
    # Resolves internal state checkpoints reliably overwriting parameters implicitly mapping highest metrics efficiently 
    best_model_path = os.path.join(output_dir, "best_classifier.tf")
    callbacks = [
        ModelCheckpoint(best_model_path, monitor='val_accuracy', save_best_only=True, save_format='tf'),
        EarlyStopping(monitor='val_accuracy', patience=10, restore_best_weights=True)
    ]
    
    print(f"--> Initiating ML Pipeline mapping over exactly {num_classes} internal geometries natively...")
    model.fit(
        train_gen,
        epochs=EPOCHS,
        validation_data=val_gen,
        class_weight=weight_dict,
        callbacks=callbacks
    )
    
    # Produce structural diagnostic visualizations statically handling outputs 
    generate_confusion_matrix(model, val_gen, class_names, output_dir)
    
    # 5. Native Payload Export Logic
    print("--> Exporting heavy execution loops securely building constraints for targeted deployments...")
    
    # Explicit conversion pipeline directly scaling weights heavily lowering memory footprints actively natively matching constraints implicitly (<10MB target logically mapped)
    converter = tf.lite.TFLiteConverter.from_saved_model(best_model_path)
    converter.optimizations = [tf.lite.Optimize.DEFAULT] 
    tflite_quant_model = converter.convert()
    
    # Resolving Output
    tflite_path = os.path.join(output_dir, "edge_classifier_quantized.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_quant_model)
        
    mb_size = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"--> Finished Export Native limits explicitly converting edge ML pipeline natively bounds to Quantized models: {mb_size:.2f} MB")

if __name__ == "__main__":
    main()
