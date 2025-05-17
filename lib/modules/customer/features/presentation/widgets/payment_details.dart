import 'package:dom_affrikia_app/core/ui/others/textfield_widget.dart';
import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  var phone = "";
  bool withMyphone = true;
  final formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = sl<MainDataProvider>().getCustomerPhone.substring(3);
  }

  @override
  Widget build(BuildContext context) {
    final heigth = MediaQuery.of(context).size.height;
    return LoaderOverlay(
      overlayColor: Colors.grey.withValues(alpha: 0.5),
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(child: Image.asset('assets/loading.gif', fit: BoxFit.contain, height: 60.h));
      },
      child: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerPaymentSuccess) {
            context.loaderOverlay.hide();
            Navigator.of(context).pop();
            sl<DialogBox>().showDialoxInfo(context, state.message);
          } else if (state is CustomerGetPaymentStatusSuccess) {
            context.loaderOverlay.hide();
            Navigator.of(context).pop();
            sl<DialogBox>().showDialoxInfo(context, state.message);
          } else if (state is CustomerPaymentError) {
            context.loaderOverlay.hide();

            sl<DialogBox>().showSnackBar(context, state.message);
          } else if (state is CustomerLoading) {
            context.loaderOverlay.show();
          }
        },
        builder: (context, state) {
          return SizedBox(
            height: heigth * 0.7,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: sl<MainDataProvider>().getNearestOverdueUnpaidBill != null
                      ? Column(
                          children: [
                            Text("Paiement", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5.h),
                            Divider(color: Theme.of(context).cardColor),
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: billColorFromValue(
                                    sl<MainDataProvider>().getNearestOverdueUnpaidBill!.billStatus ?? -1),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                billStatusFromValue(
                                    sl<MainDataProvider>().getNearestOverdueUnpaidBill!.billStatus ?? -1),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        billTitleFromType(
                                            sl<MainDataProvider>().getNearestOverdueUnpaidBill!.billTypeCode ?? "",
                                            null),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        "Dû le ${sl<MainDataProvider>().getNearestOverdueUnpaidBill!.getOverDueDate}",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      sl<MainDataProvider>().getNearestOverdueUnpaidBill!.getBillAmount,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: <Widget>[
                                Checkbox(
                                    splashRadius: 0.r,
                                    value: withMyphone,
                                    onChanged: (value) {
                                      setState(() {
                                        withMyphone = value!;

                                        if (withMyphone) {
                                          phoneController.text = sl<MainDataProvider>().getCustomerPhone.substring(3);
                                        }
                                      });
                                    }),
                                Text(
                                  "Payer avec mon numéro",
                                  style: TextStyle(fontSize: 11.sp),
                                )
                              ],
                            ),
                            TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) {
                                //onChanged(value);
                                setState(() {
                                  phone = value;
                                });
                              },
                              cursorColor: Theme.of(context).primaryColor,
                              // style: TextStyle(
                              //   fontSize: 14.0,
                              // ),
                              enabled: !withMyphone,
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.montserrat(fontSize: 14),
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
                                focusColor: Theme.of(context).primaryColor,
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10.0.r)),
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
                                labelText: "Téléphone",
                                prefixIcon: const Icon(Icons.phone, size: 18),
                                prefix: const Text("+224"),
                              ),

                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Le numéro est requis";
                                }

                                final regex = RegExp(r'^\d{9}$');
                                if (!regex.hasMatch(value.trim())) {
                                  return "Veuillez entrer un numéro valide à 9 chiffres";
                                }

                                return null; // Valid input
                              },
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                onPressed: RegExp(r'^\d{9}$').hasMatch(phoneController.text.trim())
                                    ? () {
                                        FocusScopeNode currentFocus = FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        // if (sl<AuthController>().checkLoginValidation()) {
                                        //   sl<AuthBloc>().add(AuthLoginButtonPressed());
                                        // }

                                        //context.loaderOverlay.show();
                                        sl<CustomerBloc>().add(CustomerPayBill(
                                            billToPay: sl<MainDataProvider>().getNearestOverdueUnpaidBill!,
                                            phone: "224${phoneController.text}"));
                                      }
                                    : null,
                                child: Text(
                                  'Payer',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0.sp),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text("Paiement", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5.h),
                            Divider(color: Theme.of(context).cardColor),
                            SizedBox(height: 10.h),
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
                                      text: "Aucune facture à payer pour cet appareil. ",
                                    ),
                                    if (sl<MainDataProvider>().isPhoneCompletelyUnlocked)
                                      TextSpan(
                                        text: "Le téléphone est complètement déverrouillé",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.red, // Change to the color you want
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
