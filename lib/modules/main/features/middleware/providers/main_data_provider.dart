import 'dart:async';
import 'dart:convert'; // Add this import for JSON encoding

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dom_affrikia_app/core/enums/phone-state.enum.dart';
import 'package:dom_affrikia_app/core/enums/user.enum.dart';
import 'package:dom_affrikia_app/core/utils/helpers/customer.helper.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill_type.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/customer.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/device.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

class MainDataProvider extends Disposable {
  final InternetConnectionChecker internetConnectionChecker;
  final Connectivity connectivity;

  @override
  FutureOr onDispose() {
    internetStatusSubscription.cancel();
    connectivitySubscription.cancel();
    return Future(() {});
  }

  late AndroidDeviceInfo androidDeviceInfo;
  late String? deviceID;

  UserEnum connectedUser = UserEnum.admin;

  bool hasConnection = false;
  List<ConnectivityResult> connectivityType = [];

  late StreamSubscription<InternetConnectionStatus> internetStatusSubscription;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  MainDataProvider({required this.internetConnectionChecker, required this.connectivity}) {
    //Initialize subscriptions
    internetStatusSubscription = internetConnectionChecker.onStatusChange.listen((status) {
      hasConnection = status == InternetConnectionStatus.connected;
    });

    connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      connectivityType = result;
    });
  }

  isAdmin() => connectedUser == UserEnum.admin;
  isCustomer() => connectedUser == UserEnum.customer;

  bool phoneIsActivated = false;
  String activationStep = "1";
  String billType = "";
  List<BillType> billTypes = [];
  List<Bill> bills = [];

  String get getDeviceID => deviceID != null ? deviceID!.toUpperCase() : 'AUCUN ID';
  String get getDeviceModel => "${toBeginningOfSentenceCase(androidDeviceInfo.brand)}  ${androidDeviceInfo.model}";
  bool get shouldShowActivationPage => !phoneIsActivated && activationStep == "1";
  bool get isPhoneCompletelyActivated => phoneIsActivated && activationStep == "3";
  String get getBillFormatted => billTypeToString(billType);
  List<BillType> get getBillTypes => billTypes.where((type) => type.isOpen == 1).toList();

  String get getDevicePrice => device == null
      ? '??'
      : NumberFormat.currency(symbol: "GNF ", locale: 'fr', decimalDigits: 0).format(device!.devicePrice!);
  bool shouldRetry = false;

  Customer? customerInfo;
  String activationCode = "Pas de code";

  Device? device;

  PhoneStateEnum phoneState = PhoneStateEnum.lock;

  String get getCustomerName {
    if (customerInfo == null) return 'Inconnu';
    return "${customerInfo!.firstName ?? "--"}  ${customerInfo!.lastName ?? "--"}";
  }

  String get getCustomerPhone {
    if (customerInfo == null) return '??';
    return customerInfo!.phoneNumber ?? "--";
  }

  String convertBillsToJson() {
    return jsonEncode(bills.map((bill) => bill.toJson()).toList());
  }

  void loadBillsFromJson(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    bills = jsonList.map((json) => Bill.fromJson(json)).toList();
  }

  String get billRemainingAmount {
    var totalAmount = 0.0;

    for (var bill in bills) {
      if (bill.billStatus != 2) {
        totalAmount += bill.billAmount!;
      }
    }
    return NumberFormat.currency(symbol: "GNF ", locale: 'fr', decimalDigits: 0).format(totalAmount);
  }

  Bill? get getNearestOverdueUnpaidBill {
    // Filter the bills: only unpaid (status == 0) and have an overdueTime in the past
    final overdueUnpaidBills = bills.where((bill) {
      // return bill.billStatus == 0 && bill.overdueTime != null && bill.overdueTime!.isBefore(DateTime.now());
      return bill.billStatus == 0 && bill.overdueTime != null;
    }).toList();

    // Sort by how close the overdue time is to now (ascending)
    overdueUnpaidBills.sort((a, b) {
      return a.overdueTime!.compareTo(b.overdueTime!);
    });

    // Return the one with the closest overdue time (or null if none)
    return overdueUnpaidBills.isNotEmpty ? overdueUnpaidBills.first : null;
  }

  isBillNearestOverdue(Bill bill) {
    return getNearestOverdueUnpaidBill != null && bill.id == getNearestOverdueUnpaidBill!.id;
  }

  bool get isPhoneCompletelyUnlocked => phoneState == PhoneStateEnum.unlock;
  bool get isPhoneLocked => phoneState == PhoneStateEnum.lock;

  int getBillIndex(Bill bill) => bills.indexWhere((b) => b.id == bill.id);

  int getBillIndexOfNearestBillToPay() {
    var nearestBillToPay = getNearestOverdueUnpaidBill;
    if (nearestBillToPay == null) {
      return -1;
    }
    return bills.indexWhere((b) => b.id == nearestBillToPay.id);
  }

  bool get hasBillNearest => getNearestOverdueUnpaidBill != null;

  cleanData() {
    customerInfo = null;
    bills.clear();
    phoneIsActivated = false;
    activationStep = "1";
    billType = "";
    billTypes.clear();
    activationCode = "Pas de code";
    phoneState = PhoneStateEnum.lock;
  }

  updatePhoneState(PhoneStateEnum state) {
    phoneState = state;
  }
}
