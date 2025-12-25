import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/* ===================== Screen ===================== */

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItem> items;

  @override
  void initState() {
    super.initState();
    // seed data
    items = <NotificationItem>[
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=3",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment: null,
        time: "Last Wednesday at 9:42 AM",
      ),
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=5",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment:
            "Oh, I finished de-bugging the phones, but the system's compiling for eighteen minutes, or twent…",
        time: "Last Wednesday at 9:42 AM",
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
      ),
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=8",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment: null,
        time: "Last Wednesday at 9:42 AM",
      ),
      NotificationItem.comment(
        user: const User(
          name: "Dennis Nedry",
          avatar: "https://i.pravatar.cc/100?img=9",
        ),
        docTitle: "Isla Nublar SOC2 compliance report",
        comment: null,
        time: "Last Wednesday at 9:42 AM",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Text(
                "Notifications",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFC5C65), // coral title
                  letterSpacing: 0.2,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
            Container(
              height: 3,
              color: const Color(0xFF2E89FF),
            ), // blue underline
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return Dismissible(
            key: ValueKey(item.id), // stable key
            direction: DismissDirection.endToStart,
            background: _placeholderBg(),
            secondaryBackground: _archiveBg(),
            onDismissed: (_) {
              final removed = item;
              setState(() => items.removeAt(i));

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Archived: ${removed.docTitle}'),
                  action: SnackBarAction(
                    label: 'UNDO',
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

  // Shown when swiping start->end (we disable that direction, but Dismissible requires a non-null background)
  Widget _placeholderBg() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // Shown when swiping end->start (left)
  Widget _archiveBg() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // archive green
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.archive_rounded, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Archive',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
    final border = Border.all(color: const Color(0xFFE3E7EF));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: border,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(item.user.avatar),
              ),
              const SizedBox(width: 10),
              Expanded(child: _Header(item: item)),
            ],
          ),
          if (item.kind == NotificationKind.comment &&
              item.comment != null) ...[
            const SizedBox(height: 10),
            _QuotedText(text: item.comment!),
          ],
          if (item.kind == NotificationKind.attachment) ...[
            const SizedBox(height: 10),
            _AttachmentRow(filename: item.filename!, size: item.size!),
          ],
          const SizedBox(height: 8),
          Text(
            item.time,
            style: GoogleFonts.poppins(
              color: const Color(0xFF9AA4B2),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF0E141B),
    );

    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          color: const Color(0xFF0E141B),
          height: 1.35,
        ),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _YellowNameTag(
              text: item.user.name.split(' ').first, // first name highlighted
            ),
          ),
          const TextSpan(text: " "),
          TextSpan(
            text: item.user.name.split(' ').skip(1).join(' '),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: item.kind == NotificationKind.attachment
                ? " attached a file to "
                : " commented on ",
          ),
          TextSpan(text: item.docTitle, style: titleStyle),
        ],
      ),
    );
  }
}

class _YellowNameTag extends StatelessWidget {
  const _YellowNameTag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0E141B),
          height: 1.0,
        ),
      ),
    );
  }
}

class _QuotedText extends StatelessWidget {
  const _QuotedText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFDFE3EB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "“$text”",
            style: GoogleFonts.poppins(
              color: const Color(0xFF3A4656),
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.filename, required this.size});
  final String filename;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE6E7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.insert_drive_file,
            size: 16,
            color: Color(0xFFED4C5C),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            filename,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222B38),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          size,
          style: GoogleFonts.poppins(
            color: const Color(0xFF9AA4B2),
            fontSize: 12.5,
          ),
        ),
      ],
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
  final String id; // stable id for Dismissible keys
  final NotificationKind kind;
  final User user;
  final String docTitle;
  final String time;
  final String? comment;
  final String? filename;
  final String? size;

  NotificationItem._({
    required this.id,
    required this.kind,
    required this.user,
    required this.docTitle,
    required this.time,
    this.comment,
    this.filename,
    this.size,
  });

  factory NotificationItem.comment({
    required User user,
    required String docTitle,
    required String? comment,
    required String time,
  }) => NotificationItem._(
    id: _genId(),
    kind: NotificationKind.comment,
    user: user,
    docTitle: docTitle,
    comment: comment,
    time: time,
  );

  factory NotificationItem.attachment({
    required User user,
    required String docTitle,
    required String filename,
    required String size,
    required String time,
  }) => NotificationItem._(
    id: _genId(),
    kind: NotificationKind.attachment,
    user: user,
    docTitle: docTitle,
    filename: filename,
    size: size,
    time: time,
  );

  static String _genId() =>
      "${DateTime.now().microsecondsSinceEpoch}_${UniqueKey()}";
}
