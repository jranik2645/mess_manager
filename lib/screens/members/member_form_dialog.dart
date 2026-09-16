import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/member_controller.dart';
import '../../models/member_model.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class MemberFormDialog extends StatefulWidget {
  final MemberModel? memberToEdit;
  const MemberFormDialog({super.key, this.memberToEdit});

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    if (widget.memberToEdit != null) {
      _nameCtrl.text = widget.memberToEdit!.name;
      _phoneCtrl.text = widget.memberToEdit!.phone;
      _roomCtrl.text = widget.memberToEdit!.roomNumber;
      _emailCtrl.text = widget.memberToEdit!.email;
      _status = widget.memberToEdit!.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _roomCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final authCtrl = Get.find<AuthManagerController>();
    
    // Check if logged in
    if (!authCtrl.isLoggedIn.value) {
      Get.snackbar('লগইন প্রয়োজন', 'মেম্বার যোগ বা পরিবর্তন করতে আগে ম্যানেজার হিসেবে লগইন করুন', 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final memberCtrl = Get.find<MemberController>();
    bool success = false;

    if (widget.memberToEdit != null) {
      final updated = widget.memberToEdit!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        roomNumber: _roomCtrl.text.trim(),
        status: _status,
      );
      success = await memberCtrl.updateMember(updated);
    } else {
      success = await memberCtrl.addMember(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        roomNumber: _roomCtrl.text.trim(),
        status: _status,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memberToEdit != null;
    final memberCtrl = Get.find<MemberController>();

    return AlertDialog(
      title: Text(isEditing ? 'সদস্য তথ্য আপডেট' : 'নতুন সদস্য যোগ'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameCtrl,
                label: 'সদস্যের নাম *',
                prefixIcon: Icons.person,
                validator: (v) => AppValidators.required(v),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneCtrl,
                label: 'মোবাইল নম্বর *',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => AppValidators.phone(v),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _roomCtrl,
                label: 'রুম নম্বর',
                prefixIcon: Icons.room,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailCtrl,
                label: 'ইমেইল (ঐচ্ছিক)',
                prefixIcon: Icons.email,
                validator: (v) => AppValidators.email(v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
        Obx(() => CustomButton(
          text: isEditing ? 'আপডেট' : 'সংরক্ষণ',
          isLoading: memberCtrl.isLoading.value,
          onPressed: _save,
          height: 40,
        )),
      ],
    );
  }
}
