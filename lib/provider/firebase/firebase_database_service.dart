import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/jobRequest/models/bidder_data.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../jobRequest/models/post_job_data.dart';

FirebaseDatabaseService firebaseDbService =
    FirebaseDatabaseService.getInstance();

class FirebaseDatabaseService {
  // Private static instance variable
  static FirebaseDatabaseService? _instance;

  // Firebase database reference
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // Private constructor
  FirebaseDatabaseService._();

  // Static method to access the instance
  static FirebaseDatabaseService getInstance() {
    if (_instance == null) {
      _instance = FirebaseDatabaseService._();
    }
    return _instance!;
  }

  Future<void> firebaseJobBid(
      {required BidderData bidderData, required String postJobId}) async {
    try {
      print(bidderData.toJson());
      await _databaseReference
          .child(JOB_REQUESTS)
          .child(postJobId)
          .child('bidders')
          .child(bidderData.id.toString())
          .set(
            bidderData.toJson(),
          );
    } catch (error) {
      print("Error-----$error");
    }
  }

  // Tracking Functionality
  bool _isTrackingOver = false;

  Future<void> startTracking({required String bookingId}) async {
    Position? position = await getCurrentLocation();
    print('Current position is $position');
    if (position != null) {
      updateTracking(
          bookingId: bookingId,
          latitude: position.latitude,
          longitude: position.longitude);
    }
    if (!appStorePro.isLocationTracked) {
      appStorePro.enableTracking(bookingId.toInt());
    }
    Timer.periodic(Duration(seconds: LIVE_TRACKING_TIMER_SECONDS),
        (timer) async {
      print('Started');
      if (_isTrackingOver) {
        print('Tracking is over');
        timer.cancel();
        return;
      }
      Position? position = await getCurrentLocation();
      print('Current position is $position');
      if (position != null) {
        updateTracking(
            bookingId: bookingId,
            latitude: position.latitude,
            longitude: position.longitude);
      }
    });
  }

  Future<void> stopTracking({required String bookingId}) async {
    print('Stopped tracking');
    _isTrackingOver = true;

    appStorePro.disableTracking();
    try {
      await _databaseReference.child(JOB_TRACKING).child(bookingId).remove();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateTracking(
      {required String bookingId,
      required double latitude,
      required double longitude}) async {
    try {
      await _databaseReference.child(JOB_TRACKING).child(bookingId).set(
        {
          "isDone": 0,
          "location": {
            "latitude": latitude,
            "longitude": longitude,
          },
        },
      );
      print('___________________ Updated ___________________');
    } catch (error) {
      print("Error---updateTracking---$error");
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission locationPermission =
          await Geolocator.checkPermission();
      if ([LocationPermission.always, LocationPermission.whileInUse]
          .contains(locationPermission)) {
        Position currentLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        return currentLocation;
      } else {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      print("getCurrentLocation() catched error : $e");
      return null;
    }
  }
  //   Future<void> firebaseJobRequest({required PostJobData jobRequest}) async {
  //   try {
  //     await _databaseReference.child(JOB_REQUEST).child(jobRequest.id.toString()).set({
  //       'job': jobRequest.toJson(),
  //       'bidders': json.decode('{}'),
  //     });
  //   } catch (error) {
  //     print("Error-----$error");
  //   }
  // }

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
