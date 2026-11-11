import 'package:flutter/material.dart';

void main() {
  runApp(const KhorocherHisabApp());
}

class KhorocherHisabApp extends StatelessWidget {
  const KhorocherHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'খরচের হিসাব',
      theme: ThemeData(
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFE9EEF3),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Transaction Model
enum TransactionType { income, expense, receivable, payable }

class TransactionModel {
  String id;
  String title;
  String date;
  String? dueDate;
  double amount;
  TransactionType type;
  String avatarText;
  Color avatarColor;

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    this.dueDate,
    required this.amount,
    required this.type,
    required this.avatarText,
    required this.avatarColor,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  double totalBalance = 17340.0;
  double todayExpense = 450.0;
  double totalReceivable = 1200.0;
  double totalPayable = 600.0;

  final List<TransactionModel> transactions = [
    TransactionModel(
      id: '1',
      title: 'দুপুরের খাবার',
      date: 'আজ, দুপুর ১:৩০',
      amount: 180.0,
      type: TransactionType.expense,
      avatarText: 'খা',
      avatarColor: const Color(0xFFFFD4C2),
    ),
    TransactionModel(
      id: '2',
      title: 'রাকিব হাসান',
      date: 'লেনদেন: ০৫ মার্চ ২০২৬',
      dueDate: 'ফেরত: ২৫ মার্চ ২০২৬',
      amount: 1200.0,
      type: TransactionType.receivable,
      avatarText: 'রা',
      avatarColor: const Color(0xFFD4E6F1),
    ),
    TransactionModel(
      id: '3',
      title: 'করিম চাচা (দোকান বাকি)',
      date: 'লেনদেন: ০১ মার্চ ২০২৬',
      dueDate: 'ফেরত: ১৫ মার্চ ২০২৬',
      amount: 600.0,
      type: TransactionType.payable,
      avatarText: 'ক',
      avatarColor: const Color(0xFFFFE8B8),
    ),
  ];

  void _addTransaction(String title, double amount, TransactionType type, {String? dueDate}) {
    setState(() {
      if (type == TransactionType.expense) {
        totalBalance -= amount;
        todayExpense += amount;
      } else if (type == TransactionType.income) {
        totalBalance += amount;
      } else if (type == TransactionType.receivable) {
        totalReceivable += amount;
      } else if (type == TransactionType.payable) {
        totalPayable += amount;
      }

      String defaultTitle = '';
      Color color = const Color(0xFFC7E2D8);
      if (type == TransactionType.expense) {
        defaultTitle = 'অন্যান্য খরচ';
        color = const Color(0xFFFFD4C2);
      } else if (type == TransactionType.income) {
        defaultTitle = 'অন্যান্য আয়';
      } else if (type == TransactionType.receivable) {
        defaultTitle = 'পাওনা হিসাব';
        color = const Color(0xFFD4E6F1);
      } else {
        defaultTitle = 'দেনা হিসাব';
        color = const Color(0xFFFFE8B8);
      }

      final now = DateTime.now();
      final currentDateStr = 'লেনদেন: ${now.day}/${now.month}/${now.year}';

      transactions.insert(
        0,
        TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.isEmpty ? defaultTitle : title,
          date: currentDateStr,
          dueDate: dueDate,
          amount: amount,
          type: type,
          avatarText: title.isNotEmpty ? title.characters.first : 'হি',
          avatarColor: color,
        ),
      );
    });
  }

  void _deleteTransaction(TransactionModel item) {
    setState(() {
      if (item.type == TransactionType.expense) {
        totalBalance += item.amount;
        todayExpense = (todayExpense - item.amount).clamp(0.0, double.infinity);
      } else if (item.type == TransactionType.income) {
        totalBalance -= item.amount;
      } else if (item.type == TransactionType.receivable) {
        totalReceivable = (totalReceivable - item.amount).clamp(0.0, double.infinity);
      } else if (item.type == TransactionType.payable) {
        totalPayable = (totalPayable - item.amount).clamp(0.0, double.infinity);
      }

      transactions.removeWhere((t) => t.id == item.id);
    });
  }

  void _editTransaction(TransactionModel item) {
    final titleController = TextEditingController(text: item.title);
    final amountController = TextEditingController(text: item.amount.toStringAsFixed(0));
    final dueDateController = TextEditingController(text: item.dueDate?.replaceAll('ফেরত: ', '') ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFBFBFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('হিসাব পরিবর্তন করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        labelText: 'টাকার পরিমাণ',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'বিবরণ / নাম',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    if (item.type == TransactionType.receivable || item.type == TransactionType.payable) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: dueDateController,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() {
                              dueDateController.text = '${picked.day}/${picked.month}/${picked.year}';
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'ফেরতের শেষ তারিখ',
                          prefixIcon: const Icon(Icons.calendar_month_rounded, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2028),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final newAmount = double.tryParse(amountController.text) ?? item.amount;
                          final diff = newAmount - item.amount;

                          setState(() {
                            if (item.type == TransactionType.expense) {
                              totalBalance -= diff;
                              todayExpense += diff;
                            } else if (item.type == TransactionType.income) {
                              totalBalance += diff;
                            } else if (item.type == TransactionType.receivable) {
                              totalReceivable += diff;
                            } else if (item.type == TransactionType.payable) {
                              totalPayable += diff;
                            }

                            item.title = titleController.text.isEmpty ? item.title : titleController.text;
                            item.amount = newAmount;
                            item.avatarText = item.title.characters.first;
                            if (dueDateController.text.isNotEmpty) {
                              item.dueDate = 'ফেরত: ${dueDateController.text}';
                            }
                          });

                          Navigator.pop(ctx);
                        },
                        child: const Text('পরিবর্তন সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openDebtSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dueDateController = TextEditingController();
    bool isReceivable = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFBFBFD),
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('দেনা ও পাওনার হিসাব', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isReceivable = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isReceivable ? const Color(0xFF2E7D32) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Center(
                                child: Text(
                                  'টাকা পাবো (পাওনা)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isReceivable ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isReceivable = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isReceivable ? const Color(0xFFD97706) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Center(
                                child: Text(
                                  'টাকা দেবো (দেনা)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isReceivable ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        labelText: 'টাকার পরিমাণ',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'ব্যক্তির নাম (যেমন: রাকিব, রহিম ভাই)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dueDateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() {
                            dueDateController.text = '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'ফেরতের শেষ তারিখ',
                        prefixIcon: const Icon(Icons.calendar_month_rounded, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isReceivable ? const Color(0xFF2E7D32) : const Color(0xFFD97706),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final enteredAmount = double.tryParse(amountController.text) ?? 0.0;
                          if (enteredAmount > 0) {
                            String? due;
                            if (dueDateController.text.isNotEmpty) {
                              due = 'ফেরত: ${dueDateController.text}';
                            }
                            _addTransaction(
                              nameController.text,
                              enteredAmount,
                              isReceivable ? TransactionType.receivable : TransactionType.payable,
                              dueDate: due,
                            );
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAddSheet(BuildContext context, bool isExpense) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFBFBFD),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isExpense ? 'নতুন খরচ যোগ করুন' : 'নতুন আয় যোগ করুন',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  labelText: 'টাকার পরিমাণ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'বিবরণ (যেমন: চা-নাস্তা, বেতন)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpense ? const Color(0xFF1B2028) : const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final enteredAmount = double.tryParse(amountController.text) ?? 0.0;
                    if (enteredAmount > 0) {
                      _addTransaction(
                        titleController.text,
                        enteredAmount,
                        isExpense ? TransactionType.expense : TransactionType.income,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeScreen(),
      _buildDebtScreen(),
      _buildHistoryScreen(),
      _buildNotificationScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'হোম', 0),
            _buildNavItem(Icons.sync_alt_rounded, 'দেনা-পাওনা', 1),
            _buildNavItem(Icons.pie_chart_rounded, 'রিপোর্ট', 2),
            _buildNavItem(Icons.notifications_rounded, 'বিজ্ঞপ্তি', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B2028) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE1EBF2), Color(0xFFF9F7E8), Color(0xFFE8EEF3)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('হ্যালো রাফাত! স্বাগতম', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      SizedBox(height: 2),
                      Text('খরচের হিসাব', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xFF181C20), borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: Text('খ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFE8B8), borderRadius: BorderRadius.circular(20)),
                      child: const Text('+০.৬০%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB46200))),
                    ),
                    const SizedBox(height: 6),
                    Text('৳ ${totalBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('দৈনিক খরচ ৳ ${todayExpense.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openAddSheet(context, false),
                      child: Container(
                        height: 68,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.north_east_rounded, size: 20, color: Color(0xFF2E7D32)),
                            SizedBox(height: 4),
                            Text('আয়', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _openDebtSheet(context),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.sync_alt_rounded, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openAddSheet(context, true),
                      child: Container(
                        height: 68,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.south_west_rounded, size: 20, color: Color(0xFFD32F2F)),
                            SizedBox(height: 4),
                            Text('ব্যয়', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Center(child: Text('সাম্প্রতিক হিসাব (সোয়াইপ করে মুছুন)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 12),
              ...transactions.take(3).map((item) => _buildTransactionCard(item)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebtScreen() {
    final debtItems = transactions.where((t) => t.type == TransactionType.receivable || t.type == TransactionType.payable).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFE8EEF3), Color(0xFFF9F7E8)]),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('দেনা ও পাওনার খাতা', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => _openDebtSheet(context),
                    icon: const Icon(Icons.add_circle, color: Color(0xFF1B2028), size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('মোট পাওনা (পাবেন)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('৳ ${totalReceivable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('মোট দেনা (দেবেন)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('৳ ${totalPayable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('সকল দেনা ও পাওনার তালিকা', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Expanded(
                child: debtItems.isEmpty
                    ? const Center(child: Text('কোনো দেনা-পাওনার হিসাব নেই!'))
                    : ListView.builder(
                        itemCount: debtItems.length,
                        itemBuilder: (ctx, i) => _buildTransactionCard(debtItems[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('সম্পূর্ণ হিস্ট্রি ও রিপোর্ট', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (ctx, i) => _buildTransactionCard(transactions[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationScreen() {
    return const SafeArea(
      child: Center(
        child: Text('🔔 এই মুহূর্তে কোনো রিমাইন্ডার নেই', style: TextStyle(fontSize: 15, color: Colors.grey)),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel item) {
    String sign = item.type == TransactionType.expense ? '- ৳ ' : '+ ৳ ';
    Color amountColor = item.type == TransactionType.expense ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
    if (item.type == TransactionType.payable) amountColor = const Color(0xFFD97706);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 28),
      ),
      onDismissed: (direction) => _deleteTransaction(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(22)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: item.avatarColor,
              child: Text(item.avatarText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(item.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (item.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.dueDate!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text('$sign${item.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: amountColor)),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'edit') {
                  _editTransaction(item);
                } else if (value == 'delete') {
                  _deleteTransaction(item);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text('এডিট করুন'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('মুছে ফেলুন', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
