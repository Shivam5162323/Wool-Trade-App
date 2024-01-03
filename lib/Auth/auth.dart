import 'package:firebase_auth/firebase_auth.dart';



class FirebaseUser {
  final String? uid ;
  final String? code; //code firebaseauth excemption
  FirebaseUser({this.uid,this.code});
  usda(uid) {
    // TODO: implement usda
    print(code);
  }
}







class LoginUser {
  final String? email;
  final String? password;

  LoginUser({this.email, this.password});
}








class UserModel{
  final String id;
  final String name;
  final String mail;
  final String password;
  final String phoneno;


  const UserModel(this.id, {
    required this.name,
    required this.mail,
    required this.password,
    required this.phoneno

  });


  toJson(){
    return {
      "Name": name,
      "mail": mail,
      "password": password,
      "phoneno": phoneno


    };
  }




}




class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  FirebaseUser? _firebaseUser(User? user) {
    return user != null ? FirebaseUser(uid: user.uid) : null;
  }


  Stream<FirebaseUser?> get user {
    return _auth.authStateChanges().map(_firebaseUser);
  }


  Future signInAnonymous() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      return _firebaseUser(user);
    } catch (e) {
      return FirebaseUser(code: e.toString(), uid: null);
    }
  }


  Future signInEmailPassword(LoginUser _login) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _login.email.toString(),
          password: _login.password.toString());
      User? user = userCredential.user;
      return _firebaseUser(user);
    } on FirebaseAuthException catch (e) {
      return FirebaseUser(code: e.code, uid: null);
    }
  }


  Future registerEmailPassword(LoginUser _login) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(

          email: _login.email.toString(),
          password: _login.password.toString());
      User? user = userCredential.user;
      return _firebaseUser(user);
    } on FirebaseAuthException catch (e) {
      return FirebaseUser(code: e.code, uid: null);
    } catch (e) {
      return FirebaseUser(code: e.toString(), uid: null);
    }
  }




  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }




}



