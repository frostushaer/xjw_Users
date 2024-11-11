import 'package:flutter/material.dart';
import '../models/recipient.dart';
import '../services/api_service.dart';
import 'add_recipient_screen.dart';

class ManageRecipientsScreen extends StatefulWidget {
  final String userId;

  const ManageRecipientsScreen({super.key, required this.userId});

  @override
  _ManageRecipientsScreenState createState() => _ManageRecipientsScreenState();
}

class _ManageRecipientsScreenState extends State<ManageRecipientsScreen> {
  final ApiService _apiService = ApiService();
  List<Recipient> _recipients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
  }

  Future<void> _fetchRecipients() async {
    try {
      final recipients = await _apiService.listRecipients(widget.userId);
      setState(() {
        _recipients = recipients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load recipients: $e')),
      );
    }
  }

  Future<void> _deleteRecipient(String recipientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this recipient?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final message = await _apiService.deleteRecipient(recipientId);
        setState(() {
          _recipients.removeWhere(
              (recipient) => recipient.id.toString() == recipientId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _fetchRecipients(); // Refresh recipients after deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete recipient: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Recipients'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddRecipientScreen(userId: widget.userId),
                    ),
                  )
                  .then((_) => _fetchRecipients()); // Refresh after adding
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipients.isEmpty
              ? const Center(child: Text('No recipients found.'))
              : ListView.builder(
                  itemCount: _recipients.length,
                  itemBuilder: (context, index) {
                    final recipient = _recipients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          '${recipient.firstname} ${recipient.lastname}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${recipient.phone} | ${recipient.email}'),
                            if (recipient.relation.isNotEmpty)
                              Text('Relation: ${recipient.relation}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteRecipient(
                                recipient.id.toString()); // Pass the String id
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
