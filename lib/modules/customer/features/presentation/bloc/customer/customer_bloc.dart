import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/core/enums/user.enum.dart';
import 'package:dom_affrikia_app/core/platform/network_info.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end_repo_call.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/customer.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/order.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/providers/bill_list_notifier.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final Dio dioClient;
  final Options options;
  final FlutterSecureStorage secureStorage;
  final NetworkInfo networkInfo;
  final MainDataProvider mainDataProvider;
  final BillListNotifier billListNotifier;

  CustomerBloc(
    this.billListNotifier,
    this.secureStorage,
    this.networkInfo,
    this.dioClient,
    this.options,
    this.mainDataProvider,
  ) : super(CustomerInitial()) {
    options.headers?["deviceId"] = mainDataProvider.getDeviceID;
    on<CustomerLoadInfo>((event, emit) async {
      emit(CustomerLoading());

      var custmerInfo = await secureStorage.read(key: "customerInfo");
      if (custmerInfo != null) {
        mainDataProvider.customerInfo = Customer.fromString(custmerInfo);
        emit(CustomerInfoLoaded());
      } else {
        var isOk = false;
        final response = await remoteDataSourceCall<dynamic>(
          () => requestToBackend(
            () => dioClient.get('/common/getCustomerInfo', options: options),
            (json) => json,
          ),
          networkInfo.isConnected,
        );

        response.fold(
          (failure) => emit(CustomerError(failure.toString())),
          (json) async {
            if (json['ok']) {
              isOk = true;
              mainDataProvider.customerInfo = Customer.fromJson(json['data']);

              emit(CustomerInfoLoaded());
            } else {
              emit(CustomerError(json['msg']));
            }
          },
        );

        if (isOk) {
          await secureStorage.write(key: "customerInfo", value: mainDataProvider.customerInfo.toString());
        }
      }
    });

    on<CustomerLogin>((event, emit) async {
      emit(CustomerLoading());

      final customerCode = await secureStorage.read(key: "customerCode");

      if (customerCode == event.code) {
        mainDataProvider.connectedUser = UserEnum.customer;
        sl<UserBloc>().add(UserLoggedIn());
        emit(CustomerLoginSuccess());
      } else {
        emit(const CustomerError("Le code inséré est invalide. Veuillez réessayer"));
      }
    });

    on<CustomerLogout>((event, emit) {
      sl<UserBloc>().add(UserLoggedOut());
    });

    on<CustomerGetBills>((event, emit) async {
      emit(CustomerLoading());

      var isOk = false;
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => dioClient.get('/bill/getBillsByCustomer?customerPhone=${mainDataProvider.getCustomerPhone}',
              options: options),
          (json) => json,
        ),
        networkInfo.isConnected,
      );

      response.fold(
        (failure) => emit(CustomerError(failure.toString())),
        (json) async {
          if (json['ok']) {
            isOk = true;
            var dataList = (json['data'] as List).map<Bill>((data) => Bill.fromJson(data)).toList();
            var copyList = dataList.map((fetchedBill) {
              // Find matching bill in localBills using the same ID
              final localBill = mainDataProvider.bills.firstWhere(
                (b) => b.id == fetchedBill.id,
                orElse: () => const Bill(), // empty if not found
              );
              return Bill(
                id: fetchedBill.id,
                billTypeCode: fetchedBill.billTypeCode,
                billNo: fetchedBill.billNo,
                customerId: fetchedBill.customerId,
                billAmount: fetchedBill.billAmount,
                deviceId: fetchedBill.deviceId,
                billStatus: fetchedBill.billStatus,
                createTime: fetchedBill.createTime,
                notifyTime: fetchedBill.notifyTime,
                overdueTime: fetchedBill.overdueTime,
                payTime: fetchedBill.payTime,
                settledAmount: fetchedBill.settledAmount,
                customerName: fetchedBill.customerName,
                deviceCode: fetchedBill.deviceCode,
                lastOrderId: localBill.lastOrderId, // keep the local one
              );
            }).toList();
            mainDataProvider.bills = copyList;

            emit(CustomerInfoLoaded());
          } else {
            emit(CustomerError(json['msg']));
          }
        },
      );

      if (isOk) {
        billListNotifier.changeAllBills(mainDataProvider.bills);
        await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
      }
    });
    on<CustomerPayBill>((event, emit) async {
      emit(CustomerLoading());

      /// Test full payement process code

      // mainDataProvider.bills = mainDataProvider.bills
      //     .map((bill) => bill.copyWith(
      //           billStatus: 2,
      //           payTime: DateTime.now(),
      //         ))
      //     .toList();
      // await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
      // billListNotifier.changeAllBills(mainDataProvider.bills);
      // emit(const CustomerPaymentSuccess("Paiment effectué avec succès"));

      var isOk = false;
      var orderId = "";
      var message =
          "Votre paiement est en cours de traitement....Vous pouvez réactualiser le statut en cliquant sur réactualiser dans le menu de paiement ou détails";

      final bodyData = jsonEncode({
        "billNo": event.billToPay.billNo,
        "payAmount": event.billToPay.billAmount!.toInt(),
        "mobile": event.phone,
        "description": "Paiement de la facture",
      });

      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => dioClient.post(
            '/pay/gtOrder',
            options: options,
            data: bodyData,
          ),
          (json) => json,
        ),
        networkInfo.isConnected,
      );

      response.fold(
        (failure) => emit(CustomerError(failure.toString())),
        (json) {
          if (json['ok']) {
            isOk = true;
            orderId = json['data'];
          } else {
            emit(CustomerError(json['msg']));
          }
        },
      );

      if (isOk) {
        var billIndex = mainDataProvider.bills.indexOf(event.billToPay);
        //var orderStatus = 3; // Payment is in progress

        if (billIndex != -1) {
          mainDataProvider.bills[billIndex] = event.billToPay.copyWith(lastOrderId: orderId);
          await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
        }

        var isGetStatusOk = false;
        await Future.delayed(const Duration(seconds: 20));
        final payResponse = await remoteDataSourceCall<dynamic>(
          () => requestToBackend(
            () => dioClient.get('/pay/getPaymentStatus?orderId=$orderId', options: options),
            (json) => json,
          ),
          networkInfo.isConnected,
        );

        payResponse.fold(
          (failure) => emit(CustomerPaymentError(failure.toString())),
          (json) {
            if (json['ok']) {
              isGetStatusOk = true;
              var billUpdated = Bill.fromJson(json['data']['bill']);
              var order = Order.fromJson(json['data']['order']);
              var orderStatus = order.status ?? 3;

              // If the order status is not 3 (Payment is processing)
              if (orderStatus != 3) {
                mainDataProvider.bills[billIndex] = billUpdated;
                if (billUpdated.billStatus == 2) {
                  message = "Votre paiement a été effectué avec succès!";
                } else if (billUpdated.billStatus == 0) {
                  message = "Votre paiement n'a pas abouti. Veuillez réessayer ultérieurement.";
                }
              }
            } else {
              emit(CustomerPaymentError(json['msg']));
            }
          },
        );

        if (isGetStatusOk) {
          billListNotifier.changeAllBills(mainDataProvider.bills);
          await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
          emit(CustomerPaymentSuccess(message));
        }
      }
    });
    on<CustomerGetTransactionStatus>((event, emit) async {
      emit(CustomerLoading());
      var isOk = false;
      var message =
          "Votre paiement est en cours de traitement....Vous pouvez réactualiser le statut en cliquant sur réactualiser dans le menu de paiement ou détails";
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => dioClient.get('/pay/getPaymentStatus?orderId=${event.orderId}', options: options),
          (json) => json,
        ),
        networkInfo.isConnected,
      );

      response.fold(
        (failure) => emit(CustomerPaymentError(failure.toString())),
        (json) {
          if (json['ok']) {
            isOk = true;

            var billUpdated = Bill.fromJson(json['data']['bill']);
            var order = Order.fromJson(json['data']['order']);

            // If the order status is not 3 (Payment is processing)
            if (order.status != 3) {
              mainDataProvider.bills[event.billIndex] = billUpdated;
              if (billUpdated.billStatus == 2) {
                message = "Votre paiement a été effectué avec succès!";
              } else if (billUpdated.billStatus == 0) {
                message = "Votre paiement n'a pas abouti. Veuillez réessayer ultérieurement.";
              }
            }
          } else {
            emit(CustomerPaymentError(json['msg']));
          }
        },
      );

      if (isOk) {
        billListNotifier.changeAllBills(mainDataProvider.bills);
        await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
        emit(CustomerGetPaymentStatusSuccess(message));
      }
    });
  }
}
