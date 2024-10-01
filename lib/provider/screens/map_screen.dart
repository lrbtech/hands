import 'dart:async';

import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/back_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_data.dart';
import 'package:hands_user_app/provider/service_address/service_addresses_screen.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/location_service.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constant.dart';

class MapScreen extends StatefulWidget {
  final double? latLong;
  final double? latitude;
  final AddressModel? address;
  final String fromPage;
  final int? id;

  MapScreen({
    this.latLong,
    this.latitude,
    this.address,
    this.fromPage = '',
    this.id,
  });

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  String _currentAddress = '';

  final destinationAddressController = TextEditingController();
  final destinationAddressFocusNode = FocusNode();

  String _destinationAddress = '';
  LatLng? _selectedLatLng;

  Set<Marker> markers = {};

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> deleteAddress() async {
    // appStorePro.setLoading(true);
    await removeAddress(widget.id).then((value) {
      // toast(value.message);
      // finish(context);

      // setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    // appStorePro.setLoading(false);
  }

  @override
  void initState() {
    super.initState();

    try {
      bool isUpdate = widget.address != null;

      if (isUpdate) {
        _selectedLatLng = LatLng(widget.address!.latitude.toDouble(),
            widget.address!.longitude.toDouble());
        destinationAddressController.text = widget.address!.address.validate();
        _destinationAddress = destinationAddressController.text.validate();
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId(_currentAddress),
          position: LatLng(widget.address!.latitude.toDouble(),
              widget.address!.longitude.toDouble()),
          infoWindow: InfoWindow(
              title: 'Start $_currentAddress', snippet: _destinationAddress),
          icon: BitmapDescriptor.defaultMarker,
        ));
        Timer(2.seconds, () {
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(widget.address!.latitude.toDouble(),
                      widget.address!.longitude.toDouble()),
                  zoom: 18.0),
            ),
          );
          setState(() {});
        });

        setState(() {});
      } else {
        afterBuildCreated(() {
          _getCurrentLocation();
        });
      }
    } catch (e) {
      print('Error from inside is ${e.toString()}');
    }
  }

  // Method for retrieving the current location
  void _getCurrentLocation() async {
    print('Getting current location...');
    try {
      appStorePro.setLoading(true);
      await getUserLocationPosition().then((position) async {
        print('Position = Lat:${position.latitude} Lng:${position.longitude}');
        await setAddress();

        _selectedLatLng = LatLng(position.latitude, position.longitude);
        print('_selectedLatLng = ${_selectedLatLng}');

        print('Animating to position...');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0),
          ),
        );

        print('Animated...');

        markers.clear();
        print('Adding markers...');
        markers.add(Marker(
          markerId: MarkerId(_currentAddress),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
              title: 'Start $_currentAddress', snippet: _destinationAddress),
          icon: BitmapDescriptor.defaultMarker,
        ));

        setState(() {});
        print('Markers Added...');
      }).catchError((e) {
        toast(e.toString());
      });

      appStorePro.setLoading(false);
    } catch (e) {
      print('Error getting current location: ${e.toString()}');
    }
  }

  // Method for retrieving the address
  Future<void> setAddress() async {
    try {
      Position position = await getUserLocationPosition().catchError((e) {
        //
      });

      _currentAddress = await buildFullAddressFromLatLong(
              position.latitude, position.longitude)
          .catchError((e) {
        log(e);
      });
      destinationAddressController.text = _currentAddress;
      _destinationAddress = _currentAddress;

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _handleTap(LatLng point) async {
    appStorePro.setLoading(true);

    markers.clear();
    markers.add(Marker(
      markerId: MarkerId(point.toString()),
      position: point,
      infoWindow: InfoWindow(),
      icon: BitmapDescriptor.defaultMarker,
    ));

    _selectedLatLng = point;
    destinationAddressController.text =
        await buildFullAddressFromLatLong(point.latitude, point.longitude)
            .catchError((e) {
      log(e);
    });

    _destinationAddress = destinationAddressController.text;

    appStorePro.setLoading(false);
    setState(() {});
  }

  _saveAddress() async {
    if (widget.id != null) {
      await deleteAddress();
    }

    String street = await buildStreetNameFromLatLong(
      _selectedLatLng!.latitude,
      _selectedLatLng!.longitude,
    );
    debugPrint(street);
    appStorePro.setSignupAddress(AddressModel(
      address: street,
      latitude: _selectedLatLng!.latitude.toString(),
      longitude: _selectedLatLng!.longitude.toString(),
    ));
    finish(context);
    if (widget.fromPage == 'service_addresses') {
      await addAddresses(AddressModel(
        address: street,
        latitude: _selectedLatLng!.latitude.toString(),
        longitude: _selectedLatLng!.longitude.toString(),
      ).toJson());
      finish(context);
      // finish(context);
      // if (widget.id != null) finish(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ServiceAddressesScreen(),
        ),
      );
      print('From service_addresses DONE');
    }
    // showInDialog(
    //   context,
    //   contentPadding: EdgeInsets.zero,
    //   dialogAnimation: DialogAnimation.SCALE,
    //   transitionDuration: 200.milliseconds,
    //   hideSoftKeyboard: true,
    //   builder: (p0) => AddressDialog(
    //     address: _destinationAddress,
    //     latitude: _selectedLatLng!.latitude,
    //     longitude: _selectedLatLng!.longitude,
    //     street: street,
    //     addressModel: widget.address,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarWidget(
        languages.selectAddress,
        backWidget: BackWidget(),
        color: primaryColor,
        elevation: 0,
        textColor: white,
        textSize: APP_BAR_TEXT_SIZE,
      ),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            scrollGesturesEnabled: true,
            markers: Set<Marker>.from(markers),
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: _handleTap,
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: context.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: primaryColor),
                            borderRadius: BorderRadius.circular(100)),
                        elevation: 20,
                        child: InkWell(
                          splashColor: context.primaryColor.withOpacity(0.8),
                          child: SizedBox(
                              width: 50, height: 50, child: Icon(Icons.add)),
                          onTap: () {
                            mapController.animateCamera(CameraUpdate.zoomIn());
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    ClipOval(
                      child: Material(
                        color: context.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: primaryColor),
                            borderRadius: BorderRadius.circular(100)),
                        elevation: 20,
                        child: InkWell(
                          splashColor: context.primaryColor.withOpacity(0.8),
                          child: SizedBox(
                              width: 50, height: 50, child: Icon(Icons.remove)),
                          onTap: () {
                            mapController.animateCamera(CameraUpdate.zoomOut());
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    ClipOval(
                      child: Material(
                        color: primaryColor, // button color
                        child: Icon(
                          Icons.my_location,
                          size: 25,
                          color: white,
                        ).paddingAll(10),
                      ),
                    ).paddingSymmetric(horizontal: 8).onTap(() async {
                      appStorePro.setLoading(true);

                      await getUserLocationPosition().then((value) {
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: LatLng(value.latitude, value.longitude),
                                zoom: 18.0),
                          ),
                        );

                        _handleTap(LatLng(value.latitude, value.longitude));
                      }).catchError(onError);

                      appStorePro.setLoading(false);
                    }),
                    8.height,
                  ],
                ).paddingLeft(10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: destinationAddressController,
                      focus: destinationAddressFocusNode,
                      textStyle: primaryTextStyle(color: context.primaryColor),
                      enabled: false,
                      decoration: inputDecoration(
                        context,
                      ).copyWith(fillColor: Colors.white),
                    ),
                  ],
                ),
                8.height,
                AppButton(
                  width: context.width(),
                  height: 16,
                  color: primaryColor,
                  text: languages.selectAddress.toUpperCase(),
                  textStyle: boldTextStyle(color: white, size: 12),
                  onTap: () {
                    if (destinationAddressController.text.isNotEmpty) {
                      _saveAddress();
                    } else {
                      toast(languages.lblPlsSelectAddress);
                    }
                  },
                ),
                8.height,
              ],
            ).paddingAll(16),
          ),
          Observer(
              builder: (context) =>
                  LoaderWidget().visible(appStorePro.isLoading))
        ],
      ),
    );
  }
}
