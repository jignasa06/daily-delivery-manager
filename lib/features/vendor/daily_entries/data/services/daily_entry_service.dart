import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/core/services/auth_service.dart';
import '../models/daily_entry_model.dart';
import '/core/utils/snackbar_utils.dart';

class DailyEntryService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  String _getMonthStr(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  CollectionReference _getEntriesCollection(DateTime date) {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) throw Exception('User not logged in');
    String monthStr = _getMonthStr(date);
    return _firestore
        .collection('vendors')
        .doc(uid)
        .collection('daily_entries')
        .doc(monthStr)
        .collection('entries');
  }

  String _getEntryId(String subId, DateTime date) {
    String dateStr = DateFormat('yyyyMMdd').format(date);
    return '${subId}_$dateStr';
  }

  Stream<List<DailyEntryModel>> getEntriesForMonth(DateTime date) {
    return _getEntriesCollection(date).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DailyEntryModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<DailyEntryModel>> getEntriesForDay(DateTime date) {
    String? uid = _authService.firebaseUser.value?.uid;
    if (uid == null) return Stream.value([]);

    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    String monthStr = _getMonthStr(date);

    return _firestore
        .collection('vendors')
        .doc(uid)
        .collection('daily_entries')
        .doc(monthStr)
        .collection('entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DailyEntryModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> upsertEntry(DailyEntryModel entry) async {
    try {
      String id = _getEntryId(entry.subscriptionId, entry.date);
      await _getEntriesCollection(entry.date).doc(id).set(
            entry.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      SnackbarUtils.showError('Failed to update: $e');
    }
  }
}
