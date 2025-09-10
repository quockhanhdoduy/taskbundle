import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/card.dart';
import '../../../controllers/card_controller.dart';

class CardAttachmentsWidget extends StatefulWidget {
  final TaskCard card;
  final Function(String, String) onAddAttachment; // filename, url (callback giữ cho backwards)

  const CardAttachmentsWidget({
    super.key,
    required this.card,
    required this.onAddAttachment,
  });

  @override
  State<CardAttachmentsWidget> createState() => _CardAttachmentsWidgetState();
}

class _CardAttachmentsWidgetState extends State<CardAttachmentsWidget> {
  late final CardController _cardController;
  List<Map<String, dynamic>> _attachments = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cardController = Get.find<CardController>(tag: 'card_detail_${widget.card.id}');
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    setState(() => _loading = true);
    try {
      final result = await _cardController.getCardAttachments(widget.card.id);
      if ((result['success'] == true || result['status'] == 'success') && result['data'] != null) {
        final List<dynamic> data = result['data'];
        setState(() {
          _attachments = data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        setState(() => _attachments = []);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _attachments.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
              Text(
                  '$count file${count != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add attachment button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
            ),
            child: InkWell(
              onTap: _pickAndUploadFile,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add Attachment',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_attachments.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.attachment, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No attachments yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _attachments.map((attachment) => _buildAttachmentItem(attachment)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final filename = attachment['fileName'] ?? attachment['filename'] ?? 'Attachment';
    final url = attachment['url'] ?? '';
    final uploadedBy = (attachment['uploadedBy']?['name']) ?? attachment['uploadedBy'] ?? '';
    final uploadedAtStr = attachment['uploadedAt'] ?? attachment['createdAt'];
    DateTime? uploadedAt;
    try { uploadedAt = uploadedAtStr != null ? DateTime.parse(uploadedAtStr) : null; } catch (_) {}
    final size = attachment['size'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.insert_drive_file, color: Colors.blue[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (uploadedBy.toString().isNotEmpty || size.toString().isNotEmpty)
                    Text(
                        [
                          if (uploadedBy.toString().isNotEmpty) 'Uploaded by $uploadedBy',
                          if (size.toString().isNotEmpty) size.toString(),
                        ].join(' • '),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (uploadedAt != null)
                    Text(
                      _formatDateTime(uploadedAt),
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (url.toString().isNotEmpty)
              TextButton(
                onPressed: () => _downloadFile(url, filename),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero),
                child: const Text('Download', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _confirmDeleteAttachment(attachment),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero),
                child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    // 1) Ask for permission
    final storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      Get.snackbar('Permission required', 'Storage access is needed to pick files');
      return;
    }

    // 2) Pick file
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty || result.files.first.path == null) return;
    final filePath = result.files.first.path!;

    // 3) Upload
    setState(() => _loading = true);
    final ok = await _cardController.uploadAttachment(widget.card.id, filePath);
    setState(() => _loading = false);

    if (ok) {
      await _loadAttachments();
      // Backwards callback
      final filename = filePath.split(Platform.pathSeparator).last;
      widget.onAddAttachment(filename, '');
    }
  }

  void _downloadFile(String url, String filename) async {
    final uri = Uri.tryParse(url);
    if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
      final ok = await canLaunchUrl(uri);
      if (ok) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No downloadable URL for $filename'), duration: const Duration(seconds: 2)),
    );
  }

  void _confirmDeleteAttachment(Map<String, dynamic> attachment) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text('Are you sure you want to delete "${attachment['fileName'] ?? attachment['filename']}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final id = attachment['_id'] ?? attachment['id'];
              if (id == null) return;
              final ok = await _cardController.removeAttachment(widget.card.id, id.toString());
              if (ok) {
                await _loadAttachments();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
