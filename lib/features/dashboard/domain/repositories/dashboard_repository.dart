import '../entities/monthly_stats.dart';
import '../entities/ai_human_stats.dart';
import '../entities/customer_summary.dart';

abstract class DashboardRepository {
  Future<MonthlyStats> getMonthlyStats();
  Future<AiHumanStats> getAiHumanStats();
  Future<CustomerSummary> getCustomerSummary();
  Future<String> exportConversationStats();
}