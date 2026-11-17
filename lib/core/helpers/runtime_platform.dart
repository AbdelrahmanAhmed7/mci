import 'dart:ffi';
import 'dart:io';

/// Firebase's iOS SDK currently crashes while starting on the Intel simulator.
/// Physical iPhones and Apple-Silicon simulators are not affected.
bool get isIntelIosSimulator => Platform.isIOS && Abi.current() == Abi.iosX64;
