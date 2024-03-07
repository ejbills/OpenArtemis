# OpenArtemis
[![GitHub stars](https://img.shields.io/github/stars/ejbills/OpenArtemis.svg)](https://github.com/ejbills/OpenArtemis/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ejbills/OpenArtemis.svg)](https://github.com/ejbills/OpenArtemis/network)
[![GitHub issues](https://img.shields.io/github/issues/ejbills/OpenArtemis.svg)](https://github.com/ejbills/OpenArtemis/issues)

OpenArtemis is a privacy-focused, read-only web scraping Reddit client built with SwiftUI. It places a strong emphasis on transparency and open collaboration. This project is open-source, allowing developers to contribute, inspect, and improve the codebase together.

## Features
- **Privacy-Focused:** OpenArtemis prioritizes user privacy by implementing ethical web scraping practices, tracking blockers and leveraging other open-source privacy focused web replacements.
- **SwiftUI:** The user interface is crafted with SwiftUI, providing a modern and intuitive experience for users.
- **Read-Only:** OpenArtemis operates in a read-only mode, ensuring that users cannot log in. All data, including local subreddit favorites, multis, comment and post favorites, and the home feed, are all stored locally.
- **Open Source:** Contributions are welcome! Feel free to suggest improvements, report bugs, or add new features.

## How do I open a feature request or a bug report?
*Please note, we use github issues to track both bug reports and feature requests! To do so, simply navigate to the Issues tab on the GitHub repository, click on the "New Issue" button, and use the provided template to fill in the details.*

### Opening a Feature Request:
Title: FR: Add support for user-customized themes

Description:
I would like to propose the addition of a feature that allows users to customize the app's theme colors according to their preferences. This would enhance the overall user experience and provide a more personalized feel to the app.

### Opening a Bug Report Issue:
Title: BUG: App crashes when navigating to a specific subreddit

Description:
I encountered a bug where the app crashes consistently when attempting to navigate to the "example" subreddit. This issue occurs every time I try to access that specific subreddit, and it's affecting my overall experience with the app.

Steps to Reproduce:

    Open the app.
    Navigate to the "example" subreddit.

Expected Behavior:
The app should navigate to the selected subreddit without any issues.

Actual Behavior:
The app crashes immediately upon attempting to access the "example" subreddit.

Additional Information:

    Device: iPhone X
    iOS Version: 15.0

## Getting Started for Contributing to OpenArtemis
To contribute to OpenArtemis, follow these steps:

### Prerequisites
- Xcode installed on your machine.
- Basic knowledge of Swift and SwiftUI.

### Setting Up the Project
1. Fork the repository.
2. Clone your forked repository to your local machine.
3. Open the project in Xcode.

### Contribution Guide
When contributing to OpenArtemis, it's important to follow clean coding practices and provide meaningful comments to ensure code maintainability. Here's a generic guide to help you get started:

1. **Branching:**
   - Base all new features off of `main`.
   - Create a new branch for each feature or bug fix: `git checkout -b feature/your-feature-name`.
   

3. **Coding Standards:**
   - Follow Swift coding conventions and style guidelines.
   - Aim for clear, concise, and expressive code.

4. **Documentation:**
   - Document your code using comments to explain complex logic or functionality.

5. **Testing (optional):**
   - Write unit tests for new features or changes.
   - Ensure existing tests pass before submitting a pull request.

### Example Pull Request

#### Title: Add Dark Mode Support

#### Description:
Implemented dark mode support for a better user experience during low-light conditions. Updated color schemes and adjusted UI elements to seamlessly integrate with system preferences.

#### Changes Made:
- Modified color assets in Assets.xcassets.
- Updated SwiftUI views to dynamically adjust to light and dark modes.

#### Screenshots:
{Direct link or embed of image in PR comments/body}

### License
This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

Feel free to open an issue, submit a feature request, or send a pull request. Your contributions are valued!
