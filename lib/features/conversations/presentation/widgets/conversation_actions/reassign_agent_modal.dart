import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Agent option for reassignment
class ReassignAgentOption {
  final int id;
  final String fullname;
  final String email;
  final bool isAvailable;

  const ReassignAgentOption({
    required this.id,
    required this.fullname,
    required this.email,
    this.isAvailable = true,
  });
}

/// Reassign Agent Modal
///
/// Modal for requesting reassignment to another agent.
class ReassignAgentModal extends StatefulWidget {
  final List<ReassignAgentOption> agents;
  final int? currentAgentId;
  final bool isLoading;
  final Future<bool> Function(int agentId)? onReassign;

  const ReassignAgentModal({
    super.key,
    required this.agents,
    this.currentAgentId,
    this.isLoading = false,
    this.onReassign,
  });

  /// Show the modal and return the selected agent ID or null if cancelled
  static Future<int?> show({
    required BuildContext context,
    required List<ReassignAgentOption> agents,
    int? currentAgentId,
    bool isLoading = false,
    Future<bool> Function(int agentId)? onReassign,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => ReassignAgentModal(
          agents: agents,
          currentAgentId: currentAgentId,
          isLoading: isLoading,
          onReassign: onReassign,
        ),
      ),
    );
  }

  @override
  State<ReassignAgentModal> createState() => _ReassignAgentModalState();
}

class _ReassignAgentModalState extends State<ReassignAgentModal> {
  int? _selectedAgentId;
  bool _isSubmitting = false;
  String _searchQuery = '';

  List<ReassignAgentOption> get _filteredAgents {
    if (_searchQuery.isEmpty) {
      return widget.agents;
    }
    final query = _searchQuery.toLowerCase();
    return widget.agents.where((agent) {
      return agent.fullname.toLowerCase().contains(query) ||
          agent.email.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleReassign() async {
    if (_selectedAgentId == null || widget.onReassign == null) return;

    setState(() => _isSubmitting = true);

    final success = await widget.onReassign!(_selectedAgentId!);

    if (mounted) {
      if (success) {
        Navigator.pop(context, _selectedAgentId);
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al solicitar reasignación'),
            backgroundColor: ViernesColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: ViernesSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(ViernesSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    color: ViernesColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: ViernesSpacing.sm),
                  Expanded(
                    child: Text(
                      'Solicitar reasignación',
                      style: ViernesTextStyles.h6.copyWith(
                        color: ViernesColors.getTextColor(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ViernesSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar agente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ViernesColors.getBorderColor(isDark),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ViernesColors.getBorderColor(isDark),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: ViernesSpacing.md,
                    vertical: ViernesSpacing.sm,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? ViernesColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            const Divider(height: 1),
            // Agent list
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAgents.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: ViernesSpacing.sm,
                          ),
                          itemCount: _filteredAgents.length,
                          itemBuilder: (context, index) {
                            final agent = _filteredAgents[index];
                            final isCurrentAgent = agent.id == widget.currentAgentId;
                            final isSelected = agent.id == _selectedAgentId;

                            return _buildAgentTile(
                              context,
                              isDark,
                              agent: agent,
                              isSelected: isSelected,
                              isCurrentAgent: isCurrentAgent,
                              onTap: isCurrentAgent || !agent.isAvailable
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedAgentId = agent.id;
                                      });
                                    },
                            );
                          },
                        ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(ViernesSpacing.md),
              decoration: BoxDecoration(
                color: ViernesColors.getControlBackground(isDark),
                border: Border(
                  top: BorderSide(
                    color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.md),
                        side: BorderSide(
                          color: ViernesColors.getBorderColor(isDark),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: ViernesColors.getTextColor(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ViernesSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAgentId == null || _isSubmitting
                          ? null
                          : _handleReassign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ViernesColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Reasignar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 48,
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
          ),
          const SizedBox(height: ViernesSpacing.md),
          Text(
            _searchQuery.isEmpty
                ? 'No hay agentes disponibles'
                : 'No se encontraron agentes',
            style: ViernesTextStyles.bodyText.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentTile(
    BuildContext context,
    bool isDark, {
    required ReassignAgentOption agent,
    required bool isSelected,
    required bool isCurrentAgent,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? ViernesColors.primary
            : ViernesColors.primary.withValues(alpha: 0.2),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                _getInitials(agent.fullname),
                style: ViernesTextStyles.label.copyWith(
                  color: ViernesColors.primary,
                ),
              ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              agent.fullname,
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isCurrentAgent)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ViernesSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: ViernesColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Actual',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.info,
                  fontSize: 10,
                ),
              ),
            ),
          if (!agent.isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ViernesSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: ViernesColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'No disponible',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.warning,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        agent.email,
        style: ViernesTextStyles.bodySmall.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: ViernesColors.primary)
          : null,
      enabled: !isCurrentAgent && agent.isAvailable,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.xs,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
