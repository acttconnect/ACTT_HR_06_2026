import 'dart:async';
import 'package:employeeattendance/controllers/globalvariable.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  double? latitude;
  double? longitude;
  String? address;
  StreamSubscription<Position>? streamSubscription;
  bool isLocationServiceEnabled = false;
  LocationPermission? locationPermission;
  String? errorMessage;
  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      print('Initializing location service...');

      // Check location services first
      await checkLocationServices();
      if (!isLocationServiceEnabled) {
        errorMessage =
            'Location services are disabled. Please enable location services in your device settings.';
        print('Location services disabled');
        return;
      }

      // Check permissions
      await checkLocationPermission();
      if (locationPermission != LocationPermission.whileInUse &&
          locationPermission != LocationPermission.always) {
        errorMessage =
            'Location permission not granted. Please grant location permission in app settings.';
        print('Location permission not granted');
        return;
      }

      print(
          'Location services and permissions OK, getting current position...');

      // Get current position with retry logic
      await getCurrentLocation();

      // Start location stream only if we have a valid position
      if (latitude != null && longitude != null) {
        print('Starting location stream...');
        await startLocationStream();
      }

      isInitialized = true;
      print('Location service initialized successfully');
    } catch (e) {
      print('Error initializing location service: $e');
      errorMessage = 'Error initializing location service: $e';

      // Try to initialize again after a delay, but only if not already initialized
      if (!isInitialized) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!isInitialized) {
            print('Retrying location service initialization...');
            initialize();
          }
        });
      }
    }
  }

  Future<void> getAddressFromLatLang(Position position) async {
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemark.isNotEmpty) {
        Placemark place = placemark[0];
        address =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}';
        address = address!.replaceAll(RegExp(r',\s*,+'), ',').trim();
        if (address!.startsWith(',')) {
          address = address!.substring(1).trim();
        }
        if (address!.endsWith(',')) {
          address = address!.substring(0, address!.length - 1).trim();
        }

        GlobalVariable.location = address!;
        GlobalVariable.latitude = latitude!;
        GlobalVariable.longitude = longitude!;
      }
    } catch (e) {
      print('Error getting address: $e');
      // Fallback address if geocoding fails
      address =
          'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      GlobalVariable.location = address!;
      GlobalVariable.latitude = latitude!;
      GlobalVariable.longitude = longitude!;
    }
  }

  Future<void> checkLocationServices() async {
    try {
      isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        errorMessage =
            'Location services are disabled. Please enable location services in your device settings.';
        return;
      }
    } catch (e) {
      errorMessage = 'Error checking location services: $e';
    }
  }

  Future<void> checkLocationPermission() async {
    try {
      locationPermission = await Geolocator.checkPermission();

      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();

        if (locationPermission == LocationPermission.denied) {
          errorMessage =
              'Location permissions are denied. Please grant location permission in app settings.';
          return;
        }
      }

      if (locationPermission == LocationPermission.deniedForever) {
        errorMessage =
            'Location permissions are permanently denied. Please enable location permissions in device settings.';
        return;
      }

      // Clear any previous error messages if permission is granted
      if (locationPermission == LocationPermission.whileInUse ||
          locationPermission == LocationPermission.always) {
        errorMessage = null;
      }
    } catch (e) {
      errorMessage = 'Error checking location permission: $e';
    }
  }

  // Method to manually request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      locationPermission = permission;

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        errorMessage = null;
        return true;
      } else {
        errorMessage =
            'Location permission denied. Please enable location permission in app settings.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error requesting location permission: $e';
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      // First try: High accuracy with short timeout
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5), // Increased timeout slightly
      );

      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;
      errorMessage = null;

      await getAddressFromLatLang(currentPosition);
      return;
    } catch (e) {
      print('Error getting current position (high accuracy): $e');
    }

    try {
      // Second try: Medium accuracy with short timeout
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 3),
      );

      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;
      errorMessage = null;

      await getAddressFromLatLang(currentPosition);
      return;
    } catch (e) {
      print('Error getting current position (medium accuracy): $e');
    }

    try {
      // Third try: Low accuracy (fastest)
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      );

      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;
      errorMessage = null;

      await getAddressFromLatLang(currentPosition);
      return;
    } catch (e) {
      print('Error getting current position (low accuracy): $e');
    }

    try {
      // Fourth try: Last known position (instant, no GPS needed)
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        latitude = lastKnownPosition.latitude;
        longitude = lastKnownPosition.longitude;
        errorMessage = null;

        await getAddressFromLatLang(lastKnownPosition);
        return;
      }
    } catch (e) {
      print('Error getting last known position: $e');
    }

    // If all methods fail, set a default location and continue
    print('All location methods failed, using default location');
    errorMessage = 'Location unavailable. Using default location.';

    // Set default coordinates (you can change these to your office location)
    latitude = 0.0;
    longitude = 0.0;
    address = 'Location: Default coordinates';
    GlobalVariable.location = address!;
    GlobalVariable.latitude = latitude!;
    GlobalVariable.longitude = longitude!;
  }

  Future<void> startLocationStream() async {
    try {
      // Only start stream if we have valid coordinates
      if (latitude == null || longitude == null) {
        print('No valid coordinates available, skipping location stream');
        return;
      }

      streamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 20,
          timeLimit: Duration(seconds: 10),
        ),
      ).listen(
        (Position position) {
          latitude = position.latitude;
          longitude = position.longitude;
          errorMessage = null;
          getAddressFromLatLang(position);
        },
        onError: (error) {
          print('Location stream error: $error');

          // Don't set error message for timeout - just continue with last known location
          if (error is TimeoutException) {
            print('Location timeout - will retry on next interval');
          } else {
            errorMessage = 'Location stream error: $error';
          }

          // Cancel the current stream
          streamSubscription?.cancel();
          streamSubscription = null;

          // Try to restart the stream after a longer delay to avoid tight retry loops
          Future.delayed(const Duration(seconds: 30), () {
            if (isInitialized && streamSubscription == null) {
              print('Restarting location stream...');
              startLocationStream();
            }
          });
        },
        cancelOnError: false, // Don't cancel on error, continue listening
      );
    } catch (e) {
      print('Error starting location stream: $e');
      // Don't set error message - just continue

      // Retry after a delay
      Future.delayed(const Duration(seconds: 10), () {
        if (isInitialized && streamSubscription == null) {
          print('Retrying location stream initialization...');
          startLocationStream();
        }
      });
    }
  }

  void dispose() {
    streamSubscription?.cancel();
    isInitialized = false;
  }

  // Method to manually refresh location
  Future<void> refreshLocation() async {
    try {
      await getCurrentLocation();
      if (latitude != null && longitude != null) {
        await startLocationStream();
      }
    } catch (e) {
      print('Error refreshing location: $e');
      errorMessage = 'Error refreshing location: $e';
    }
  }

  // Getter methods for easy access
  String get currentAddress => address ?? 'Location not available';
  double? get currentLatitude => latitude;
  double? get currentLongitude => longitude;
  bool get hasLocation => latitude != null && longitude != null;
  String? get currentError => errorMessage;
  bool get isLocationAvailable => hasLocation && errorMessage == null;

  // Get location status for UI
  String get locationStatus {
    if (isLocationAvailable) {
      return "Available";
    } else if (hasLocation) {
      return "Available";
    } else if (currentError != null) {
      if (currentError!.contains("Location services are disabled")) {
        return "Fetching";
      } else if (currentError!.contains("permission")) {
        return "Permission Required";
      } else {
        return "Error";
      }
    } else if (!isLocationServiceEnabled) {
      return "Fetching";
    } else if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      return "Permission Required";
    } else if (!isInitialized) {
      return "Fetching";
    } else {
      return "Fetching";
    }
  }

  // Get location status color for UI
  Color get locationStatusColor {
    if (isLocationAvailable || hasLocation) {
      return Colors.green;
    } else if (currentError != null) {
      if (currentError!.contains("Location services are disabled") ||
          currentError!.contains("permission")) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    } else if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      return Colors.orange;
    } else if (!isLocationServiceEnabled) {
      return Colors.orange;
    } else {
      return Colors.blue; // For "Initializing..." and "Checking..." states
    }
  }
}

// Keep the old LocationPage widget for backward compatibility
class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    super.initState();
    LocationService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
