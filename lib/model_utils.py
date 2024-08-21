import os
import cv2
import numpy as np
from fpdf import FPDF
import tensorflow as tf
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from PIL import Image, ImageDraw, ImageFont
from tensorflow.keras.models import load_model, Model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.densenet import preprocess_input

def focal_loss_function(gamma=2., alpha=4.):
    def focal_loss_fixed(y_true, y_pred):
        epsilon = tf.keras.backend.epsilon()
        y_pred = tf.clip_by_value(y_pred, epsilon, 1. - epsilon)
        y_true = tf.cast(y_true, tf.float32)
        alpha_t = y_true * alpha + (tf.keras.backend.ones_like(y_true) - y_true) * (1 - alpha)
        p_t = y_true * y_pred + (tf.keras.backend.ones_like(y_true) - y_pred) * (1 - y_pred)
        fl = - alpha_t * tf.keras.backend.pow((tf.keras.backend.ones_like(y_true) - p_t), gamma) * tf.keras.backend.log(p_t)
        return tf.reduce_mean(fl)
    return focal_loss_fixed

def make_gradcam_heatmap(img_array, model, last_conv_layer_name, pred_index):
    grad_model = Model(
        inputs=[model.inputs],
        outputs=[model.get_layer(last_conv_layer_name).output, model.output])
    with tf.GradientTape() as tape:
        conv_outputs, predictions = grad_model(img_array)
        loss = predictions[:, pred_index]
    grads = tape.gradient(loss, conv_outputs)[0]
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1))
    heatmap = tf.reduce_mean(tf.multiply(pooled_grads, conv_outputs[0]), axis=-1)
    heatmap = tf.maximum(heatmap, 0) / tf.reduce_max(heatmap)
    return heatmap.numpy()

def apply_circular_mask(img):
    center = (int(img.shape[1]/2), int(img.shape[0]/2))
    radius = min(center[0], center[1], img.shape[1]-center[0], img.shape[0]-center[1])
    Y, X = np.ogrid[:img.shape[0], :img.shape[1]]
    dist_from_center = np.sqrt((X - center[0])**2 + (Y - center[1])**2)
    mask = dist_from_center <= radius
    img[~mask] = 0
    return img

def create_pdf(heatmap_dir, class_names, predictions):
    pdf = FPDF()
    pdf.set_auto_page_break(auto=False, margin=0.0)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except IOError:
        font = ImageFont.load_default()

    # Generate and add the bar chart to the first page
    pdf.add_page()
    plt.figure(figsize=(14, 7))  # Larger figure size
    bar_width = 0.35  # Adjust bar width for better visibility
    index = np.arange(len(class_names))
    
    bars = plt.bar(index, predictions, bar_width, alpha=0.8, color='b', label='Prediction')
    
    plt.xlabel('Conditions', fontsize=12)
    plt.ylabel('Percentage (%)', fontsize=12)
    plt.title('Prediction Results', fontsize=14)
    plt.xticks(index, class_names, rotation=45, ha="right", fontsize=10)  # Rotate labels to avoid overlap
    # Annotate bars with percentage values
    for bar in bars:
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, yval, f'{yval:.2%}', va='bottom', ha='center', fontsize=8)  # Adjust text alignment and position
    
    plt.tight_layout()  # Adjust layout to make room for label rotation

    # Optionally, add a grid
    plt.grid(True, linestyle='--', which='major', color='grey', alpha=0.5)
    chart_path = os.path.join(heatmap_dir, 'prediction_chart.png')
    plt.savefig(chart_path)
    plt.close()
    pdf.image(chart_path, x=10, y=8, w=190)  # Adjust dimensions as needed    
    
    images_per_page = 9
    x_positions = [10, 75, 140]
    y_positions = [10, 90, 170]

    for i in range(0, len(class_names), images_per_page):
        pdf.add_page()
        for j in range(images_per_page):
            if i + j < len(class_names):
                img_path = os.path.join(heatmap_dir, f'{class_names[i+j]}_heatmap.jpg')
                if os.path.exists(img_path):
                    img = Image.open(img_path)
                    draw = ImageDraw.Draw(img)
                    class_name = class_names[i + j]
                    prob = predictions[i + j]
                    text = f"{class_name}: {prob:.2%}"
                    text_bbox = draw.textbbox((0, 0), text, font=font)
                    text_x = (img.width - text_bbox[2]) // 2
                    text_y = img.height - text_bbox[3] - 5
                    draw.text((text_x, text_y), text, font=font, fill=(255, 255, 255))
                    img_path_label = img_path.replace('.jpg', '_labeled.jpg')
                    img.save(img_path_label)
                    x_pos = x_positions[j % 3]
                    y_pos = y_positions[j // 3]
                    pdf.image(img_path_label, x=x_pos, y=y_pos, w=60)
                    pdf.set_xy(x_pos, y_pos + 60)
                    pdf.set_font("Arial", size=12)
                    pdf.cell(60, 10, txt=text, ln=1, align='C')

    return pdf

# Assuming focal_loss_function is defined elsewhere or here
def load_custom_model(path):
    try:
        # Attempt to load the model using the HDF5 format
        model = load_model(path, custom_objects={'focal_loss_function': focal_loss_function()})
        return model
    except (OSError, ValueError) as e:
        # Handle the error if the file is not an HDF5 file or other issues occur
        print(f"Error loading model: {e}")
        return None
    
def process_image_and_generate_pdf(file_path, model):
    img = image.load_img(file_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    
    predictions = model.predict(img_array)[0]
    class_names = ["DR", "ARMD", "MH", "DN", "MYA", "BRVO", "TSLN", "ERM", "LS", "MS",
                    "CSR", "ODC", "CRVO", "TV", "AH", "ODP", "ODE", "ST", "AION", "PT",
                    "RT", "RS", "CRS", "EDN", "RPEC", "MHL", "RP", "OTHER"]
    
    original_image = cv2.imread(file_path)
    last_conv_layer_name = "conv5_block16_2_conv"
    # Base directory for all file operations
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # Gets the directory where your script is located
    HEATMAP_DIR = os.path.join(BASE_DIR, 'heatmaps')

    # Ensure the directory exists
    os.makedirs(HEATMAP_DIR, exist_ok=True)

    for i, class_name in enumerate(class_names):
        heatmap = make_gradcam_heatmap(img_array, model, last_conv_layer_name, i)
        heatmap = cv2.resize(heatmap, (original_image.shape[1], original_image.shape[0]))
        heatmap = np.uint8(255 * heatmap)
        heatmap = cv2.applyColorMap(heatmap, cv2.COLORMAP_JET)
        heatmap = apply_circular_mask(heatmap)
        superimposed_img = heatmap * 0.6 + original_image * 0.4
        superimposed_img = np.uint8(superimposed_img)
        cv2.imwrite(os.path.join(HEATMAP_DIR, f'{class_name}_heatmap.jpg'), superimposed_img)

    # Create PDF
    pdf = create_pdf(HEATMAP_DIR, class_names, predictions)
    output_pdf_path = os.path.join(BASE_DIR, 'combined_heatmap.pdf')
    pdf.output(output_pdf_path)
    return output_pdf_path

