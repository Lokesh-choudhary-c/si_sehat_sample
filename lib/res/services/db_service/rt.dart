import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Create
  Future<void> createData(String path, dynamic data) async {
    await _database.ref(path).set(data);
  }

  // Read
  Future<dynamic> readData(String path) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref(path);

  try {
    DataSnapshot snapshot = await ref.get();
    
    if (snapshot.exists && snapshot.value != null) {
      return snapshot.value;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
  Future<void> updateData(String path, dynamic data) async {
    await _database.ref(path).update(data);
  }

  Future<void> deleteData(String path) async {
    await _database.ref(path).remove();
  }
}