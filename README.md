# marvel_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Marvel Flutter App Screens

This document provides an overview of the screens included in the Marvel Flutter App, detailing the purpose and key features of each.

## Home Screen

- **File:** [lib/screens/home.dart](lib/screens/home.dart)
- **Description:** The Home Screen serves as the landing page of the app, showcasing featured Marvel characters and comics. It provides quick access to different categories and recent releases.

## Character Screen

- **File:** [lib/screens/character.dart](lib/screens/character.dart)
- **Description:** This screen displays a list of Marvel characters. Users can search for characters by name and view detailed information by tapping on a character card.

## Comic Screen

- **File:** [lib/screens/comics.dart](lib/screens/comics.dart)
- **Description:** The Comic Screen lists Marvel comics. It includes functionality to search for comics by title and filter results based on various criteria such as release date and issue number.

## Comic Detail Screen

- **File:** [lib/screens/child-pages/comicsDetails.dart](lib/screens/child-pages/comicsDetails.dart)
- **Description:** Detailed view for a specific comic. It shows the comic's cover art, title, description, and characters featured in the comic.

## Character Detail Screen

- **File:** [lib/screens/child-pages/characterDetails.dart](lib/screens/child-pages/characterDetails.dart)
- **Description:** This screen provides detailed information about a specific Marvel character, including their backstory, powers, and comics they appear in.

## Extra Screen

- **File:** [lib/screens/extra.dart](lib/screens/extra.dart)
- **Description:** An additional screen for showcasing extra content or features not covered by the main screens, such as behind-the-scenes looks, interviews with creators, or trivia.

## Navigation

- **File:** [lib/navigation.dart](lib/navigation.dart)
- **Description:** Manages navigation between the different screens of the app. It includes a bottom navigation bar that allows users to easily switch between the Home, Character, Comic, and Extra screens.
