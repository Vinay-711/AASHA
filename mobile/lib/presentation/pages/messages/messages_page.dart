import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const _chats = [
    _ChatData('Dr. Priya Sharma', 'Your BP report looks normal...', '10:24', 2),
    _ChatData('Dr. Rahul Verma', 'Please take the medicine after...', '09:15', 0),
    _ChatData('Dr. Anjali Gupta', 'The test results are ready.', 'Yesterday', 1),
    _ChatData('AASHA Support', 'How can we help you today?', 'Yesterday', 0),
    _ChatData('Dr. Arjun Singh', 'See you on your next appointment', '2 days', 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => AppUi.showToast(context, 'Search coming soon'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const Divider(
          indent: 86,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return _ChatTile(data: chat);
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final _ChatData data;

  const _ChatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => AppUi.showToast(context, 'Opening chat...'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.person_rounded,
          color: AppColors.primary,
          size: 26,
        ),
      ),
      title: Text(
        data.name,
        style: TextStyle(
          fontSize: 15,
          fontWeight: data.unread > 0 ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          data.lastMessage,
          style: TextStyle(
            fontSize: 13,
            color: data.unread > 0
                ? AppColors.textBody
                : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            data.time,
            style: TextStyle(
              fontSize: 12,
              color: data.unread > 0
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          if (data.unread > 0) ...[
            const SizedBox(height: 6),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${data.unread}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatData {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;

  const _ChatData(this.name, this.lastMessage, this.time, this.unread);
}
