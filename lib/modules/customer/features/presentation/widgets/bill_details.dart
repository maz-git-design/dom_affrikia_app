import 'package:dom_affrikia_app/core/ui/widgets/dialog_box.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/bloc/customer/customer_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

class BillDetails extends StatefulWidget {
  const BillDetails({super.key, required this.bill, required this.index});

  final Bill bill;
  final int index;

  @override
  State<BillDetails> createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
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
            Navigator.of(context).pop();
            context.loaderOverlay.hide();
          } else if (state is CustomerPaymentError) {
            context.loaderOverlay.hide();
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
                  child: Column(
                    children: [
                      Text("Détails de la facture", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5.h),
                      Divider(color: Theme.of(context).cardColor),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: billColorFromValue(widget.bill.billStatus ?? -1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          billStatusFromValue(widget.bill.billStatus ?? -1),
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
                                  billTitleFromType(widget.bill.billTypeCode ?? "", widget.index),
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
                      if (widget.bill.lastOrderId != null) SizedBox(height: 10.h),
                      if (widget.bill.lastOrderId != null)
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                sl<CustomerBloc>().add(CustomerGetTransactionStatus(
                                    orderId: widget.bill.lastOrderId!, billIndex: widget.index));
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Actualiser le denier paiement"),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(right: 4.w, left: 4.w),
                              ),
                            ),
                          ],
                        ),
                      if (sl<MainDataProvider>().isBillNearestOverdue(widget.bill)) SizedBox(height: 10.h),
                      if (sl<MainDataProvider>().isBillNearestOverdue(widget.bill))
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
                      if (sl<MainDataProvider>().isBillNearestOverdue(widget.bill))
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
                      if (sl<MainDataProvider>().isBillNearestOverdue(widget.bill)) SizedBox(height: 20.h),
                      if (sl<MainDataProvider>().isBillNearestOverdue(widget.bill))
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
                                    sl<CustomerBloc>().add(
                                        CustomerPayBill(billToPay: widget.bill, phone: "224${phoneController.text}"));
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
