import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/admin_users/admin_users_cubit.dart';
import '../../cubits/admin_users/admin_users_state.dart';
import '../../models/admin_users/admin_doctor_item.dart';
import '../../models/admin_users/admin_doctor_requests.dart';
import '../../models/admin_users/admin_patient_item.dart';
import '../../models/admin_users/admin_patient_requests.dart';
import '../../widgets/admin_style.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminUsersCubit>();
    cubit.loadDoctors();
    cubit.loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersCubit, AdminUsersState>(
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final isDoctors = _tab == 0;

        return AdminPageScaffold(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.supervised_user_circle_outlined, color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Users Management',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cs.primary,
                      ),
                      onPressed: () => isDoctors ? _openCreateDoctorDialog(context) : _openCreatePatientDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text(isDoctors ? 'New Doctor' : 'New Patient'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Doctors')),
                    ButtonSegment(value: 1, label: Text('Patients')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (v) => setState(() => _tab = v.first),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AdminSectionCard(
                  child: isDoctors ? _DoctorsTable(state: state) : _PatientsTable(state: state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCreateDoctorDialog(BuildContext context) async {
    final result = await showDialog<CreateAdminDoctorRequest>(
      context: context,
      builder: (_) => const _CreateDoctorDialog(),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminUsersCubit>().createDoctor(result);
  }

  Future<void> _openCreatePatientDialog(BuildContext context) async {
    final result = await showDialog<CreateAdminPatientRequest>(
      context: context,
      builder: (_) => const _CreatePatientDialog(),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminUsersCubit>().createPatient(result);
  }
}

class _DoctorsTable extends StatelessWidget {
  const _DoctorsTable({required this.state});
  final AdminUsersState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingDoctors) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.doctors.isEmpty) {
      return const Center(child: Text('No doctors found.'));
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Specialization')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.doctors
              .map(
                (d) => DataRow(
                  onSelectChanged: (_) => _showDoctorDetails(context, d),
                  cells: [
                    DataCell(Text(d.fullName.isEmpty ? '-' : d.fullName)),
                    DataCell(Text(d.email.isEmpty ? '-' : d.email)),
                    DataCell(Text((d.specialization ?? '-'))),
                    DataCell(Text((d.location ?? '-'))),
                    DataCell(
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeleteDoctor(context, d),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDoctor(BuildContext context, AdminDoctorItem doctor) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Delete "${doctor.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AdminUsersCubit>().deleteDoctor(doctor.id);
    }
  }

  void _showDoctorDetails(BuildContext context, AdminDoctorItem doctor) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doctor.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${doctor.id}'),
            Text('Email: ${doctor.email}'),
            Text('Phone: ${doctor.phoneNumber ?? '-'}'),
            Text('Specialization: ${doctor.specialization ?? '-'}'),
            Text('Location: ${doctor.location ?? '-'}'),
            Text('Active: ${doctor.isActive?.toString() ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _PatientsTable extends StatelessWidget {
  const _PatientsTable({required this.state});
  final AdminUsersState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingPatients) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.patients.isEmpty) {
      return const Center(child: Text('No patients found.'));
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Age')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.patients
              .map(
                (p) => DataRow(
                  onSelectChanged: (_) => _showPatientDetails(context, p),
                  cells: [
                    DataCell(Text(p.fullName.isEmpty ? '-' : p.fullName)),
                    DataCell(Text(p.email.isEmpty ? '-' : p.email)),
                    DataCell(Text(p.age?.toString() ?? '-')),
                    DataCell(Text(p.location ?? '-')),
                    DataCell(
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeletePatient(context, p),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePatient(BuildContext context, AdminPatientItem patient) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Delete "${patient.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AdminUsersCubit>().deletePatient(patient.id);
    }
  }

  void _showPatientDetails(BuildContext context, AdminPatientItem patient) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(patient.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${patient.id}'),
            Text('Email: ${patient.email}'),
            Text('Phone: ${patient.phoneNumber ?? '-'}'),
            Text('Age: ${patient.age?.toString() ?? '-'}'),
            Text('Sex: ${patient.sex ?? '-'}'),
            Text('Location: ${patient.location ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _CreateDoctorDialog extends StatefulWidget {
  const _CreateDoctorDialog();

  @override
  State<_CreateDoctorDialog> createState() => _CreateDoctorDialogState();
}

class _CreateDoctorDialogState extends State<_CreateDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _age = TextEditingController();
  final _specialization = TextEditingController();
  final _workingAt = TextEditingController();
  final _experience = TextEditingController();
  final _location = TextEditingController();
  final _languages = TextEditingController();

  bool get _isValid {
    final age = int.tryParse(_age.text.trim());
    final experience = int.tryParse(_experience.text.trim());
    final languages = _languages.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return _emailValidator(_email.text) == null &&
        _passwordValidator(_password.text) == null &&
        _requiredValidator(_fullName.text) == null &&
        _requiredValidator(_phone.text) == null &&
        _requiredValidator(_specialization.text) == null &&
        _requiredValidator(_workingAt.text) == null &&
        _requiredValidator(_location.text) == null &&
        age != null &&
        age >= 18 &&
        age <= 120 &&
        experience != null &&
        languages.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_email, _password, _fullName, _phone, _age, _specialization, _workingAt, _experience, _location, _languages]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_email, _password, _fullName, _phone, _age, _specialization, _workingAt, _experience, _location, _languages]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backendErrors = context.select((AdminUsersCubit c) => c.state.validationErrors);
    return AlertDialog(
      title: const Text('Create Doctor'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _txtV(_email, 'Email', validator: (v) => _withBackend(_emailValidator(v), backendErrors, ['email'])),
                _txtV(_password, 'Password', validator: (v) => _withBackend(_passwordValidator(v), backendErrors, ['password'])),
                _txtV(_fullName, 'Full Name', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['fullName', 'name'])),
                _txtV(_phone, 'Phone Number', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['phoneNumber'])),
                _txtV(_age, 'Age', num: true, validator: (v) => _withBackend(_ageValidator(v), backendErrors, ['age'])),
                _txtV(_specialization, 'Specialization', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['specialization'])),
                _txtV(_workingAt, 'Workplace', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['workplace', 'workingAt'])),
                _txtV(_experience, 'Experience (years)', num: true, validator: (v) => _withBackend(_experienceValidator(v), backendErrors, ['experience'])),
                _txtV(_location, 'Location', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['location'])),
                _txtV(_languages, 'Languages comma-separated', validator: (v) => _withBackend(_languagesValidator(v), backendErrors, ['languages'])),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isValid
              ? () {
            final age = int.tryParse(_age.text.trim());
            final experience = int.tryParse(_experience.text.trim());
            final languages = _languages.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(growable: false);

            final request = CreateAdminDoctorRequest(
              email: _email.text.trim(),
              password: _password.text,
              fullName: _fullName.text.trim(),
              phoneNumber: _phone.text.trim(),
              age: age!,
              specialization: _specialization.text.trim(),
              workingAt: _workingAt.text.trim(),
              experience: experience!,
              location: _location.text.trim(),
              languages: languages,
            );
            Navigator.pop(context, request);
          }
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _CreatePatientDialog extends StatefulWidget {
  const _CreatePatientDialog();

  @override
  State<_CreatePatientDialog> createState() => _CreatePatientDialogState();
}

class _CreatePatientDialogState extends State<_CreatePatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _age = TextEditingController();

  bool get _isValid {
    final ageText = _age.text.trim();
    final age = ageText.isEmpty ? null : int.tryParse(ageText);
    final ageOk = ageText.isEmpty || (age != null && age >= 18 && age <= 120);
    return _emailValidator(_email.text) == null &&
        _passwordValidator(_password.text) == null &&
        _requiredValidator(_fullName.text) == null &&
        ageOk;
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_email, _password, _fullName, _phone, _age]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_email, _password, _fullName, _phone, _age]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backendErrors = context.select((AdminUsersCubit c) => c.state.validationErrors);
    return AlertDialog(
      title: const Text('Create Patient'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _txtV(_email, 'Email', validator: (v) => _withBackend(_emailValidator(v), backendErrors, ['email'])),
                _txtV(_password, 'Password', validator: (v) => _withBackend(_passwordValidator(v), backendErrors, ['password'])),
                _txtV(_fullName, 'Full Name', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['fullName', 'name'])),
                _txtV(_phone, 'Phone Number (optional)'),
                _txtV(_age, 'Age (optional)', num: true, validator: (v) => _withBackend(_optionalAgeValidator(v), backendErrors, ['age'])),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isValid
              ? () {
            final parsedAge = int.tryParse(_age.text.trim());
            final age = (parsedAge != null && parsedAge >= 18 && parsedAge <= 120) ? parsedAge : null;
            final request = CreateAdminPatientRequest(
              email: _email.text.trim(),
              password: _password.text,
              fullName: _fullName.text.trim(),
              phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              age: age,
            );
            Navigator.pop(context, request);
          }
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

Widget _txtV(
  TextEditingController c,
  String label, {
  bool num = false,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: c,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

String? _requiredValidator(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Required field';
  return null;
}

String? _emailValidator(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Email is required';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  if (!ok) return 'Invalid email';
  return null;
}

String? _passwordValidator(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Password is required';
  if (v.length < 12) return 'Min 12 characters';
  if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must include uppercase';
  if (!RegExp(r'[a-z]').hasMatch(v)) return 'Must include lowercase';
  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must include number';
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) return 'Must include symbol';
  return null;
}

String? _ageValidator(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Age is required';
  final age = int.tryParse(v);
  if (age == null) return 'Age must be a number';
  if (age < 18 || age > 120) return 'Age must be 18-120';
  return null;
}

String? _optionalAgeValidator(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return null;
  final age = int.tryParse(v);
  if (age == null) return 'Age must be a number';
  if (age < 18 || age > 120) return 'Age must be 18-120';
  return null;
}

String? _experienceValidator(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Experience is required';
  final ex = int.tryParse(v);
  if (ex == null) return 'Experience must be a number';
  return null;
}

String? _languagesValidator(String? value) {
  final items = (value ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (items.isEmpty) return 'Provide at least one language';
  return null;
}

String? _withBackend(String? localError, Map<String, String> backendErrors, List<String> keys) {
  if (localError != null) return localError;
  for (final key in keys) {
    final message = backendErrors[key];
    if (message != null && message.trim().isNotEmpty) return message;
  }
  return null;
}
