import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnrollmentScreen extends StatefulWidget {
  final String courseId;
  const EnrollmentScreen({super.key, required this.courseId});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  int _currentStep = 1;
  String _selectedPaymentMethod = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildOverviewStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, color: Colors.black),
            children: [
              TextSpan(text: 'Nama Kursus : '),
              TextSpan(text: 'Graphic Design', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildIconText(Icons.book, '80+ Materi'),
                  const Spacer(),
                  _buildIconText(Icons.workspace_premium, 'Sertifikat'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildIconText(Icons.access_time_filled, '8 Minggu'),
                  const Spacer(),
                  _buildIconText(Icons.local_offer, 'Diskon 10%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildDetailRow('Rating Kursus :', Row(
          children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFF003399), size: 20)),
        )),
        _buildDetailRow('Waktu Kursus :', const Text('8 Minggu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        _buildDetailRow('Trainer Kursus :', const Text('Syed Hasnain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
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
              _buildPriceRow('Tanggal :', '19/03/2024', 'Harga :', '72\$'),
              const SizedBox(height: 12),
              _buildPriceRow('Kupon :', 'Diskon 10%', 'Total :', '65\$', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
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

  Widget _buildConfirmationStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Transaksi Berhasil!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Selamat! Pendaftaran Anda telah berhasil diproses.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Center(
          child: Image.asset(
            'assets/complate_payment.png',
            height: 320,
            fit: BoxFit.contain,
          ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            context.go('/home');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003399),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(_currentStep == 3 ? 'Selesai' : 'Lanjutkan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
