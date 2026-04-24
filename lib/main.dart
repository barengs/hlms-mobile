import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/core/config/app_router.dart';
import 'package:hlms_mobile/core/config/app_theme.dart';
import 'package:hlms_mobile/core/network/api_client.dart';
import 'package:hlms_mobile/features/auth/data/auth_repository.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MolangApp());
}

class MolangApp extends StatelessWidget {
  const MolangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ApiClient()),
        RepositoryProvider(
          create: (context) => AuthRepository(context.read<ApiClient>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>())
              ..add(AuthCheckRequested()),
          ),
        ],
        child: MaterialApp.router(
          title: 'MOLANG',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
