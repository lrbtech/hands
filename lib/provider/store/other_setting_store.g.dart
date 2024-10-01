// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_setting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OtherSettingStore on _OtherSettingStore, Store {
  late final _$maintenanceModeEnableAtom =
      Atom(name: '_OtherSettingStore.maintenanceModeEnable', context: context);

  @override
  int get maintenanceModeEnable {
    _$maintenanceModeEnableAtom.reportRead();
    return super.maintenanceModeEnable;
  }

  @override
  set maintenanceModeEnable(int value) {
    _$maintenanceModeEnableAtom.reportWrite(value, super.maintenanceModeEnable,
        () {
      super.maintenanceModeEnable = value;
    });
  }

  late final _$enableChatGptAtom =
      Atom(name: '_OtherSettingStore.enableChatGpt', context: context);

  @override
  int get enableChatGpt {
    _$enableChatGptAtom.reportRead();
    return super.enableChatGpt;
  }

  @override
  set enableChatGpt(int value) {
    _$enableChatGptAtom.reportWrite(value, super.enableChatGpt, () {
      super.enableChatGpt = value;
    });
  }

  late final _$testWithoutKeyAtom =
      Atom(name: '_OtherSettingStore.testWithoutKey', context: context);

  @override
  int get testWithoutKey {
    _$testWithoutKeyAtom.reportRead();
    return super.testWithoutKey;
  }

  @override
  set testWithoutKey(int value) {
    _$testWithoutKeyAtom.reportWrite(value, super.testWithoutKey, () {
      super.testWithoutKey = value;
    });
  }

  late final _$enableAutoAssignAtom =
      Atom(name: '_OtherSettingStore.enableAutoAssign', context: context);

  @override
  int get enableAutoAssign {
    _$enableAutoAssignAtom.reportRead();
    return super.enableAutoAssign;
  }

  @override
  set enableAutoAssign(int value) {
    _$enableAutoAssignAtom.reportWrite(value, super.enableAutoAssign, () {
      super.enableAutoAssign = value;
    });
  }

  late final _$chatGptKeyAtom =
      Atom(name: '_OtherSettingStore.chatGptKey', context: context);

  @override
  String get chatGptKey {
    _$chatGptKeyAtom.reportRead();
    return super.chatGptKey;
  }

  @override
  set chatGptKey(String value) {
    _$chatGptKeyAtom.reportWrite(value, super.chatGptKey, () {
      super.chatGptKey = value;
    });
  }

  late final _$firebaseKeyAtom =
      Atom(name: '_OtherSettingStore.firebaseKey', context: context);

  @override
  String get firebaseKey {
    _$firebaseKeyAtom.reportRead();
    return super.firebaseKey;
  }

  @override
  set firebaseKey(String value) {
    _$firebaseKeyAtom.reportWrite(value, super.firebaseKey, () {
      super.firebaseKey = value;
    });
  }

  late final _$_OtherSettingStoreActionController =
      ActionController(name: '_OtherSettingStore', context: context);

  @override
  void setFirebaseKey(String val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setFirebaseKey');
    try {
      return super.setFirebaseKey(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChatGptEnable(int val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setChatGptEnable');
    try {
      return super.setChatGptEnable(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTestWithoutKey(int val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setTestWithoutKey');
    try {
      return super.setTestWithoutKey(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnableAutoAssign(int val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setEnableAutoAssign');
    try {
      return super.setEnableAutoAssign(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChatGptKey(String val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setChatGptKey');
    try {
      return super.setChatGptKey(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMaintenanceModeEnable(int val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setMaintenanceModeEnable');
    try {
      return super.setMaintenanceModeEnable(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
maintenanceModeEnable: ${maintenanceModeEnable},
enableChatGpt: ${enableChatGpt},
testWithoutKey: ${testWithoutKey},
enableAutoAssign: ${enableAutoAssign},
chatGptKey: ${chatGptKey},
firebaseKey: ${firebaseKey}
    ''';
  }
}
