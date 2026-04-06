import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dom_affrikia_app/core/ui/others/wave_widget.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/core/validators/validator_mixin.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/activation_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/activation_step_widget.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/cycle_step_widget.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/about_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomerActivation extends StatefulWidget with ValidatorMixin {
  const CustomerActivation({super.key});

  @override
  State<CustomerActivation> createState() => _CustomerActivationState();
}

class _CustomerActivationState extends State<CustomerActivation> {
  static const String _kSuppressForegroundLaunchUntilMs =
      'suppressForegroundLaunchUntilMs';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  bool _keyboardOpen = false;
  int _tapCounter = 0;
  DateTime _firstTapTime = DateTime.now();

  List<ConnectivityResult> connectivityType = [];

  void _handleSecretTap() {
    DateTime now = DateTime.now();
    if (now.difference(_firstTapTime).inSeconds > 3) {
      // Reset counter if taps are slow
      _tapCounter = 0;
    }

    _firstTapTime = now;
    _tapCounter++;

    if (_tapCounter >= 5) {
      // Success after 5 quick taps
      _tapCounter = 0;
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => AdminLoginScreen()),
      // );
      sl<NavigationBloc>().add(NavigationAdmin());
    }
  }

  void getConnectionStatus() async {
    sl<MainDataProvider>().hasConnection =
        await sl<InternetConnectionChecker>().hasConnection;
    setState(() {});
  }

  getNetworkIconData() {
    if (sl<MainDataProvider>().hasConnection) {
      if (connectivityType.contains(ConnectivityResult.wifi)) {
        return Icons.wifi_rounded;
      } else if (connectivityType.contains(ConnectivityResult.mobile)) {
        return Icons.signal_cellular_alt_rounded;
      } else {
        return Icons.wifi;
      }
    } else {
      return Icons.wifi_off_rounded;
    }
  }

  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus> internetStatusSubscription;
  @override
  void initState() {
    super.initState();

    getConnectionStatus();
    internetStatusSubscription =
        sl<InternetConnectionChecker>().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          setState(() {
            sl<MainDataProvider>().hasConnection = true;
          });

          break;
        case InternetConnectionStatus.disconnected:
          setState(() {
            sl<MainDataProvider>().hasConnection = false;
          });

          break;
        default:
      }
    });
    connectivitySubscription =
        sl<Connectivity>().onConnectivityChanged.listen((result) {
      setState(() {
        connectivityType = result;
      });
    });
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    internetStatusSubscription.cancel();
    super.dispose();
  }

  Future<void> _suppressAutoLaunchWhileOpeningSettings() async {
    final until = DateTime.now().millisecondsSinceEpoch +
        const Duration(minutes: 2).inMilliseconds;
    await _secureStorage.write(
        key: _kSuppressForegroundLaunchUntilMs, value: until.toString());
  }

  void openWifiSettings() async {
    await _suppressAutoLaunchWhileOpeningSettings();
    const intent = AndroidIntent(
      action: 'android.settings.WIFI_SETTINGS',
    );
    intent.launch();
  }

  void openMobileDataSettings() async {
    await _suppressAutoLaunchWhileOpeningSettings();
    const intent = AndroidIntent(
      action: 'android.settings.DATA_ROAMING_SETTINGS',
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardVisibility(
      onChanged: (isKeyboardVisible) {
        setState(() {
          _keyboardOpen = isKeyboardVisible;
        });
      },
      child: LoaderOverlay(
        overlayColor: Colors.grey.withValues(alpha: 0.5),
        overlayWidgetBuilder: (_) {
          //ignored progress for the moment
          return Center(
              child: Image.asset('assets/loading.gif',
                  fit: BoxFit.contain, height: 60.h));
        },
        child: Stack(
          children: <Widget>[
            Container(
              height: size.height - 300.h,
              color: Theme.of(context).primaryColor,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
              top: _keyboardOpen ? -size.height / 4.5 : 0.0,
              child: WaveWidget(
                size: size,
                yOffset: size.height / 3.5,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30.0.r),
              child: BlocConsumer<ActivationBloc, ActivationState>(
                listener: (context, state) {
                  if (state is ActivationError) {
                    sl<DialogBox>().showSnackBar(context, state.message);
                    context.loaderOverlay.hide();
                  } else if (state is ActivationLoading) {
                    context.loaderOverlay.show();
                  } else if (state is ActivationDone) {
                    sl<DialogBox>()
                        .showSnackBar(context, "Activation réussie!");
                    context.loaderOverlay.hide();
                  } else if (state is ActivationBillTypesLoaded) {
                    context.loaderOverlay.hide();
                  }
                },
                builder: (context, state) {
                  return sl<MainDataProvider>().shouldShowActivationPage
                      ? const ActivationStepWidget()
                      : CycleStepWidget();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: size.height <= 640 ? 10.h : 25.h,
                  left: 20.w,
                  right: 20.w),
              child: SizedBox(
                height: 150.h,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (!_keyboardOpen)
                      Row(
                        children: <Widget>[
                          Icon(
                            getNetworkIconData(),
                            size: 16.0.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5.0.w),
                          Text(
                            sl<MainDataProvider>().hasConnection
                                ? "Connecté"
                                : "Déconnecté",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.circle,
                            size: 12.0.sp,
                            color: sl<MainDataProvider>().hasConnection
                                ? Colors.green
                                : Colors.red,
                          ),
                          const Spacer(),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              backgroundColor: Theme.of(context).canvasColor,
                              elevation: 8,
                            ),
                            onPressed: openWifiSettings,
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 18.sp,
                                ), // Main icon
                                Positioned(
                                  right: -2,
                                  top: -1,
                                  child: Container(
                                    padding: const EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Theme.of(context).canvasColor,
                                    ),
                                    child: Icon(
                                      Icons.settings,
                                      size: 10.sp,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              backgroundColor: Theme.of(context).canvasColor,
                              elevation: 8,
                            ),
                            splashRadius: 10,
                            onPressed: openMobileDataSettings,
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.signal_cellular_alt_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 18.sp,
                                ), // Main icon
                                Positioned(
                                  right: -2,
                                  top: -1,
                                  child: Container(
                                    padding: const EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Theme.of(context).canvasColor,
                                    ),
                                    child: Icon(
                                      Icons.settings,
                                      size: 10.sp,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              backgroundColor: Theme.of(context).canvasColor,
                              elevation: 8,
                            ),
                            splashRadius: 10,
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AboutScreen.routeName);
                            },
                            icon: Icon(
                              MdiIcons.informationVariant,
                              color: Theme.of(context).primaryColor,
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    GestureDetector(
                      onTap: _handleSecretTap,
                      child: Image.asset(
                        'assets/logo/logo_w.png',
                        fit: BoxFit.contain,
                        height: 60.h,
                      ),
                    ),
                    // Text(
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
