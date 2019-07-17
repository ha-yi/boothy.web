import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;
import 'dart:convert';

void initApp() {
  fb.initializeApp(
    apiKey: "", // todo add api key
    authDomain: "", // todo add auth domain
    databaseURL: "", // todo add database URL
    projectId: "", // todo add project id
    storageBucket: "", // todo add storage bucket
    messagingSenderId: "", // todo add messaging sender id
  );
}

Stream<fs.QuerySnapshot> getBoothOfEventStream(String eventID) {
  fs.DocumentReference doc = fb.firestore().collection("events").doc(eventID);
  return doc.collection("booth").get().asStream();
}

void deleteDoc(String ref, Function onFinish) {
  fs.DocumentReference doc = fb.firestore().doc(ref);
  doc.delete().whenComplete(() {
    onFinish();
  });
}

Stream<fs.QuerySnapshot> getTamuListStream(String ref) {
  return fb.firestore().doc(ref).collection("tamu").get().asStream();
}

void createEventFB(String username, String eventName, Function(bool) callback) {
  var bytesU = utf8.encode(username);
  var base64Username = base64.encode(bytesU);

  var dataToSave = {
    "name": eventName,
    "created_at": DateTime.now().millisecondsSinceEpoch,
  };

  fs.Firestore store = fb.firestore();
  fs.CollectionReference ref = store.collection("users").doc(base64Username).collection("events");
  ref.add(dataToSave).asStream().listen((dt) {
    callback(true);
  }).onError((error) {
    callback(false);
  });
}

void createBoothsFB(String eventID, String kodeBooth, String boothName, Function(bool) callback) {
  var dataToSave = {
    "name": boothName,
    "kode": kodeBooth,
    "created_at": DateTime.now().millisecondsSinceEpoch,
  };

  fs.CollectionReference ref = fb.firestore().collection("events").doc(eventID).collection("booth");
  ref.doc(kodeBooth).set(dataToSave).asStream().listen((dt) {
    callback(true);
  }).onError((error) {
    callback(false);
  });
}

Stream<fs.QuerySnapshot> getEvents(String user) {
  var bytesU = utf8.encode(user);
  var base64Username = base64.encode(bytesU);
  fs.Firestore store = fb.firestore();
  fs.CollectionReference ref = store.collection("users").doc(base64Username).collection("events");
  return ref.get().asStream();
}

void checkUserIDExist(String username, Function(bool) callback) {
  var bytesU = utf8.encode(username);
  var base64Username = base64.encode(bytesU);
  fs.Firestore store = fb.firestore();
  fs.CollectionReference ref = store.collection("users");

  ref.doc(base64Username).get().then((ds) {
    if (ds.data() == null || ds.data().isEmpty) {
      callback(false);
    } else {
      if (ds.get("id") == base64Username) {
        callback(true);
      } else {
        callback(false);
      }
    }
  }, onError: (error) {
    callback(false);
  });
}

void login(String username, String password, Function(bool, String) callback) {
  var bytesU = utf8.encode(username);
  var bytesP = utf8.encode(password);
  var base64Username = base64.encode(bytesU);
  var base64Password = base64.encode(bytesP);

  fs.Firestore store = fb.firestore();
  fs.CollectionReference ref = store.collection("users");

  ref.doc(base64Username).get().then((ds) {
    if (ds.data() == null || ds.data().isEmpty) {
      callback(false, "User belum ada, silahkan daftar");
    } else {
      if (ds.get("key") == base64Password && ds.get("id") == base64Username) {
        callback(true, ds.get("name"));
      } else {
        callback(false, "Password salah");
      }
    }
  }, onError: (error) {
    callback(false, "Gagal Login, silahkan cek koneksi anda.");
  });
}

void registerUser(String username, String password, String namaLengkap,
    Function(bool, String) callback) {
  var bytesU = utf8.encode(username);
  var bytesP = utf8.encode(password);
  var base64Username = base64.encode(bytesU);
  var base64Password = base64.encode(bytesP);

  var dataToSave = {
    "id": base64Username,
    "email": username,
    "key": base64Password,
    "name": namaLengkap
  };

  fs.Firestore store = fb.firestore();
  fs.CollectionReference ref = store.collection("users");

  ref.doc(base64Username).get().then((ds) {
    if (ds.data() == null || ds.data().isEmpty) {
      ref.doc(base64Username).set(dataToSave).asStream().listen((dt) {
        callback(true, "Success");
      }).onError((error) {
        callback(false, "failed creating data");
      });
    } else {
      callback(false, "Username sudah ada, silahkan login.");
    }
  }, onError: (error) {
    ref.doc(base64Username).set(dataToSave).asStream().listen((dt) {
      callback(true, "Success");
    }).onError((error) {
      callback(false, "failed creating data");
    });
  });
}
