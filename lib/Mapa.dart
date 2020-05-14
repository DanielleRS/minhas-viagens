import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Mapa extends StatefulWidget {
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

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
  }

  _displayMarker(LatLng latLng) async {

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

  @override
  void initState() {
    // TODO: implement initState
    _addListenerLocation();
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
          onLongPress: _displayMarker,
        ),
      ),
    );
  }
}
