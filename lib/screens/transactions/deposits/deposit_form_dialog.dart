import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/deposit_controller.dart';
import '../../../controllers/member_controller.dart';
import '../../../models/deposit_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class DepositFormDialog extends StatefulWidget {
  final DepositModel? depositToEdit;

  const DepositFormDialog({super.key, this.depositToEdit});

  @override
  State<DepositFormDialog> createState() => _DepositFormDialogState();
}

class _DepositFormDialogState extends State<DepositFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _selectedMemberId;
  String _selectedMethod = AppConstants.paymentMethods.first;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final memberCtrl = Get.find<MemberController>();

    if (widget.depositToEdit != null) {
      _selectedMemberId = widget.depositToEdit!.memberId;
      _amountCtrl.text = widget.depositToEdit!.amount.toStringAsFixed(0);
      _noteCtrl.text = widget.depositToEdit!.note;
      _selectedMethod = widget.depositToEdit!.paymentMethod;
      _date = widget.depositToEdit!.date;
    } else if (memberCtrl.activeMembers.isNotEmpty) {
      _selectedMemberId = memberCtrl.activeMembers.first.id;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
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
    if (_selectedMemberId == null) {
      Get.snackbar('ত্রুটি', 'সদস্য নির্বাচন করুন', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final depositCtrl = Get.find<DepositController>();
    final memberCtrl = Get.find<MemberController>();
    final member = memberCtrl.findMemberById(_selectedMemberId!);
    final memberName = member?.name ?? 'সদস্য';
    final amount = double.parse(_amountCtrl.text.trim());

    if (widget.depositToEdit != null) {
      final updated = widget.depositToEdit!.copyWith(
        memberId: _selectedMemberId!,
        memberName: memberName,
        amount: amount,
        date: _date,
        monthKey: AppFormatters.getMonthKey(_date),
        paymentMethod: _selectedMethod,
        note: _noteCtrl.text.trim(),
      );
      final success = await depositCtrl.updateDeposit(updated);
      if (success) Navigator.pop(context);
    } else {
      final success = await depositCtrl.addDeposit(
        memberId: _selectedMemberId!,
        memberName: memberName,
        amount: amount,
        date: _date,
        paymentMethod: _selectedMethod,
        note: _noteCtrl.text.trim(),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberCtrl = Get.find<MemberController>();
    final depositCtrl = Get.find<DepositController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.depositToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'জমা সম্পাদনা' : 'নতুন জমা গ্রহণ (Deposit)'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Selector
                const Text('সদস্য নির্বাচন করুন *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedMemberId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  items: memberCtrl.members.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Text('${m.name} ${m.roomNumber.isNotEmpty ? "(${m.roomNumber})" : ""}'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedMemberId = val),
                  validator: (val) => val == null ? 'সদস্য আবশ্যক' : null,
                ),
                const SizedBox(height: 14),

                // Amount
                CustomTextField(
                  controller: _amountCtrl,
                  label: 'টাকার পরিমাণ (৳) *',
                  hint: 'যেমন: ৩০০০',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: AppValidators.amount,
                ),
                const SizedBox(height: 14),

                // Payment Method Selector
                const Text('পেমেন্ট মেথড *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.payment_outlined, size: 20),
                  ),
                  items: AppConstants.paymentMethods.map((method) {
                    return DropdownMenuItem(value: method, child: Text(method));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMethod = val);
                  },
                ),
                const SizedBox(height: 14),

                // Date Picker
                const Text('তারিখ *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
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
                const SizedBox(height: 14),

                // Note
                CustomTextField(
                  controller: _noteCtrl,
                  label: 'নোট বা বিবরণ (ঐচ্ছিক)',
                  hint: 'যেমন: ১ম কিস্তি / বিকাশ ট্রানজেকশন ID',
                  prefixIcon: Icons.note_alt_outlined,
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
            text: isEditing ? 'আপডেট' : 'জমা সংরক্ষণ',
            isLoading: depositCtrl.isLoading.value,
            onPressed: _save,
            height: 40,
          ),
        ),
      ],
    );
  }
}
