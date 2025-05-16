import 'package:dom_affrikia_app/background_task.dart';
import 'package:dom_affrikia_app/core/enums/cycle.enum.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:dom_affrikia_app/modules/admin/features/providers/admin_data_provider.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/cycle.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  CycleDurationEnum _cycle = CycleDurationEnum.second;

  List<Cycle> cycles = [
    const Cycle(name: "Séconde", duration: CycleDurationEnum.second),
    const Cycle(name: "Minute", duration: CycleDurationEnum.minute),
    const Cycle(name: "Heure", duration: CycleDurationEnum.hour),
    const Cycle(name: "Jour", duration: CycleDurationEnum.day),
    const Cycle(name: "Semaine", duration: CycleDurationEnum.week),
    const Cycle(name: "Mois", duration: CycleDurationEnum.month),
    const Cycle(name: "Année", duration: CycleDurationEnum.year),
  ];

  @override
  void initState() {
    super.initState();
    sl<AdminBloc>().add(AdminLoadData());
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: Colors.grey.withValues(alpha: 0.5),
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(child: Image.asset('assets/loading.gif', fit: BoxFit.contain, height: 60.h));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminLoading) {
              context.loaderOverlay.show();
            } else if (state is AdminLoaded) {
              context.loaderOverlay.hide();
            } else if (state is AdminConfigChanged) {
              sl<DialogBox>().showSnackBar(context, state.message);
              context.loaderOverlay.hide();
            } else if (state is AdminError) {
              sl<DialogBox>().showSnackBar(context, state.message);
              context.loaderOverlay.hide();
            }
          },
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Bienvenu chez Afrrikia ",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Container(
                  //       height: 40.h,
                  //       width: 4.w,
                  //       decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  //     ),
                  //     SizedBox(width: 5.w),
                  //     Flexible(
                  //       child: Container(
                  //         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  //         ),
                  //         child: Text(
                  //           "Pour toute information ou assistance, n'hésitez pas à nous contacter.",
                  //           style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
                          "Profile",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings,
                            ),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                "Administrateur",
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                              ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gestion de configurations",
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
                          ListView.builder(
                            itemCount: sl<AdminDataProvider>().adminConfigs.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => Row(
                              children: [
                                Icon(
                                  sl<AdminDataProvider>().adminConfigs[index].icon,
                                  color: sl<AdminDataProvider>().adminConfigs[index].isActivatePhone
                                      ? Colors.red[800]
                                      : null,
                                  size: 20.0,
                                ),
                                SizedBox(width: 5.w),
                                Text(sl<AdminDataProvider>().adminConfigs[index].title,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    )),
                                const Spacer(),
                                SizedBox(
                                  height: 40,
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Switch(
                                      value: sl<AdminDataProvider>().adminConfigs[index].state,
                                      padding: const EdgeInsets.all(0),
                                      splashRadius: 2,
                                      onChanged: sl<AdminDataProvider>().adminConfigs[index].isAdminConfigMode
                                          ? null
                                          : (value) {
                                              sl<AdminBloc>().add(
                                                AdminToggleOption(
                                                  option: sl<AdminDataProvider>().adminConfigs[index],
                                                  newState: value,
                                                  optionIndex: index,
                                                ),
                                              );
                                            },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Theme.of(context).cardColor),
                          Row(
                            children: [
                              Icon(
                                Icons.sync_outlined,
                                color: Colors.amber,
                                size: 20.0,
                              ),
                              SizedBox(width: 5.w),
                              Text("Activer le service principal",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                  )),
                              const Spacer(),
                              SizedBox(
                                height: 40,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Switch(
                                    value: sl<AdminDataProvider>().isForegroundServiceRunning,
                                    padding: const EdgeInsets.all(0),
                                    splashRadius: 2,
                                    onChanged: (value) async {
                                      if (value) {
                                        await startService();
                                        setState(() {
                                          sl<AdminDataProvider>().isForegroundServiceRunning = true;
                                        });
                                      } else {
                                        await stopService();
                                        setState(() {
                                          sl<AdminDataProvider>().isForegroundServiceRunning = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
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
                          Text(
                            "Activation",
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
                                Icon(MdiIcons.keyChain, size: 35.0.sp),
                                SizedBox(width: 5.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Code d'activation",
                                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      sl<MainDataProvider>().activationCode,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 5.h),
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
                          SizedBox(height: 10.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                FocusScopeNode currentFocus = FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                // if (sl<AuthController>().checkLoginValidation()) {
                                //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                                // }

                                //context.loaderOverlay.show();
                                var response = await sl<DialogBox>().showDialoxBox(
                                  context,
                                  "Cette action va supprimer toutes les données liées à l'activation de ce téléphone, voulez-vous continuer ?",
                                  "Attention",
                                );

                                if (response != null && response) {
                                  sl<AdminBloc>().add(AdminCleanData());
                                }
                              },
                              child: Text(
                                'Réinitialiser tout',
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

                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(10.0),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.start,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Cycle de paiment",
                  //           style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                  //         ),
                  //         SizedBox(height: 5.h),
                  //         Divider(color: Theme.of(context).cardColor),
                  //         SizedBox(height: 5.h),
                  //         Row(
                  //           spacing: 5.w,
                  //           children: [
                  //             Flexible(
                  //               child: TextField(
                  //                 onChanged: (value) {},
                  //                 cursorColor: Theme.of(context).primaryColor,
                  //                 // style: TextStyle(
                  //                 //   fontSize: 14.0,
                  //                 // ),
                  //                 style: GoogleFonts.montserrat(fontSize: 14),
                  //                 keyboardType: TextInputType.number,
                  //                 decoration: InputDecoration(
                  //                   labelStyle: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
                  //                   focusColor: Theme.of(context).primaryColor,
                  //                   filled: true,
                  //                   fillColor: Theme.of(context).cardColor,
                  //                   border: UnderlineInputBorder(
                  //                       borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0.r)),
                  //                   focusedBorder: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),
                  //                   enabledBorder: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),
                  //                   errorBorder: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),
                  //                   disabledBorder: InputBorder.none,
                  //                   labelText: "Cycle",
                  //                   prefixIcon: Icon(MdiIcons.syncIcon),
                  //                 ),
                  //               ),
                  //             ),
                  //             Flexible(
                  //               child: DropdownButtonFormField<CycleDurationEnum>(
                  //                 itemHeight: 50,
                  //                 decoration: InputDecoration(
                  //                   isDense: false,
                  //                   contentPadding: EdgeInsets.all(5.h),
                  //                   border: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),

                  //                   focusedBorder: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),
                  //                   enabledBorder: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),
                  //                   errorBorder: UnderlineInputBorder(
                  //                     borderSide: BorderSide.none,
                  //                     borderRadius: BorderRadius.circular(8.0.r),
                  //                   ),
                  //                   disabledBorder: InputBorder.none,
                  //                   filled: true,
                  //                   fillColor: Theme.of(context).cardColor,
                  //                   label: Text(
                  //                     "Durée",
                  //                     style: GoogleFonts.montserrat(fontSize: 14.sp),
                  //                   ),

                  //                   //hintText: 'Selectionner le genre',
                  //                   labelStyle: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
                  //                   prefixIcon: Icon(MdiIcons.clockOutline),
                  //                 ),
                  //                 value: _cycle,
                  //                 onChanged: (value) {
                  //                   setState(() {
                  //                     _cycle = value!;
                  //                   });
                  //                 },
                  //                 // validator: (value) {
                  //                 //   return sl<AuthController>().validateSexe(value);
                  //                 // },
                  //                 items: cycles.map((cycle) {
                  //                   return DropdownMenuItem<CycleDurationEnum>(
                  //                     value: cycle.duration,
                  //                     child: Text(cycle.name, style: TextStyle(fontSize: 12.sp)),
                  //                   );
                  //                 }).toList(),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         SizedBox(height: 10.h),
                  //         SizedBox(
                  //           width: double.infinity,
                  //           child: ElevatedButton(
                  //             style: ElevatedButton.styleFrom(
                  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //               alignment: Alignment.center,
                  //               padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                  //               backgroundColor: Theme.of(context).primaryColor,
                  //             ),
                  //             onPressed: () {
                  //               FocusScopeNode currentFocus = FocusScope.of(context);

                  //               if (!currentFocus.hasPrimaryFocus) {
                  //                 currentFocus.unfocus();
                  //               }
                  //               // if (sl<AuthController>().checkLoginValidation()) {
                  //               //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                  //               // }

                  //               //context.loaderOverlay.show();
                  //             },
                  //             child: Text(
                  //               'Modifier',
                  //               style: GoogleFonts.montserrat(
                  //                   color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: 10.h),

                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(10.0),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.start,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Mise à jour à distance",
                  //           style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                  //         ),
                  //         SizedBox(height: 5.h),
                  //         Divider(color: Theme.of(context).cardColor),
                  //         SizedBox(height: 5.h),
                  //         TextField(
                  //           onChanged: (value) {},
                  //           cursorColor: Theme.of(context).primaryColor,
                  //           // style: TextStyle(
                  //           //   fontSize: 14.0,
                  //           // ),
                  //           style: GoogleFonts.montserrat(fontSize: 14),
                  //           keyboardType: TextInputType.url,
                  //           decoration: InputDecoration(
                  //             labelStyle: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
                  //             focusColor: Theme.of(context).primaryColor,
                  //             filled: true,
                  //             fillColor: Theme.of(context).cardColor,
                  //             border: UnderlineInputBorder(
                  //                 borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0.r)),
                  //             focusedBorder: UnderlineInputBorder(
                  //               borderSide: BorderSide.none,
                  //               borderRadius: BorderRadius.circular(8.0.r),
                  //             ),
                  //             enabledBorder: UnderlineInputBorder(
                  //               borderSide: BorderSide.none,
                  //               borderRadius: BorderRadius.circular(8.0.r),
                  //             ),
                  //             errorBorder: UnderlineInputBorder(
                  //               borderSide: BorderSide.none,
                  //               borderRadius: BorderRadius.circular(8.0.r),
                  //             ),
                  //             disabledBorder: InputBorder.none,
                  //             labelText: "Lien de téléchargement",
                  //             prefixIcon: Icon(MdiIcons.download),
                  //           ),
                  //         ),
                  //         SizedBox(height: 10.h),
                  //         SizedBox(
                  //           width: double.infinity,
                  //           child: ElevatedButton(
                  //             style: ElevatedButton.styleFrom(
                  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //               alignment: Alignment.center,
                  //               padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                  //               backgroundColor: Theme.of(context).primaryColor,
                  //             ),
                  //             onPressed: () {
                  //               FocusScopeNode currentFocus = FocusScope.of(context);

                  //               if (!currentFocus.hasPrimaryFocus) {
                  //                 currentFocus.unfocus();
                  //               }
                  //               // if (sl<AuthController>().checkLoginValidation()) {
                  //               //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                  //               // }

                  //               //context.loaderOverlay.show();
                  //             },
                  //             child: Text(
                  //               'Valider',
                  //               style: GoogleFonts.montserrat(
                  //                   color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
