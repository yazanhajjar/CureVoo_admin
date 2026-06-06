import 'package:curevoo_admin/cubits/admin_users/admin_users_cubit.dart';
import 'package:curevoo_admin/models/admin_users/admin_patient_item.dart';
import 'package:curevoo_admin/repos/admin_users_repo.dart';
import 'package:curevoo_admin/repos/api_client.dart';
import 'package:curevoo_admin/screens/admin_users/patients_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminUsersRepo extends AdminUsersRepo {
  _FakeAdminUsersRepo({required this.patients}) : super(ApiClient());

  final List<AdminPatientItem> patients;

  @override
  Future<List<AdminPatientItem>> fetchPatients() async => patients;
}

void main() {
  testWidgets('Patient details dialog de-duplicates created/updated timestamps', (tester) async {
    const timestamp = '2026-05-15T12:00:00.000Z';
    final patient = AdminPatientItem.fromJson(<String, dynamic>{
      'id': 'p1',
      'email': 'patient@example.com',
      'fullName': 'Patient One',
      'createdAt': timestamp,
      'updatedAt': timestamp,
      'patientProfile': <String, dynamic>{
        'id': 'pp1',
        'fullName': 'Patient One',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      },
    });
    final cubit = AdminUsersCubit(_FakeAdminUsersRepo(patients: <AdminPatientItem>[patient]));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const PatientsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patient One').first);
    await tester.pumpAndSettle();

    expect(find.text('Created At'), findsOneWidget);
    expect(find.text('Updated At'), findsOneWidget);
    expect(find.text('Profile Created At'), findsNothing);
    expect(find.text('Profile Updated At'), findsNothing);

    await cubit.close();
  });
}
