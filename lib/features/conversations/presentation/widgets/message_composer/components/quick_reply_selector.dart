import 'package:flutter/material.dart';
import '../../../../../../gen_l10n/app_localizations.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_spacing.dart';
import '../../../../../../core/theme/viernes_text_styles.dart';
import '../../../../domain/entities/quick_reply_entity.dart';

/// Quick Reply Selector Component
///
/// Dropdown panel with searchable list of quick replies.
class QuickReplySelector extends StatefulWidget {
  final List<QuickReplyEntity> quickReplies;
  final bool isLoading;
  final void Function(QuickReplyEntity reply)? onSelect;
  final void Function(String query)? onSearch;
  final VoidCallback? onClose;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const QuickReplySelector({
    super.key,
    required this.quickReplies,
    this.isLoading = false,
    this.onSelect,
    this.onSearch,
    this.onClose,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  State<QuickReplySelector> createState() => _QuickReplySelectorState();
}

class _QuickReplySelectorState extends State<QuickReplySelector> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!widget.isLoading && widget.hasMore) {
        widget.onLoadMore?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 300,
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(isDark, l10n),
          // Search field
          _buildSearchField(isDark, l10n),
          const Divider(height: 1),
          // Quick reply list
          Flexible(
            child: _buildQuickReplyList(isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            size: 20,
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Text(
            l10n?.quickReplies ?? 'Quick Replies',
            style: TextStyle(
              color: ViernesColors.getTextColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: Icon(
              Icons.close,
              size: 20,
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark, AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.all(ViernesSpacing.sm),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearch,
        style: ViernesTextStyles.bodySmall.copyWith(
          color: ViernesColors.getTextColor(isDark),
        ),
        decoration: InputDecoration(
          hintText: l10n?.searchQuickReplies ?? 'Search quick replies...',
          hintStyle: ViernesTextStyles.bodySmall.copyWith(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: isDark
              ? const Color(0xFF1b2e4b)
              : const Color(0xFFF4F4F4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
            borderSide: BorderSide(
              color: isDark ? ViernesColors.accent : ViernesColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplyList(bool isDark, AppLocalizations? l10n) {
    if (widget.isLoading && widget.quickReplies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(ViernesSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.quickReplies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Center(
          child: Text(
            l10n?.noQuickRepliesFound ?? 'No quick replies found',
            style: ViernesTextStyles.bodySmall.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: widget.quickReplies.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.quickReplies.length) {
          return const Padding(
            padding: EdgeInsets.all(ViernesSpacing.sm),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final reply = widget.quickReplies[index];
        return _QuickReplyTile(
          reply: reply,
          onTap: () {
            widget.onSelect?.call(reply);
            _searchController.clear();
          },
        );
      },
    );
  }
}

/// Individual quick reply tile
class _QuickReplyTile extends StatelessWidget {
  final QuickReplyEntity reply;
  final VoidCallback? onTap;

  const _QuickReplyTile({
    required this.reply,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reply.title,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                reply.content,
                style: ViernesTextStyles.caption.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
