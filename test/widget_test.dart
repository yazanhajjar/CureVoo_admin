import 'package:curevoo_admin/cubits/auth/auth_cubit.dart';
import 'package:curevoo_admin/repos/api_client.dart';
import 'package:curevoo_admin/repos/auth_repo.dart';
import 'package:curevoo_admin/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepo extends AuthRepo {
  _FakeAuthRepo() : super(ApiClient());

  @override
  Future<void> clearSession() async {}
}

void main() {
  testWidgets('Login form shows validation errors when empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthCubit(_FakeAuthRepo()),
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
