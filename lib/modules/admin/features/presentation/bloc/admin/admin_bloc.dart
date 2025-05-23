import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dom_affrikia_app/core/config/config.dart';
import 'package:dom_affrikia_app/core/enums/admin.config.dart';
import 'package:dom_affrikia_app/core/enums/user.enum.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/admin/features/domain/entities/admin_config.dart';
import 'package:dom_affrikia_app/modules/admin/features/providers/admin_data_provider.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/bloc/user/bloc/user_bloc.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/providers/main_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final MethodChannel methodChannel;
  final AdminDataProvider adminDataProvider;
  final FlutterSecureStorage secureStorage;

  AdminBloc({required this.methodChannel, required this.adminDataProvider, required this.secureStorage})
      : super(AdminInitial()) {
    on<AdminToggleOption>((event, emit) async {
      emit(AdminLoading());

      String? message = "";

      switch (event.option.config) {
        case AdminConfigEnum.activatePhone:
          try {
            message = await methodChannel.invokeMethod<String>(event.newState ? 'enableKioskMode' : 'disableKioskMode');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            add(AdminLoadData());
          } catch (e) {
            message = "Erreur lors de l'activation de l'appareil";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockFactoryReset:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockFactoryReset2' : 'allowFactoryReset');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockUSB:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockUsbTransfer' : 'allowUsbTransfer');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockInstall:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockInstallApps' : 'allowInstallApps');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockUninstall:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockUninstallApps' : 'allowUninstallApps');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockSafeBoot:
          try {
            message = await methodChannel.invokeMethod<String>(event.newState ? 'blockSafeBoot' : 'allowSafeBoot');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockTetheringSettings:
          try {
            message = await methodChannel.invokeMethod<String>(event.newState ? 'blockTethering' : 'allowTethering');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;

        case AdminConfigEnum.lockAddUser:
          try {
            message = await methodChannel.invokeMethod<String>(event.newState ? 'blockAddUser' : 'allowAddUser');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;
        case AdminConfigEnum.lockDateConfig:
          try {
            message = await methodChannel.invokeMethod<String>(event.newState ? 'blockDateConfig' : 'allowDateConfig');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;
        case AdminConfigEnum.lockAdb:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockAdbDebugging' : 'allowAdbDebugging');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;
        case AdminConfigEnum.lockAdbFeatures:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockAdbFeatures' : 'allowAdbFeatures');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;
        case AdminConfigEnum.lockAppsControl:
          try {
            message =
                await methodChannel.invokeMethod<String>(event.newState ? 'blockAppsControl' : 'allowAppsControl');
            adminDataProvider.adminConfigs[event.optionIndex] =
                adminDataProvider.adminConfigs[event.optionIndex].copyWith(state: event.newState);
            emit(AdminConfigChanged(message: message ?? ""));
          } catch (e) {
            message = "Erreur ${e.toString()}";
            emit(AdminError(message: message));
          }
          break;
        default:
          break;
      }
    });

    on<AdminLoadData>(
      (event, emit) async {
        emit(AdminLoading());

        final adminStatus = await methodChannel.invokeMethod<bool>('getAdminStatus');
        final kioskStatus = await methodChannel.invokeMethod<bool>('getKioskStatus');
        final factoryResetStatus = await methodChannel.invokeMethod<bool>('getFactoryResetStatus');
        final usbStatus = await methodChannel.invokeMethod<bool>('getUsbTransferStatus');
        final uninstallStatus = await methodChannel.invokeMethod<bool>('getUninstallAppsStatus');
        final installStatus = await methodChannel.invokeMethod<bool>('getInstallAppsStatus');
        final safeBootStatus = await methodChannel.invokeMethod<bool>('getSafeBootStatus');
        final tetheringStatus = await methodChannel.invokeMethod<bool>('getTetheringStatus');
        final addUserStatus = await methodChannel.invokeMethod<bool>('getAddUserStatus');
        final dateConfigStatus = await methodChannel.invokeMethod<bool>('getDateTimeStatus');
        final adbDebuggingStatus = await methodChannel.invokeMethod<bool>('getAdbDebuggingStatus');
        final adbFeaturesStatus = await methodChannel.invokeMethod<bool>('getAdbFeaturesStatus');
        final appsControlStatus = await methodChannel.invokeMethod<bool>('getAppsControlStatus');

        log("Admin status: $adminStatus");
        log("Kiosk status: $kioskStatus");
        log("Factory reset status: $factoryResetStatus");
        log("USB transfer status: $usbStatus");
        log("Uninstall status: $uninstallStatus");
        log("Install status: $installStatus");
        log("Safe boot status: $safeBootStatus");
        log("Tethering status: $tetheringStatus");
        log("Add user status: $addUserStatus");
        log("Date/heure configuration status: $dateConfigStatus");
        log("Adb débuggage status: $adbDebuggingStatus");
        log("Adb features status: $adbFeaturesStatus");

        adminDataProvider.adminConfigs = [
          AdminConfig(
            title: "Activer le mode admin",
            config: AdminConfigEnum.adminMode,
            state: adminStatus!,
            methodName: "",
            icon: Icons.handyman_outlined,
          ),
          AdminConfig(
            title: "Vérouiller l'appareil",
            config: AdminConfigEnum.activatePhone,
            state: kioskStatus!,
            methodName: "",
            icon: Icons.lock,
          ),
          AdminConfig(
            title: "Bloquer la factory reset",
            config: AdminConfigEnum.lockFactoryReset,
            state: factoryResetStatus!,
            methodName: "",
            icon: Icons.lock_reset,
          ),
          AdminConfig(
            title: "Empêcher le transfert USB",
            config: AdminConfigEnum.lockUSB,
            state: usbStatus!,
            methodName: "",
            icon: Icons.usb_off_outlined,
          ),
          AdminConfig(
            title: "Empêcher la désinstallation",
            config: AdminConfigEnum.lockUninstall,
            state: uninstallStatus!,
            methodName: "",
            icon: MdiIcons.downloadLock,
          ),
          AdminConfig(
            title: "Empêcher l'installation d'apps",
            config: AdminConfigEnum.lockInstall,
            state: installStatus!,
            methodName: "",
            icon: MdiIcons.downloadOff,
          ),
          AdminConfig(
            title: "Bloquer le Safe Boot",
            config: AdminConfigEnum.lockSafeBoot,
            state: safeBootStatus!,
            methodName: "",
            icon: MdiIcons.security,
          ),
          AdminConfig(
            title: "Bloquer le tethering",
            config: AdminConfigEnum.lockTetheringSettings,
            state: tetheringStatus!,
            methodName: "",
            icon: MdiIcons.wifiOff,
          ),
          AdminConfig(
            title: "Empêcher l'ajout d'utilisateurs",
            config: AdminConfigEnum.lockAddUser,
            state: addUserStatus!,
            methodName: "",
            icon: MdiIcons.accountCancel,
          ),
          AdminConfig(
            title: "Empêcher la modif. date",
            config: AdminConfigEnum.lockDateConfig,
            state: dateConfigStatus!,
            methodName: "",
            icon: MdiIcons.calendarLock,
          ),
          AdminConfig(
            title: "Désactiver l'ADB",
            config: AdminConfigEnum.lockAdb,
            state: adbDebuggingStatus!,
            methodName: "",
            icon: MdiIcons.usbFlashDrive,
          ),
          AdminConfig(
            title: "Désactiver l'option dev.",
            config: AdminConfigEnum.lockAdbFeatures,
            state: adbFeaturesStatus!,
            methodName: "",
            icon: MdiIcons.developerBoard,
          ),
          AdminConfig(
            title: "Désactiver apps. control",
            config: AdminConfigEnum.lockAppsControl,
            state: appsControlStatus!,
            methodName: "",
            icon: Icons.app_blocking_rounded,
          ),
        ];
        emit(AdminLoaded());
      },
    );

    on<AdminLogin>((event, emit) async {
      emit(AdminLoading());

      final adminCode = await secureStorage.read(key: "adminPassword");

      if (event.code == adminCode) {
        sl<MainDataProvider>().connectedUser = UserEnum.admin;
        sl<UserBloc>().add(UserLoggedIn());
        emit(AdminLoginSuccess());
      } else {
        emit(const AdminError(message: "Code d'admin incorrect"));
      }
    });

    on<AdminCleanData>((_, emit) async {
      emit(AdminLoading());
      await secureStorage.deleteAll();
      await secureStorage.write(key: "adminPassword", value: ADMIN_PASSWORD);
      await secureStorage.write(key: "phoneIMEI", value: sl<MainDataProvider>().deviceID);
      sl<MainDataProvider>().cleanData();
      var message = await methodChannel.invokeMethod<String>('enableKioskMode');
      log("Phone disabled: $message");
      add(AdminLoadData());
      emit(AdminLoaded());
    });
  }
}
