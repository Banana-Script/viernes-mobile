import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../domain/entities/quick_reply_entity.dart';
import 'models/attachment_model.dart';
import 'components/composer_toolbar.dart';
import 'components/composer_text_field.dart';
import 'components/send_button.dart';
import 'components/file_preview_bar.dart';
import 'components/emoji_picker_panel.dart';
import 'components/quick_reply_selector.dart';

/// Message Composer Widget
///
/// Complete message input with emoji picker, quick replies, and file attachments.
class MessageComposer extends StatefulWidget {
  final int conversationId;
  final bool isSending;
  final List<QuickReplyEntity> quickReplies;
  final bool isLoadingQuickReplies;
  final bool hasMoreQuickReplies;
  final Future<bool> Function(String text) onSendMessage;
  final Future<void> Function(List<AttachmentModel> attachments, String? caption)? onSendMedia;
  final void Function(String query)? onSearchQuickReplies;
  final VoidCallback? onLoadMoreQuickReplies;

  const MessageComposer({
    super.key,
    required this.conversationId,
    this.isSending = false,
    this.quickReplies = const [],
    this.isLoadingQuickReplies = false,
    this.hasMoreQuickReplies = false,
    required this.onSendMessage,
    this.onSendMedia,
    this.onSearchQuickReplies,
    this.onLoadMoreQuickReplies,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<AttachmentModel> _attachments = [];
  int _attachmentCounter = 0;

  bool _showEmojiPicker = false;
  bool _showQuickReplies = false;
  bool _isSending = false;

  @override
  void dispose() {
    // Clean up unsent attachments to prevent memory leak
    _cleanupAttachments(_attachments);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Cleans up temporary attachment files
  void _cleanupAttachments(List<AttachmentModel> attachments) {
    for (final attachment in attachments) {
      _deleteFile(attachment.path);
    }
  }

  /// Safely deletes a file if it exists
  void _deleteFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      debugPrint('Failed to delete file: $path - $e');
    }
  }

  /// Shows an error snackbar if mounted
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ViernesColors.danger,
      ),
    );
  }

  bool get _canSend {
    return !_isSending &&
        !widget.isSending &&
        (_textController.text.trim().isNotEmpty || _attachments.isNotEmpty);
  }

  bool get _hasAttachments => _attachments.isNotEmpty;

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      _showQuickReplies = false;
    });
  }

  void _toggleQuickReplies() {
    setState(() {
      _showQuickReplies = !_showQuickReplies;
      _showEmojiPicker = false;
    });
  }

  void _closeOverlays() {
    if (_showEmojiPicker || _showQuickReplies) {
      setState(() {
        _showEmojiPicker = false;
        _showQuickReplies = false;
      });
    }
  }

  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPos = selection.isValid ? selection.baseOffset : text.length;

    final newText = text.substring(0, cursorPos) + emoji + text.substring(cursorPos);

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + emoji.length),
    );

    _focusNode.requestFocus();
  }

  void _insertQuickReply(QuickReplyEntity reply) {
    final currentText = _textController.text.trim();
    final newText = currentText.isEmpty
        ? reply.content
        : '$currentText ${reply.content}';

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    _closeOverlays();
    _focusNode.requestFocus();
  }

  Future<void> _pickImageFromGallery() async {
    _closeOverlays();
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImageFromCamera() async {
    _closeOverlays();
    await _pickImage(ImageSource.camera);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return; // User cancelled

      final fileSize = await image.length();
      if (!AttachmentModel.isValidSize(fileSize)) {
        _showErrorSnackBar('Archivo muy grande. El máximo es 5MB.');
        return;
      }

      setState(() {
        _attachmentCounter++;
        _attachments.add(AttachmentModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_$_attachmentCounter',
          path: image.path,
          fileName: image.name,
          fileSize: fileSize,
          type: AttachmentType.image,
          mimeType: image.mimeType ?? 'image/jpeg',
        ));
      });
    } on PlatformException catch (e) {
      // Handle permission denied or other platform errors
      final permissionType = source == ImageSource.camera ? 'cámara' : 'galería';
      if (e.code == 'camera_access_denied' ||
          e.code == 'photo_access_denied' ||
          e.code.contains('denied')) {
        _showErrorSnackBar('Permiso denegado. Habilita el acceso a la $permissionType en Configuración.');
      } else {
        _showErrorSnackBar('Error al seleccionar imagen: ${e.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error inesperado al seleccionar imagen.');
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _pickDocument() async {
    _closeOverlays();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AttachmentModel.allowedDocumentExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return;

      final file = result.files.single;
      if (!AttachmentModel.isValidSize(file.size)) {
        _showErrorSnackBar('Archivo muy grande. El máximo es 5MB.');
        return;
      }

      setState(() {
        _attachmentCounter++;
        _attachments.add(AttachmentModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_$_attachmentCounter',
          path: file.path!,
          fileName: file.name,
          fileSize: file.size,
          type: AttachmentType.document,
          mimeType: AttachmentModel.getMimeType(file.extension ?? ''),
        ));
      });
    } on PlatformException catch (e) {
      _showErrorSnackBar('Error al seleccionar documento: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Error inesperado al seleccionar documento.');
      debugPrint('Document picker error: $e');
    }
  }

  void _removeAttachment(AttachmentModel attachment) {
    setState(() {
      _attachments.removeWhere((a) => a.id == attachment.id);
    });
    // Clean up the file to prevent memory leak
    _deleteFile(attachment.path);
  }

  Future<void> _handleSend() async {
    if (!_canSend) return;

    // Set flag immediately to prevent double-tap race condition
    setState(() {
      _isSending = true;
    });

    final text = _textController.text.trim();
    final attachmentsToSend = List<AttachmentModel>.from(_attachments);

    // Clear input after capturing values for better UX
    _textController.clear();
    setState(() {
      _attachments.clear();
    });

    _closeOverlays();

    try {
      // Send text message if present and no attachments
      if (text.isNotEmpty && attachmentsToSend.isEmpty) {
        final success = await widget.onSendMessage(text);
        if (!success) {
          _showErrorSnackBar('Error al enviar mensaje');
          // Restore text on failure
          _textController.text = text;
        }
      }
      // Send media if present
      else if (attachmentsToSend.isNotEmpty && widget.onSendMedia != null) {
        await widget.onSendMedia!(
          attachmentsToSend,
          text.isNotEmpty ? text : null,
        );
      }
      // Send text only if we have attachments but no media handler
      else if (text.isNotEmpty) {
        final success = await widget.onSendMessage(text);
        if (!success) {
          _showErrorSnackBar('Error al enviar mensaje');
          _textController.text = text;
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = _isSending || widget.isSending;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overlays (emoji picker, quick replies)
        _buildOverlays(isDark),
        // Main composer container
        Container(
          decoration: BoxDecoration(
            color: ViernesColors.getControlBackground(isDark),
            border: Border(
              top: BorderSide(
                color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // File preview bar
                if (_hasAttachments)
                  FilePreviewBar(
                    attachments: _attachments,
                    onRemove: _removeAttachment,
                  ),
                // Input area
                Padding(
                  padding: const EdgeInsets.all(ViernesSpacing.md),
                  child: _buildInputRow(isDark, isLoading),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(bool isDark, bool isLoading) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 44,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1b2e4b) : const Color(0xFFf4f4f4),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: ComposerToolbar(
              isEmojiActive: _showEmojiPicker,
              onEmojiToggle: _toggleEmojiPicker,
              onQuickReplyToggle: _toggleQuickReplies,
              onCameraPick: _pickImageFromCamera,
              onImagePick: _pickImageFromGallery,
              onDocumentPick: _pickDocument,
              enabled: !isLoading,
            ),
          ),
          // Text field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ComposerTextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: !isLoading,
                onChanged: (_) => setState(() {}), // Trigger rebuild for send button
              ),
            ),
          ),
          // Send button
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            child: SendButton(
              isLoading: isLoading,
              isEnabled: _canSend,
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlays(bool isDark) {
    if (!_showEmojiPicker && !_showQuickReplies) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _closeOverlays,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showEmojiPicker)
              EmojiPickerPanel(
                onEmojiSelected: _insertEmoji,
                onClose: _closeOverlays,
              ),
            if (_showQuickReplies)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: ViernesSpacing.md),
                  child: QuickReplySelector(
                    quickReplies: widget.quickReplies,
                    isLoading: widget.isLoadingQuickReplies,
                    hasMore: widget.hasMoreQuickReplies,
                    onSelect: _insertQuickReply,
                    onSearch: widget.onSearchQuickReplies,
                    onLoadMore: widget.onLoadMoreQuickReplies,
                    onClose: _closeOverlays,
                  ),
                ),
              ),
            const SizedBox(height: ViernesSpacing.sm),
          ],
        ),
      ),
    );
  }
}
