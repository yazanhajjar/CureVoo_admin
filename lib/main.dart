import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/accounts/accounts_cubit.dart';
import 'cubits/admin_users/admin_users_cubit.dart';
import 'cubits/ai/ai_cubit.dart';
import 'cubits/articles/articles_cubit.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/notifications/notifications_cubit.dart';
import 'repos/main_repo.dart';
import 'screens/app_view.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_controller_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mainRepo = MainRepo.create();
  final themeController = await ThemeController.create();
  runApp(CurevooAdminApp(mainRepo: mainRepo, themeController: themeController));
}

class CurevooAdminApp extends StatelessWidget {
  const CurevooAdminApp({
    super.key,
    required this.mainRepo,
    required this.themeController,
  });

  final MainRepo mainRepo;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: mainRepo),
        RepositoryProvider.value(value: mainRepo.authRepo),
        RepositoryProvider.value(value: mainRepo.accountsRepo),
        RepositoryProvider.value(value: mainRepo.adminUsersRepo),
        RepositoryProvider.value(value: mainRepo.articlesRepo),
        RepositoryProvider.value(value: mainRepo.notificationsRepo),
        RepositoryProvider.value(value: mainRepo.aiRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(context.read())..initialize()),
          BlocProvider(create: (context) => AccountsCubit(context.read())),
          BlocProvider(create: (context) => AdminUsersCubit(context.read())),
          BlocProvider(create: (context) => ArticlesCubit(context.read())),
          BlocProvider(create: (context) => NotificationsCubit(context.read())),
          BlocProvider(create: (context) => AiCubit(context.read())),
        ],
        child: ThemeControllerScope(
          controller: themeController,
          child: AnimatedBuilder(
            animation: themeController,
            builder: (context, _) => MaterialApp(
              title: 'Curevoo Admin',
              theme: MyTheme.lightTheme,
              darkTheme: MyTheme.darkTheme,
              themeMode: themeController.themeMode,
              debugShowCheckedModeBanner: false,
              home: const AppView(),
            ),
          ),
        ),
      ),
    );
  }
}
