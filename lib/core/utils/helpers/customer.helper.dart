import 'package:dom_affrikia_app/core/enums/phone-state.enum.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

billTypeToString(String type) {
  switch (type) {
    case "month":
      return "Mensuel";

    case "week":
      return "Hebdomadaire";

    case "year":
      return "Annuel";

    case "quarter":
      return "Trimestrel";

    case "b-week":
      return "2 semaines";

    case "minute":
      return "Par minute";
    case "hour":
      return "Par heure";

    case "day":
      return "Par jour";
    case "second":
      return "Par seconde";
    default:
      return "Inconnu";
  }
}

billStatusFromValue(int value) {
  switch (value) {
    case 0:
      return "Non payé(e)";
    case 1:
      return "Non payé(e) (passé)";
    case 2:
      return "Payé(e)";
    case 3:
      return "Payé(e) en partie";
    default:
      return "Inconnu";
  }
}

billColorFromValue(int value) {
  switch (value) {
    case 0:
      return Colors.red;
    case 1:
      return Colors.pinkAccent;
    case 2:
      return Colors.green;
    case 3:
      return Colors.amber;
    default:
      return Colors.grey;
  }
}

billTitleFromType(String type, int? index) {
  switch (type) {
    case "activation":
      return "Frais d'activation";
    default:
      return "Tranche-${index ?? ''}";
  }
}

getPhoneStatusFromState(PhoneStateEnum state) {
  switch (state) {
    case PhoneStateEnum.lock:
      return "Desactivé";
    case PhoneStateEnum.unlock:
      return "Activé complètement";
    case PhoneStateEnum.unlockPartially:
      return "Activé partiellement";
  }
}

getPhoneStatusFromStateString(String state) {
  switch (state) {
    case "0":
      return "Desactivé";
    case "1":
      return "Activé partiellement";
    case "2":
      return "Activé complètement";
    default:
      return "Inconnu";
  }
}

getPhoneStatusColorFromState(PhoneStateEnum state) {
  switch (state) {
    case PhoneStateEnum.lock:
      return Colors.red;
    case PhoneStateEnum.unlock:
      return Colors.green;
    case PhoneStateEnum.unlockPartially:
      return Colors.amber;
  }
}

getPhoneStatusIconDataFromState(PhoneStateEnum state) {
  switch (state) {
    case PhoneStateEnum.lock:
      return MdiIcons.lock;
    case PhoneStateEnum.unlock:
      return MdiIcons.lockOpenCheck;
    case PhoneStateEnum.unlockPartially:
      return MdiIcons.lockOpen;
  }
}
