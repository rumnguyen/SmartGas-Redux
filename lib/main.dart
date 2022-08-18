import 'package:anpha_petrol_smartgas/core/code_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/network/server_endpoint.dart';
import 'package:anpha_petrol_smartgas/core/storage/hive_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/notification_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/pages/home/home_screen.dart';
import 'package:anpha_petrol_smartgas/pages/signin/sign_in_page.dart';
import 'package:anpha_petrol_smartgas/providers/providers.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/loading_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

typedef ShowDialogFunction = Future<void> Function(BuildContext context);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
GlobalKey<SmartGasAppState> _appGlobalKey = GlobalKey();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const String appName = "SmartGas";

NotificationAppLaunchDetails? notificationAppLaunchDetails;
bool isAppRunning = false;
Widget? nextScreenAfterInit;
ShowDialogFunction? showPopupFunc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Crashlytics
  await initializeCrashlytics(enableInDevMode: true);
  /**
   * Initialize local notification here
   * */
  await NotificationUtils.initializeLocalNotification();

  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.black.withOpacity(0.2)),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((res) {
    runApp(SmartGasApp());
  });
}

class SmartGasApp extends StatefulWidget {
  SmartGasApp() : super(key: _appGlobalKey);

  static _restart() {
    showPopupFunc = null;
    nextScreenAfterInit = null;
    _appGlobalKey.currentState?.restart();
  }

  static restartApp(String sysCode) async {
    switch (sysCode) {
      case "":
        _restart();
        return;
      case LOG_OUT:
        RUser.logout();
        _restart();
        return;
      case ACCESS_DENY:
        RUser.logout();
        _restart();
        return;
      case MAINTENANCE:
        _restart();
        return;
      case FORCE_UPDATE:
        RUser.logout();
        _restart();
        return;
      default:
        return;
    }
  }

  @override
  SmartGasAppState createState() => SmartGasAppState();
}

class SmartGasAppState extends State<SmartGasApp> {
  void restart() {
    setState(() {
      navigatorKey = GlobalKey<NavigatorState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: globalProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('vi'), // Vietnamese
        ],
        title: appName,
        theme: ThemeData(
          fontFamily: 'Lexend',
          primaryColor: Colors.white,
          //brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
        ),
        home: const SplashPage(),
      ),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<StatefulWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _initPage());
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    // size on vsmart live 4
    //double standardDeviceHeight = 732.0;
    //double boxPadding = size.height * 190 / standardDeviceHeight;
    String? locale = Intl.defaultLocale;
    if (locale == null || locale.isEmpty) {
      locale = Intl.systemLocale.split("_")[0];
    } else {
      locale = Intl.defaultLocale!.split("_")[0];
    }
    String pleaseWait;
    // if (locale.contains('vi') == true) {
    pleaseWait = "";
    // } else {
    //   pleaseWait = "Please wait...";
    // }

    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: ImageCacheManager.getImage(
                    url: GlobalManager.images.appLogo,
                    width: 200,
                    height: 75,
                  ),
                ),
              ),
              LoadingIndicator(color: GlobalManager.colors.colorAccent),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                pleaseWait,
                textScaleFactor: 1.0,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: GlobalManager.colors.majorColor(),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ));
  }

  Future<void> _initPage() async {
    await initializeConfigs(context);

    // if (hasSelectedLanguageFirstTime()) {
    await loadCurrentLanguage();
    // }

    Future.delayed(
      const Duration(milliseconds: 2500),
      () => openStartPage(),
    );
  }

  void openStartPage() async {
    // if (hasSelectedLanguageFirstTime()) {

    String? userToken = await HiveManager.getUserToken();
    if (checkStringNullOrEmpty(userToken)) {
      ServerEndpoint();
      showPage(context, const SignInPage());
    } else {
      isAppRunning = true;
      await initAppRoleAndEndpoint();
      showPage(context, const HomeScreen());
      if (nextScreenAfterInit != null || showPopupFunc != null) {
        showNextScreenAfterInit();
      }
    }
    // } else {
    //   await RUser.getLoginFeatures();
    //   RUser.logout();
    //   showPage(context, SelectLanguagePage());
    // }
  }

  Future<void> showNextScreenAfterInit() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () async {
        if (showPopupFunc != null) {
          await showPopupFunc!(context);
        } else if (nextScreenAfterInit != null) {
          await pushPageWithNavState(nextScreenAfterInit!);
        }
        nextScreenAfterInit = null;
        showPopupFunc = null;
      },
    );
  }
}
