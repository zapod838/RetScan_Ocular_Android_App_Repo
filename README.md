# RetScan - Ocular Health Diagnostic App

**RetScan** is a Flutter-based Android application designed to empower users with precision diagnostics for ocular health. The app allows users to upload Retinal and OCT (Optical Coherence Tomography) scans for instant analysis, integrating machine learning models deployed via Flask on AWS.

## Features

- **User Authentication:** Secure login system with options for social media sign-in.
- **Scan Upload:** Users can upload Retinal and OCT scans for analysis.
- **Instant Results:** Integration with machine learning models to provide real-time diagnostic feedback.
- **Medical Services:** Users can browse through available specialists and view their profiles and ratings.

## Screenshots

### 1. Welcome, Login, and Dashboard
![Welcome, Login, and Dashboard](![Merged_1_3](https://github.com/user-attachments/assets/c52c95b8-946b-402b-97a1-6a8ac800fef1))

### 2. Upload Screens for Retinal and OCT Scans
![Upload Screens](![Merged_4_5](https://github.com/user-attachments/assets/b3c72357-372f-4158-b501-c4e658942723))

## Technology Stack

- **Flutter**: Cross-platform mobile framework for building the app.
- **Flask**: Lightweight Python framework used to serve the machine learning models.
- **Machine Learning Models**: Integrated for ocular health diagnostics.
- **AWS**: Deployed Flask backend on AWS for scalable and reliable performance.

## Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/zapod838/RetScan.git
   cd RetScan
   ```
2. **Install dependencies**:
  ```bash
  flutter pub get
  ```
3. **Run the app**:
  ```bash
  flutter run
  ```
4. **Backend Setup**:
The Flask server hosting the machine learning models should be set up on AWS. Ensure the API endpoints in the Flutter app are correctly configured to point to your Flask deployment.

## Contribution
Feel free to fork this repository and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License. See the LICENSE file for details.






