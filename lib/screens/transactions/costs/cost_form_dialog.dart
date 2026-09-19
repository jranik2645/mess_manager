import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/cost_controller.dart';
import '../../../controllers/auth_manager_controller.dart';
import '../../../models/cost_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class CostFormDialog extends StatefulWidget {
  final CostModel? costToEdit;

  const CostFormDialog({super.key, this.costToEdit});

  @override
  State<CostFormDialog> createState() => _CostFormDialogState();
}

class _CostFormDialogState extends State<CostFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _addedByCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _selectedCategory = AppConstants.costCategories.first;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final authCtrl = Get.find<AuthManagerController>();

    if (widget.costToEdit != null) {
      _titleCtrl.text = widget.costToEdit!.title;
      _amountCtrl.text = widget.costToEdit!.amount.toStringAsFixed(0);
      _selectedCategory = widget.costToEdit!.category;
      _addedByCtrl.text = widget.costToEdit!.addedBy;
      _noteCtrl.text = widget.costToEdit!.note;
      _date = widget.costToEdit!.date;
    } else {
      _addedByCtrl.text = authCtrl.currentManager.value?.name ?? 'ম্যানেজার';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _addedByCtrl.dispose();
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

    final costCtrl = Get.find<CostController>();
    final amount = double.parse(_amountCtrl.text.trim());

    if (widget.costToEdit != null) {
      final updated = widget.costToEdit!.copyWith(
        title: _titleCtrl.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _date,
        monthKey: AppFormatters.getMonthKey(_date),
        addedBy: _addedByCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
      );
      final success = await costCtrl.updateCost(updated);
      if (success && mounted) {
        Navigator.pop(context);
      }
    } else {
      final success = await costCtrl.addCost(
        title: _titleCtrl.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _date,
        addedBy: _addedByCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
      );
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final costCtrl = Get.find<CostController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.costToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'বাজার খরচ সম্পাদনা' : 'নতুন বাজার খরচ যোগ করুন'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                CustomTextField(
                  controller: _titleCtrl,
                  label: 'খরচের নাম / বিবরণ *',
                  hint: 'যেমন: চাল, ডাল ও তেল কেনা',
                  prefixIcon: Icons.shopping_bag_outlined,
                  validator: (val) => AppValidators.required(val, message: 'খরচের বিবরণ দিন'),
                ),
                const SizedBox(height: 14),

                // Amount
                CustomTextField(
                  controller: _amountCtrl,
                  label: 'টাকার পরিমাণ (৳) *',
                  hint: 'যেমন: ১৫০০',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: AppValidators.amount,
                ),
                const SizedBox(height: 14),

                // Category Selector
                const Text('খরচের ক্যাটাগরি *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: AppConstants.costCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 14),

                // Date Picker
                const Text('বাজারের তারিখ *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
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

                // Added By
                CustomTextField(
                  controller: _addedByCtrl,
                  label: 'বাজার করেছেন কে?',
                  hint: 'ম্যানেজার / রহিম',
                  prefixIcon: Icons.person_pin_outlined,
                ),
                const SizedBox(height: 14),

                // Note
                CustomTextField(
                  controller: _noteCtrl,
                  label: 'অতিরিক্ত নোট (ঐচ্ছিক)',
                  hint: 'দোকানের নাম / মেমোর বিবরণ',
                  prefixIcon: Icons.notes_outlined,
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
            text: isEditing ? 'আপডেট' : 'খরচ সংরক্ষণ',
            isLoading: costCtrl.isLoading.value,
            onPressed: _save,
            height: 40,
          ),
        ),
      ],
    );
  }
}
