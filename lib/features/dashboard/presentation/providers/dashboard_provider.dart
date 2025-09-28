import 'package:flutter/foundation.dart';
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

  // Export conversation stats
  Future<String?> exportConversationStats() async {
    if (_isExporting) return null;

    _isExporting = true;
    notifyListeners();

    try {
      final csvData = await _exportConversationStatsUseCase();
      return csvData;
    } catch (e) {
      _errorMessage = 'Failed to export conversation stats: $e';
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
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