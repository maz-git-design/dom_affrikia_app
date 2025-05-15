mixin ValidatorMixin {
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Le nom est requis";
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return "L'adresse est requise";
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return "La description est requise";
    }
    return null;
  }

  String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return "Le message est requise";
    }
    return null;
  }

  String? validateOptionalDescription(String? value) {
    // if (value == null || value.isEmpty) {
    //   return "La description est requise";
    // }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Le mot de passe est requis";
    } else if (value.length < 7) {
      return "Le mot de passe doit comporter au moins 7 caractères";
    }

    return null;
  }

  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return "Le code est requis";
    } else if (value.length != 6 || int.tryParse(value) == null) {
      return "Le code doit contenir 6 chiffres";
    }

    return null;
  }

  String? verifyPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Le mot de passe est requis";
    } else if (value != password) {
      return "Les mots de passe ne sont pas identiques";
    }

    return null;
  }

  String? validateEmail(String value) {
    RegExp emailReg = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (!emailReg.hasMatch(value)) {
      return "Veuillez entrer une adresse e-mail valide";
    }

    return null;
  }

  String? validateMobileNumber(String? value) {
    RegExp mobileNumberReg = RegExp(r'^((8|9)\d{8})$');

    if (value == null || value.isEmpty) {
      return "Le numéro est requis";
    } else {
      if (!mobileNumberReg.hasMatch(value)) {
        return "Entrez un numéro de téléphone valide";
      }
    }
    return null;
  }

  String? validateCarModelNumber(String value) {
    if (value.isEmpty) {
      return "Model est requis";
    }

    return null;
  }

  String? validatePlaqueNumber(String value) {
    RegExp plaqueNumberReg = RegExp(r"^(\d{2}[A-Z]{2}\d{3})$");
    if (!plaqueNumberReg.hasMatch(value)) {
      return "Le numéro de la plaque est requise et le format est 10AB123";
    }

    return null;
  }

  String? validateYear(String value) {
    RegExp yearReg = RegExp(r"^((19[0-9][0-9])|([2-9][0-9][0-9][0-9]))$");
    if (!yearReg.hasMatch(value)) {
      return "Veuillez entrer une année valide";
    } else {
      var year = DateTime(int.parse(value));
      if (year.isAfter(DateTime.now())) {
        return "L'année doit être inférieure ou égale à ${DateTime.now().year}";
      }
    }
    return null;
  }

  String? validateFrameNumber(String value) {
    //RegExp frameNumberReg = RegExp(r"^([0-9A-Z]{17})$");
    if (value.isEmpty) {
      return "Le chassis est requis";
    }
    return null;
  }

  String? validateKilometrage(String value) {
    if (value.isEmpty) {
      return "Le kilométrage est réquis";
    } else if (double.tryParse(value) == null) {
      return "Le kilométrage doît être un nombre";
    }

    return null;
  }

  String? validateSubject(String? value) {
    if (value == null || value.isEmpty) {
      return "Le sujet est requis";
    }
    return null;
  }
}
