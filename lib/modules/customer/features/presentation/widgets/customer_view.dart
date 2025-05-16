import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/bill_details.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/widgets/payment_details.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  List<ConnectivityResult> connectivityType = [];

  void getConnectionStatus() async {
    sl<MainDataProvider>().hasConnection = await sl<InternetConnectionChecker>().hasConnection;
    setState(() {});
  }

  getNetworkIconData() {
    if (sl<MainDataProvider>().hasConnection) {
      if (connectivityType.contains(ConnectivityResult.wifi)) {
        return Icons.wifi_rounded;
      } else if (connectivityType.contains(ConnectivityResult.mobile)) {
        return Icons.signal_cellular_alt_rounded;
      } else {
        return Icons.wifi_rounded;
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

    sl<CustomerBloc>().add(CustomerLoadInfo());

    getConnectionStatus();
    internetStatusSubscription = sl<InternetConnectionChecker>().onStatusChange.listen((status) {
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
    connectivitySubscription = sl<Connectivity>().onConnectivityChanged.listen((result) {
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

  void openWifiSettings() {
    const intent = AndroidIntent(
      action: 'android.settings.WIFI_SETTINGS',
    );
    intent.launch();
  }

  void openMobileDataSettings() {
    const intent = AndroidIntent(
      action: 'android.settings.DATA_ROAMING_SETTINGS',
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoaderOverlay(
      overlayColor: Colors.grey.withValues(alpha: 0.5),
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(child: Image.asset('assets/loading.gif', fit: BoxFit.contain, height: 60.h));
      },
      child: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerLoading) {
            context.loaderOverlay.show();
          } else if (state is CustomerError) {
            context.loaderOverlay.hide();
            sl<DialogBox>().showSnackBar(context, state.message);
          } else if (state is CustomerInfoLoaded ||
              state is CustomerPaymentSuccess ||
              state is CustomerGetPaymentStatusSuccess) {
            context.loaderOverlay.hide();
          }
        },
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            height: size.height,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Bienvenu chez Afrrikia ",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 5.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Propriétaire",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            const Icon(Icons.person_2_outlined),
                            SizedBox(width: 5.w),
                            Text(
                              sl<MainDataProvider>().getCustomerName,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              sl<MainDataProvider>().getCustomerPhone,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            getNetworkIconData(),
                            size: 16.0.sp,
                          ),
                          SizedBox(width: 5.0.w),
                          Text(
                            sl<MainDataProvider>().hasConnection ? "Connecté" : "Déconnecté",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.circle,
                            size: 12.0.sp,
                            color: sl<MainDataProvider>().hasConnection ? Colors.green : Colors.red,
                          ),
                          const Spacer(),
                          IconButton(
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              backgroundColor: Colors.grey.shade200,
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
                                      color: Colors.grey.shade200,
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
                          IconButton(
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              alignment: Alignment.center,
                              backgroundColor: Colors.grey.shade200,
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
                                      color: Colors.grey.shade200,
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Information sur le téléphone",
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                          ),
                          SizedBox(height: 5.h),
                          Divider(color: Theme.of(context).cardColor),
                          SizedBox(height: 5.h),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.phone_android_rounded, size: 35.0.sp),
                                SizedBox(width: 5.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sl<MainDataProvider>().getDeviceModel,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      sl<MainDataProvider>().getDeviceID,
                                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Icon(
                                getPhoneStatusIconDataFromState(sl<MainDataProvider>().phoneState),
                                size: 20.0,
                                color: getPhoneStatusColorFromState(sl<MainDataProvider>().phoneState),
                              ),
                              SizedBox(width: 5.w),
                              Text(getPhoneStatusFromState(sl<MainDataProvider>().phoneState),
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Paiement",
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                "|",
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(width: 5.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                ),
                                child: Text(sl<MainDataProvider>().getBillFormatted,
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).primaryColor,
                                ),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.center,
                                  backgroundColor: Colors.grey.shade200,
                                  elevation: 8,
                                ),
                                splashRadius: 10,
                                onPressed: () {
                                  sl<CustomerBloc>().add(CustomerGetBills());
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Divider(color: Theme.of(context).cardColor),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              Text(
                                "Montant total dû",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  sl<MainDataProvider>().getDevicePrice,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Divider(color: Theme.of(context).cardColor),
                          ListView.builder(
                            itemCount: sl<MainDataProvider>().bills.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: InkWell(
                                highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                overlayColor:
                                    WidgetStateProperty.all(Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                                focusColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                onTap: () {
                                  if (sl<MainDataProvider>().bills[index].hasOverdue) {
                                    sl<DialogBox>().showBottomSheet(context,
                                        contentChild: BillDetails(
                                          bill: sl<MainDataProvider>().bills[index],
                                          index: index,
                                        ));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        sl<MainDataProvider>().isBillNearestOverdue(sl<MainDataProvider>().bills[index])
                                            ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                                            : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            billTitleFromType(
                                                sl<MainDataProvider>().bills[index].billTypeCode ?? "", index),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          if (sl<MainDataProvider>().bills[index].hasOverdue)
                                            Text(
                                              "Dû:${sl<MainDataProvider>().bills[index].getOverDueDate}",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(width: 8.w),
                                      if (sl<MainDataProvider>().bills[index].hasOverdue)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: billColorFromValue(
                                                sl<MainDataProvider>().bills[index].billStatus ?? -1),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            billStatusFromValue(sl<MainDataProvider>().bills[index].billStatus ?? -1),
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          sl<MainDataProvider>().bills[index].getBillAmount,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          if (!sl<MainDataProvider>().isPhoneCompletelyUnlocked)
                            Text(
                              "La tranche colorée est celle qui doit être payée",
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          Divider(color: Theme.of(context).cardColor),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              Text(
                                "Montant total restant",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  sl<MainDataProvider>().billRemainingAmount,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          if (!sl<MainDataProvider>().isPhoneCompletelyUnlocked)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  FocusScopeNode currentFocus = FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  // if (sl<AuthController>().checkLoginValidation()) {
                                  //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                                  // }

                                  //context.loaderOverlay.show();

                                  sl<DialogBox>().showBottomSheet(context, contentChild: const PaymentDetails());
                                },
                                child: Text(
                                  'Payer maintenant',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (sl<MainDataProvider>().getNearestOverdueUnpaidBill != null &&
                      !sl<MainDataProvider>().isPhoneCompletelyUnlocked)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Default color for the main text
                          ),
                          children: [
                            const TextSpan(
                                text: "Ce téléphone sera bloqué si vous ne payez pas la prochaine tranche d'ici le "),
                            TextSpan(
                              text: sl<MainDataProvider>().getNearestOverdueUnpaidBill!.getOverDueDate,
                              style: GoogleFonts.montserrat(
                                color: Colors.red, // Change to the color you want
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (sl<MainDataProvider>().isPhoneCompletelyUnlocked)
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black, // Default color for the main text
                            ),
                            children: [
                              const TextSpan(text: "Ce téléphone est à vous, merci d'avoir choisi afrrikia "),
                              TextSpan(
                                text: "Au plaisirs de vous avoir!",
                                style: GoogleFonts.montserrat(
                                  color: Colors.green, // Change to the color you want
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
