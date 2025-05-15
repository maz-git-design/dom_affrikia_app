import 'package:dom_affrikia_app/core/ui/others/textfield_widget.dart';
import 'package:dom_affrikia_app/core/ui/others/wave_widget.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/admin/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CustomerAuthView extends StatefulWidget {
  const CustomerAuthView({super.key});

  @override
  State<CustomerAuthView> createState() => _CustomerAuthViewState();
}

class _CustomerAuthViewState extends State<CustomerAuthView> {
  bool _isPasswordVisible = false;
  bool _keyboardOpen = false;

  String code = "";

  int _tapCounter = 0;
  DateTime _firstTapTime = DateTime.now();

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
        child: BlocConsumer<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerError) {
              context.loaderOverlay.hide();
              sl<DialogBox>().showSnackBar(context, state.message);
            } else if (state is CustomerLoading) {
              context.loaderOverlay.show();
            } else if (state is CustomerLoginSuccess) {
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
                          SizedBox(height: 5.h),
                          Text(
                            "Bienvenu chez Affrikia",
                            style: TextStyle(
                              fontSize: 15.0.sp,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Veuillez insérer le code d\'activation pour vous connecter comme propriétaire',
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
                                      sl<CustomerBloc>().add(CustomerLogin(code: code));
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
                        GestureDetector(
                          onTap: _handleSecretTap,
                          child: Image.asset(
                            'assets/logo/logo_w.png',
                            fit: BoxFit.contain,
                            height: 60.h,
                          ),
                        ),
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
