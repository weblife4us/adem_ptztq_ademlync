import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'app_delegate.dart';

class UISpecification {
  // Singleton
  static final _instance = UISpecification._internal();
  UISpecification._internal();

  factory UISpecification() => _instance;

  // Constants for screen factors
  static const minTablaWidth = 600.0;
  static const maxWidthForTablet = 450.0;
  static const mobileBodyPadding = EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 48.0);
  static const bodyPadding = EdgeInsets.only(top: 36.0, bottom: 120);

  /// Get the root context.
  static BuildContext get _context => AppDelegate.rootContext!;

  /// Get the root Media Query.
  static MediaQueryData get _media => MediaQuery.of(_context);

  /// Determine if the device is iOS.
  static bool get isIos => Platform.isIOS;

  /// Determine if the device is Android.
  static bool get isAndroid => Platform.isAndroid;

  /// Determine if the device is tablet.
  static bool get isTablet => screenWidth >= minTablaWidth ? true : false;

  /// Determine the platform.
  static PlatformType get platform => isTablet
      ? isIos
            ? PlatformType.iPad
            : PlatformType.tablet
      : isIos
      ? PlatformType.iPhone
      : PlatformType.phone;

  /// Get the screen height.
  static double get screenHeight => _media.size.height;

  /// Get the screen width.
  static double get screenWidth => _media.size.width;

  /// Determine if the orientation is landscape.
  static bool get isLandscape => _media.orientation == Orientation.landscape;
}

enum PlatformType { iPhone, iPad, phone, tablet }
