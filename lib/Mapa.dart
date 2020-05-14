import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Mapa extends StatefulWidget {

  String idTrip;
  Mapa({this.idTrip});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Mapa> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  CameraPosition _positionCamera = CameraPosition(
      target: LatLng(-23.562436, -46.655005),
      zoom: 18
  );
  Firestore _db = Firestore.instance;

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
  }

  _addMarker(LatLng latLng) async {

    List<Placemark> listAddress = await Geolocator().placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if(listAddress != null && listAddress.length > 0){
      Placemark address = listAddress[0];
      String street = address.thoroughfare;

      Marker marker = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(
              title: street
          )
      );

      setState(() {
        _markers.add(marker);

        Map<String, dynamic> trip = Map();
        trip["title"] = street;
        trip["latitude"] = latLng.latitude;
        trip["longitude"] = latLng.longitude;

        _db.collection("trips").add(trip);
      });
    }
    }

  _moveCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        _positionCamera
      )
    );
  }

  _addListenerLocation(){
    var geolocator = Geolocator();
    var localOptions = LocationOptions(accuracy: LocationAccuracy.high);
    geolocator.getPositionStream(localOptions).listen((Position position) {
      setState(() {
        _positionCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
          zoom: 18
        );
        _moveCamera();
      });
    });
  }

  _retrievesTripToId(String idTrip) async {
    if(idTrip != null){
      DocumentSnapshot documentSnapshot = await _db
          .collection("trips")
          .document(idTrip)
          .get();

      var data = documentSnapshot.data;
      String title = data["title"];
      LatLng latLng = LatLng(
          data["latitude"],
          data["longitude"]
      );

      setState(() {
        Marker marker = Marker(
            markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(
                title: title
            )
        );

        _markers.add(marker);
        _positionCamera = CameraPosition(
            target: latLng,
          zoom: 18
        );
        _moveCamera();
      });

    } else {
      _addListenerLocation();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _retrievesTripToId(widget.idTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa"),),
      body: Container(
        child: GoogleMap(
          markers: _markers,
          mapType: MapType.normal,
            initialCameraPosition: _positionCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _addMarker,
        ),
      ),
    );
  }
}
