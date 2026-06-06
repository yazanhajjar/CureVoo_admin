import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/admin_users/admin_users_cubit.dart';
import '../../cubits/admin_users/admin_users_state.dart';
import '../../models/admin_users/admin_patient_item.dart';
import '../../models/admin_users/admin_patient_requests.dart';
import '../../widgets/admin_style.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersCubit>().loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersCubit, AdminUsersState>(
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          final isError = state.status == AdminUsersStatus.failure;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green.shade700,
              ),
            );
        }
      },
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final isSubmitting = state.status == AdminUsersStatus.submitting;
        final filteredPatients = state.patients.where(_matchesPatientSearch).toList(growable: false);
        return AdminPageScaffold(
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: [cs.primary, cs.secondary.withValues(alpha: 0.85)]),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline, color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Patients', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: cs.primary),
                      onPressed: isSubmitting ? null : () => _openCreatePatientDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Patient'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.people_alt_outlined,
                      label: 'Total Patients',
                      value: '${state.patients.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.place_outlined,
                      label: 'With Location',
                      value: '${state.patients.where((p) => (p.location ?? '').trim().isNotEmpty).length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.wc_outlined,
                      label: 'With Sex',
                      value: '${state.patients.where((p) => (p.sex ?? '').trim().isNotEmpty).length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AdminSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AdminSectionTitle('Patients List'),
                          OutlinedButton.icon(
                            onPressed: state.isLoadingPatients || isSubmitting
                                ? null
                                : () => context.read<AdminUsersCubit>().loadPatients(),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap any row to view full details. Use Edit or Delete from the Actions column.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, location, sex',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.isLoadingPatients)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (filteredPatients.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text('No patients found.')),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                      child: DataTable(
                                        columnSpacing: 24,
                                        showCheckboxColumn: false,
                                        headingRowColor: WidgetStatePropertyAll(
                                          cs.surfaceContainerHighest.withValues(alpha: 0.38),
                                        ),
                                        columns: const [
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('Email')),
                                          DataColumn(label: Text('Age')),
                                          DataColumn(label: Text('Location')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: filteredPatients
                                            .map(
                                              (p) => DataRow(
                                                onSelectChanged: (_) => _showPatientDetails(context, p),
                                                cells: [
                                                  DataCell(Text(p.fullName.isEmpty ? '-' : p.fullName)),
                                                  DataCell(Text(p.email.isEmpty ? '-' : p.email)),
                                                  DataCell(Text(p.age?.toString() ?? '-')),
                                                  DataCell(Text(p.location ?? '-')),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          tooltip: 'Edit',
                                                          onPressed: isSubmitting ? null : () => _openEditPatientDialog(context, p),
                                                          icon: const Icon(Icons.edit_outlined),
                                                        ),
                                                        IconButton(
                                                          tooltip: 'Delete',
                                                          onPressed: isSubmitting ? null : () => _confirmDeletePatient(context, p),
                                                          icon: const Icon(Icons.delete_outline),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(growable: false),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _matchesPatientSearch(AdminPatientItem p) {
    if (_searchQuery.isEmpty) return true;
    final haystack = <String>[
      p.fullName,
      p.email,
      p.location ?? '',
      p.sex ?? '',
      p.phoneNumber ?? '',
      p.age?.toString() ?? '',
    ].join(' ').toLowerCase();
    return haystack.contains(_searchQuery);
  }

  Future<void> _openCreatePatientDialog(BuildContext context) async {
    final result = await showDialog<CreateAdminPatientRequest>(
      context: context,
      builder: (_) => const _CreatePatientDialog(),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminUsersCubit>().createPatient(result);
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

  Future<void> _openEditPatientDialog(BuildContext context, AdminPatientItem patient) async {
    final result = await showDialog<UpdateAdminPatientRequest>(
      context: context,
      builder: (_) => _EditPatientDialog(patient: patient),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminUsersCubit>().updatePatient(patient.id, result);
  }

  void _showPatientDetails(BuildContext context, AdminPatientItem patient) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final dialogMaxHeight = MediaQuery.of(ctx).size.height * 0.86;
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 620,
            constraints: BoxConstraints(maxHeight: dialogMaxHeight),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 20, 14, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer.withValues(alpha: 0.92)]),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName.isEmpty ? 'Patient Details' : patient.fullName,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patient.location ?? 'No location',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _detailsCard(ctx, Icons.badge_outlined, 'ID', patient.id),
                        _detailsCard(ctx, Icons.email_outlined, 'Email', patient.email),
                        _detailsCard(ctx, Icons.phone_outlined, 'Phone', patient.phoneNumber ?? '-'),
                        _detailsCard(ctx, Icons.cake_outlined, 'Age', patient.age?.toString() ?? '-'),
                        _detailsCard(ctx, Icons.wc_outlined, 'Sex', patient.sex ?? '-'),
                        _detailsCard(ctx, Icons.location_on_outlined, 'Location', patient.location ?? '-'),
                        ..._patientProfileCards(ctx, patient.raw),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopMetricCard extends StatelessWidget {
  const _TopMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
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
  bool _isSubmitting = false;

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
          onPressed: _isSubmitting || !_isValid
              ? null
              : () {
                  setState(() => _isSubmitting = true);
            Navigator.pop(
              context,
              CreateAdminPatientRequest(
                email: _email.text.trim(),
                password: _password.text,
                fullName: _fullName.text.trim(),
                phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                age: (() {
                  final parsedAge = int.tryParse(_age.text.trim());
                  if (parsedAge == null) return null;
                  return parsedAge >= 18 && parsedAge <= 120 ? parsedAge : null;
                })(),
              ),
            );
                },
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}

class _EditPatientDialog extends StatefulWidget {
  const _EditPatientDialog({required this.patient});

  final AdminPatientItem patient;

  @override
  State<_EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<_EditPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _age;
  late final TextEditingController _location;
  String _sex = 'FEMALE';
  bool _isSubmitting = false;

  bool get _isValid {
    return _requiredValidator(_fullName.text) == null &&
        _optionalAgeValidator(_age.text) == null;
  }

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.patient.fullName);
    _phone = TextEditingController(text: widget.patient.phoneNumber ?? '');
    _age = TextEditingController(text: widget.patient.age?.toString() ?? '');
    _sex = _normalizeSex(widget.patient.sex);
    _location = TextEditingController(text: widget.patient.location ?? '');
    for (final c in [_fullName, _phone, _age, _location]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _age.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backendErrors = context.select((AdminUsersCubit c) => c.state.validationErrors);
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 620,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer.withValues(alpha: 0.92)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Text('Edit Patient', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            Flexible(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _txtV(_fullName, 'Full Name', validator: (v) => _withBackend(_requiredValidator(v), backendErrors, ['fullName', 'name'])),
                      _txtV(_phone, 'Phone Number', validator: (v) => _withBackend(null, backendErrors, ['phoneNumber'])),
                      _txtV(_age, 'Age', num: true, validator: (v) => _withBackend(_optionalAgeValidator(v), backendErrors, ['age'])),
                      DropdownButtonFormField<String>(
                        value: _sex,
                        decoration: const InputDecoration(labelText: 'Sex'),
                        items: const [
                          DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
                          DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                        ],
                        onChanged: _isSubmitting ? null : (v) => setState(() => _sex = v ?? 'FEMALE'),
                      ),
                      const SizedBox(height: 10),
                      _txtV(_location, 'Location', validator: (v) => _withBackend(null, backendErrors, ['location'])),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSubmitting || !_isValid
                        ? null
                        : () {
                            setState(() => _isSubmitting = true);
                      Navigator.pop(
                        context,
                        UpdateAdminPatientRequest(
                          fullName: _fullName.text.trim().isEmpty ? null : _fullName.text.trim(),
                          phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                          age: int.tryParse(_age.text.trim()),
                          sex: _sex,
                          location: _location.text.trim().isEmpty ? null : _location.text.trim(),
                        ),
                      );
                          },
                    child: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

String? _optionalAgeValidator(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return null;
  final age = int.tryParse(v);
  if (age == null) return 'Age must be a number';
  if (age < 18 || age > 120) return 'Age must be 18-120';
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

String _normalizeSex(String? value) {
  final normalized = (value ?? '').trim().toUpperCase();
  if (normalized == 'MALE' || normalized == 'FEMALE') {
    return normalized;
  }
  return 'FEMALE';
}

Widget _detailsCard(BuildContext context, IconData icon, String label, String value) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              SelectableText(value, style: TextStyle(fontSize: 14, color: cs.onSurface, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );
}

List<Widget> _patientProfileCards(BuildContext context, Map<String, dynamic> raw) {
  final profile = raw['patientProfile'] is Map ? Map<String, dynamic>.from(raw['patientProfile'] as Map) : const <String, dynamic>{};
  final cards = <Widget>[];
  final accountCreatedAt = '${raw['createdAt'] ?? '-'}';
  final accountUpdatedAt = '${raw['updatedAt'] ?? '-'}';
  final profileCreatedAt = '${profile['createdAt'] ?? '-'}';
  final profileUpdatedAt = '${profile['updatedAt'] ?? '-'}';

  if (profile.isNotEmpty) {
    cards.addAll([
      _detailsCard(context, Icons.badge_outlined, 'Profile ID', '${profile['id'] ?? '-'}'),
      _detailsCard(context, Icons.person_outline, 'Full Name', '${profile['fullName'] ?? raw['name'] ?? '-'}'),
    ]);
    if (profileCreatedAt != accountCreatedAt) {
      cards.add(_detailsCard(context, Icons.calendar_today_outlined, 'Profile Created At', profileCreatedAt));
    }
    if (profileUpdatedAt != accountUpdatedAt) {
      cards.add(_detailsCard(context, Icons.update_outlined, 'Profile Updated At', profileUpdatedAt));
    }
  }

  // Show useful account-level fields that usually exist in patient list responses.
  cards.addAll([
    _detailsCard(context, Icons.verified_user_outlined, 'Email Verified', '${raw['isEmailVerified'] ?? '-'}'),
    _detailsCard(context, Icons.access_time_outlined, 'Created At', accountCreatedAt),
    _detailsCard(context, Icons.update_outlined, 'Updated At', accountUpdatedAt),
  ]);

  return cards;
}
