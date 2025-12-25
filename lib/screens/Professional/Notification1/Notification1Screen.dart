import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/constants/apps_colors.dart';

/* ===================== Screen ===================== */

class Notification1Screen extends StatefulWidget {
  const Notification1Screen({super.key});

  @override
  State<Notification1Screen> createState() => _Notification1ScreenState();
}

class _Notification1ScreenState extends State<Notification1Screen> {
  late List<NotificationItem> items;

  @override
  void initState() {
    super.initState();
    // Sample notifications matching Figma design
    items = <NotificationItem>[
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=3",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment: null,
        time: "Last Wednesday at 9:42 AM",
        isRead: false,
      ),
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=5",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment:
            "Oh, I finished de-bugging the phones, but the system's compiling for eighteen minutes, or twenty. So, some minor systems may go on and off for a while.",
        time: "Last Wednesday at 9:42 AM",
        isRead: false,
      ),
      NotificationItem.attachment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=7",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        filename: "landing_paage_ver2.fig",
        size: "2mb",
        time: "Last Wednesday at 9:42 AM",
        isRead: false,
      ),
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=8",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment: null,
        time: "Last Wednesday at 9:42 AM",
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title
                  Expanded(
                    child: Center(
                      child: Text(
                        "Notifications",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF36969), // Exact Figma color
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Menu Button
                  GestureDetector(
                    onTap: () {
                      _showOptionsMenu(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.black87,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.horizontal,
                  background: _buildReadAction(),
                  secondaryBackground: _buildArchiveAction(),
                  onDismissed: (direction) {
                    final removed = item;
                    setState(() => items.removeAt(i));

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          direction == DismissDirection.startToEnd
                              ? 'Read: ${removed.docTitle}'
                              : 'Archived: ${removed.docTitle}',
                        ),
                        backgroundColor: AppColors.buttonBg,
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() => items.insert(i, removed));
                          },
                        ),
                      ),
                    );
                  },
                  child: NotificationCard(item: item),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Notifications",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text("Mark all as read"),
              onTap: () {
                setState(() {
                  for (var item in items) {
                    item.isRead = true;
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text("Clear all notifications"),
              onTap: () {
                setState(() {
                  items.clear();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadAction() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5469D4), // Exact Figma blue color
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_email_read,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            'Read',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveAction() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3C4257), // Exact Figma dark gray color
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            'Archive',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== UI Pieces ===================== */

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDADADA)), // Exact Figma border color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Unread Indicator
          if (!item.isRead)
            Container(
              height: 8,
              width: 16,
              margin: const EdgeInsets.only(left: 0, top: 8),
              alignment: Alignment.topLeft,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF36969), // Red dot
                  shape: BoxShape.circle,
                ),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and Subject Line
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(item.user.avatar),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    // Subject Line
                    Expanded(
                      child: _buildSubjectLine(),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                // Comment/Attachment Content
                if (item.kind == NotificationKind.comment && item.comment != null) ...[
                  const SizedBox(height: 8),
                  _buildQuotedText(item.comment!),
                ],
                if (item.kind == NotificationKind.attachment) ...[
                  const SizedBox(height: 8),
                  _buildAttachmentRow(item.filename!, item.size!),
                ],
                // Timestamp
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    item.time,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA5ACB8), // Exact Figma gray color
                      height: 1.43, // 20px line height
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE4E8EE), // Exact Figma divider color
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectLine() {
    final nameParts = item.user.name.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    String actionText = '';
    if (item.kind == NotificationKind.attachment) {
      actionText = 'attached a file to';
    } else {
      actionText = 'commented on';
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1F36), // Exact Figma text color
          height: 1.43, // 20px line height
        ),
        children: [
          TextSpan(
            text: firstName,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, // SemiBold
            ),
          ),
          if (lastName.isNotEmpty) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: lastName,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          TextSpan(
            text: ' $actionText ',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400, // Regular
            ),
          ),
          TextSpan(
            text: item.docTitle,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, // Bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDEE1), // Exact Figma gray
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$text"',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1F36),
                height: 1.43,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentRow(String filename, String size) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDDEE1)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.insert_drive_file,
              size: 16,
              color: Color(0xFF00AC54), // Green for file icon
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filename,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1F36),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            size,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA5ACB8),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Models ===================== */

enum NotificationKind { comment, attachment }

class User {
  final String name;
  final String avatar;
  const User({required this.name, required this.avatar});
}

class NotificationItem {
  final String id;
  final NotificationKind kind;
  final User user;
  final String docTitle;
  final String time;
  bool isRead;
  final String? comment;
  final String? filename;
  final String? size;

  NotificationItem._({
    required this.id,
    required this.kind,
    required this.user,
    required this.docTitle,
    required this.time,
    this.isRead = false,
    this.comment,
    this.filename,
    this.size,
  });

  factory NotificationItem.comment({
    required User user,
    required String docTitle,
    required String? comment,
    required String time,
    bool isRead = false,
  }) =>
      NotificationItem._(
        id: _genId(),
        kind: NotificationKind.comment,
        user: user,
        docTitle: docTitle,
        comment: comment,
        time: time,
        isRead: isRead,
      );

  factory NotificationItem.attachment({
    required User user,
    required String docTitle,
    required String filename,
    required String size,
    required String time,
    bool isRead = false,
  }) =>
      NotificationItem._(
        id: _genId(),
        kind: NotificationKind.attachment,
        user: user,
        docTitle: docTitle,
        filename: filename,
        size: size,
        time: time,
        isRead: isRead,
      );

  static String _genId() =>
      "${DateTime.now().microsecondsSinceEpoch}_${UniqueKey()}";
}
