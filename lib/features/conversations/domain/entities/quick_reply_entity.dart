/// Quick Reply Entity
///
/// Represents a canned response template for quick messaging.
class QuickReplyEntity {
  final int id;
  final String title;
  final String content;
  final String? category;

  const QuickReplyEntity({
    required this.id,
    required this.title,
    required this.content,
    this.category,
  });
}
