mixin ValidateCardExpiryMonthMixin{
  String? validateCardExpiryMonthFromMixin(String? value) {
    RegExp ExpiryMonthReg = RegExp(r'^\d{1,2}$');

    if (value == null || value.isEmpty) {
      return 'Requis';
    } else {
      if (!ExpiryMonthReg.hasMatch(value) || int.parse(value) > 12 || int.parse(value) ==0  ) {
        return 'Mois incorrect';
      }
    }
    return null;
  }
}