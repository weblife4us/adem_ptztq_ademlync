// ===========================================================================
// AdEM PTZq Android App - Debug Configuration
// ===========================================================================
// PRODUCTION CHECKLIST (disable before shipping):
//   1. kSLGDebugEnabled - set to FALSE to remove SLG47011 debug page
// See: Android_Start_Initialization/ folder for full configuration report
// ===========================================================================

/// SLG47011 debug readback feature flag.
/// Set to true to enable real-time SLG47011 buffer monitoring page
/// in the side menu. Set to false for production builds -- the Dart
/// compiler will tree-shake all debug code when this is false.
const bool kSLGDebugEnabled = true;
