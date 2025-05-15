import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogBox {
  bool isSnackBarShown = false;
  Future<void> showSnackBar(BuildContext context, String message) async {
    if (isSnackBarShown) {
      return;
    }
    isSnackBarShown = true;

    await showFlash(
      context: context,
      duration: const Duration(seconds: 7),
      builder: (context, controller) {
        return FlashBar(
          behavior: FlashBehavior.floating,
          margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 30.h),
          backgroundColor: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
          ),
          position: FlashPosition.bottom,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black))
            ],
          ),
          content: Text(message, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11.sp)),
          icon: Icon(Icons.info, color: Theme.of(context).primaryColor),
          controller: controller,
          dismissDirections: const [FlashDismissDirection.startToEnd],
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.slowMiddle,
        );
      },
    );
    isSnackBarShown = false;
  }

  Future<bool?> showDialoxBox(BuildContext context, String message, String title) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Revenir', textAlign: TextAlign.center),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuer', textAlign: TextAlign.center),
            ),
          ],
          title: Column(
            children: [
              Icon(Icons.info, color: Theme.of(context).primaryColor),
              Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          titlePadding: EdgeInsets.symmetric(vertical: 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.0.w, 0.h, 20.0.w, 10.0.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0.r),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          alignment: Alignment.center,
          content: Text(message, style: TextStyle(fontSize: 13.sp), textAlign: TextAlign.justify),
        );
      },
    );
  }

  void showDialoxInfo(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(onPressed: Navigator.of(context).pop, child: const Text('OK', textAlign: TextAlign.center)),
          ],
          title: Column(
            children: [
              Icon(Icons.info, color: Theme.of(context).primaryColor),
              Text('Information', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          titlePadding: EdgeInsets.symmetric(vertical: 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.0.w, 0.h, 20.0.w, 10.0.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0.r),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          content: Text(message, style: TextStyle(fontSize: 13.sp), textAlign: TextAlign.justify),
        );
      },
    );
  }

  void showUsersPicker({required BuildContext context, required Widget child}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: child,
        );
      },
    );
  }

  Future<void> showBottomSheet(BuildContext context, {required Widget contentChild}) async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: contentChild,
        );
      },
    );
  }
}
