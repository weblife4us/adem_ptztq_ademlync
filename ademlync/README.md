# AdEMLync

AdEMLync is a mobile app designed to support phone and tablet control of AdEM, a gas meter produced by RometLimited company. The app works with Amazon cloud services and connects to AdEM via Bluetooth through a AdEM Key, also provided by Romet.

## Table of Contents

-   [Installation](#installation)
-   [Features](#features)
-   [Contributing](#contributing)
-   [Licenses](#licenses)
-   [Contact](#contact)
-   [Variable Naming Conventions](#variable-naming-conventions)

## Installation

Instructions on how to install and set up AdEMLync.

```bash
# Clone the repository
git clone git@bitbucket.org:romet-engineering/skylab_mobile_app.git

# Change directory into the project folder
cd skylab_mobile_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Features

A list of the major features of AdEMLync.

1. Bluetooth connectivity to AdEM
2. Integration with Amazon cloud services

## Contributing

Guidelines for contributing to AdEMLync.

1. Clone the repository.
2. Create a new branch in feature/release branch with your name in Bitbucket.
3. Commit your changes (git commit).
4. Push to the branch (git push origin <branch_name>).
5. Wait for review.
6. Create a pull request.

## License

Copyright (c) 2024 Romet Limited. All rights reserved.

Permission to use, copy, modify, and distribute this software and its documentation for internal use within Romet Limited is hereby granted, provided that the above copyright notice and this permission notice appear in all copies of the software and related documentation.

THIS SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact

For any questions or inquiries, please contact:

Andrew Chan - Software Engineer - andrewchan@rometlimited.com

## Variable Naming Conventions

Short forms used for variable naming:

```dart
dynamic press; // Pressure
dynamic temp; // Temperature
dynamic cor; // Corrected
dynamic unc; // Uncorrected
dynamic vol; // Volume
dynamic calib; // Calibration
dynamic disp; // Display
```

Feel free to adjust the formatting or content further based on your preferences!
