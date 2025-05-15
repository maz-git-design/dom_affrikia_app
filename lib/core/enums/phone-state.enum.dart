enum PhoneStateEnum { lock, unlockPartially, unlock }

PhoneStateEnum? getPhoneState(int state) {
  switch (state) {
    case 0:
      return PhoneStateEnum.lock;
    case 1:
      return PhoneStateEnum.unlockPartially;
    case 2:
      return PhoneStateEnum.unlock;
    default:
      return null;
  }
}
