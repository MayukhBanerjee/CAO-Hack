from flask import Flask, request, send_file
import cv2
import numpy as np
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
PROCESSED_FOLDER = 'processed'

# Create folders if they don't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

# Load Haar Cascade for face detection
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

def check_blur(image, threshold=100):
    """Check if image is blurry (Feature 3)"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY) if len(image.shape) == 3 else image
    fm = cv2.Laplacian(gray, cv2.CV_64F).var()
    return fm > threshold

def auto_adjust(image):
    """Automatic brightness/contrast adjustment (Feature 4)"""
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
    l = clahe.apply(l)
    lab = cv2.merge((l,a,b))
    return cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)

def remove_background(img):
    """Background removal (Feature 2)"""
    mask = np.zeros(img.shape[:2], np.uint8)
    bgdModel = np.zeros((1,65), np.float64)
    fgdModel = np.zeros((1,65), np.float64)
    rect = (10,10,img.shape[1]-20,img.shape[0]-20)
    cv2.grabCut(img, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT)
    mask = np.where((mask==2)|(mask==0), 0, 1).astype('uint8')
    return img * mask[:,:,np.newaxis]

def detect_and_crop_face(image):
    """Detect and crop the largest face in the image"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)
    
    if len(faces) == 0:
        return None
    
    (x, y, w, h) = max(faces, key=lambda f: f[2]*f[3])
    padding = int(w * 0.2)
    x = max(0, x - padding)
    y = max(0, y - padding)
    w = min(image.shape[1] - x, w + 2*padding)
    h = min(image.shape[0] - y, h + 2*padding)
    
    return image[y:y+h, x:x+w]

@app.route('/')
def index():
    return 'Flask Backend Running!'

@app.route('/process_image', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return 'No image file provided', 400

    image_file = request.files['image']
    filename = secure_filename(image_file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    image_file.save(filepath)

    # Read the image
    img = cv2.imread(filepath)
    if img is None:
        return 'Invalid image file', 400

    # Check image quality
    if not check_blur(img):
        return 'Image is too blurry', 400

    # Auto-adjust brightness/contrast
    img = auto_adjust(img)

    # Detect and crop face
    face_img = detect_and_crop_face(img)
    
    if face_img is None:
        return 'No face detected', 400
    
    # Remove background
    face_img = remove_background(face_img)

    # Apply Sobel edge detection to each color channel
    channels = cv2.split(face_img)
    edge_channels = []
    for channel in channels:
        sobelx = cv2.Sobel(channel, cv2.CV_64F, 1, 0, ksize=3)
        sobely = cv2.Sobel(channel, cv2.CV_64F, 0, 1, ksize=3)
        sobel = cv2.magnitude(sobelx, sobely)
        edge_channels.append(np.uint8(np.clip(sobel, 0, 255)))
    
    # Merge color channels
    sobel_color = cv2.merge(edge_channels)

    # Save the result
    processed_path = os.path.join(PROCESSED_FOLDER, 'processed_' + filename)
    cv2.imwrite(processed_path, sobel_color)

    # Send processed image back to Flutter
    return send_file(processed_path, mimetype='image/png')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)