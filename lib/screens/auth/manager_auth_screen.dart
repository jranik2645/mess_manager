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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authCtrl = Get.find<AuthManagerController>();
    bool success = false;

    if (widget.isEditing) {
      success = await authCtrl.saveManagerProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        joiningDate: _joiningDate,
      );
    } else if (_isLoginMode) {
      success = await authCtrl.login(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
    } else {
      // Registration: Note that we might need to update saveManagerProfile 
      // inside registerManager if we want to save joining date there too.
      // For now, it defaults to DateTime.now() in the controller.
      success = await authCtrl.registerManager(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      
      // If registration is successful, we might want to update the joining date immediately
      if (success && !widget.isEditing) {
         await authCtrl.saveManagerProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          joiningDate: _joiningDate,
        );
      }
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
              // Avatar Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(20),
                  ),
                  child: const Icon(Icons.security, size: 50, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              const Center(child: Text('ম্যানেজার তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isLoginMode || widget.isEditing) ...[
                        CustomTextField(
                          controller: _nameCtrl,
                          label: 'ম্যানেজারের নাম *',
                          hint: ' djbabu',
                          prefixIcon: Icons.badge_outlined,
                          validator: (val) => AppValidators.required(val),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneCtrl,
                          label: 'মোবাইল নম্বর *',
                          hint: ' 01510076424',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.phone,
                        ),
                        const SizedBox(height: 16),
                        
                        // Joining Date Field
                        const Text('দায়িত্ব গ্রহণের তারিখ *', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(AppFormatters.formatDate(_joiningDate), style: const TextStyle(fontSize: 15)),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'ইমেইল *',
                        hint: ' djbabau@gmail.com',
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
