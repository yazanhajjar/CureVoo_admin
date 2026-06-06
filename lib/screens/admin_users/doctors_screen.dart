import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/admin_users/admin_users_cubit.dart';
import '../../cubits/admin_users/admin_users_state.dart';
import '../../models/admin_users/admin_doctor_item.dart';
import '../../models/admin_users/admin_doctor_requests.dart';
import '../../widgets/admin_style.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersCubit>().loadDoctors();
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
        final filteredDoctors = state.doctors.where(_matchesDoctorSearch).toList(growable: false);
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
                    const Icon(Icons.medical_services_outlined, color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Doctors', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: cs.primary),
                      onPressed: isSubmitting ? null : () => _openCreateDoctorDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Doctor'),
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
                      label: 'Total Doctors',
                      value: '${state.doctors.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.medical_information_outlined,
                      label: 'With Specialty',
                      value: '${state.doctors.where((d) => (d.specialization ?? '').trim().isNotEmpty).length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.place_outlined,
                      label: 'With Location',
                      value: '${state.doctors.where((d) => (d.location ?? '').trim().isNotEmpty).length}',
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
                          const AdminSectionTitle('Doctors List'),
                          OutlinedButton.icon(
                            onPressed: state.isLoadingDoctors || isSubmitting
                                ? null
                                : () => context.read<AdminUsersCubit>().loadDoctors(),
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
                          hintText: 'Search by name, email, specialization, location',
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
                      if (state.isLoadingDoctors)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (filteredDoctors.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text('No doctors found.')),
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
                                          DataColumn(label: Text('Specialization')),
                                          DataColumn(label: Text('Location')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: filteredDoctors
                                            .map(
                                              (d) => DataRow(
                                                onSelectChanged: (_) => _showDoctorDetails(context, d),
                                                cells: [
                                                  DataCell(Text(d.fullName.isEmpty ? '-' : d.fullName)),
                                                  DataCell(Text(d.email.isEmpty ? '-' : d.email)),
                                                  DataCell(Text(d.specialization ?? '-')),
                                                  DataCell(Text(d.location ?? '-')),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          tooltip: 'Edit',
                                                          onPressed: isSubmitting ? null : () => _openEditDoctorDialog(context, d),
                                                          icon: const Icon(Icons.edit_outlined),
                                                        ),
                                                        IconButton(
                                                          tooltip: 'Delete',
                                                          onPressed: isSubmitting ? null : () => _confirmDeleteDoctor(context, d),
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

  bool _matchesDoctorSearch(AdminDoctorItem d) {
    if (_searchQuery.isEmpty) return true;
    final haystack = <String>[
      d.fullName,
      d.email,
      d.specialization ?? '',
      d.location ?? '',
      d.phoneNumber ?? '',
    ].join(' ').toLowerCase();
    return haystack.contains(_searchQuery);
  }

  Future<void> _openCreateDoctorDialog(BuildContext context) async {
    final result = await showDialog<CreateAdminDoctorRequest>(
      context: context,
      builder: (_) => const _CreateDoctorDialog(),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminUsersCubit>().createDoctor(result);
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

  Future<void> _openEditDoctorDialog(BuildContext context, AdminDoctorItem doctor) async {
    final result = await showDialog<UpdateAdminDoctorRequest>(
      context: context,
      builder: (_) => _EditDoctorDialog(doctor: doctor),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminUsersCubit>().updateDoctor(doctor.id, result);
  }

  void _showDoctorDetails(BuildContext context, AdminDoctorItem doctor) {
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
                        child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.fullName.isEmpty ? 'Doctor Details' : doctor.fullName,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization ?? 'No specialization',
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
                        _detailsCard(ctx, Icons.badge_outlined, 'ID', doctor.id),
                        _detailsCard(ctx, Icons.email_outlined, 'Email', doctor.email),
                        _detailsCard(ctx, Icons.phone_outlined, 'Phone', doctor.phoneNumber ?? '-'),
                        _detailsCard(ctx, Icons.work_outline, 'Specialization', doctor.specialization ?? '-'),
                        _detailsCard(ctx, Icons.location_on_outlined, 'Location', doctor.location ?? '-'),
                        _detailsCard(ctx, Icons.verified_user_outlined, 'Active', doctor.isActive?.toString() ?? '-'),
                        ..._doctorProfileCards(ctx, doctor.raw),
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
  bool _isSubmitting = false;

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
          onPressed: _isSubmitting || !_isValid
              ? null
              : () {
                  final age = int.tryParse(_age.text.trim());
                  final experience = int.tryParse(_experience.text.trim());
                  final languages = _languages.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(growable: false);

                  setState(() => _isSubmitting = true);
            Navigator.pop(
              context,
              CreateAdminDoctorRequest(
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

class _EditDoctorDialog extends StatefulWidget {
  const _EditDoctorDialog({required this.doctor});

  final AdminDoctorItem doctor;

  @override
  State<_EditDoctorDialog> createState() => _EditDoctorDialogState();
}

class _EditDoctorDialogState extends State<_EditDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phoneNumber;
  late final TextEditingController _age;
  late final TextEditingController _specialization;
  late final TextEditingController _workingAt;
  late final TextEditingController _location;
  late final TextEditingController _languages;
  late final TextEditingController _qualifications;
  late final TextEditingController _experience;
  late final TextEditingController _bio;
  late final TextEditingController _photoUrl;
  late final TextEditingController _consultationFee;
  bool _isSubmitting = false;

  bool get _isValid {
    return _requiredValidator(_fullName.text) == null &&
        _optionalAgeValidator(_age.text) == null &&
        _optionalIntValidator(_experience.text, field: 'Experience') == null &&
        _optionalDoubleValidator(_consultationFee.text, field: 'Consultation fee') == null &&
        _optionalLanguagesValidator(_languages.text) == null;
  }

  @override
  void initState() {
    super.initState();
    final profile = widget.doctor.raw['doctorProfile'] is Map
        ? Map<String, dynamic>.from(widget.doctor.raw['doctorProfile'] as Map)
        : const <String, dynamic>{};
    _fullName = TextEditingController(text: widget.doctor.fullName);
    _phoneNumber = TextEditingController(text: widget.doctor.phoneNumber ?? '');
    _age = TextEditingController(text: '${widget.doctor.raw['age'] ?? ''}');
    _specialization = TextEditingController(text: widget.doctor.specialization ?? '');
    _workingAt = TextEditingController(text: '${profile['workingAt'] ?? ''}');
    _location = TextEditingController(text: widget.doctor.location ?? '');
    _languages = TextEditingController(text: _listToText(profile['languages']));
    _qualifications = TextEditingController(text: '${profile['qualifications'] ?? ''}');
    _experience = TextEditingController(text: '${profile['experience'] ?? ''}');
    _bio = TextEditingController(text: '${profile['bio'] ?? ''}');
    _photoUrl = TextEditingController(text: '${profile['photoUrl'] ?? ''}');
    _consultationFee = TextEditingController(text: '${profile['consultationFee'] ?? ''}');
    for (final c in [
      _fullName,
      _phoneNumber,
      _age,
      _specialization,
      _workingAt,
      _location,
      _languages,
      _qualifications,
      _experience,
      _bio,
      _photoUrl,
      _consultationFee,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phoneNumber.dispose();
    _age.dispose();
    _specialization.dispose();
    _workingAt.dispose();
    _location.dispose();
    _languages.dispose();
    _qualifications.dispose();
    _experience.dispose();
    _bio.dispose();
    _photoUrl.dispose();
    _consultationFee.dispose();
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
              child: const Text('Edit Doctor', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
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
                      _txtV(_phoneNumber, 'Phone Number', validator: (v) => _withBackend(null, backendErrors, ['phoneNumber'])),
                      _txtV(_age, 'Age', num: true, validator: (v) => _withBackend(_optionalAgeValidator(v), backendErrors, ['age'])),
                      _txtV(_specialization, 'Specialization', validator: (v) => _withBackend(null, backendErrors, ['specialization'])),
                      _txtV(_workingAt, 'Working At', validator: (v) => _withBackend(null, backendErrors, ['workplace', 'workingAt'])),
                      _txtV(_location, 'Location', validator: (v) => _withBackend(null, backendErrors, ['location'])),
                      _txtV(_languages, 'Languages (comma-separated)', validator: (v) => _withBackend(_optionalLanguagesValidator(v), backendErrors, ['languages'])),
                      _txtV(_qualifications, 'Qualifications'),
                      _txtV(_experience, 'Experience', num: true, validator: (v) => _withBackend(_optionalIntValidator(v, field: 'Experience'), backendErrors, ['experience'])),
                      _txtV(_bio, 'Bio'),
                      _txtV(_photoUrl, 'Photo URL'),
                      _txtV(
                        _consultationFee,
                        'Consultation Fee',
                        num: true,
                        validator: (v) => _optionalDoubleValidator(v, field: 'Consultation fee'),
                      ),
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
                        UpdateAdminDoctorRequest(
                          fullName: _fullName.text.trim().isEmpty ? null : _fullName.text.trim(),
                          phoneNumber: _phoneNumber.text.trim().isEmpty ? null : _phoneNumber.text.trim(),
                          age: int.tryParse(_age.text.trim()),
                          specialization: _specialization.text.trim().isEmpty ? null : _specialization.text.trim(),
                          workingAt: _workingAt.text.trim().isEmpty ? null : _workingAt.text.trim(),
                          location: _location.text.trim().isEmpty ? null : _location.text.trim(),
                          languages: _languages.text.trim().isEmpty
                              ? null
                              : _languages.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false),
                          qualifications: _qualifications.text.trim().isEmpty ? null : _qualifications.text.trim(),
                          experience: int.tryParse(_experience.text.trim()),
                          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
                          photoUrl: _photoUrl.text.trim().isEmpty ? null : _photoUrl.text.trim(),
                          consultationFee: double.tryParse(_consultationFee.text.trim()),
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

String? _optionalAgeValidator(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return null;
  final age = int.tryParse(v);
  if (age == null) return 'Age must be a number';
  if (age < 18 || age > 120) return 'Age must be 18-120';
  return null;
}

String? _optionalIntValidator(String? value, {required String field}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return null;
  if (int.tryParse(v) == null) return '$field must be a number';
  return null;
}

String? _optionalDoubleValidator(String? value, {required String field}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return null;
  if (double.tryParse(v) == null) return '$field must be a number';
  return null;
}

String? _optionalLanguagesValidator(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return null;
  final items = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (items.isEmpty) return 'Provide at least one language';
  return null;
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

List<Widget> _doctorProfileCards(BuildContext context, Map<String, dynamic> raw) {
  final profile = raw['doctorProfile'] is Map ? Map<String, dynamic>.from(raw['doctorProfile'] as Map) : const <String, dynamic>{};
  if (profile.isEmpty) return const <Widget>[];
  return <Widget>[
    _detailsCard(context, Icons.business_outlined, 'Working At', '${profile['workingAt'] ?? '-'}'),
    _detailsCard(context, Icons.language_outlined, 'Languages', _listToText(profile['languages'])),
    _detailsCard(context, Icons.workspace_premium_outlined, 'Qualifications', '${profile['qualifications'] ?? '-'}'),
    _detailsCard(context, Icons.timeline_outlined, 'Experience', '${profile['experience'] ?? '-'}'),
    _detailsCard(context, Icons.info_outline, 'Bio', '${profile['bio'] ?? '-'}'),
    _detailsCard(context, Icons.image_outlined, 'Photo URL', '${profile['photoUrl'] ?? '-'}'),
    _detailsCard(context, Icons.payments_outlined, 'Consultation Fee', '${profile['consultationFee'] ?? '-'}'),
    _detailsCard(context, Icons.qr_code_2_outlined, 'QR Code', '${profile['qrCode'] ?? '-'}'),
    _detailsCard(context, Icons.fingerprint_outlined, 'Profile ID', '${profile['id'] ?? '-'}'),
  ];
}

String _listToText(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).join(', ');
  return '${value ?? '-'}';
}
