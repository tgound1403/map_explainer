import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static final instance = Firestore();
  static late final FirebaseFirestore db;

  static Future<void> init() async {
    db = FirebaseFirestore.instance;
  }

  Future<void> addData(Map<String, dynamic> data, String collection) async {
    try {
      await db.collection(collection).add(data).then((DocumentReference doc) =>
          Logger.i('DocumentSnapshot added with ID: ${doc.id}'));
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
    }
  }

  Future<List<Map<String, dynamic>>> readAllData(String collection) async {
    var result = <Map<String, dynamic>>[];
    await db.collection(collection).get().then((event) {
      for (var doc in event.docs) {
        // final docId = doc.id;
        final docData = doc.data();
        result.add(docData);
      }
    });
    return result;
  }

  Future<Map<String, dynamic>> readSpecificData(
      String collection, String id) async {
    var result = <String, dynamic>{};
    try {
      await db.collection(collection).where('id', isEqualTo: id).get().then((event) {
        for (var doc in event.docs) {
          result = doc.data();
          return result;
        }
      });
    } catch (e) {
      return result;
    }
  return result;
  }

  Future<void> modifyData(String collection, String id, Map<String,dynamic> newData) async {
    // Create a query to find documents with a specific field value
    await db.collection(collection).where('id', isEqualTo: id).get().then((event) {
      event.docs.first.reference.update(newData);
    });
  }

  Future<bool> deleteSpecificData(
      String collection, String id) async {
    try {
      await db
          .collection(collection)
          .where('id', isEqualTo: id)
          .get()
          .then((event) {
        for (var doc in event.docs) {
          doc.reference.delete();
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }


}
