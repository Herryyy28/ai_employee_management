import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class FinancePayrollScreen extends StatefulWidget {
  const FinancePayrollScreen({super.key});

  @override
  State<FinancePayrollScreen> createState() => _FinancePayrollScreenState();
}

class _FinancePayrollScreenState extends State<FinancePayrollScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Payroll state variables
  double _baseSalary = 5000.0;
  double _allowances = 1200.0;
  double _pfRate = 0.12; // 12% Provident Fund
  double _esiRate = 0.0075; // 0.75% ESI

  // Invoice state variables
  final _invoiceFormKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _descController = TextEditingController();
  double _rate = 50.0;
  double _hours = 40.0;
  double _taxRate = 0.18; // 18% GST/VAT

  // Expense claims list
  final List<Map<String, dynamic>> _expenses = [
    {'title': 'Client Dinner - Acme Corp', 'category': 'Travel & Client', 'amount': 185.50, 'status': 'Approved'},
    {'title': 'AWS Cloud Hosting Fees', 'category': 'Infrastructure', 'amount': 1200.00, 'status': 'Pending Approval'},
  ];
  final _expFormKey = GlobalKey<FormState>();
  final _expTitleController = TextEditingController();
  final _expAmtController = TextEditingController();
  String _selectedExpCat = 'Travel';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _clientController.dispose();
    _descController.dispose();
    _expTitleController.dispose();
    _expAmtController.dispose();
    super.dispose();
  }

  // Calculate Net salary dynamically
  double get _pfDeduction => _baseSalary * _pfRate;
  double get _esiDeduction => _baseSalary * _esiRate;
  double get _totalDeductions => _pfDeduction + _esiDeduction + (_baseSalary * 0.10); // Assume 10% base income tax
  double get _netSalary => (_baseSalary + _allowances) - _totalDeductions;

  // Invoice calculations
  double get _subtotal => _rate * _hours;
  double get _taxAmount => _subtotal * _taxRate;
  double get _grandTotal => _subtotal + _taxAmount;

  void _addExpense() {
    if (_expFormKey.currentState?.validate() ?? false) {
      setState(() {
        _expenses.insert(0, {
          'title': _expTitleController.text.trim(),
          'category': _selectedExpCat,
          'amount': double.tryParse(_expAmtController.text) ?? 0.0,
          'status': 'Pending Approval'
        });
        _expTitleController.clear();
        _expAmtController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense claim submitted for reimbursement!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance & Payroll Suite'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Payroll Calculator'),
            Tab(text: 'Invoice Generator'),
            Tab(text: 'Expense Claims'),
            Tab(text: 'Budget Hub'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPayrollTab(context, isDark),
          _buildInvoiceTab(context, isDark),
          _buildExpensesTab(context, isDark),
          _buildBudgetTab(context, isDark),
        ],
      ),
    );
  }

  // TAB 1: Payroll Calculator
  Widget _buildPayrollTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Salary Calculator (PF, ESI, Deductions)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _baseSalary.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Base Salary (\$)', prefixIcon: Icon(Icons.money)),
                  onChanged: (val) {
                    setState(() {
                      _baseSalary = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _allowances.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Allowances (\$)', prefixIcon: Icon(Icons.add_circle_outline)),
                  onChanged: (val) {
                    setState(() {
                      _allowances = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Estimated Deductions breakdown:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                _buildBreakdownRow('Provident Fund (PF - 12%)', '-\$${_pfDeduction.toStringAsFixed(2)}'),
                _buildBreakdownRow('Employee State Insurance (ESI - 0.75%)', '-\$${_esiDeduction.toStringAsFixed(2)}'),
                _buildBreakdownRow('Estimated Income Tax (10%)', '-\$${(_baseSalary * 0.10).toStringAsFixed(2)}'),
                const Divider(),
                _buildBreakdownRow('Net Payout (Net Salary)', '\$${_netSalary.toStringAsFixed(2)}', isBold: true),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payslip PDF generated & saved to documents!'), backgroundColor: AppColors.success),
                    );
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export Payslip PDF'),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppColors.success : Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  // TAB 2: Invoice Generator
  Widget _buildInvoiceTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _invoiceFormKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Generate Client Billing Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clientController,
                  decoration: const InputDecoration(labelText: 'Client Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Services / Projects description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _rate.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Hourly Rate (\$)'),
                        onChanged: (val) => setState(() => _rate = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _hours.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Billable Hours'),
                        onChanged: (val) => setState(() => _hours = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildBreakdownRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
                _buildBreakdownRow('Tax / GST (18%)', '\$${_taxAmount.toStringAsFixed(2)}'),
                const Divider(),
                _buildBreakdownRow('Grand Total Billing', '\$${_grandTotal.toStringAsFixed(2)}', isBold: true),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Client billing Invoice exported to PDF!'), backgroundColor: AppColors.success),
                    );
                  },
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Export & Dispatch Invoice'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TAB 3: Expense claims uploader
  Widget _buildExpensesTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _expFormKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('File Reimbursement Claim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expTitleController,
                    decoration: const InputDecoration(labelText: 'Expense Claim Description'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter expense detail' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expAmtController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Claim Amount (\$)'),
                          validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid number' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedExpCat,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const [
                            DropdownMenuItem(value: 'Travel', child: Text('Travel & Hotel')),
                            DropdownMenuItem(value: 'Food', child: Text('Meals & Hosting')),
                            DropdownMenuItem(value: 'Infrastructure', child: Text('Infrastructure')),
                            DropdownMenuItem(value: 'Others', child: Text('Others')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedExpCat = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addExpense,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Submit Claim with Receipt'),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Reimbursement History & Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ..._expenses.map((exp) {
          final isPending = exp['status'] == 'Pending Approval';
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.success),
              title: Text(exp['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Category: ${exp['category']} • Amount: \$${exp['amount'].toStringAsFixed(2)}'),
              trailing: Text(
                exp['status'],
                style: TextStyle(
                  color: isPending ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 4: Financial Budgets Dashboard
  Widget _buildBudgetTab(BuildContext context, bool isDark) {
    final budgets = [
      {'dept': 'Engineering & Tech', 'spent': 45000, 'total': 60000, 'color': AppColors.indigoAccent},
      {'dept': 'Human Resources', 'spent': 8500, 'total': 15000, 'color': Colors.teal},
      {'dept': 'DevOps & Tooling', 'spent': 18000, 'total': 20000, 'color': Colors.redAccent},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Departmental Capital Budgets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        ...budgets.map((b) {
          final double progress = (b['spent'] as int) / (b['total'] as int);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b['dept'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('\$${b['spent']} / \$${b['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    color: b['color'] as Color,
                    backgroundColor: (b['color'] as Color).withOpacity(0.12),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Budget utilization: ${(progress * 100).toInt()}% utilized.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
