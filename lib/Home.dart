import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _list = [
    "Rio de Janeiro",
    "São Paulo",
    "Orlando",
    "Maragogi",
    "Porto de Galinhas",
    "Arraial D'Ajuda"
  ];

  _openMap(){

  }

  _deleteTrip(){

  }

  _addLocal(){
    
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
                itemBuilder: (context, index){
                String title = _list[index];
                return GestureDetector(
                  onTap: (){
                    _openMap();
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: (){
                              _deleteTrip();
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
      ),
    );
  }
}
