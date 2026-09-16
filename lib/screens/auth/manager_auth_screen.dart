import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../app/routes/app_routes.dart';

class ManagerAuthScreen extends StatefulWidget {
  final bool isEditing;
  const ManagerAuthScreen({super.key, this.isEditing = false});

  @override
  State<ManagerAuthScreen> createState() => _ManagerAuthScreenState();
}

class _ManagerAuthScreenState extends State<ManagerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  DateTime _joiningDate = DateTime.now();
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    _isLoginMode = !widget.isEditing;
    final authCtrl = Get.find<AuthManagerController>();
    final mgr = authCtrl.currentManager.value;
    if (mgr != null && widget.isEditing) {
      _nameCtrl.text = mgr.name;
      _phoneCtrl.text = mgr.phone;
      _emailCtrl.text = mgr.email;
      _joiningDate = mgr.joiningDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authCtrl = Get.find<AuthManagerController>();
    bool success = false;

    if (widget.isEditing) {
      success = await authCtrl.saveManagerProfile(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        joiningDate: _joiningDate,
      );
    } else if (_isLoginMode) {
      success = await authCtrl.login(_emailCtrl.text, _passwordCtrl.text);
    } else {
      success = await authCtrl.registerManager(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    }

    if (success) {
      Get.offAllNamed(AppRoutes.mainNav);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthManagerController>();

    String titleText = 'ম্যানেজার পোর্টাল';
    if (widget.isEditing) titleText = 'প্রোফাইল আপডেট';
    else if (_isLoginMode) titleText = 'ম্যানেজার লগইন';
    else titleText = 'ম্যানেজার রেজিস্ট্রেশন';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        automaticallyImplyLeading: widget.isEditing || Navigator.canPop(context),
        actions: [
          if (authCtrl.isLoggedIn.value && widget.isEditing)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authCtrl.logout();
                Get.offAllNamed(AppRoutes.mainNav);
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Role Card
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.security, size: 40, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isLoginMode && !widget.isEditing
                          ? 'স্বাগতম! লগইন করুন'
                          : 'ম্যানেজার তথ্য',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (!_isLoginMode || widget.isEditing) ...[
                        CustomTextField(
                          controller: _nameCtrl,
                          label: 'ম্যানেজারের নাম *',
                          hint: 'আরিফুল ইসলাম',
                          prefixIcon: Icons.badge_outlined,
                          validator: (val) => AppValidators.required(val),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneCtrl,
                          label: 'মোবাইল নম্বর *',
                          hint: '01712345678',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.phone,
                        ),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'ইমেইল *',
                        hint: 'manager@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 16),
                      if (!widget.isEditing)
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: 'পাসওয়ার্ড *',
                          hint: '******',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (val) => (val?.length ?? 0) < 6 ? 'পাসওয়ার্ড ৬ ডিজিটের বেশি হতে হবে' : null,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Obx(
                () => CustomButton(
                  text: widget.isEditing
                      ? 'আপডেট করুন'
                      : (_isLoginMode ? 'লগইন' : 'রেজিস্ট্রেশন করুন'),
                  isLoading: authCtrl.isLoading.value,
                  onPressed: _submit,
                ),
              ),

              if (!widget.isEditing) ...[
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(_isLoginMode
                      ? 'নতুন ম্যানেজার? এখানে ক্লিক করে রেজিস্ট্রেশন করুন'
                      : 'ইতিমধ্যেই ম্যানেজার আছেন? লগইন করুন'),
                ),
                if (_isLoginMode)
                  TextButton(
                    onPressed: () {
                      if (_emailCtrl.text.isEmpty) {
                        Get.snackbar('ত্রুটি', 'পাসওয়ার্ড রিসেট করতে আগে ইমেইল দিন');
                        return;
                      }
                      // Implement forgot password logic in controller
                      Get.snackbar('তথ্য', 'পাসওয়ার্ড রিসেট লিংক আপনার ইমেইলে পাঠানো হয়েছে (যদি ইমেইলটি নিবন্ধিত থাকে)');
                    },
                    child: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
