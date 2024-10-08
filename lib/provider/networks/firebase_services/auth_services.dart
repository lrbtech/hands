import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  //region Email

  Future<String> signUpWithEmailPassword(BuildContext context,
      {required UserDatas UserDatas}) async {
    return await _auth
        .createUserWithEmailAndPassword(
            email: UserDatas.email.validate(),
            password: DEFAULT_PASSWORD_FOR_FIREBASE)
        .then((userCredential) async {
      User currentUser = userCredential.user!;

      UserDatas.uid = currentUser.uid.validate();
      UserDatas.createdAt = Timestamp.now().toDate().toString();
      UserDatas.updatedAt = Timestamp.now().toDate().toString();
      UserDatas.playerId = getStringAsync(PLAYERID);

      log("Step 1 ${UserDatas.toFirebaseJson()}");

      return await setRegisterData(UserDatas: UserDatas);
    }).catchError((e) {
      throw "User is Not Registered in Firebase";
    });
  }

  Future<String> setRegisterData({required UserDatas UserDatas}) async {
    return await userService
        .addDocumentWithCustomId(
            UserDatas.uid.validate(), UserDatas.toFirebaseJson())
        .then((value) async {
      return value.id.validate();
    }).catchError((e) {
      throw false;
    });
  }

  Future<String> signInWithEmailPassword({required String email}) async {
    return await _auth
        .signInWithEmailAndPassword(
            email: email, password: DEFAULT_PASSWORD_FOR_FIREBASE)
        .then((value) async {
      return value.user!.uid.validate();
    }).catchError((e) async {
      appStore.setLoading(false);
      log(e.toString());
      FirebaseAuth.instance.currentUser?.delete();
      throw "User Not Found";
    });
  }
//endregion
}
