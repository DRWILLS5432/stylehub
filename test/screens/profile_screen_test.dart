// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:provider/provider.dart';
// import 'package:stylehub/screens/profile_screen.dart';
// import 'package:stylehub/services/auth_service.dart';

// class MockAuthService extends Mock implements AuthService {}

// void main() {
//   late MockAuthService mockAuthService;

//   setUp(() {
//     mockAuthService = MockAuthService();
//   });

//   testWidgets('ProfileScreen shows user information', (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthService.currentUser).thenReturn(
//       TestUser(
//         displayName: 'Test User',
//         email: 'test@example.com',
//         photoURL: 'https://example.com/photo.jpg',
//       ),
//     );

//     // Build our widget
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MultiProvider(
//           providers: [
//             Provider<AuthService>.value(value: mockAuthService),
//           ],
//           child: const ProfileScreen(),
//         ),
//       ),
//     );

//     // Assert
//     expect(find.text('Test User'), findsOneWidget);
//     expect(find.text('test@example.com'), findsOneWidget);
//   });

//   testWidgets('ProfileScreen shows edit button', (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthService.currentUser).thenReturn(
//       TestUser(
//         displayName: 'Test User',
//         email: 'test@example.com',
//       ),
//     );

//     // Build our widget
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MultiProvider(
//           providers: [
//             Provider<AuthService>.value(value: mockAuthService),
//           ],
//           child: const ProfileScreen(),
//         ),
//       ),
//     );

//     // Assert
//     expect(find.byIcon(Icons.edit), findsOneWidget);
//   });

//   testWidgets('ProfileScreen shows loading indicator when loading', (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthService.isLoading).thenReturn(true);

//     // Build our widget
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MultiProvider(
//           providers: [
//             Provider<AuthService>.value(value: mockAuthService),
//           ],
//           child: const ProfileScreen(),
//         ),
//       ),
//     );

//     // Assert
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);
//   });

//   testWidgets('Tapping edit button shows edit dialog', (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthService.currentUser).thenReturn(
//       TestUser(
//         displayName: 'Test User',
//         email: 'test@example.com',
//       ),
//     );

//     // Build our widget
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MultiProvider(
//           providers: [
//             Provider<AuthService>.value(value: mockAuthService),
//           ],
//           child: const ProfileScreen(),
//         ),
//       ),
//     );

//     // Act
//     await tester.tap(find.byIcon(Icons.edit));
//     await tester.pumpAndSettle();

//     // Assert
//     expect(find.text('Edit Profile'), findsOneWidget);
//     expect(find.byType(TextField), findsWidgets);
//   });
// }

// class TestUser {
//   final String? displayName;
//   final String? email;
//   final String? photoURL;

//   TestUser({
//     this.displayName,
//     this.email,
//     this.photoURL,
//   });
// }
