import 'package:app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Firestore firestore = Firestore.instance;
  DocumentReference ref;

  Future<void> addUserToDB(User user) {
    firestore.collection("users").document(user.uid).setData(user.toMap(user));
    return null;
  }

  Future<List> getLists(String uid) async {
    DocumentSnapshot doc =
    await firestore.collection("users").document(uid).get();
    return doc['My groups'] ?? [];
  }
}
