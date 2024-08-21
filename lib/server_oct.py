import torch
from torch import nn
from torch.nn import init
import torch.nn.functional as F
import torch.utils.model_zoo as model_zoo
from PIL import Image
import torchvision.transforms as transforms
import numpy as np
import random
import os
from flask import Flask, request, send_file, abort
from werkzeug.utils import secure_filename
import matplotlib.pyplot as plt
from fpdf import FPDF

# Flask app setup
app = Flask(__name__)

# Ensure consistent results
torch.manual_seed(0)
np.random.seed(0)
random.seed(0)
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False

# Model architecture details
base = {'352': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 512, 512, 512, 'M', 512, 512, 512, 'M']}
extra = {'352': [2, 7, 14, 21, 28]}

# URLs for pretrained models
model_urls = {
    'vgg16': 'https://download.pytorch.org/models/vgg16-397923af.pth',
}

# VGG configuration function
def vgg(cfg, i, batch_norm=False):
    layers = []
    in_channels = i
    for v in cfg:
        if v == 'M':
            layers += [nn.MaxPool2d(kernel_size=2, stride=2)]
        else:
            conv2d = nn.Conv2d(in_channels, v, kernel_size=3, padding=1)
            if batch_norm:
                layers += [conv2d, nn.BatchNorm2d(v), nn.ReLU(inplace=True)]
            else:
                layers += [conv2d, nn.ReLU(inplace=True)]
            in_channels = v
    return layers

# Custom convolutional construct
class ConvConstract(nn.Module):
    def __init__(self, in_channel):
        super(ConvConstract, self).__init__()
        self.conv1 = nn.Conv2d(in_channel, 128, kernel_size=3, padding=1)
        self.cons1 = nn.AvgPool2d(3, stride=1, padding=1)

    def forward(self, x):
        x = F.relu(self.conv1(x), inplace=True)
        x2 = self.cons1(x)
        return x, x - x2

# Extra layers function
def extra_layer(vgg, cfg):
    feat_layers, pool_layers = [], []
    for k, v in enumerate(cfg):
        feat_layers += [ConvConstract(vgg[v].out_channels)]
        if k == 0:
            pool_layers += [nn.Conv2d(128 * (6 - k), 128 * (5 - k), 1)]
        else:
            pool_layers += [nn.ConvTranspose2d(128 * (6 - k), 128 * (5 - k), 3, 2, 1, 1)]
    return vgg, feat_layers, pool_layers

class LDN(nn.Module):
    def __init__(self, base, feat_layers, pool_layers, pretrained=True, num_classes=4):
        super(LDN, self).__init__()
        self.base = nn.ModuleList(base)
        self.feat = nn.ModuleList(feat_layers)
        self.pool = nn.ModuleList(pool_layers)
        self.glob = nn.Sequential(nn.Conv2d(512, 128, 3), nn.ReLU(inplace=True),
                                  nn.Conv2d(128, 128, 3), nn.ReLU(inplace=True),
                                  nn.Conv2d(128, 128, 3))
        self.conv_g = nn.Conv2d(128, 1, 1)
        self.conv_l = nn.Conv2d(128, num_classes, 1)

        self.apply(weights_init)
        if pretrained:
            self.load_pretrained_weights()

    def load_pretrained_weights(self):
        my_dict = model_zoo.load_url(model_urls['vgg16'], model_dir='./pretrained_vgg')
        keys_to_remove = {k for k in my_dict if k.startswith('classifier') or 'conv_l' in k}
        for key in keys_to_remove:
            del my_dict[key]
        self.base.load_state_dict({k.replace('features.', ''): v for k, v in my_dict.items()}, strict=False)
        init.kaiming_normal_(self.conv_l.weight, mode='fan_out', nonlinearity='relu')
        init.constant_(self.conv_l.bias, 0)
        print('Loaded VGG pretrained weights, initialized new layers.')

    def forward(self, x):
        for layer in self.base:
            x = layer(x)
        glob_out = self.glob(x)
        out = self.conv_l(glob_out)
        out = F.interpolate(out, size=(176, 176), mode='bilinear', align_corners=False)
        return out

def weights_init(m):
    if isinstance(m, nn.Conv2d):
        init.kaiming_uniform_(m.weight, mode='fan_in', nonlinearity='relu')
        if m.bias is not None:
            init.constant_(m.bias, 0)
    elif isinstance(m, nn.BatchNorm2d):
        init.constant_(m.weight, 1)
        init.constant_(m.bias, 0)
    elif isinstance(m, nn.Linear):
        init.kaiming_uniform_(m.weight, mode='fan_in', nonlinearity='relu')
        if m.bias is not None:
            init.constant_(m.bias, 0)

# Define the build_model function
def build_model():
    base_layers = vgg(base['352'], 3, batch_norm=False)
    _, feat_layers, pool_layers = extra_layer(base_layers, extra['352'])
    return LDN(base_layers, feat_layers, pool_layers, pretrained=True, num_classes=4)

# Now create the model instance
model = build_model()

# Ensure the model state is loaded properly
model_path = 'B:/Fiverr Projects/Ocular_App/LDN_epoch_20.pth'
checkpoint = torch.load(model_path, map_location=torch.device('cpu'))
for name, param in checkpoint.items():
    if 'conv_l' not in name:
        model.state_dict()[name].copy_(param)

# Set the model to evaluation mode
model.eval()
print("Model loaded successfully!")

def load_image(image_path, img_size):
    img = Image.open(image_path).convert('RGB')
    transform = transforms.Compose([
        transforms.Resize((img_size, img_size)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    img_tensor = transform(img).unsqueeze(0)
    return img_tensor

name2label = {'CNV': 0, 'DRUSEN': 1, 'DME': 2, 'NORMAL': 3}
label2name = {v: k for k, v in name2label.items()}

def predict(model, image_path, img_size=352):
    image_tensor = load_image(image_path, img_size)
    model.eval()
    with torch.no_grad():
        output = model(image_tensor)
        output = torch.mean(output, dim=[2, 3])
        probabilities = torch.softmax(output, dim=1)
        predicted_class = torch.argmax(probabilities, dim=1).item()
    class_name = label2name[predicted_class]
    return probabilities.numpy(), class_name

def plot_probabilities_pdf(probabilities, filename='probabilities.png'):
    labels = list(name2label.keys())
    plt.bar(labels, probabilities[0])
    plt.xlabel('Condition')
    plt.ylabel('Probability')
    plt.title('Prediction Probabilities')
    for i, v in enumerate(probabilities[0]):
        plt.text(i, v + 0.01, f"{v:.2f}", ha='center')
    plt.savefig(filename)
    plt.close()

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 12)
        self.cell(0, 10, 'Prediction Report', 0, 1, 'C')

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

    def chapter_title(self, title):
        self.set_font('Arial', 'B', 12)
        self.cell(0, 10, title, 0, 1, 'L')
        self.ln(10)

    def chapter_body(self, body):
        self.set_font('Arial', '', 12)
        self.multi_cell(0, 10, body)
        self.ln()

def generate_pdf(predicted_class, probabilities):
    pdf = PDF()
    pdf.add_page()
    pdf.chapter_title(f"Predicted Condition: {predicted_class}")
    plot_probabilities_pdf(probabilities)
    pdf.image('probabilities.png', x=10, y=None, w=180)
    pdf.output('prediction_report.pdf')

# Flask route to handle prediction requests
@app.route('/predict', methods=['POST'])
def predict_route():
    if 'file' not in request.files:
        return "No file provided", 400

    file = request.files['file']
    if file.filename == '':
        return "No file selected", 400
    if not allowed_file(file.filename):
        return "File type not allowed", 400

    filename = secure_filename(file.filename)
    filepath = os.path.join('uploads_oct', filename)
    file.save(filepath)

    probabilities, class_name = predict(model, filepath)
    generate_pdf(class_name, probabilities)
    return send_file('prediction_report.pdf', as_attachment=True, download_name='result.pdf')

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'jpg', 'jpeg', 'png'}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002, threaded=True)
