import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location.dart';
import '../providers/sellsProvider.dart';
import '../widgets/qrReaderSells.dart';

class SellsMap extends StatefulWidget {
  final bool openPlace;

  SellsMap({
    this.openPlace = false,
  });

  @override
  _SellsMapState createState() => _SellsMapState();
}

class _SellsMapState extends State<SellsMap> {
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  String address;
  bool moved = false;
  var currentLocation = Position();
  BitmapDescriptor customIcon;
  LatLng userLatLng;

  createMarker(context) {
    if (customIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(
        context,
        size: Size.square(12.0),
      );
      BitmapDescriptor.fromAssetImage(configuration, 'assets/transport.png')
          .then((icon) {
        setState(() {
          customIcon = icon;
        });
      });
    }
  }

  void _onDone(BuildContext context) {
    Navigator.pop(context, [userLatLng, address]);
  }

//   Future<String> _getAddress(Position pos) async {
//     List<Placemark> placeMarks = await Geolocator()
//         .placemarkFromCoordinates(pos.latitude, pos.longitude);
//     if (placeMarks != null && placeMarks.isNotEmpty) {
//       final Placemark pos = placeMarks[0];
// //      print(':::::::::::::' + pos.thoroughfare + ', ' + pos.locality);
//       address = pos.thoroughfare + ', ' + pos.locality;
//       return address;
//     }
//     return "";
//   }

  Future<void> _getLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    userLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    print("BeforeRemove:" +
        'lat :' +
        currentLocation.latitude.toString() +
        '-long :' +
        currentLocation.longitude.toString());
    // _getAddress(currentLocation);
    setState(() {
      _markers.clear();
      final marker = Marker(
        draggable: false,
        icon: customIcon,
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: tr('map.marker_info')),
      );
      setState(() {
        _markers["Current Location"] = marker;
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 20,
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    initPlatformState();
    _getLocation();
    super.initState();
  }

  Future<void> initPlatformState() async {
    if (Provider.of<GPS>(context, listen: false).locationOn == false) {
      AppSettings.openLocationSettings();
      Provider.of<GPS>(context, listen: false).locationOn = true;
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    createMarker(context);
    Provider.of<SellsData>(context, listen: false).stores.data.forEach((store) {
      if (store.lat != null && store.long != null) {
        final marker = Marker(
          markerId: MarkerId(store.storeName),
          position: LatLng(
              double.tryParse(store.lat) == null
                  ? 120.000
                  : double.tryParse(store.lat),
              double.tryParse(store.long) == null
                  ? 120.000
                  : double.tryParse(store.long)),
          infoWindow: InfoWindow(title: store.storeName),
          onTap: () async {
            if (currentLocation.latitude != null &&
                currentLocation.longitude != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QrReaderSells(),
                ),
              );
            }
          },
        );
        _markers[store.storeName] = marker;
      }
    });
    return SafeArea(
      child: Scaffold(
        body: currentLocation == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: <Widget>[
                  GoogleMap(
                    onMapCreated: onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(31.037933, 31.381523),
                      zoom: 5.0,
                    ),
                    markers: _markers.values.toSet(),
                  ),
                  Positioned(
                    bottom: 100.0,
                    right: 20.0,
                    child: currentLocation.latitude == null ||
                            currentLocation.latitude == null
                        ? CircularProgressIndicator()
                        : FloatingActionButton(
                            onPressed: () async {
                              setState(() {
                                currentLocation = Position();
                              });
                              await _getLocation();
                              // await _getAddress(currentLocation);
                            },
                            tooltip: 'Get Location',
                            child: Icon(
                              Icons.location_searching,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  widget.openPlace
                      ? Positioned(
                          bottom: 30.0,
                          right: 20.0,
                          child: currentLocation.latitude == null ||
                                  currentLocation.latitude == null
                              ? SizedBox()
                              : RaisedButton(
                                  onPressed: () {
                                    userLatLng = LatLng(
                                        currentLocation.latitude,
                                        currentLocation.longitude);
                                    Navigator.of(context).pop([userLatLng]);
                                    print('*************' +
                                        userLatLng.latitude.toString() +
                                        '    ' +
                                        userLatLng.longitude.toString());
                                  },
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  // tooltip: 'Go to shop',
                                  child: Icon(
                                    Icons.done,
                                    color: Colors.white,
                                  ),
                                ),
                        )
                      : SizedBox(),
                ],
              ),
      ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
