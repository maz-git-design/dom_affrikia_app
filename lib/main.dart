// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'database_helper.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //bool isActivated = prefs.getBool("isActivate") ?? false;
//   bool isActivated = false;

//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     title: 'Kiosk Mode',
//     theme: ThemeData(primarySwatch: Colors.blue),
//     home: ActivationScreen(),
//   ));
// }

// class KioskApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Kiosk Mode',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: ActivationScreen(),
//     );
//   }
// }

// class ActivationScreen extends StatefulWidget {
//   @override
//   _ActivationScreenState createState() => _ActivationScreenState();
// }

// class _ActivationScreenState extends State<ActivationScreen> {
//   static const platform = MethodChannel("device_admin");
//   final TextEditingController _codeController = TextEditingController();
//   String _message = "";
//   bool isActivated = false;

//   @override
//   void initState() {
//     super.initState();
//     enableKioskMode();
//     checkActivationStatus();
//   }

//   Future<void> enableKioskMode() async {
//     try {
//       await platform.invokeMethod("enableKioskMode");
//     } catch (e) {
//       print("Error enabling Kiosk Mode: $e");
//     }
//   }

//   Future<void> checkActivationStatus() async {
//     //SharedPreferences prefs = await SharedPreferences.getInstance();
//     // setState(() {

//     //   isActivated = prefs.getBool("isActivated") ?? false;
//     // });
//   }

//   Future<void> checkActivationCode() async {
//     bool exists = await DatabaseHelper().checkCodeExists(_codeController.text);
//     if (exists) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool("isActivated", true);

//       setState(() {
//         _message = "Activation Successful! Exiting Kiosk Mode...";
//         isActivated = true;
//       });

//       // Exit Kiosk Mode (in a real app, you'd call a method to exit)
//       await platform.invokeMethod("disableKioskMode");
//     } else {
//       setState(() {
//         _message = "Invalid Code. Try Again!";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Kiosk Mode Activation")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: isActivated
//             ? Center(child: Text("Device is activated."))
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text("Enter Activation Code:", style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 20),
//                   TextField(
//                     controller: _codeController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: "Enter Code",
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: checkActivationCode,
//                     child: Text("Submit"),
//                   ),
//                   SizedBox(height: 20),
//                   Text(_message, style: TextStyle(color: Colors.red)),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// class AdminPanel extends StatefulWidget {
//   @override
//   _AdminPanelState createState() => _AdminPanelState();
// }

// class _AdminPanelState extends State<AdminPanel> {
//   final TextEditingController _newCodeController = TextEditingController();
//   String _adminMessage = "";

//   Future<void> addActivationCode() async {
//     bool success = await DatabaseHelper().insertCode(_newCodeController.text);
//     setState(() {
//       _adminMessage = success ? "Code Added Successfully!" : "Code Already Exists!";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Admin Panel")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Add New Activation Code:", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 20),
//             TextField(
//               controller: _newCodeController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: "Enter New Code",
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: addActivationCode,
//               child: Text("Add Code"),
//             ),
//             SizedBox(height: 20),
//             Text(_adminMessage, style: TextStyle(color: Colors.green)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:dom_affrikia_app/lock_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'activation_screen.dart';
// import 'connection_panel.dart';
// import 'admin_login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // Future<Widget> checkActivation() async {
//   //   String? code = await getSavedCode(); // Assume you saved code in SharedPreferences
//   //   if (code == null) return ActivationScreen();

//   //   bool expired = await isCycleExpired(code);
//   //   if (expired) {
//   //     return LockScreen(onUnlock: () {
//   //       // You can navigate to ActivationScreen
//   //     });
//   //   } else {
//   //     return HomeScreen(); // your normal screen
//   //   }
//   // }
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Affrikia Device Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeRouter(),
//     );
//   }
// }

// class HomeRouter extends StatefulWidget {
//   @override
//   _HomeRouterState createState() => _HomeRouterState();
// }

// class _HomeRouterState extends State<HomeRouter> {
//   bool isActivated = false;

//   @override
//   void initState() {
//     super.initState();
//     checkActivationStatus();
//   }

//   Future<void> checkActivationStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isActivated = prefs.getBool("isActivated") ?? false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ActivationScreen();
//   }
// }
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:dom_affrikia_app/core/errors/bloc/error_bloc.dart';
import 'package:dom_affrikia_app/core/ui/themes/app_themes.dart';
import 'package:dom_affrikia_app/core/ui/themes/bloc/theme_bloc.dart';
import 'package:dom_affrikia_app/get_imei.dart';
import 'package:dom_affrikia_app/init_download.dart';
import 'package:dom_affrikia_app/init_storage.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/activation_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/about_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/authenticated_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/contract_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/home_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/main_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'injection_container.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) log(change.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(transition.toString());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  WidgetsFlutterBinding.ensureInitialized();

  // initialize instances
  init();

  //await stopService();

  sl<MainDataProvider>().androidDeviceInfo = await sl<DeviceInfoPlugin>().androidInfo;
  await initImei();
  //PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //log("App version: $packageInfo");

  //sl<FlutterSecureStorage>().deleteAll();
  // init storage
  await initStorage();
  await initDownload();

  //initBackgroundTask();
  FlutterForegroundTask.initCommunicationPort();

  // // Local notification initialization
  // const AndroidInitializationSettings initializationSettingsAndroid =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');

  // const InitializationSettings initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  // );

  // await sl<FlutterLocalNotificationsPlugin>().initialize(initializationSettings);

  Bloc.observer = AppBlocObserver();

  // await sl<AdminBloc>().add(AdminLoad());
  //DartPluginRegistrant.ensureInitialized();
  runApp(const MyApp());
  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        BlocProvider<ErrorBloc>(create: (_) => sl<ErrorBloc>()),
        BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
        BlocProvider<NavigationBloc>(create: (_) => sl<NavigationBloc>()),
        BlocProvider<AdminBloc>(create: (_) => sl<AdminBloc>()),
        BlocProvider<ActivationBloc>(create: (_) => sl<ActivationBloc>()),
        BlocProvider<CustomerBloc>(create: (_) => sl<CustomerBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        builder: (context, _) => BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
              child: MaterialApp(
                // localizationsDelegates: context.localizationDelegates,
                // supportedLocales: context.supportedLocales,
                // locale: context.locale,
                locale: DevicePreview.locale(context), // Add the locale here
                title: 'Afrrikia Device Manager',
                builder: DevicePreview.appBuilder,

                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                home: const MainScreen(),
                routes: {
                  HomeScreen.routeName: (context) => const HomeScreen(),
                  AuthenticatedScreen.routeName: (context) => const AuthenticatedScreen(),
                  MainScreen.routeName: (context) => const MainScreen(),
                  ContractScreen.routeName: (context) => const ContractScreen(),
                  AboutScreen.routeName: (context) => const AboutScreen(),
                  // EditProfileScreen.routeName: (context) => const EditProfileScreen(),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
