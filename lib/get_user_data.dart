import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetUserData {

  String? username;
  String? age;
  String? weight;
  String? height;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> getUserDatas() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await users.doc(user!.uid).get();
    username = doc['name'];
    age = doc['age'];
    weight = doc['weight'];
    height = doc['height'];
  }

  Future<void> updateUserData(String name, String age, String weight, String height) async {
    final user = FirebaseAuth.instance.currentUser;
    await users.doc(user!.uid).update({'name': name, 'age': age, 'weight': weight, 'height': height});
  }
}