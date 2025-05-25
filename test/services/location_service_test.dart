// import 'package:flutter_test/flutter_test.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:stylehub/services/location_service.dart';

// @GenerateMocks([Geolocator, Position])
// void main() {
//   late LocationService locationService;
//   late MockPosition mockPosition;

//   setUp(() {
//     mockPosition = MockPosition();
//     locationService = LocationService();
//   });

//   group('LocationService', () {
//     test('getCurrentLocation returns current position', () async {
//       // Arrange
//       when(Geolocator.getCurrentPosition()).thenAnswer((_) async => mockPosition);

//       // Act
//       final result = await locationService.getCurrentLocation();

//       // Assert
//       expect(result, equals(mockPosition));
//       verify(Geolocator.getCurrentPosition()).called(1);
//     });

//     test('calculateDistance returns correct distance', () {
//       // Arrange
//       const lat1 = 40.7128;
//       const lon1 = -74.0060;
//       const lat2 = 34.0522;
//       const lon2 = -118.2437;

//       when(Geolocator.distanceBetween(lat1, lon1, lat2, lon2)).thenReturn(3935.73); // Distance in kilometers

//       // Act
//       final distance = locationService.calculateDistance(
//         lat1,
//         lon1,
//         lat2,
//         lon2,
//       );

//       // Assert
//       expect(distance, equals(3935.73));
//       verify(Geolocator.distanceBetween(lat1, lon1, lat2, lon2)).called(1);
//     });

//     test('checkLocationPermission returns true when permitted', () async {
//       // Arrange
//       when(Geolocator.checkPermission()).thenAnswer((_) async => LocationPermission.always);

//       // Act
//       final result = await locationService.checkLocationPermission();

//       // Assert
//       expect(result, isTrue);
//       verify(Geolocator.checkPermission()).called(1);
//     });

//     test('formatDistance returns formatted string', () {
//       // Arrange
//       const distanceInMeters = 1500.0;

//       // Act
//       final result = locationService.formatDistance(distanceInMeters);

//       // Assert
//       expect(result, equals('1.5 km'));
//     });
//   });
// }
