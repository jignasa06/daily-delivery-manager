import 'dart:async';
import '../models/daily_entry_model.dart';
import '../../domain/repositories/i_daily_entry_repository.dart';

class MockDailyEntryRepository implements IDailyEntryRepository {
  final _entriesController = StreamController<List<DailyEntryModel>>.broadcast();
  
  final Map<String, DailyEntryModel> _dummyEntries = {};

  @override
  Stream<List<DailyEntryModel>> getEntriesForDay(DateTime date) {
    Timer(const Duration(milliseconds: 300), () {
      _entriesController.add(_dummyEntries.values.where((e) => 
        e.date.year == date.year && 
        e.date.month == date.month && 
        e.date.day == date.day
      ).toList());
    });
    return _entriesController.stream;
  }

  @override
  Stream<List<DailyEntryModel>> getEntriesForMonth(DateTime date) {
    Timer(const Duration(milliseconds: 300), () {
      _entriesController.add(_dummyEntries.values.where((e) => 
        e.date.year == date.year && 
        e.date.month == date.month
      ).toList());
    });
    return _entriesController.stream;
  }

  @override
  Future<void> upsertEntry(DailyEntryModel entry) async {
    await Future.delayed(const Duration(milliseconds: 500));
    String key = "${entry.subscriptionId}_${entry.date.toIso8601String().split('T')[0]}";
    _dummyEntries[key] = entry;
    _entriesController.add(_dummyEntries.values.toList());
  }
}
