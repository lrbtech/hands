import 'package:mobx/mobx.dart';

part 'other_setting_store.g.dart';

class OtherSettingStorePro = _OtherSettingStore with _$OtherSettingStore;

abstract class _OtherSettingStore with Store {
  @observable
  int maintenanceModeEnable = 0;

  @observable
  int enableChatGpt = 0;

  @observable
  int testWithoutKey = 0;

  @observable
  int enableAutoAssign = 0;

  @observable
  String chatGptKey = '';

  @observable
  String firebaseKey = '';

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
  void setEnableAutoAssign(int val) {
    enableAutoAssign = val;
  }

  @action
  void setChatGptKey(String val) {
    chatGptKey = val;
  }

  @action
  void setMaintenanceModeEnable(int val) {
    maintenanceModeEnable = val;
  }
}
