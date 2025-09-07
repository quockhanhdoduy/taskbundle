import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/card.dart';

class CardAttachmentsWidget extends StatefulWidget {
  final TaskCard card;
  final Function(String, String) onAddAttachment; // filename, url

  const CardAttachmentsWidget({
    super.key,
    required this.card,
    required this.onAddAttachment,
  });

  @override
  State<CardAttachmentsWidget> createState() => _CardAttachmentsWidgetState();
}

class _CardAttachmentsWidgetState extends State<CardAttachmentsWidget> {
  // Mock attachments for demonstration
  final List<Map<String, dynamic>> _mockAttachments = [
    {
      'id': '1',
      'filename': 'project_spec.pdf',
      'url': 'https://example.com/files/project_spec.pdf',
      'uploadedBy': 'John Doe',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 2)),
      'size': '2.3 MB',
    },
    {
      'id': '2',
      'filename': 'mockup_design.png',
      'url': 'https://example.com/files/mockup_design.png',
      'uploadedBy': 'Jane Smith',
      'uploadedAt': DateTime.now().subtract(const Duration(hours: 5)),
      'size': '1.8 MB',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          // Header
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
              Text(
                '${_mockAttachments.length} file${_mockAttachments.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
              onTap: _showAddAttachmentDialog,
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

          // Attachments list
          if (_mockAttachments.isEmpty)
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
              children: _mockAttachments.map((attachment) => _buildAttachmentItem(attachment)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final filename = attachment['filename'];
    final url = attachment['url'];
    final size = attachment['size'];
    final uploadedBy = attachment['uploadedBy'];
    final uploadedAt = attachment['uploadedAt'] as DateTime;

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
          // File info row
          Row(
            children: [
              Text(
                _getFileEmoji(filename),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Uploaded by $uploadedBy • $size',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDateTime(uploadedAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _downloadFile(url, filename),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: const Text('Download', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _deleteAttachment(attachment),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFileEmoji(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'mp4':
      case 'avi':
      case 'mov':
        return '🎥';
      case 'mp3':
      case 'wav':
      case 'flac':
        return '🎵';
      default:
        return '📁';
    }
  }


  void _showAddAttachmentDialog() {
    final TextEditingController filenameController = TextEditingController();
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Attachment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: filenameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'Enter file name (e.g., document.pdf)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'File URL',
                hintText: 'Enter file URL or path',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: In a real app, this would allow file upload from device storage.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (filenameController.text.trim().isNotEmpty &&
                  urlController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _addAttachment(filenameController.text.trim(), urlController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addAttachment(String filename, String url) {
    final newAttachment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'filename': filename,
      'url': url,
      'uploadedBy': 'Current User',
      'uploadedAt': DateTime.now(),
      'size': '${(filename.length * 0.1).toStringAsFixed(1)} MB', // Mock size
    };

    setState(() {
      _mockAttachments.add(newAttachment);
    });

    // Call parent callback
    widget.onAddAttachment(filename, url);
  }

  void _downloadFile(String url, String filename) {
    // TODO: Implement file download
    // For now, just show info
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download feature would download: $filename'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _extractFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'Unknown file';
    } catch (e) {
      return 'Unknown file';
    }
  }

  void _deleteAttachment(Map<String, dynamic> attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text('Are you sure you want to delete "${attachment['filename']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _mockAttachments.removeWhere((item) => item['id'] == attachment['id']);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${attachment['filename']}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
