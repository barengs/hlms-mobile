import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hlms_mobile/features/course/data/course_repository.dart';
import 'package:hlms_mobile/core/models/course.dart';
import 'package:hlms_mobile/features/auth/logic/auth_bloc/auth_bloc.dart';

class EnrollmentScreen extends StatefulWidget {
  final String courseId;
  const EnrollmentScreen({super.key, required this.courseId});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  int _currentStep = 1;
  String _selectedPaymentMethod = '';
  Course? _course;
  Map<String, dynamic>? _cartSummary;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = context.read<CourseRepository>();
      final course = await repo.getCourseDetail(widget.courseId);
      await repo.addToCart(course.id);
      final cart = await repo.getCart();
      
      setState(() {
        _course = course;
        _cartSummary = cart;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        context.pop();
      }
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      final total = double.tryParse(_cartSummary?['total']?.toString() ?? '0') ?? 0;
      final isFree = total <= 0;
      if (!isFree && _selectedPaymentMethod.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih metode pembayaran')));
        return;
      }
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      setState(() => _isProcessing = true);
      try {
        await context.read<CourseRepository>().processCheckout({
          'payment_simulation': true,
        });
        setState(() {
          _isProcessing = false;
          _currentStep = 4;
        });
      } catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final Map<String, dynamic> userData = authState is AuthAuthenticated ? authState.user : {};
        
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                if (_currentStep > 1 && _currentStep < 4) {
                  setState(() => _currentStep--);
                } else {
                  context.pop();
                }
              },
            ),
          ),
          body: Column(
            children: [
              if (_currentStep < 4) _buildStepper(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(userData),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepper() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(1, 'Ringkasan', isCompleted: _currentStep > 1, isActive: _currentStep == 1),
          _buildStepLine(),
          _buildStepItem(2, 'Metode Bayar', isCompleted: _currentStep > 2, isActive: _currentStep == 2),
          _buildStepLine(),
          _buildStepItem(3, 'Konfirmasi', isCompleted: _currentStep > 3, isActive: _currentStep == 3),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, {bool isCompleted = false, bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? const Color(0xFF003399) : Colors.black,
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF003399) : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.grey.shade400,
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _buildStepContent(Map<String, dynamic> userData) {
    switch (_currentStep) {
      case 1:
        return _buildOverviewStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildConfirmationSummary(userData);
      case 4:
        return _buildSuccessStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewStep() {
    if (_course == null) return const SizedBox();
    
    final subtotal = _cartSummary?['subtotal'] ?? 0;
    final discount = _cartSummary?['discount'] ?? 0;
    final total = _cartSummary?['total'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 20, color: Colors.black),
            children: [
              const TextSpan(text: 'Nama Kursus : '),
              TextSpan(text: _course!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildIconText(Icons.book, 'Materi Lengkap'),
                  const Spacer(),
                  _buildIconText(Icons.workspace_premium, 'Sertifikat'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildIconText(Icons.access_time_filled, 'Akses Selamanya'),
                  const Spacer(),
                  _buildIconText(Icons.local_offer, 'Diskon Spesial'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildDetailRow('Trainer Kursus :', Text(_course!.instructorName ?? 'Instructor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detail Pembelian', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _buildPriceRow('Subtotal :', 'Rp $subtotal', 'Potongan :', 'Rp $discount'),
              const SizedBox(height: 12),
              _buildPriceRow('', '', 'Total Pembayaran :', 'Rp $total', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final total = double.tryParse(_cartSummary?['total']?.toString() ?? '0') ?? 0;
    final isFree = total <= 0;
    
    if (isFree) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 16),
                Text('Kursus ini Gratis!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Anda dapat langsung mengambil kursus ini tanpa perlu melakukan pembayaran. Klik Lanjutkan untuk konfirmasi.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildPaymentOption('QRIS', Icons.qr_code_scanner),
        _buildPaymentOption('Virtual Account', Icons.account_balance),
        _buildPaymentOption('GoPay', Icons.wallet),
        _buildPaymentOption('Debit', Icons.credit_card),
        
        if (_selectedPaymentMethod == 'Debit') ...[
          const SizedBox(height: 24),
          const TextField(decoration: InputDecoration(labelText: 'Nama di Kartu')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Nomor Kartu')),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Nomor CVC'))),
              SizedBox(width: 16),
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Tanggal Kadaluarsa'))),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmationSummary(Map<String, dynamic> userData) {
    final total = double.tryParse(_cartSummary?['total']?.toString() ?? '0') ?? 0;
    final isFree = total <= 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        const Text('Profil Siswa', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userData['name'] ?? 'Nama Siswa', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(userData['email'] ?? 'Email Siswa', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        const Text('Detail Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildPriceRow('Metode Pembayaran', isFree ? 'Gratis' : _selectedPaymentMethod, '', ''),
              const Divider(height: 32),
              _buildPriceRow('Total yang harus dibayar', 'Rp ${_cartSummary?['total'] ?? 0}', '', '', isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          isFree 
              ? 'Dengan menekan tombol Ambil Kursus, Anda akan langsung terdaftar di kursus ini.'
              : 'Dengan menekan tombol Bayar Sekarang, Anda menyetujui syarat dan ketentuan yang berlaku.',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, size: 100, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Pendaftaran Berhasil!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Selamat! Pendaftaran Anda telah berhasil diproses. Silakan mulai belajar sekarang.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    bool isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFF003399)) : null,
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.add_circle : Icons.add_circle_outline, color: isSelected ? const Color(0xFF003399) : Colors.black),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF003399), size: 24),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDetailRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildPriceRow(String l1, String v1, String l2, String v2, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l1, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(v1, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(l2, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(v2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 14)),
          ],
        ),
      ],
    );
  }
  Widget _buildBottomButton() {
    final total = double.tryParse(_cartSummary?['total']?.toString() ?? '0') ?? 0;
    final isFree = total <= 0;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003399),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isProcessing 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(
              _currentStep == 3 
                  ? (isFree ? 'Ambil Kursus' : 'Bayar Sekarang') 
                  : (_currentStep == 4 ? 'Mulai Belajar' : 'Lanjutkan'), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
      ),
    );
  }
}
