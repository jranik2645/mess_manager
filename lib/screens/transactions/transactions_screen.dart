import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_manager_controller.dart';
import '../../controllers/deposit_controller.dart';
import '../../controllers/cost_controller.dart';
import '../../controllers/extra_bill_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/deposit_model.dart';
import '../../models/cost_model.dart';
import '../../models/extra_bill_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state_widget.dart';
import 'deposits/deposit_form_dialog.dart';
import 'costs/cost_form_dialog.dart';
import 'extra_bills/extra_bill_form_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  final int initialTabIndex;
  const TransactionsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NavigationController _navCtrl = Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _navCtrl.transactionSubTabIndex.value,
    );
    
    // Sync TabController with NavigationController's sub-index
    ever(_navCtrl.transactionSubTabIndex, (int index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    _tabController.addListener(() {
      _navCtrl.transactionSubTabIndex.value = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    if (_tabController.index == 0) {
      showDialog(context: context, builder: (ctx) => const DepositFormDialog());
    } else if (_tabController.index == 1) {
      showDialog(context: context, builder: (ctx) => const CostFormDialog());
    } else {
      showDialog(context: context, builder: (ctx) => const ExtraBillFormDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthManagerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('লেনদেন ও হিসাব (Transactions)'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.savings_outlined), text: 'জমা (Deposit)'),
            Tab(icon: Icon(Icons.shopping_basket_outlined), text: 'বাজার খরচ (Cost)'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'এক্সট্রা বিল (Extra)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDepositTab(context),
          _buildCostTab(context),
          _buildExtraBillTab(context),
        ],
      ),
      floatingActionButton: authCtrl.isLoggedIn.value
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('নতুন লেনদেন যোগ করুন'),
              onPressed: _openAddDialog,
            )
          : null,
    );
  }

  // ===================== TAB 1: DEPOSIT =====================
  Widget _buildDepositTab(BuildContext context) {
    final depositCtrl = Get.find<DepositController>();
    final authCtrl = Get.find<AuthManagerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Total Deposits Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.green.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'চলতি মাসের মোট জমা:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: isDark ? Colors.grey.shade300 : Colors.green.shade900,
                ),
              ),
              Obx(
                () => Text(
                  AppFormatters.formatCurrency(depositCtrl.totalDepositsInMonth),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade300 : Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search & Filter
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (val) => depositCtrl.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'মেম্বারের নাম বা মেথড দিয়ে খুঁজুন...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),

        // Deposits List
        Expanded(
          child: Obx(() {
            final list = depositCtrl.filteredDeposits;
            if (list.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.savings_outlined,
                title: 'কোনো জমা রেকর্ড পাওয়া যায়নি',
                message: 'মেম্বারদের জমার টাকা এন্ট্রি করতে নিচের বাটনে চাপুন।',
                actionText: 'জমা গ্রহণ করুন',
                onAction: () => showDialog(context: context, builder: (ctx) => const DepositFormDialog()),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final dep = list[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                    ),
                    title: Text(
                      dep.memberName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      '${dep.paymentMethod} • ${AppFormatters.formatDate(dep.date)}${dep.note.isNotEmpty ? "\nনোট: ${dep.note}" : ""}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    isThreeLine: dep.note.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(dep.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        if (authCtrl.isLoggedIn.value)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (val) {
                              if (val == 'edit') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => DepositFormDialog(depositToEdit: dep),
                                );
                              } else if (val == 'delete') {
                                _confirmDeleteDeposit(context, depositCtrl, dep);
                              }
                            },
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                              PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmDeleteDeposit(BuildContext context, DepositController ctrl, DepositModel dep) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('জমা মুছে ফেলার নিশ্চিতকরণ'),
        content: Text('আপনি কি নিশ্চিত যে ৳${dep.amount.toStringAsFixed(0)} জমার এন্ট্রি মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteDeposit(dep.id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===================== TAB 2: REGULAR COST =====================
  Widget _buildCostTab(BuildContext context) {
    final costCtrl = Get.find<CostController>();
    final authCtrl = Get.find<AuthManagerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Total Regular Cost Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.deepOrange.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'চলতি মাসের মোট বাজার খরচ:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: isDark ? Colors.grey.shade300 : Colors.deepOrange.shade900,
                ),
              ),
              Obx(
                () => Text(
                  AppFormatters.formatCurrency(costCtrl.totalCostsInMonth),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.deepOrange.shade300 : Colors.deepOrange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (val) => costCtrl.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'বাজার খরচের বিবরণ দিয়ে খুঁজুন...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),

        // Cost List
        Expanded(
          child: Obx(() {
            final list = costCtrl.filteredCosts;
            if (list.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.shopping_basket_outlined,
                title: 'কোনো বাজার খরচের রেকর্ড নেই',
                message: 'দৈনিক বাজার খরচের এন্ট্রি করতে নিচের বাটনে চাপুন।',
                actionText: 'বাজার খরচ যোগ করুন',
                onAction: () => showDialog(context: context, builder: (ctx) => const CostFormDialog()),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final cost = list[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.shade100,
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.deepOrange, size: 20),
                    ),
                    title: Text(
                      cost.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                    subtitle: Text(
                      '${cost.category} • ${AppFormatters.formatDate(cost.date)}${cost.addedBy.isNotEmpty ? " • করেছেন: ${cost.addedBy}" : ""}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(cost.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            color: Colors.redAccent,
                          ),
                        ),
                        if (authCtrl.isLoggedIn.value)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (val) {
                              if (val == 'edit') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => CostFormDialog(costToEdit: cost),
                                );
                              } else if (val == 'delete') {
                                _confirmDeleteCost(context, costCtrl, cost);
                              }
                            },
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                              PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmDeleteCost(BuildContext context, CostController ctrl, CostModel cost) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('খরচ মুছে ফেলার নিশ্চিতকরণ'),
        content: Text('আপনি কি নিশ্চিত যে "${cost.title}"-এর ৳${cost.amount.toStringAsFixed(0)} খরচ মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteCost(cost.id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===================== TAB 3: EXTRA BILL =====================
  Widget _buildExtraBillTab(BuildContext context) {
    final extraCtrl = Get.find<ExtraBillController>();
    final authCtrl = Get.find<AuthManagerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Total Extra Bill Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.indigo.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'চলতি মাসের মোট অতিরিক্ত বিল:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: isDark ? Colors.grey.shade300 : Colors.indigo.shade900,
                ),
              ),
              Obx(
                () => Text(
                  AppFormatters.formatCurrency(extraCtrl.totalExtraBillsInMonth),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (val) => extraCtrl.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'ওয়াইফাই, বিদ্যুৎ বা গ্যাস বিল খুঁজুন...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),

        // Extra Bills List
        Expanded(
          child: Obx(() {
            final list = extraCtrl.filteredBills;
            if (list.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'কোনো অতিরিক্ত বিল নেই',
                message: 'ওয়াইফাই, বিদ্যুৎ, গ্যাস ইত্যাদির বিল আলাদাভাবে বণ্টন করতে পারেন।',
                actionText: 'এক্সট্রা বিল যোগ করুন',
                onAction: () => showDialog(context: context, builder: (ctx) => const ExtraBillFormDialog()),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final bill = list[index];
                final memberCount = bill.memberShares.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(Icons.receipt_outlined, color: Colors.indigo, size: 20),
                    ),
                    title: Text(
                      bill.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                    subtitle: Text(
                      '${bill.category} • বন্টন: $memberCount জনের মধ্যে • ${AppFormatters.formatDate(bill.date)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(bill.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            color: Colors.indigo,
                          ),
                        ),
                        if (authCtrl.isLoggedIn.value)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (val) {
                              if (val == 'edit') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => ExtraBillFormDialog(billToEdit: bill),
                                );
                              } else if (val == 'delete') {
                                _confirmDeleteExtraBill(context, extraCtrl, bill);
                              }
                            },
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
                              PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmDeleteExtraBill(BuildContext context, ExtraBillController ctrl, ExtraBillModel bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('অতিরিক্ত বিল মুছে ফেলার নিশ্চিতকরণ'),
        content: Text('আপনি কি নিশ্চিত যে "${bill.title}"-এর ৳${bill.amount.toStringAsFixed(0)} বিল মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteExtraBill(bill.id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
