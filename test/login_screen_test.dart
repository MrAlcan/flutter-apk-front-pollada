import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pollada/core/storage/secure_token_storage.dart';
import 'package:pollada/features/auth/presentation/screens/login_screen.dart';

/// Fake en memoria: en los tests no existe el plugin nativo de Keystore.
class _MemoryTokenStorage extends SecureTokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(_MemoryTokenStorage()),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('muestra la marca y el formulario', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Mundial Polla'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Entrar al estadio'), findsOneWidget);
  });

  testWidgets('valida campos vacíos al enviar', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Entrar al estadio'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Escribe tu email'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
  });

  testWidgets('valida formato de email mientras se escribe', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byType(TextFormField).first, 'no-es-email');
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Ese email no parece válido'), findsOneWidget);
  });
}
