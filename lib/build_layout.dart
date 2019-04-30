import 'dart:convert' as JSON;
import 'dart:async';
import 'package:flutter/material.dart';
import 'customtextstyle.dart';
import 'package:http/http.dart' as http;
import 'evento.dart';
import 'spazio.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  String urlevento = "http://10.0.2.2:3000/events";
  String urlspazioget = "http://10.0.2.2:3000/spazi";

  var _eventi = <Evento>[];
  var _spazi = <Spazio>[];

  Future<List<Evento>> _loadEvento() async {
    var response = await http.get(urlevento);
    if (response.statusCode == 200) {
      final eventiJSON = JSON.jsonDecode(response.body);
      for (var eventoJSON in eventiJSON) {
        final evento = new Evento(
            eventoJSON["nome_eve"],
            eventoJSON["data_inizio"],
            eventoJSON["data_fine"],
            eventoJSON["nome_via"]);
        _eventi.add(evento);
        print('regno ' + evento.nome);
      }
    } else
      print("Request failed with status: ${response.statusCode}.");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _loadEvento(),
        builder: (BuildContext context, AsyncSnapshot<List<Evento>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text("OPS! Qualcosa è andato storto");
            case ConnectionState.waiting:
              return new Center(child: new CircularProgressIndicator());
            case ConnectionState.active:
              return new Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return new Text('${snapshot.error}');
              } else
                return new Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      _eventi[0].nome,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "04/05 - 10/05",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 3,
                      child: Container(
                        margin:
                            new EdgeInsetsDirectional.only(start: 2, end: 2),
                        color: Colors.blue,
                      )),
                  Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(_eventi[0].via),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: SizedBox(
                            height: 10,
                            width: 10,
                            child: Container(
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                        Text(
                          'posti occupati',
                        ),
                        Padding(
                          padding: EdgeInsets.all(14),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: Container(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              Text(
                                'posti liberi',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: FutureBuilder(
                        future: _loadSpazi(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Spazio>> snapshot) {
                          return GridView.count(
                            mainAxisSpacing: 40,
                            crossAxisSpacing: 5,
                            crossAxisCount: 6,
                            padding: EdgeInsets.all(8),
                            childAspectRatio: 10 / 7,
                            children: _buildGrid(context),
                          );
                        }),
                  )
                ]);
          }
        },
      ),
    );
  }

  Future<List<Spazio>> _loadSpazi() async {
    var response = await http.get(urlspazioget);
    if (response.statusCode == 200) {
      final spaziJSON = JSON.jsonDecode(response.body);
      for (var spazioJSON in spaziJSON) {
        final spazio = new Spazio(
            spazioJSON["cod"],
            spazioJSON["descrizione_spazio"],
            spazioJSON["dimensione_spazio"],
            spazioJSON["prezzo_spazio"],
            spazioJSON["stato_spazio"]);
        _spazi.add(spazio);
        print('regno ' + spazio.cod_spazio);
      }
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
  }

  List<Card> _buildGrid(BuildContext context) {
    return _spazi.map((spazio) {
      return Card(
          color: spazio.stato == 0 ? Colors.orangeAccent : Colors.green,
          clipBehavior: Clip.antiAlias,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: ListTile(
                  onTap: () => _showDialog(context, spazio),
                  leading: Flex(direction: Axis.vertical, children: <Widget>[
                    Container(
                        child: Center(
                            child: Text(
                      spazio.cod_spazio,
                      style: TextStyle(fontSize: 12),
                    ))),
                  ]),
                )),
              ]));
      //Text(info.stato.toString())
    }).toList();
  }
}

void _showDialog(context, Spazio spazio) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
              height: 400,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      spazio.cod_spazio,
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: spazio.stato == 0
                          ? Colors.orangeAccent
                          : Colors.green,
                    ),
                    height: 60,
                  ),
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                        //color: info.owned ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )),
                    // color: info.owned ? Colors.red : Colors.green,
                  ),
                  SizedBox(height: 20),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        spazio.desc_spazio,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        spazio.dim_spazio,
                        style: CustomTextStyle.display5(context),
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        spazio.prezzo.toString(),
                        style: CustomTextStyle.display5(context),
                      )),
                ],
              )),
          actions: <Widget>[
            FlatButton(
                child: Text('GESTISCI POSTO'),
                onPressed: () => http.post("http://10.0.2.2:3000/dati_spazio/" +
                            spazio.stato.toString() ==
                        '0'
                    ? spazio.stato.toString() == '1'
                    : spazio.stato.toString() ==
                        '0' + "/" + spazio.cod_spazio.toString()))
          ],
        );
      });
}

class MyDialog extends StatefulWidget {
  Spazio spazio;

  MyDialog(this.spazio){
  }

  @override
  _MyButtonState createState() {
    _MyButtonState();
  }
}

class _MyButtonState extends State<MyDialog> {
  Spazio spazio;

  @override
  Widget build(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
                height: 400,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        spazio.cod_spazio,
                        style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: spazio.stato == 0
                            ? Colors.orangeAccent
                            : Colors.green,
                      ),
                      height: 60,
                    ),
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        //color: info.owned ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          )),
                      // color: info.owned ? Colors.red : Colors.green,
                    ),
                    SizedBox(height: 20),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          spazio.desc_spazio,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          spazio.dim_spazio,
                          style: CustomTextStyle.display5(context),
                        )),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          spazio.prezzo.toString(),
                          style: CustomTextStyle.display5(context),
                        )),
                  ],
                )),
            actions: <Widget>[
              FlatButton(
                onPressed:()=> setState(() {
                  spazio.stato==0?spazio.stato==1:spazio.stato==0;
                })
          //HERE ADD HTTP POST AND SETSTATE TO CHANGE COLOR BASED ON STATO SPAZIO
            /*http.post("http://10.0.2.2:3000/dati_spazio/" +
                      spazio.stato.toString() ==
                      '0'
                      ? spazio.stato.toString() == '1'
                      : spazio.stato.toString() ==
                      '0' + "/" + spazio.cod_spazio.toString()))*/
              )],
          );
        });


  }
}