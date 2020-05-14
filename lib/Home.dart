import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'Mapa.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;

  _openMap(String idTrip){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Mapa(idTrip: idTrip)
        )
    );
  }

  _deleteTrip(String idTrip){
    _db.collection("trips").document(idTrip).delete();
  }

  _addLocal(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Mapa()
        )
    );
  }

  _addListenerTrips(){
    final stream = _db.collection("trips").snapshots();

    stream.listen((data) {
      _controller.add(data);
    });
  }

  @override
  void initState() {
    super.initState();
    _addListenerTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas viagens"),),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
            backgroundColor: Color(0xff0066cc),
            onPressed: (){
              _addLocal();
            },
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.none:
                QuerySnapshot querySnapshot = snapshot.data;
                List<DocumentSnapshot> trips = querySnapshot.documents.toList();

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: trips.length,
                          itemBuilder: (context, index){

                            DocumentSnapshot item = trips[index];
                            String title = item["title"];
                            String idTrip = item.documentID;

                            return GestureDetector(
                              onTap: (){
                                _openMap(idTrip);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(title),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: (){
                                          _deleteTrip(idTrip);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    )
                  ],
                );
                break;
            }
          }
      ),
    );
  }
}
