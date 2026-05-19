import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hlms_mobile/features/instructor/data/instructor_repository.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_bloc.dart';
import 'package:hlms_mobile/features/instructor/logic/instructor_dashboard_bloc/instructor_dashboard_state.dart';

class InstructorRedeemScreen extends StatefulWidget {
  const InstructorRedeemScreen({super.key});

  @override
  State<InstructorRedeemScreen> createState() => _InstructorRedeemScreenState();
}

class _InstructorRedeemScreenState extends State<InstructorRedeemScreen> {
  late Future<List<dynamic>> _payoutsFuture;
  final _amountController = TextEditingController();
  final _accountInfoController = TextEditingController();
  String _selectedMethod = 'bank_transfer';
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPayouts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountInfoController.dispose();
    super.dispose();
  }

  void _loadPayouts() {
    setState(() {
      _payoutsFuture = context.read<InstructorRepository>().getPayouts();
    });
  }

  Future<void> _submitPayoutRequest(double availableBalance) async {
    if (!_formKey.currentState!.validate()) return;

    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr) ?? 0.0;

    if (amount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi untuk penarikan ini'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<InstructorRepository>().requestPayout(
        amount: amount,
        method: _selectedMethod,
        accountInfo: _accountInfoController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan penarikan berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );
      _amountController.clear();
      _accountInfoController.clear();
      _loadPayouts();
      // Refresh dashboard data too
      context.read<InstructorDashboardBloc>().add(InstructorDashboardRequested());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstructorDashboardBloc, InstructorDashboardState>(
      builder: (context, state) {
        double availableBalance = 0.0;
        if (state is InstructorDashboardLoaded) {
          final summary = state.dashboardData['revenue_summary'] ?? {};
          availableBalance = double.tryParse(summary['available_balance']?.toString() ?? '0.0') ?? 0.0;
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/app_icon.png',
                    height: 32,
                    width: 32,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Redeem & Payouts',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance Card
                _buildBalanceCard(availableBalance),
                const SizedBox(height: 24),
                
                // Form to Payout
                _buildPayoutForm(availableBalance),
                const SizedBox(height: 24),

                // Payout History
                const Text(
                  'Riwayat Penarikan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                _buildPayoutHistoryList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo yang Dapat Ditarik',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatCurrency(balance)}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Biaya penarikan standard flat Rp 2.500 per transaksi.',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutForm(double availableBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajukan Penarikan Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Penarikan (Rupiah)',
                hintText: 'Min. 50.000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixText: 'Rp ',
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Harap masukkan jumlah';
                final amt = double.tryParse(val);
                if (amt == null) return 'Masukkan angka yang valid';
                if (amt < 50000) return 'Jumlah minimal Rp 50.000';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Method Dropdown
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: InputDecoration(
                labelText: 'Metode Penarikan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'bank_transfer', child: Text('Transfer Bank')),
                DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet (Gopay/OVO)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMethod = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Account Info
            TextFormField(
              controller: _accountInfoController,
              decoration: InputDecoration(
                labelText: 'Informasi Rekening/Akun',
                hintText: 'Contoh: BCA - 12345678 a.n John Doe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Harap masukkan info rekening';
                return null;
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitPayoutRequest(availableBalance),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'AJUKAN PENARIKAN',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutHistoryList() {
    return FutureBuilder<List<dynamic>>(
      future: _payoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
          ));
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(
              snapshot.error.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada riwayat penarikan',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        final payouts = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payouts.length,
          itemBuilder: (context, index) {
            final payout = payouts[index];
            final amount = payout['amount'] ?? 0;
            final status = payout['status'] ?? 'pending';
            final method = payout['method'] == 'bank_transfer' ? 'Transfer Bank' : 'E-Wallet';
            final created = payout['created_at'] != null ? DateTime.parse(payout['created_at']) : DateTime.now();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp ${_formatCurrency(amount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$method - ${created.day}/${created.month}/${created.year}',
                        style: const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                  _buildPayoutStatusBadge(status),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPayoutStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        label = 'SUKSES';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'DITOLAK';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
