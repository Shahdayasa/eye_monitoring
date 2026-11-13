import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_snackbar.dart';
import 'features/authentication/data/auth_repository.dart';
import 'features/authentication/presentation/auth_provider.dart';
import 'features/device/presentation/ble_provider.dart';
import 'features/history/data/session_repository.dart';
import 'features/history/presentation/session_provider.dart';
import 'features/monitoring/presentation/monitoring_provider.dart';
import 'features/predictions/data/prediction_repository.dart';
import 'features/predictions/presentation/prediction_provider.dart';
import 'services/ble/ble_service.dart';
import 'services/ble/flutter_blue_plus_ble_service.dart';
import 'services/ble/mock_ble_service.dart';
import 'shared/widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConnectivityService()..initialize(),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<BleService>(
          create: (_) => AppConfig.useMockBle
              ? MockBleService()
              : FlutterBluePlusBleService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) => BleProvider(context.read<BleService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => MonitoringProvider(context.read<BleService>()),
        ),
        Provider<SessionRepositoryBase>(
          create: (_) => SessionRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => SessionProvider(
            repository: context.read<SessionRepositoryBase>(),
            bleService: context.read<BleService>(),
          ),
        ),
        Provider<PredictionRepository>(
          create: (_) => PredictionRepository(),
          dispose: (_, repo) => repo.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) => PredictionProvider(
            repository: context.read<PredictionRepository>(),
            monitoringProvider: context.read<MonitoringProvider>(),
            bleProvider: context.read<BleProvider>(),
            authProvider: context.read<AuthProvider>(),
            sessionProvider: context.read<SessionProvider>(),
            sessionRepository: context.read<SessionRepositoryBase>(),
          ),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      authProvider: context.read<AuthProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Eye Monitoring',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.router,
      builder: (context, child) => OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
