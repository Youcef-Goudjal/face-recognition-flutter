import 'package:app/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> getCurrentUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    return User(
      email: firebaseUser.email,
      uid: firebaseUser.uid,
      username: firebaseUser.displayName,
    );
  }

  Future<void> signOut() {
    _auth.signOut();
    return null;
  }

  Future<User> register(User user) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: user.email, password: user.password);
    FirebaseUser firebaseUser = result.user;
    return User(
      email: firebaseUser.email,
      uid: firebaseUser.uid,
      username: firebaseUser.displayName,
    );
  }

  Future<User> signin(User user) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: user.email, password: user.password);
    FirebaseUser firebaseUser = result.user;
    return User(
      email: firebaseUser.email,
      uid: firebaseUser.uid,
      username: firebaseUser.displayName,
    );
  }
}
