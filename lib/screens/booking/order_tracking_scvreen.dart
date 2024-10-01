import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'dart:ui' as ui;

import 'package:hands_user_app/services/firebase/firebase_database_service.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({required this.bookingId, this.userLocation, this.driverName, this.userImage, super.key});
  final int bookingId;
  final LatLng? userLocation;
  final String? driverName;
  final String? userImage;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  StreamSubscription<DatabaseEvent>? _databaseEvent;

  late Uint8List markerIcon;
  late Uint8List driverMarkerIcon;

  bool _added = false;
  String? _mapStyle;

  late GoogleMapController _mapController;
  LatLng? driverLocation;

  bool _recordExists = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    init();
  }

  @override
  void dispose() {
    // TODO: implement initState
    super.dispose();
    _databaseEvent?.cancel();
    try {
      _mapController.dispose();
    } catch (e) {
      print(e.toString());
    }
    driverLocation = null;
  }

  init() async {
    appStore.setLoading(true);
    loadMarkerIcon().then((value) async {
      final reference = FirebaseDatabaseService.getDatabaseReference().child(JOB_TRACKING).child(widget.bookingId.toString());

      bool isExist = await checkIfRecordExists(reference: reference, bookingId: widget.bookingId.toString());

      print('isExist : $isExist');
      if (isExist) {
        _databaseEvent = reference.onChildChanged.listen((event) async {
          // Assuming 'event' is the DataSnapshot
          var snapshotValue = json.encode(event.snapshot.value);
          print('Data is ${snapshotValue}');
          var decodedData = json.decode(snapshotValue);
          print('decodedData is ${decodedData}');

          driverLocation = LatLng(decodedData['latitude'], decodedData['longitude']);
          if (_mapController != null) {
            _mapController.animateCamera(CameraUpdate.newLatLng(driverLocation!));
          }
          appStore.setLoading(false);
          setState(() {});
          // Now you can access the data in snapshotValue and perform necessary actions
        });
      } else {
        appStore.setLoading(false);
        setState(() {});
      }
    });
  }

  Future<bool> checkIfRecordExists({required DatabaseReference reference, required String bookingId}) async {
    // Check if the record exists
    try {
      DatabaseEvent event = await reference.once();
      if (event.snapshot.value != null) {
        print('Record is HERE!');
        // Record Exists
        print('${event.snapshot.value}');
        print(event.snapshot.value);
        var snapshotValue = json.encode(event.snapshot.value);
        var decodedData = json.decode(snapshotValue);
        driverLocation = LatLng(decodedData['location']['latitude'], decodedData['location']['longitude']);
        _recordExists = true;
        appStore.setLoading(false);

        setState(() {});
        return true;
      } else {
        print('Record does not exist');
        // Record DOESN'T Exist
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> loadMarkerIcon() async {
    driverMarkerIcon = await getBytesFromAsset("assets/images/hands_driver.png", 200);
    setState(() {});
    markerIcon = await getBytesFromAsset("assets/images/user_marker.png", 200);
    setState(() {});
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    // print(' userLocation = ${widget.userLocation != null}');
    return AppScaffold(
      appBarTitle: '${language.lblBookingID} : #${widget.bookingId}',
      child: !_recordExists
          ? Column(
              children: [
                lottie.Lottie.asset('assets/lottie/delivery.json'),
                30.height,
                Text(
                  appStore.isArabic ? "" : "${(widget.driverName != null ? widget.driverName.validate() : "The Proffessional")} Is On The Way !",
                  style: boldTextStyle(size: 18),
                  textAlign: TextAlign.center,
                ),
                10.height,
                Text(
                  appStore.isArabic ? "" : 'tracking is not available currently , please keep waiting , driver is on the way .',
                  style: primaryTextStyle(size: 12),
                  textAlign: TextAlign.center,
                ).paddingSymmetric(horizontal: 20),
                40.height,
              ],
            )
          : Stack(
              children: [
                driverLocation == null
                    ? SizedBox()
                    : GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(zoom: 14.47, target: driverLocation ?? LatLng(24.38768, 78.75475)),
                        markers: driverLocation == null
                            ? {}
                            : widget.userLocation != null
                                ? <Marker>{
                                    Marker(
                                      markerId: const MarkerId('driver'),
                                      position: driverLocation!,
                                      icon: BitmapDescriptor.fromBytes(driverMarkerIcon),
                                    ),

                                    Marker(
                                      markerId: MarkerId('user'),
                                      position: widget.userLocation!,
                                      icon: BitmapDescriptor.fromBytes(markerIcon),
                                    )
                                    // Marker(
                                    //     icon: BitmapDescriptor.fromBytes(markerIcon),
                                    //     markerId: const MarkerId('Destination'),
                                    //     position: LatLng(bookingController.bookingDetailsContent!.serviceAddress!.lat!.toDouble(), bookingController.bookingDetailsContent!.serviceAddress!.lon!.toDouble()))
                                  }
                                : <Marker>{
                                    Marker(markerId: const MarkerId('driver'), position: driverLocation!),
                                  },
                        onCameraMoveStarted: () => setState(() {
                          _added = false;
                        }),
                        onMapCreated: (GoogleMapController controller) {
                          setState(() {
                            _mapController = controller;
                            _added = true;
                            // _mapController.setMapStyle(_mapStyle);
                          });
                        },
                      ),
                LoaderWidget().visible(appStore.isLoading)
              ],
            ),
    );
  }
}
