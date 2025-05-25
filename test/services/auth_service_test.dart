// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:stylehub/services/auth_service.dart';

// @GenerateMocks([FirebaseAuth, UserCredential, User])
// void main() {
//   late AuthService authService;
//   late MockFirebaseAuth mockFirebaseAuth;
//   late MockUserCredential mockUserCredential;
//   late MockUser mockUser;

//   setUp(() {
//     mockFirebaseAuth = MockFirebaseAuth();
//     mockUserCredential = MockUserCredential();
//     mockUser = MockUser();
//     authService = AuthService(firebaseAuth: mockFirebaseAuth);
//   });

//   group('AuthService', () {
//     test('sign in with email and password', () async {
//       // Arrange
//       when(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: 'test@example.com',
//         password: 'password123',
//       )).thenAnswer((_) async => mockUserCredential);
      
//       when(mockUserCredential.user).thenReturn(mockUser);

//       // Act
//       final result = await authService.signInWithEmailAndPassword(
//         'test@example.com',
//         'password123',
//       );

//       // Assert
//       expect(result, equals(mockUserCredential));
//       verify(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: 'test@example.com',
//         password: 'password123',
//       )).called(1);
//     });

//     test('sign up with email and password', () async {
//       // Arrange
//       when(mockFirebaseAuth.createUserWithEmailAndPassword(
//         email: 'test@example.com',
//         password: 'password123',
//       )).thenAnswer((_) async => mockUserCredential);

//       // Act
//       final result = await authService.signUpWithEmailAndPassword(
//         'test@example.com',
//         'password123',
//       );

//       // Assert
//       expect(result, equals(mockUserCredential));
//       verify(mockFirebaseAuth.createUserWithEmailAndPassword(
//         email: 'test@example.com',
//         password: 'password123',
//       )).called(1);
//     });

//     test('sign out', () async {
//       // Act
//       await authService.signOut();

//       // Assert
//       verify(mockFirebaseAuth.signOut()).called(1);
//     });

//     test('get current user', () {
//       // Arrange
//       when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

//       // Act
//       final result = authService.currentUser;

//       // Assert
//       expect(result, equals(mockUser));
//       verify(mockFirebaseAuth.currentUser).called(1);
//     });
//   });
// } 