import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_companion/features/auth/domain/repositories/auth_repository.dart';
import 'package:pet_health_companion/features/auth/domain/usecases/sign_in_with_email.dart';

@GenerateMocks([AuthRepository])
import 'sign_in_with_email_test.mocks.dart';

void main() {
  late SignInWithEmail usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithEmail(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  test('should sign in with email through the repository', () async {
    // arrange
    when(mockAuthRepository.signInWithEmail(any, any))
        .thenAnswer((_) async => true);

    // act
    final result = await usecase.execute(tEmail, tPassword);

    // assert
    expect(result, true);
    verify(mockAuthRepository.signInWithEmail(tEmail, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}