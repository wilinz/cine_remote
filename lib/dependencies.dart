import 'dart:async';

import 'package:camera_control_dart/camera_control_dart.dart';
import 'package:cine_remote/adapter/wifi_info_adapter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart' as logger_impl;

import 'logging/camera_control_logger.dart';
import 'presentation/core/adapter/date_time_adapter.dart';
import 'presentation/features/camera_connection/bloc/camera_connection_cubit.dart';
import 'presentation/features/camera_pairing/bloc/camera_pairing_cubit.dart';
import 'presentation/features/camera_selection/bloc/camera_discovery_cubit.dart';
import 'presentation/features/recent_cameras/bloc/recent_cameras_cubit.dart';
import 'presentation/features/recent_cameras/repository/recent_cameras_repository.dart';

void registerDependencies() {
  factory<DateTimeAdapter>(() => const DateTimeAdapter());
  singleton<HiveAdapter>(() => const HiveAdapter());
  singleton<RecentCamerasRepostitory>(() => RecentCamerasRepostitory(
        get<HiveAdapter>(),
        get<DateTimeAdapter>(),
      ));

  factory<CameraConnectionCubit>(() => CameraConnectionCubit(
        cameraFactoryProvider: const CameraFactoryProvider(),
        recentCamerasRepostitory: get<RecentCamerasRepostitory>(),
      ));
  factory<CameraDiscoveryCubit>(() => CameraDiscoveryCubit(
      CameraDiscoveryService(wifiInfoAdapter: WifiInfoAdapterImpl())));
  factory<CameraPairingCubit>(() => CameraPairingCubit(
        const CameraFactoryProvider(),
        get<RecentCamerasRepostitory>(),
      ));
  factory<RecentCamerasCubit>(
      () => RecentCamerasCubit(get<RecentCamerasRepostitory>()));
}

Future<void> setup() async {
  await setupFirebase();
  setupCrashReporting();

  registerDependencies();

  setupLogging();
  await setupHive();
}

Future<void> setupFirebase() async {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
}

void setupCrashReporting() {
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
}

void setupLogging() {
  CameraControlLoggerConfig.init(
      logger: CameraControlLoggerImpl(),
      enabledTopics: [
        // const EosPtpTransactionQueueTopic(),
        // const EosPtpIpDiscoveryTopic(),
      ]);

  logger_impl.Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

Future<void> setupHive() => get<HiveAdapter>().init();

T get<T extends Object>({dynamic param1, dynamic param2}) {
  if (GetIt.instance.isRegistered<T>()) {
    return GetIt.instance.get<T>(param1: param1, param2: param2);
  }

  throw Exception('get<$T>: not registered');
}

void factory<T extends Object>(T Function() constructor) {
  GetIt.instance.registerFactory<T>(constructor);
}

void singleton<T extends Object>(T Function() constructor,
    [FutureOr<dynamic> Function(T)? dispose]) {
  GetIt.instance.registerLazySingleton<T>(constructor, dispose: dispose);
}
