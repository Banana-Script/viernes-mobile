import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

class CallsPage extends ConsumerStatefulWidget {
  const CallsPage({super.key});

  @override
  ConsumerState<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends ConsumerState<CallsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calls),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Missed'),
            Tab(text: 'Outbound'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _makeCall,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CallsList(type: 'recent'),
          _CallsList(type: 'missed'),
          _CallsList(type: 'outbound'),
        ],
      ),
    );
  }

  void _makeCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Make call functionality coming soon')),
    );
  }
}

class _CallsList extends StatelessWidget {
  final String type;

  const _CallsList({required this.type});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 15, // Mock data
      itemBuilder: (context, index) {
        final isIncoming = index % 2 == 0;
        final isMissed = type == 'missed' || (index % 5 == 0 && type == 'recent');

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCallTypeColor(isIncoming, isMissed),
              child: Icon(
                _getCallIcon(isIncoming, isMissed),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text('Contact ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('+1 (555) 123-456${index.toString().padLeft(2, '0')}'),
                Text(
                  '${DateTime.now().subtract(Duration(hours: index)).hour}:00 - ${_getCallDuration()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () => _callBack(context, index),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _viewCallDetails(context, index),
                ),
              ],
            ),
            onTap: () => _viewCallDetails(context, index),
          ),
        );
      },
    );
  }

  Color _getCallTypeColor(bool isIncoming, bool isMissed) {
    if (isMissed) return Colors.red;
    return isIncoming ? Colors.green : Colors.blue;
  }

  IconData _getCallIcon(bool isIncoming, bool isMissed) {
    if (isMissed) return Icons.call_received;
    return isIncoming ? Icons.call_received : Icons.call_made;
  }

  String _getCallDuration() {
    final durations = ['2:34', '0:45', '5:12', '1:23', '3:45'];
    return durations[DateTime.now().millisecond % durations.length];
  }

  void _callBack(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling Contact ${index + 1}...')),
    );
  }

  void _viewCallDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CallDetailsSheet(contactIndex: index),
    );
  }
}

class _CallDetailsSheet extends StatelessWidget {
  final int contactIndex;

  const _CallDetailsSheet({required this.contactIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text('C${contactIndex + 1}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact ${contactIndex + 1}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('+1 (555) 123-456${contactIndex.toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Duration',
            value: '2:34',
          ),
          _DetailRow(
            icon: Icons.schedule,
            label: 'Time',
            value: '${DateTime.now().subtract(Duration(hours: contactIndex)).hour}:00',
          ),
          _DetailRow(
            icon: Icons.phone,
            label: 'Type',
            value: contactIndex % 2 == 0 ? 'Incoming' : 'Outgoing',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling Contact ${contactIndex + 1}...')),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Messaging Contact ${contactIndex + 1}...')),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}