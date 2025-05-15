import 'package:dom_affrikia_app/core/enums/cycle.enum.dart';
import 'package:dom_affrikia_app/core/ui/others/textfield_widget.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/cycle.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/activation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/pages/contract_screen.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';

class ActivationStepWidget extends StatefulWidget {
  const ActivationStepWidget({super.key});

  @override
  State<ActivationStepWidget> createState() => _ActivationStepWidgetState();
}

class _ActivationStepWidgetState extends State<ActivationStepWidget> {
  bool _isRead = false;
  bool _isPasswordVisible = false;
  String code = "";

  bool _keyboardOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return KeyboardVisibility(
      onChanged: (isKeyboardVisible) {
        setState(() {
          _keyboardOpen = isKeyboardVisible;
        });
      },
      child: SizedBox(
        height: size.height,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: _keyboardOpen ? size.height / 6 : size.height / 3.5),
              const CircleAvatar(
                child: Text("1"),
              ),
              Text(
                'Activation',
                style: GoogleFonts.pacifico(
                  fontSize: 30.0.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Veuillez entrer le code pour activer l'appareil",
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
              TextFieldWidget(
                hintText: 'Code d\'activation',
                prefixIconData: Icons.lock_outline,
                suffixIconData: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                obscureText: !_isPasswordVisible,
                onChanged: (value) {
                  // validateCode(value);
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
              const SizedBox(height: 10.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                        splashRadius: 8.r,
                        value: _isRead,
                        onChanged: (value) {
                          setState(() {
                            _isRead = value!;
                          });
                        }),
                    Text(
                      "J'ai lu et j'accepte le contrat d'activation",
                      style: TextStyle(fontSize: 11.sp),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  // navigate to next page
                  Navigator.of(context).pushNamed(ContractScreen.routeName);
                },
                splashColor: Theme.of(context).splashColor,
                child: Text(
                  textAlign: TextAlign.center,
                  "Lire le contrat d'activation de l'appareil mobile",
                  style:
                      TextStyle(fontSize: 11.0.sp, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800),
                ),
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
                  onPressed: code.length >= 3 && sl<MainDataProvider>().hasConnection && _isRead
                      ? () async {
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          // if (sl<AuthController>().checkLoginValidation()) {
                          //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                          // }

                          //context.loaderOverlay.show();
                          //sl<UserBloc>().add(UserLoggedIn());
                          var response = await sl<DialogBox>().showDialoxBox(
                            context,
                            "Veuillez conserver ce code en lieu sûr, car il vous sera nécessaire pour vous connecter à votre portail ultérieurement.",
                            "Information",
                          );

                          if (response != null && response) {
                            sl<ActivationBloc>().add(ActivationActivate(code: code));
                          }
                        }
                      : null,
                  child: Text(
                    'Activer',
                    style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
