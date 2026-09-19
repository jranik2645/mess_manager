import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/member_controller.dart';
import '../../models/member_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state_widget.dart';
import 'member_form_dialog.dart';
import 'member_detail_screen.dart';

class MembersListScreen extends StatelessWidget {
  const MembersListScreen({super.key});

  void _openAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const MemberFormDialog(),
    );
  }

  void _openEditMemberDialog(BuildContext context, MemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => MemberFormDialog(memberToEdit: member),
    );
  }

  void _confirmDelete(BuildContext context, MemberController memberCtrl, MemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সদস্য মুছে ফেলুন'),
        content: Text('আপনি কি নিশ্চিত যে "${member.name}"-কে মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              memberCtrl.deleteMember(member.id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberCtrl = Get.find<MemberController>();
    final authCtrl = Get.find<AuthManagerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('মেস সদস্যবৃন্দ (Members)'),
        actions: [
          Obx(() => authCtrl.isLoggedIn.value 
            ? IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: () => _openAddMemberDialog(context),
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: TextField(
              onChanged: (val) => memberCtrl.searchQuery.value = val,
              decoration: const InputDecoration(
                hintText: 'নাম বা রুম নম্বর দিয়ে খুঁজুন...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Member List
          Expanded(
            child: Obx(() {
              final list = memberCtrl.filteredMembers;
              if (list.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'কোনো সদস্য পাওয়া যায়নি',
                  message: 'সদস্য যোগ করতে ম্যানেজারকে অনুরোধ করুন।',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final member = list[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () => Get.to(() => MemberDetailScreen(member: member)),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Text(member.name.isNotEmpty ? member.name[0] : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ),
                      title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('রুম: ${member.roomNumber} • মিল: ${AppFormatters.formatMeal(member.totalMeal)}'),
                      trailing: authCtrl.isLoggedIn.value
                          ? PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _openEditMemberDialog(context, member);
                                } else if (val == 'delete') {
                                  _confirmDelete(context, memberCtrl, member);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                                const PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন', style: TextStyle(color: Colors.red))),
                              ],
                            )
                          : const Icon(Icons.chevron_right),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => authCtrl.isLoggedIn.value 
        ? FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _openAddMemberDialog(context),
            child: const Icon(Icons.add),
          )
        : const SizedBox.shrink()
      ),
    );
  }
}
