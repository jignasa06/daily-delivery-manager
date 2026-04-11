import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/daily_entry_model.dart';
import '../../domain/repositories/i_daily_entry_repository.dart';

class FirebaseDailyEntryRepository implements IDailyEntryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String vendorId;

  FirebaseDailyEntryRepository({required this.vendorId});

  String _getMonthStr(DateTime date) => DateFormat('yyyy-MM').format(date);

  CollectionReference _getEntriesCollection(DateTime date) {
    return _firestore
        .collection('vendors')
        .doc(vendorId)
        .collection('daily_entries')
        .doc(_getMonthStr(date))
        .collection('entries');
  }

  @override
  Stream<List<DailyEntryModel>> getEntriesForDay(DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _getEntriesCollection(date)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DailyEntryModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<DailyEntryModel>> getEntriesForMonth(DateTime date) {
    return _getEntriesCollection(date).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DailyEntryModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> upsertEntry(DailyEntryModel entry) async {
    String dateStr = DateFormat('yyyyMMdd').format(entry.date);
    String id = '${entry.subscriptionId}_$dateStr';
    
    await _getEntriesCollection(entry.date).doc(id).set(
          entry.toJson(),
          SetOptions(merge: true),
        );
  }
}
