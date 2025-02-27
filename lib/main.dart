import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:settings/settings.dart';
import 'package:speed_share/app/controller/chat_controller.dart';
import 'package:speed_share/app/controller/setting_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'android_window.dart';
import 'app/controller/device_controller.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'dynamic_island.dart';
import 'generated/l10n.dart';
import 'global/global.dart';
import 'themes/default_theme_data.dart';
import 'package:file_manager_view/file_manager_view.dart' as fm;
import 'dart:async';

// 初始化hive的设置
Future<void> initSetting() async {
  await initSettingStore(RuntimeEnvir.configPath);
}

// class NoPrint
@pragma('vm:entry-point')
Future<void> androidWindow() async {
  Log.defaultLogger.level = LogLevel.error;
  Log.d("androidWindow");
  Log.v("androidWindow");
  Log.w("androidWindow");
  Log.e("androidWindow");
  Log.i("androidWindow");
  if (!GetPlatform.isWeb && !GetPlatform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    // 拿到应用程序路径
    // get app directory
    final dir = (await getApplicationSupportDirectory()).path;
    RuntimeEnvir.initEnvirWithPackageName(
      Config.packageName,
      appSupportDirectory: dir,
    );
    // 启动文件服务器
    // start file manager server
    fm.Server.start();
  }
  if (!GetPlatform.isWeb) {
    await initSetting();
  }
  Get.put(SettingController());
  Get.put(DeviceController());
  Get.put(ChatController());

  pop = true;
  runApp(const AndroidWindowApp());
  StatusBarUtil.transparent();
}

bool pop = false;
@pragma('vm:entry-point')
void constIsland() {
  pop = true;
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    home: DynamicIsland(),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  StatusBarUtil.transparent();
}

Future<void> main() async {
  if (!GetPlatform.isWeb && !GetPlatform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    // 拿到应用程序路径
    // get app directory
    final dir = (await getApplicationSupportDirectory()).path;
    RuntimeEnvir.initEnvirWithPackageName(
      Config.packageName,
      appSupportDirectory: dir,
    );
    // 启动文件服务器
    // start file manager server
    fm.Server.start();
  }
  Get.config(
    logWriterCallback: (text, {isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  if (!GetPlatform.isWeb) {
    await initSetting();
  }
  Get.put(SettingController());
  Get.put(DeviceController());
  Get.put(ChatController());

  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (!GetPlatform.isIOS) {
        String dir;
        if (!GetPlatform.isWeb) {
          dir = (await getApplicationSupportDirectory()).path;
          RuntimeEnvir.initEnvirWithPackageName(
            Config.packageName,
            appSupportDirectory: dir,
          );
        }
      }
      runApp(const SpeedShare());
    },
    (error, stackTrace) {
      Log.e('未捕捉到的异常 : $error \n$stackTrace');
    },
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('页面构建异常 : ${details.exception}');
  };
  if (GetPlatform.isDesktop) {
    if (!GetPlatform.isWeb) {
      await windowManager.ensureInitialized();
    }
  }
  // 透明状态栏
  // transparent the appbar
  StatusBarUtil.transparent();
  Global().initGlobal();
}

class SpeedShare extends StatelessWidget {
  const SpeedShare({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initRoute = SpeedPages.initial;
    ChatController controller = Get.put(ChatController());
    SettingController settingController = Get.find();
    return ToastApp(
      child: GetBuilder<SettingController>(builder: (context) {
        return GetMaterialApp(
          locale: settingController.currentLocale,
          title: '速享',
          initialRoute: initRoute,
          getPages: SpeedPages.routes,
          defaultTransition: Transition.fadeIn,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) {
            final bool isDark = Theme.of(context).brightness == Brightness.dark;
            final ThemeData theme =
                isDark ? DefaultThemeData.dark() : DefaultThemeData.light();
            return ResponsiveWrapper.builder(
              Builder(
                builder: (context) {
                  if (ResponsiveWrapper.of(context).isDesktop) {
                    ScreenAdapter.init(896);
                  } else {
                    ScreenAdapter.init(414);
                  }
                  return GetBuilder<SettingController>(
                    builder: (context) {
                      return Localizations(
                        locale: context.currentLocale,
                        delegates: const [
                          S.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        child: Theme(
                          data: theme,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              child,
                              DynamicIsland(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // maxWidth: 1200,
              minWidth: 480,
              defaultScale: false,
              breakpoints: const [
                ResponsiveBreakpoint.resize(300, name: MOBILE),
                ResponsiveBreakpoint.autoScale(600, name: TABLET),
                ResponsiveBreakpoint.resize(600, name: DESKTOP),
              ],
            );
          },
        );
      }),
    );
  }
}
