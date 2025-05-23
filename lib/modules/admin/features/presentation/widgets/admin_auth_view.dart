import 'package:dom_affrikia_app/core/ui/others/textfield_widget.dart';
import 'package:dom_affrikia_app/core/ui/others/wave_widget.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/about_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AdminAuthView extends StatefulWidget {
  const AdminAuthView({super.key});

  @override
  State<AdminAuthView> createState() => _AdminAuthViewState();
}

class _AdminAuthViewState extends State<AdminAuthView> {
  bool _isPasswordVisible = false;
  bool _keyboardOpen = false;

  String code = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardVisibility(
      onChanged: (isKyeboardVisible) {
        setState(() {
          _keyboardOpen = isKyeboardVisible;
        });
      },
      child: LoaderOverlay(
        overlayColor: Colors.grey.withValues(alpha: 0.5),
        overlayWidgetBuilder: (_) {
          //ignored progress for the moment
          return Center(child: Image.asset('assets/loading.gif', fit: BoxFit.contain, height: 60.h));
        },
        child: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminError) {
              context.loaderOverlay.hide();
              sl<DialogBox>().showSnackBar(context, state.message);
            } else if (state is AdminLoading) {
              context.loaderOverlay.show();
            } else if (state is AdminLoginSuccess) {
              context.loaderOverlay.hide();
            }
          },
          builder: (context, state) {
            return Stack(
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
                  child: SizedBox(
                    height: size.height,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: _keyboardOpen ? size.height / 6 : size.height / 3.5),
                          Text(
                            'Connexion',
                            style: GoogleFonts.pacifico(
                              fontSize: 30.0.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Veuillez insérer le code d\'accès pour vous connecter comme admin',
                            style: TextStyle(
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // TextFieldWidget(
                          //   hintText: 'Email',
                          //   obscureText: false,
                          //   prefixIconData: Icons.mail_outline,
                          //   suffixIconData: null,
                          //   onChanged: (value) {
                          //     validateEmail(value);
                          //   },
                          // ),
                          const SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFieldWidget(
                                hintText: 'Code d\'accès',
                                prefixIconData: Icons.lock_outline,
                                suffixIconData: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                obscureText: !_isPasswordVisible,
                                onChanged: (value) {
                                  setState(() {
                                    code = value;
                                  });
                                },
                                onChangeIconstate: (change) {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              if (code.isEmpty)
                                const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Le code est requis",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              if (code.isNotEmpty && code.length < 3)
                                const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Le code doit avoir au moins 3 caractères",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: code.length > 2
                                  ? () {
                                      FocusScopeNode currentFocus = FocusScope.of(context);

                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      // if (sl<AuthController>().checkLoginValidation()) {
                                      //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                                      // }

                                      //context.loaderOverlay.show();
                                      sl<AdminBloc>().add(AdminLogin(code: code));
                                    }
                                  : null,
                              child: Text(
                                'Se connecter',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: Theme.of(context).primaryColor, width: 1.0.w),
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                              ),
                              onPressed: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                // if (sl<AuthController>().checkLoginValidation()) {
                                //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                                // }

                                if (sl<MainDataProvider>().isPhoneCompletelyActivated) {
                                  sl<NavigationBloc>().add(NavigationLaunchCustomerLogin());
                                } else {
                                  sl<NavigationBloc>().add(NavigationLaunchCustomerActivation());
                                }
                              },
                              child: Text(
                                'Quitter',
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                              ),
                            ),
                          ),
                          //SizedBox(height: 20.0.h),
                          //ButtonWidget(title: 'Activer', hasBorder: false),
                          // ButtonWidget(
                          //   title: 'Sign Up',
                          //   hasBorder: true,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: size.height <= 640 ? 10.h : 25.h),
                  child: SizedBox(
                    height: 150.h,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (!_keyboardOpen)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: <Widget>[
                                const Spacer(),
                                SizedBox(
                                  height: 20.sp,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 0),
                                      visualDensity: VisualDensity.compact,
                                      shape: const CircleBorder(),
                                      alignment: Alignment.center,
                                      backgroundColor: Theme.of(context).canvasColor,
                                      elevation: 8,
                                    ),
                                    splashRadius: 20,
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(AboutScreen.routeName);
                                    },
                                    icon: Icon(
                                      MdiIcons.informationVariant,
                                      color: Theme.of(context).primaryColor,
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Image.asset('assets/logo/logo_w.png', fit: BoxFit.contain, height: 60.h),
                        // Text(
                        //   'Device Manager',
                        //   style: TextStyle(color: Colors.white, fontSize: 16.0.sp),
                        // ),
                        SizedBox(height: 20.0.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
