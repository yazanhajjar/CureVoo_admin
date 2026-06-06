// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/articles/articles_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../widgets/admin_style.dart';
import '../admin_users/doctors_screen.dart';
import '../admin_users/patients_screen.dart';
import '../articles/articles_screen.dart';
import '../../theme/theme_controller_scope.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ArticlesCubit>().loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('lib/images/curvoo.jpg', height: 32)),
            const SizedBox(width: 12),
            const Text('Curevoo Admin'),
          ],
        ),
        actions: const [SizedBox(width: 8)],
      ),
      drawer: isMobile
          ? Drawer(child: _buildNav(context, isDrawer: true))
          : null,
      body: AdminPageScaffold(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (!isMobile)
              SizedBox(
                width: 250,
                child: AdminSectionCard(
                  padding: const EdgeInsets.all(12),
                  child: _buildNav(context),
                ),
              ),
            if (!isMobile) const SizedBox(width: 14),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DoctorsScreen();
      case 1:
        return const PatientsScreen();
      case 2:
        return const ArticlesScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNav(BuildContext context, {bool isDrawer = false}) {
    final email = context.select((AuthCubit c) => c.state.session?.email ?? '');
    final themeController = ThemeControllerScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDrawer)
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: AdminSectionTitle('Navigation'),
          ),
        _navTile(context, 0, Icons.medical_services_outlined, 'Doctors'),
        _navTile(context, 1, Icons.people_outline, 'Patients'),
        _navTile(context, 2, Icons.article_outlined, 'Articles'),
        const Spacer(),
        if (email.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            ),
            child: Row(
              children: [
                Icon(Icons.alternate_email, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: themeController,
          builder: (_, __) => SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: themeController.toggleTheme,
              icon: Icon(themeController.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18),
              label: Text(themeController.isDarkMode ? 'Light Mode' : 'Dark Mode'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  Widget _navTile(
    BuildContext context,
    int index,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    final selected = _selectedIndex == index;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: selected
            ? cs.primaryContainer.withOpacity(0.7)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        selected: selected,
        onTap: () {
          onTap?.call();
          _select(context, index);
        },
      ),
    );
  }

  void _select(BuildContext context, int index) {
    setState(() => _selectedIndex = index);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}
