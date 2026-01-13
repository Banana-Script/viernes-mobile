import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/monthly_stats.dart';
import '../../domain/entities/ai_human_stats.dart';
import '../../domain/entities/customer_summary.dart';
import '../../domain/usecases/get_monthly_stats_usecase.dart';
import '../../domain/usecases/get_ai_human_stats_usecase.dart';
import '../../domain/usecases/get_customer_summary_usecase.dart';
import '../../domain/usecases/export_conversation_stats_usecase.dart';
import '../../../../core/utils/logger.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final GetMonthlyStatsUseCase _getMonthlyStatsUseCase;
  final GetAiHumanStatsUseCase _getAiHumanStatsUseCase;
  final GetCustomerSummaryUseCase _getCustomerSummaryUseCase;
  final ExportConversationStatsUseCase _exportConversationStatsUseCase;

  DashboardProvider({
    required GetMonthlyStatsUseCase getMonthlyStatsUseCase,
    required GetAiHumanStatsUseCase getAiHumanStatsUseCase,
    required GetCustomerSummaryUseCase getCustomerSummaryUseCase,
    required ExportConversationStatsUseCase exportConversationStatsUseCase,
  })  : _getMonthlyStatsUseCase = getMonthlyStatsUseCase,
        _getAiHumanStatsUseCase = getAiHumanStatsUseCase,
        _getCustomerSummaryUseCase = getCustomerSummaryUseCase,
        _exportConversationStatsUseCase = exportConversationStatsUseCase;

  // State management
  DashboardStatus _status = DashboardStatus.initial;
  String? _errorMessage;

  // Data
  MonthlyStats? _monthlyStats;
  AiHumanStats? _aiHumanStats;
  CustomerSummary? _customerSummary;

  // Export state
  bool _isExporting = false;

  // Getters
  DashboardStatus get status => _status;
  String? get errorMessage => _errorMessage;
  MonthlyStats? get monthlyStats => _monthlyStats;
  AiHumanStats? get aiHumanStats => _aiHumanStats;
  CustomerSummary? get customerSummary => _customerSummary;
  bool get isExporting => _isExporting;
  bool get hasData => _monthlyStats != null || _aiHumanStats != null || _customerSummary != null;

  // Initialize dashboard data
  Future<void> initialize() async {
    if (_status == DashboardStatus.loading) return;

    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load all dashboard data in parallel
      await Future.wait([
        _loadMonthlyStats(),
        _loadAiHumanStats(),
        _loadCustomerSummary(),
      ]);

      _status = DashboardStatus.loaded;
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    // Clear existing data
    _monthlyStats = null;
    _aiHumanStats = null;
    _customerSummary = null;

    await initialize();
  }

  // Load individual data sections
  Future<void> _loadMonthlyStats() async {
    try {
      _monthlyStats = await _getMonthlyStatsUseCase();
    } catch (e) {
      AppLogger.error('Error loading monthly stats: $e', tag: 'DashboardProvider');
      // Don't throw, allow other data to load
    }
  }

  Future<void> _loadAiHumanStats() async {
    try {
      _aiHumanStats = await _getAiHumanStatsUseCase();
    } catch (e) {
      AppLogger.error('Error loading AI vs Human stats: $e', tag: 'DashboardProvider');
      // Don't throw, allow other data to load
    }
  }

  Future<void> _loadCustomerSummary() async {
    try {
      _customerSummary = await _getCustomerSummaryUseCase();
    } catch (e) {
      AppLogger.error('Error loading customer summary: $e', tag: 'DashboardProvider');
      // Don't throw, allow other data to load
    }
  }

  // Export conversation stats to file
  Future<String?> exportConversationStats() async {
    if (_isExporting) return null;

    _isExporting = true;
    notifyListeners();

    try {
      // Get CSV data from use case
      AppLogger.info('Starting CSV export...', tag: 'DashboardProvider');
      final csvData = await _exportConversationStatsUseCase();
      AppLogger.info('CSV data received, length: ${csvData.length} chars', tag: 'DashboardProvider');

      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'viernes_stats_$timestamp.csv';

      // Get the directory to save the file
      final directory = await _getExportDirectory();

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }
      AppLogger.info('Directory: ${directory.path}', tag: 'DashboardProvider');

      // Create file and write CSV data
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData);

      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      AppLogger.info('CSV exported to: ${file.path}, exists: $exists, size: $size bytes', tag: 'DashboardProvider');

      // Return file path for sharing
      return file.path;
    } catch (e) {
      _errorMessage = 'Failed to export conversation stats: $e';
      AppLogger.error('Export error: $e', tag: 'DashboardProvider');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Get the appropriate directory for exporting files
  /// - Android <= 12: Request storage permission, use Downloads folder
  /// - Android 13+: Use app-specific directory (scoped storage)
  /// - iOS: Use app documents directory
  Future<Directory?> _getExportDirectory() async {
    if (Platform.isAndroid) {
      // Check Android SDK version
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      AppLogger.info('Android SDK: $sdkInt', tag: 'DashboardProvider');

      // Android 12 (API 32) and below: Request permission for Downloads
      if (sdkInt <= 32) {
        final status = await Permission.storage.request();
        AppLogger.info('Storage permission status: $status', tag: 'DashboardProvider');

        if (status.isGranted) {
          // Try public Downloads folder
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            return downloadsDir;
          }
        }
        // Permission denied or Downloads doesn't exist, fall back to app storage
        AppLogger.info('Using app-specific storage (permission denied or Downloads not found)', tag: 'DashboardProvider');
      }

      // Android 13+ or fallback: Use app-specific external storage
      return await getExternalStorageDirectory();
    } else {
      // iOS: Use app documents directory
      return await getApplicationDocumentsDirectory();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Retry loading data
  Future<void> retry() async {
    _status = DashboardStatus.initial;
    _errorMessage = null;
    await initialize();
  }
}