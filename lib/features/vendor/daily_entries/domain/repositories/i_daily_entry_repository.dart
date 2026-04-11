import '../../data/models/daily_entry_model.dart';

abstract class IDailyEntryRepository {
  Stream<List<DailyEntryModel>> getEntriesForDay(DateTime date);
  Stream<List<DailyEntryModel>> getEntriesForMonth(DateTime date); // Added for Billing support
  Future<void> upsertEntry(DailyEntryModel entry);
}
