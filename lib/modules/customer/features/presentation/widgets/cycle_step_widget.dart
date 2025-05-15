import 'package:dom_affrikia_app/core/enums/cycle.enum.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill_type.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/cycle.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/activation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';

class CycleStepWidget extends StatefulWidget {
  CycleStepWidget({super.key});

  @override
  State<CycleStepWidget> createState() => _CycleStepWidgetState();
}

class _CycleStepWidgetState extends State<CycleStepWidget> {
  bool _keyboardOpen = false;
  BillType? _billType;

  List<Cycle> cycles = [
    const Cycle(name: "Hedbomadaire", value: CycleEnum.weekly),
    const Cycle(name: "Chaque 2 semaines", value: CycleEnum.biweekly),
    const Cycle(name: "Mensuel", value: CycleEnum.monthly),
  ];

  @override
  void initState() {
    super.initState();
    sl<ActivationBloc>().add(ActivationGetBillType());
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
      child: SizedBox(
        height: size.height,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: _keyboardOpen ? size.height / 6 : size.height / 3.5),
              const CircleAvatar(
                child: Text("2"),
              ),
              Text(
                'Mode de paiement',
                style: GoogleFonts.pacifico(
                  fontSize: 30.0.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Veuillez choisir votre mode de paiement',
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
              DropdownButtonFormField<BillType>(
                itemHeight: 50,
                decoration: InputDecoration(
                  isDense: false,
                  contentPadding: EdgeInsets.all(5.h),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                  disabledBorder: InputBorder.none,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  label: Text(
                    "Cycle de paiement",
                    style: GoogleFonts.montserrat(fontSize: 14.sp),
                  ),

                  //hintText: 'Selectionner le genre',
                  labelStyle: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                ),
                value: _billType,
                onChanged: (value) {
                  setState(() {
                    _billType = value!;
                  });
                },
                // validator: (value) {
                //   return sl<AuthController>().validateSexe(value);
                // },
                items: sl<MainDataProvider>().getBillTypes.map((type) {
                  return DropdownMenuItem<BillType>(
                    value: type,
                    child: Text(type.typeName, style: TextStyle(fontSize: 12.sp)),
                  );
                }).toList(),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    sl<ActivationBloc>().add(ActivationGetBillType());
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text("Reactualiser les cycles"),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(right: 4.w, left: 4.w),
                  ),
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
                  onPressed: _billType != null
                      ? () {
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          // if (sl<AuthController>().checkLoginValidation()) {
                          //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                          // }

                          //context.loaderOverlay.show();
                          sl<ActivationBloc>().add(ActivationCreateBills(billType: _billType!));
                        }
                      : null,
                  child: Text(
                    'Valider',
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
