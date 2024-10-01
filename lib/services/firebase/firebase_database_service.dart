import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/utils/constant.dart';

FirebaseDatabaseService firebaseDbService = FirebaseDatabaseService.getInstance();

class FirebaseDatabaseService {
  // Private static instance variable
  static FirebaseDatabaseService? _instance;

  // Firebase database reference
  static DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // Private constructor
  FirebaseDatabaseService._();

  static DatabaseReference getDatabaseReference() {
    return _databaseReference;
  }

  // Static method to access the instance
  static FirebaseDatabaseService getInstance() {
    if (_instance == null) {
      _instance = FirebaseDatabaseService._();
    }
    return _instance!;
  }

  Future<void> firebaseJobRequest({required PostJobData jobRequest}) async {
    try {
      // print('route is $JOB_REQUESTS / ${jobRequest.id.toString()}');
      await _databaseReference.child(JOB_REQUESTS).child(jobRequest.id.toString()).set({
        'job': jobRequest.toJson(),
        'bidders': json.decode('{}'),
        // 'isPublic': 1,
      });

      // print('kareem ispublic = 1');
    } catch (error) {
      print("Error-----$error");
    }
  }

  // Future<void> setPayment(String zoneId, String bookingId) async {
  //   try {
  //     await _databaseReference.child(zoneId).child(AppConstants.paymentStatus).child(bookingId).set({AppConstants.paymentStatus: "unpaid"});
  //   } catch (error) {
  //     print("Error-----$error");
  //   }
  // }

  // Future<void> sendPaymentStatus(String zoneId, String bookingId) async {
  //   try {
  //     await _databaseReference.child("$zoneId/${AppConstants.paymentStatus}").child(bookingId).set({AppConstants.paymentStatus: "paid"});
  //   } catch (error) {
  //     print("Error-----$error");
  //   }
  // }
}
