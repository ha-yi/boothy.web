import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_web/material.dart';
import 'dart:html';
import 'package:firebase/firestore.dart' as fs;
import 'Splash.dart';
import 'file_helper.dart';
import 'firebase_helper.dart';
import 'package:csv/csv.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen(this.username, {Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool addEvent = false;
  bool addBooth = false;

  String selectedEvent;
  String selectedEventName;
  String selectedBooth;
  String selectedBoothID;
  String selectedBoothName;
  String selectedTamu;

  logout() {
    window.sessionStorage.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Splash()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: createBody(),
      appBar: AppBar(
        title: Text("BOOTH.y Dashboard"),
        actions: <Widget>[
          InkWell(
            onTap: logout,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Image.network(
                "https://www.pinclipart.com/picdir/big/182-1821638_logout-icon-png-red-clipart.png",
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  createBody() {
    return Row(
      children: <Widget>[
        Flexible(
          child: createEventsList(),
          flex: 1,
        ),
        Container(
          width: 2,
          color: Colors.lightBlue,
        ),
        Flexible(
          child: createBoothsList(),
          flex: 1,
        ),
        Container(
          width: 2,
          color: Colors.lightBlue,
        ),
        Flexible(
          child: createTamuList(),
          flex: 1,
        ),
      ],
    );
  }

  showError(String msg) {
    _key.currentState.showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red,));
  }

  createEventsList() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(
              "Events List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          daftarEvent.length >= 5
              ? Container()
              : Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 5),
                  child: addEvent
                      ? createAddEvent()
                      : MaterialButton(
                          onPressed: () {
                            addEvent = true;
                            if (daftarEvent.length >= 5) {
                              addEvent = false;
                              showError("Ada sudah mencapai list Maksimal pembuatan Event");
                            }
                            setState(() {});
                          },
                          color: Colors.lightGreen,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: Center(
                              child: Text(
                                "+ TAMBAH EVENT",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                ),
          StreamBuilder(
            stream: getEventsStream(),
            builder: (context, snap) {
              if (snap.hasData) {
                return generateEventList(snap.data);
              } else {
                return Text("loading....");
              }
            },
          ),
        ],
      ),
    );
  }

  createBoothsList() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(
              "Booth List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          selectedEvent == null || daftarBooth.length >= 5
              ? Container()
              : Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 5),
                  child: addBooth
                      ? createAddBooth()
                      : MaterialButton(
                          onPressed: () {
                            addBooth = true;
                            if (daftarBooth.length >= 5) {
                              addBooth = false;
                              showError("Ada sudah mencapai list Maksimal pembuatan Booth");
                            }
                            setState(() {});
                          },
                          color: Colors.lightBlue,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: Center(
                              child: Text(
                                "+ TAMBAH Booth",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                ),
          selectedEvent == null
              ? Container(
                  margin: EdgeInsets.all(20),
                  child: Text("Pilih event terlebih dahulu"),
                )
              : StreamBuilder(
                  stream: getBoothOfEventStream(selectedEvent),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return generateBoothsList(snap.data);
                    } else {
                      return Text("loading....");
                    }
                  },
                ),
        ],
      ),
    );
  }

  generateAndDownloadQRCode() {
    String url =
        "https://log.girilabs.com/boothy/event?id=${selectedEvent}&b=${selectedBoothID}";
    String encoded = Uri.encodeComponent(url);
    print(encoded);
    String qrApiUrl =
        "https://api.qrserver.com/v1/create-qr-code/?size=1000x1000&data=$encoded";
    window.open(qrApiUrl, "QR Code");
  }

  generateAndDownloadListTamu() {
    if (daftarTamu == null || daftarTamu.isEmpty) {
      showError("Daftar tamu masih kosong.");
      return;
    }

    List<List<dynamic>> data = List();
    data.add(["No", "Nama", "Email", "Phone", "Address", "Question"]);

    for (fs.DocumentSnapshot ds in daftarTamu) {
      data.add([
        data.length,
        ds.get("name") == null ? ds.get("a") : ds.get("name"),
        ds.get("email") == null ? ds.get("b") : ds.get("email"),
        ds.get("phone") == null ? ds.get("c") : ds.get("phone"),
        ds.get("address") == null ? ds.get("d") : ds.get("address"),
        ds.get("question") == null ? ds.get("e") : ds.get("question"),
      ]);
    }

    String csv = const ListToCsvConverter().convert(data);
    download('attendance.csv', utf8.encode(csv) as Uint8List, type: 'text/csv');
  }

  createTamuList() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(
              "Daftar Tamu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: selectedBooth == null
                    ? Container()
                    : Container(
                  margin:
                  EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 5),
                  child: MaterialButton(
                    onPressed: () {
                      generateAndDownloadQRCode();
                    },
                    color: Colors.lightBlue,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Center(
                        child: Text(
                          "DOWNLOAD QRCODE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: selectedBooth == null
                    ? Container()
                    : Container(
                  margin:
                  EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 5),
                  child: MaterialButton(
                    onPressed: () {
                      generateAndDownloadListTamu();
                    },
                    color: Colors.orange,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Center(
                        child: Text(
                          "DOWNLOAD DAFTAR TAMU",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          selectedBooth == null
              ? Container()
              : Container(
                  margin: EdgeInsets.all(20),
                  child: Text(
                      "Cetak QR Code dari Booth ini, kemudian Tamu dapan men-scan QR Code ini untuk mengisi buku tamu. Tamu dapat menggunakan Aplikasi QR Code Reader apapun untuk dapat mengisi buku tamu."),
                ),
          selectedBooth == null
              ? Container(
                  margin: EdgeInsets.all(20),
                  child: Text("Pilih Booth terlebih dahulu"),
                )
              : StreamBuilder(
                  stream: getTamuListStream(selectedBooth),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return generateTamuList(snap.data);
                    } else {
                      return Text("loading....");
                    }
                  },
                ),
        ],
      ),
    );
  }

  List<fs.DocumentSnapshot> daftarTamu = List();
  List<fs.DocumentSnapshot> daftarEvent = List();
  List<fs.DocumentSnapshot> daftarBooth = List();

  generateTamuList(fs.QuerySnapshot data) {
    if (data.docs.isEmpty) {
      return Center(child: Text("- data kosong -"));
    }
    daftarTamu = data.docs;
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () {
              selectedTamu = data.docs[i].ref.path;
              setState(() {});
            },
            onLongPress: () {},
            child: Container(
              color: selectedTamu == data.docs[i].ref.path
                  ? Colors.lightBlue[100]
                  : Colors.transparent,
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${data.docs[i].get("name") == null ? data.docs[i].get("a") : data.docs[i].get("name")}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${data.docs[i].get("email") == null ? data.docs[i].get("b") : data.docs[i].get("email")}",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "${data.docs[i].get("phone") == null ? data.docs[i].get("c") : data.docs[i].get("phone")}",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "${data.docs[i].get("address") == null ? data.docs[i].get("d") : data.docs[i].get("address")}",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Pertanyaan: ${data.docs[i].get("question") == null ? data.docs[i].get("e") : data.docs[i].get("question")}",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: data.docs.length,
        shrinkWrap: true,
        addRepaintBoundaries: true,
      ),
    );
  }

  generateBoothsList(fs.QuerySnapshot data) {
    if (data.docs.isEmpty) {
      return Center(child: Text("- data kosong -"));
    }
    daftarBooth = data.docs;
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () {
              selectedBooth = data.docs[i].ref.path;
              selectedBoothID = data.docs[i].id;
              selectedBoothName = data.docs[i].get("name");
              daftarTamu = null;
              setState(() {});
            },
            onLongPress: () {},
            child: Container(
              color: selectedBooth == data.docs[i].ref.path
                  ? Colors.lightBlue[100]
                  : Colors.transparent,
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    "${data.docs[i].get("kode")}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text("${data.docs[i].get("name")}"),
                  ),
                  InkWell(
                    onTap: () {
                      print("DELETING ${data.docs[i].ref.path}");
                      deleteDoc(data.docs[i].ref.path, () {
                        setState(() {});
                      });
                    },
                    child: Image.network(
                      "https://img.icons8.com/cotton/2x/delete-sign.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: data.docs.length,
        shrinkWrap: true,
      ),
    );
  }

  generateEventList(fs.QuerySnapshot data) {
    if (data.docs.isEmpty) {
      return Center(child: Text("- data kosong -"));
    }
    daftarEvent = data.docs;
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () {
              daftarBooth = List();
              selectedEvent = data.docs[i].id;
              selectedEventName = data.docs[i].get("name");
              selectedBooth = null;
              daftarTamu = null;
              setState(() {});
            },
            onLongPress: () {},
            child: Container(
              color: selectedEvent == data.docs[i].id
                  ? Colors.lightBlue[100]
                  : Colors.transparent,
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("${data.docs[i].get("name")}"),
                  InkWell(
                    onTap: () {
                      print("DELETING ${data.docs[i].ref.path}");
                      deleteDoc(data.docs[i].ref.path, () {
                        setState(() {});
                      });
                    },
                    child: Image.network(
                      "https://img.icons8.com/cotton/2x/delete-sign.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: data.docs.length,
        shrinkWrap: true,
      ),
    );
  }

  Stream getEventsStream() {
    return getEvents(widget.username);
  }

  createAddEvent() {
    GlobalKey<FormState> _key = GlobalKey();
    String name;

    return Form(
      key: _key,
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: TextFormField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Nama Event",
                hintText: "Nama Event",
              ),
              validator: (value) {
                return value.isEmpty ? "nama tidak boleh kosong" : null;
              },
              onSaved: (value) {
                name = value;
              },
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_key.currentState.validate()) {
                _key.currentState.save();
                createEventFB(widget.username, name, (status) {
                  addEvent = false;
                  setState(() {});
                });
              }
            },
            child: Text(
              "Simpan",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.lightGreen,
          ),
        ],
      ),
    );
  }

  createAddBooth() {
    GlobalKey<FormState> _key = GlobalKey();
    String name;
    String kode;

    return Form(
      key: _key,
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Kode Booth",
                    hintText: "Kode Booth",
                  ),
                  validator: (value) {
                    return value.isEmpty ? "Kode tidak boleh kosong" : null;
                  },
                  onSaved: (value) {
                    kode = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Nama Booth",
                    hintText: "Nama Booth",
                  ),
                  validator: (value) {
                    return value.isEmpty ? "nama tidak boleh kosong" : null;
                  },
                  onSaved: (value) {
                    name = value;
                  },
                ),
              ],
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_key.currentState.validate()) {
                _key.currentState.save();
                addBooth = false;
                createBoothsFB(selectedEvent, kode, name, (status) {
                  setState(() {});
                });
                setState(() {});
              }
            },
            child: Text(
              "Simpan",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.lightBlue,
          ),
        ],
      ),
    );
  }
}
