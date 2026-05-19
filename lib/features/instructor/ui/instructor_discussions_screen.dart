import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';

class InstructorDiscussionsScreen extends StatefulWidget {
  const InstructorDiscussionsScreen({super.key});

  @override
  State<InstructorDiscussionsScreen> createState() => _InstructorDiscussionsScreenState();
}

class _InstructorDiscussionsScreenState extends State<InstructorDiscussionsScreen> {
  late Future<List<dynamic>> _discussionsFuture;

  @override
  void initState() {
    super.initState();
    _loadDiscussions();
  }

  void _loadDiscussions() {
    setState(() {
      _discussionsFuture = context.read<InstructorRepository>().getDiscussions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pertanyaan & Diskusi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDiscussions();
        },
        child: FutureBuilder<List<dynamic>>(
          future: _discussionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDiscussions,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.question_answer_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada pertanyaan atau diskusi baru',
                      style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            final discussions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: discussions.length,
              itemBuilder: (context, index) {
                final disc = discussions[index];
                return _buildDiscussionCard(disc);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(Map<String, dynamic> disc) {
    final title = disc['title'] ?? 'Diskusi';
    final content = disc['content'] ?? '';
    final studentName = disc['user']?['name'] ?? 'Siswa';
    final studentAvatar = disc['user']?['avatar'] ?? '';
    final repliesCount = disc['replies_count'] ?? (disc['replies'] as List?)?.length ?? 0;
    final createdAtStr = disc['created_at'] ?? '';

    String dateStr = '';
    if (createdAtStr.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAtStr);
        dateStr = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        dateStr = createdAtStr;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: studentAvatar.isNotEmpty ? NetworkImage(studentAvatar) : null,
          child: studentAvatar.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(studentName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 8),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.comment, size: 14, color: Color(0xFF0D47A1)),
              const SizedBox(width: 6),
              Text(
                '$repliesCount',
                style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        onTap: () => _showDiscussionBottomSheet(disc),
      ),
    );
  }

  void _showDiscussionBottomSheet(Map<String, dynamic> disc) {
    final parentId = disc['id'] as int;
    final title = disc['title'] ?? 'Diskusi';
    final content = disc['content'] ?? '';
    final studentName = disc['user']?['name'] ?? 'Siswa';
    final replies = List<dynamic>.from(disc['replies'] ?? []);
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Dari: $studentName', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Original Question Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Balasan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: replies.isEmpty
                        ? const Center(
                            child: Text('Belum ada balasan. Jadilah yang pertama membalas!',
                                style: TextStyle(color: Colors.grey, fontSize: 13)),
                          )
                        : ListView.builder(
                            itemCount: replies.length,
                            itemBuilder: (context, index) {
                              final reply = replies[index];
                              final rUser = reply['user']?['name'] ?? 'Pengguna';
                              final rContent = reply['content'] ?? '';
                              final rAvatar = reply['user']?['avatar'] ?? '';
                              final rCreatedAtStr = reply['created_at'] ?? '';

                              String rDate = '';
                              if (rCreatedAtStr.isNotEmpty) {
                                try {
                                  final date = DateTime.parse(rCreatedAtStr);
                                  rDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                                } catch (e) {
                                  rDate = rCreatedAtStr;
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: rAvatar.isNotEmpty ? NetworkImage(rAvatar) : null,
                                      child: rAvatar.isEmpty ? const Icon(Icons.person, size: 14, color: Colors.grey) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                rUser,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              Text(
                                                rDate,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rContent,
                                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: InputDecoration(
                            hintText: 'Tulis balasan Anda...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF0D47A1)),
                        onPressed: () async {
                          final text = replyController.text.trim();
                          if (text.isEmpty) return;

                          try {
                            await context.read<InstructorRepository>().replyToDiscussion(
                                  parentId: parentId,
                                  content: text,
                                );

                            setModalState(() {
                              replies.add({
                                'content': text,
                                'created_at': DateTime.now().toIso8601String(),
                                'user': {
                                  'name': 'Anda (Instruktur)',
                                  'avatar': '',
                                }
                              });
                              replyController.clear();
                            });
                            _loadDiscussions();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Balasan berhasil dikirim!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
