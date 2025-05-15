import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:dom_affrikia_app/core/enums/phone-state.enum.dart';
import 'package:dom_affrikia_app/core/platform/network_info.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end.dart';
import 'package:dom_affrikia_app/core/request/request_to_back_end_repo_call.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/bill_type.dart';
import 'package:dom_affrikia_app/modules/customer/features/domain/entities/device.dart';
import 'package:dom_affrikia_app/modules/customer/features/presentation/providers/bill_list_notifier.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/navigation/bloc/navigation_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'activation_event.dart';
part 'activation_state.dart';

class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  final Dio dioClient;
  final MainDataProvider mainDataProvider;
  final Options options;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;
  final BillListNotifier billListNotifier;

  ActivationBloc(
      this.dioClient, this.mainDataProvider, this.options, this.networkInfo, this.secureStorage, this.billListNotifier)
      : super(ActivationInitial()) {
    options.headers?["deviceId"] = mainDataProvider.getDeviceID;
    on<ActivationActivate>((event, emit) async {
      // Handle ActivationActivate event
      emit(ActivationLoading());
      // Add your activation logic here
      var isOk = false;
      Map<String, dynamic> jsonData = {};
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => dioClient.post(
            '/device/activate?code=${event.code}&deviceType=1',
            options: options,
            data: {},
          ),
          (json) => json,
        ),
        networkInfo.isConnected,
      );

      response.fold(
        (failure) => emit(ActivationError(failure.toString())),
        (json) async {
          if (json['ok']) {
            jsonData = json['data'];
            isOk = true;
          } else {
            emit(ActivationError(json['msg']));
          }
        },
      );

      if (isOk) {
        var activationBill = Bill.fromJson(jsonData['bill']);
        var device = Device.fromJson(jsonData['device']);

        mainDataProvider.device = device;
        mainDataProvider.bills.add(activationBill);

        await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
        await secureStorage.write(key: "device", value: device.toString());

        await secureStorage.write(key: "activationStep", value: "2");
        await secureStorage.write(key: "customerCode", value: event.code);

        mainDataProvider.activationStep = "2";
        mainDataProvider.activationCode = event.code;

        //billListNotifier.addBill(activationBill);

        emit(const ActivationDone("Téléphone activé"));
      }
    });

    on<ActivationCreateBills>((event, emit) async {
      // Handle ActivationCreateBills event
      emit(ActivationLoading());
      // Add your bill creation logic here
      var isOk = false;
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => dioClient.put(
            '/bill/createBills?typeCode=${event.billType.typeCode}',
            options: options,
            data: {},
          ),
          (json) => json,
        ),
        networkInfo.isConnected,
      );

      response.fold(
        (failure) => emit(ActivationError(failure.toString())),
        (json) async {
          if (json['ok']) {
            isOk = true;
            var dataList = (json['data'] as List).map<Bill>((data) => Bill.fromJson(data)).toList();
            mainDataProvider.bills.addAll(dataList);

            emit(ActivationBillTypesLoaded());
          } else {
            emit(ActivationError(json['msg']));
          }
        },
      );
      if (isOk) {
        await secureStorage.write(key: "isActivated", value: true.toString());
        await secureStorage.write(key: "activationStep", value: "3");
        await secureStorage.write(key: "billType", value: event.billType.typeCode);
        await secureStorage.write(key: "bills", value: mainDataProvider.convertBillsToJson());
        await secureStorage.write(key: "phoneState", value: PhoneStateEnum.unlockPartially.index.toString());

        mainDataProvider.phoneIsActivated = true;
        mainDataProvider.activationStep = "3";
        mainDataProvider.phoneState = PhoneStateEnum.unlockPartially;
        mainDataProvider.billType = event.billType.typeCode;
        billListNotifier.addManyBills(mainDataProvider.bills);
        sl<NavigationBloc>().add(NavigationLaunchCustomerLogin());
      }
    });

    on<ActivationGetBillType>((event, emit) async {
      // Handle ActivationGetBillType event
      emit(ActivationLoading());
      // Add your bill type fetching logic here
      final response = await remoteDataSourceCall<dynamic>(
        () => requestToBackend(
          () => dioClient.get('/bill/getBillTypes', options: options),
          (json) => json,
        ),
        networkInfo.isConnected,
      );

      response.fold(
        (failure) => emit(ActivationError(failure.toString())),
        (json) async {
          if (json['ok']) {
            var dataList = (json['data'] as List).map<BillType>((data) => BillType.fromJson(data)).toList();
            mainDataProvider.billTypes = dataList;

            log("datalist : $dataList");

            emit(ActivationBillTypesLoaded());
          } else {
            emit(ActivationError(json['msg']));
          }
        },
      );
    });
  }
}
