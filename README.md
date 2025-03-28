# 🧠 Sudoku Solver – Snap. Solve. Play.

This mobile app solves Sudoku puzzles from just a photo — whether it's snapped from your camera or pulled from your gallery.

Behind the scenes? A blend of computer vision, OCR, a custom Flutter UI, and a FastAPI backend. All designed to recognize, process, and solve a Sudoku with minimal user effort. Oh, and yes — users can log in securely to track their solving streaks.

## 📸 What It Does

You point your phone at a Sudoku puzzle. The app finds the grid, reads the digits using Tesseract OCR and OpenCV, and lets you verify the recognized numbers. Once you're happy, it sends the board to a FastAPI server which instantly solves it using an efficient DFS algorithm. Then, the solved puzzle fades into view — beautifully animated and ready for you to admire.

## ✨ Features

- **Smart Recognition**  
  Capture or upload a Sudoku puzzle, and let the app extract and read it automatically.

- **Manual Correction**  
  Didn’t quite get that smudged 7? You can easily edit any misread digit before solving.

- **Instant Solving**  
  The puzzle is solved server-side using a DFS algorithm based on Peter Norvig’s technique.

- **Secure Login**  
  Users can sign up and log in securely via a dedicated backend with JWT (HS256) encryption.

- **Smooth Experience**  
  Animated screens, gradients, transitions — everything's crafted to feel fluid and modern.

## 🛠️ Tech Stack

| Layer               | Tech                                                                    |
| ------------------- | ----------------------------------------------------------------------- |
| **Frontend (App)**  | Flutter (Dart), Camera, Animated UI                                     |
| **OCR**             | Tesseract OCR + OpenCV                                                  |
| **Backend**         | FastAPI with Docker, deployed on Render                                 |
| **Solving Logic**   | DFS algorithm inspired by Peter Norvig’s constraint propagation         |
| **Authentication**  | MongoDB Atlas + JWT (HS256)                                             |

## 🔁 How It All Connects

1. **Login/Register**  
   The user signs in via email and password. Auth tokens are managed securely.

2. **Pick or Snap a Sudoku**  
   The app lets users either take a photo or choose one from their gallery.

3. **Grid Detection & OCR**  
   OpenCV locates the grid, and Tesseract extracts digits — done locally and on the server for extra accuracy.

4. **Review & Edit**  
   Users are shown the recognized digits in a Sudoku grid and can manually fix mistakes.

5. **Solve It**  
   A FastAPI server receives the puzzle and runs a depth-first search to return a valid solution.

6. **Celebrate the Grid**  
   Animated cell-by-cell reveal of the solved puzzle. Then — ready to go again.

## 📁 Project Structure (Client)

    lib/
    ├── main.dart                         # App entrypoint and routes
    ├── screens/                          # App UI screens
    │   ├── splash_screen.dart
    │   ├── auth_screen.dart
    │   ├── main_menu_screen.dart
    │   ├── capture_sudoku_screen.dart
    │   ├── image_preview_screen.dart
    │   ├── edit_recognized_digits_screen.dart
    │   └── sudoku_solution_screen.dart
    ├── services/                         # API calls, camera & gallery logic
    │   ├── auth_api_service.dart
    │   ├── sudoku_api_service.dart
    │   ├── camera_manager.dart
    │   └── gallery_image_picker.dart
    └── widgets/
        └── camera_preview_overlay.dart

## 🚀 Getting Started

### 📦 Requirements

- Flutter SDK (2.0+)
- Dart SDK
- Android Studio or VS Code (with Flutter plugin)
- A running instance of the backend (FastAPI + MongoDB)

### 🧰 Setup Instructions

1. **Clone the Repo**

    ```bash
    git clone https://github.com/davideblesse/sudoku-solver-client.git
    cd sudoku-solver-client
    ```

2. **Install Dependencies**

    ```bash
    flutter pub get
    ```

3. **Configure API Endpoints**

    Make sure the backend URLs in `auth_api_service.dart` and `sudoku_api_service.dart` point to your running backend or Render-hosted server.

4. **Run the App**

    ```bash
    flutter run
    ```

✅ Works on Android, iOS, and emulators.

## 🤝 Contributing

Found a bug? Want to contribute a feature or improve OCR accuracy? Open a pull request or drop an issue — collaboration is welcome.

## ⚖️ License

This project is open-source under the [MIT License](LICENSE).

## 💬 Questions or Ideas?

Feel free to open an issue or start a discussion in this repository — I'm always open to feedback, improvements, and puzzle-loving collaborators.