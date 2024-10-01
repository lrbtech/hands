import 'package:mobx/mobx.dart';

part 'other_setting_store.g.dart';

class OtherSettingStore = _OtherSettingStore with _$OtherSettingStore;

abstract class _OtherSettingStore with Store {
  @observable
  int postJobRequestEnable = 0;

  @observable
  int blogEnable = 0;

  @observable
  int socialLoginEnable = 0;

  @observable
  int googleLoginEnable = 0;

  @observable
  int appleLoginEnable = 0;

  @observable
  int otpLoginEnable = 0;

  @observable
  int maintenanceModeEnable = 0;

  @observable
  int enableChatGpt = 0;

  @observable
  int testWithoutKey = 0;

  @observable
  String chatGptKey = '';

  @observable
  String firebaseKey = '';

  @observable
  String disclimerText = '';

  @observable
  String disclimerTextAr = '';

  @action
  void setDisclimerText(String disclimerTextEnglish, String disclimerTextArabic) {
    disclimerText = disclimerTextEnglish;
    disclimerTextAr = disclimerTextArabic;
  }

  @action
  void setFirebaseKey(String val) {
    firebaseKey = val;
  }

  @action
  void setChatGptEnable(int val) {
    enableChatGpt = val;
  }

  @action
  void setTestWithoutKey(int val) {
    testWithoutKey = val;
  }

  @action
  void setChatGptKey(String val) {
    chatGptKey = val;
  }

  @action
  void setPostJobRequestEnable(int val) {
    postJobRequestEnable = val;
  }

  @action
  void setBlogEnable(int val) {
    blogEnable = val;
  }

  @action
  void setSocialLoginEnable(int val) {
    socialLoginEnable = val;
  }

  @action
  void setGoogleLoginEnable(int val) {
    googleLoginEnable = val;
  }

  @action
  void setAppleLoginEnable(int val) {
    appleLoginEnable = val;
  }

  @action
  void setOTPLoginEnable(int val) {
    otpLoginEnable = val;
  }

  @action
  void setMaintenanceModeEnable(int val) {
    maintenanceModeEnable = val;
  }
}
