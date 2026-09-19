import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/extra_bill_controller.dart';
import '../../../controllers/member_controller.dart';
import '../../../controllers/auth_manager_controller.dart';
import '../../../models/extra_bill_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class ExtraBillFormDialog extends StatefulWidget {
  final ExtraBillModel? billToEdit;

  const ExtraBillFormDialog({super.key, this.billToEdit});

  @override
  State<ExtraBillFormDialog> createState() => _ExtraBillFormDialogState();
}

class _ExtraBillFormDialogState extends State<ExtraBillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addedByCtrl = TextEditingController();

  String _selectedCategory = AppConstants.extraBillCategories.first;
  String _distributionType = AppConstants.distEqual; // 'equal', 'selected', 'manual'
  DateTime _date = DateTime.now();

  // Selected member IDs (for 'selected' mode)
  final Set<String> _selectedMemberIds = {};

  // Manual amounts (for 'manual' mode)
  final Map<String, TextEditingController> _manualCtrls = {};

  @override
  void initState() {
    super.initState();
    final memberCtrl = Get.find<MemberController>();
    final authCtrl = Get.find<AuthManagerController>();

    for (final m in memberCtrl.members) {
      _selectedMemberIds.add(m.id);
      _manualCtrls[m.id] = TextEditingController(text: '0');
    }

    if (widget.billToEdit != null) {
      final bill = widget.billToEdit!;
      _titleCtrl.text = bill.title;
      _amountCtrl.text = bill.amount.toStringAsFixed(0);
      _selectedCategory = bill.category;
      _distributionType = bill.distributionType;
      _date = bill.date;
      _descriptionCtrl.text = bill.description;
      _addedByCtrl.text = bill.addedBy;

      _selectedMemberIds.clear();
      _selectedMemberIds.addAll(bill.memberShares.keys);

      bill.memberShares.forEach((id, val) {
        if (_manualCtrls.containsKey(id)) {
          _manualCtrls[id]!.text = val.toStringAsFixed(0);
        }
      });
    } else {
      _addedByCtrl.text = authCtrl.currentManager.value?.name ?? 'ম্যানেজার';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _addedByCtrl.dispose();
    for (final ctrl in _manualCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final extraBillCtrl = Get.find<ExtraBillController>();
    final memberCtrl = Get.find<MemberController>();
    final amount = double.parse(_amountCtrl.text.trim());

    final Map<String, double> manualMap = {};
    if (_distributionType == AppConstants.distManual) {
      _manualCtrls.forEach((id, ctrl) {
        manualMap[id] = double.tryParse(ctrl.text.trim()) ?? 0.0;
      });
    }

    if (widget.billToEdit != null) {
      // Calculate updated shares
      final shares = <String, double>{};
      if (_distributionType == AppConstants.distEqual) {
        final active = memberCtrl.activeMembers;
        final per = amount / (active.isEmpty ? 1 : active.length);
        for (final m in active) {
          shares[m.id] = double.parse(per.toStringAsFixed(2));
        }
      } else if (_distributionType == AppConstants.distSelected) {
        final count = _selectedMemberIds.length;
        final per = amount / (count == 0 ? 1 : count);
        for (final id in _selectedMemberIds) {
          shares[id] = double.parse(per.toStringAsFixed(2));
        }
      } else {
        shares.addAll(manualMap);
      }

      final updated = widget.billToEdit!.copyWith(
        title: _titleCtrl.text.trim(),
        category: _selectedCategory,
        amount: amount,
        date: _date,
        monthKey: AppFormatters.getMonthKey(_date),
        distributionType: _distributionType,
        memberShares: shares,
        description: _descriptionCtrl.text.trim(),
        addedBy: _addedByCtrl.text.trim(),
      );
      final success = await extraBillCtrl.updateExtraBill(updated);
      if (success && mounted) {
        Navigator.pop(context);
      }
    } else {
      final success = await extraBillCtrl.createExtraBill(
        title: _titleCtrl.text.trim(),
        category: _selectedCategory,
        amount: amount,
        date: _date,
        distributionType: _distributionType,
        activeMembers: memberCtrl.activeMembers,
        selectedMemberIds: _selectedMemberIds.toList(),
        manualAmounts: manualMap,
        description: _descriptionCtrl.text.trim(),
        addedBy: _addedByCtrl.text.trim(),
      );
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberCtrl = Get.find<MemberController>();
    final extraBillCtrl = Get.find<ExtraBillController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.billToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'অতিরিক্ত বিল সম্পাদনা' : 'নতুন অতিরিক্ত বিল (Extra Bill)'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                CustomTextField(
                  controller: _titleCtrl,
                  label: 'বিলের নাম / শিরোনাম *',
                  hint: 'যেমন: মে মাসের বিদ্যুৎ বিল',
                  prefixIcon: Icons.receipt_long_outlined,
                  validator: (val) => AppValidators.required(val, message: 'বিলের নাম দিন'),
                ),
                const SizedBox(height: 14),

                // Category
                const Text('বিলের ধরন / ক্যাটাগরি *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: AppConstants.extraBillCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 14),

                // Amount
                CustomTextField(
                  controller: _amountCtrl,
                  label: 'মোট বিলের পরিমাণ (৳) *',
                  hint: 'যেমন: ১০০০',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: AppValidators.amount,
                  onTap: () => setState(() {}),
                ),
                const SizedBox(height: 14),

                // Date
                const Text('বিলের তারিখ *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.grey.shade800 : AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(AppFormatters.formatDate(_date)),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Distribution Type Selection
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'বিল বণ্টনের পদ্ধতি (Distribution)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('সমান বণ্টন (Equal Split)'),
                        subtitle: const Text('সকল সক্রিয় মেম্বারদের মাঝে সমান ভাগ হবে'),
                        value: AppConstants.distEqual,
                        groupValue: _distributionType,
                        onChanged: (val) => setState(() => _distributionType = val!),
                      ),
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('নির্দিষ্ট সদস্য নির্বাচন (Selected Members)'),
                        subtitle: const Text('যাদের টিক দেবেন শুধু তাদের মাঝে ভাগ হবে'),
                        value: AppConstants.distSelected,
                        groupValue: _distributionType,
                        onChanged: (val) => setState(() => _distributionType = val!),
                      ),
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('কাস্টম / আলাদা পরিমাণ (Individual Amount)'),
                        subtitle: const Text('প্রতিটি মেম্বারের জন্য আলাদা টাকা লিখুন'),
                        value: AppConstants.distManual,
                        groupValue: _distributionType,
                        onChanged: (val) => setState(() => _distributionType = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Member Selection Area (for Selected or Manual)
                if (_distributionType == AppConstants.distSelected) ...[
                  const Text('কোন কোন সদস্য বিল পরিশোধ করবেন:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...memberCtrl.members.map((m) {
                    final isChecked = _selectedMemberIds.contains(m.id);
                    return CheckboxListTile(
                      dense: true,
                      title: Text(m.name),
                      subtitle: Text(m.roomNumber.isNotEmpty ? 'রুম: ${m.roomNumber}' : ''),
                      value: isChecked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedMemberIds.add(m.id);
                          } else {
                            _selectedMemberIds.remove(m.id);
                          }
                        });
                      },
                    );
                  }),
                ],

                if (_distributionType == AppConstants.distManual) ...[
                  const Text('সদস্যভিত্তিক টাকার পরিমাণ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...memberCtrl.members.map((m) {
                    final ctrl = _manualCtrls[m.id] ?? TextEditingController();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(m.name, style: const TextStyle(fontSize: 13.5)),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 38,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  prefixText: '৳ ',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 10),
                CustomTextField(
                  controller: _descriptionCtrl,
                  label: 'মন্তব্য / নোট (ঐচ্ছিক)',
                  hint: 'যেমন: শুধুমাত্র ৩য় তলার মেম্বারদের জন্য প্রযোজ্য',
                  prefixIcon: Icons.notes,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বাতিল'),
        ),
        Obx(
          () => CustomButton(
            text: isEditing ? 'আপডেট' : 'বিল সংরক্ষণ',
            isLoading: extraBillCtrl.isLoading.value,
            onPressed: _save,
            height: 40,
          ),
        ),
      ],
    );
  }
}
