import 'package:flutter/material.dart';

import '../models/payment_option.dart';
import '../state/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({
    super.key,
    required this.option,
    required this.controller,
  });

  final PaymentOption option;
  final StoreController controller;

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNumberController;
  late final TextEditingController _accountNameController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _cvvController;
  late final TextEditingController _transactionIdController;
  late final TextEditingController _phoneNumberController;
  bool _saveInformation = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.paymentDetailsFor(widget.option) ?? {};
    _cardNumberController = TextEditingController(
      text: existing['card_number'] ?? '',
    );
    _accountNameController = TextEditingController(
      text: existing['account_name'] ?? '',
    );
    _expiryDateController = TextEditingController(
      text: existing['expiry_date'] ?? '',
    );
    _cvvController = TextEditingController(text: existing['cvv'] ?? '');
    _transactionIdController = TextEditingController(
      text: existing['transaction_id'] ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: existing['phone_number'] ?? '',
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _accountNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _transactionIdController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mist,
      appBar: AppBar(
        backgroundColor: AppTheme.mist,
        title: Text(
          widget.option == PaymentOption.card
              ? 'Add New Card'
              : '${widget.option.label} Details',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (widget.option == PaymentOption.card) ...[
                _CardPreview(
                  cardNumber: _cardNumberController.text,
                  accountName: _accountNameController.text,
                  expiryDate: _expiryDateController.text,
                ),
                const SizedBox(height: 18),
              ],
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: _buildFields(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    switch (widget.option) {
      case PaymentOption.cashOnDelivery:
        return const Text(
          'Cash on Delivery does not need extra payment details.',
          style: TextStyle(fontSize: 16, height: 1.5),
        );
      case PaymentOption.abaBank:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Account Holder Name'),
            _AppTextField(
              controller: _accountNameController,
              hintText: 'Your account name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            _FieldLabel('ABA Transaction ID'),
            _AppTextField(
              controller: _transactionIdController,
              hintText: 'Enter ABA transaction ID',
              validator: _requiredValidator,
            ),
          ],
        );
      case PaymentOption.wing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Phone Number'),
            _AppTextField(
              controller: _phoneNumberController,
              hintText: 'Wing phone number',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            _FieldLabel('Wing Transaction ID'),
            _AppTextField(
              controller: _transactionIdController,
              hintText: 'Enter Wing transaction ID',
              validator: _requiredValidator,
            ),
          ],
        );
      case PaymentOption.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Card Number'),
            _AppTextField(
              controller: _cardNumberController,
              hintText: '1234 5678 9000 0000',
              validator: _requiredValidator,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Account Holder Name'),
            _AppTextField(
              controller: _accountNameController,
              hintText: 'Your account name',
              validator: _requiredValidator,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Expiry Date'),
                      _AppTextField(
                        controller: _expiryDateController,
                        hintText: '12/28',
                        validator: _requiredValidator,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('CVV'),
                      _AppTextField(
                        controller: _cvvController,
                        hintText: '224',
                        validator: _requiredValidator,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () => setState(() => _saveInformation = !_saveInformation),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Icon(
                    _saveInformation
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Save Card Information',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final details = <String, String>{};
    switch (widget.option) {
      case PaymentOption.cashOnDelivery:
        break;
      case PaymentOption.abaBank:
        details['account_name'] = _accountNameController.text.trim();
        details['transaction_id'] = _transactionIdController.text.trim();
        break;
      case PaymentOption.wing:
        details['phone_number'] = _phoneNumberController.text.trim();
        details['transaction_id'] = _transactionIdController.text.trim();
        break;
      case PaymentOption.card:
        details['card_number'] = _cardNumberController.text.trim();
        details['account_name'] = _accountNameController.text.trim();
        details['expiry_date'] = _expiryDateController.text.trim();
        details['cvv'] = _cvvController.text.trim();
        break;
    }

    widget.controller.savePaymentDetails(widget.option, details);
    Navigator.of(context).pop(true);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.cardNumber,
    required this.accountName,
    required this.expiryDate,
  });

  final String cardNumber;
  final String accountName;
  final String expiryDate;

  @override
  Widget build(BuildContext context) {
    final formattedNumber = cardNumber.trim().isEmpty
        ? '1234 5678 9000 0000'
        : cardNumber;
    final name = accountName.trim().isEmpty ? 'Card Holder' : accountName;
    final expiry = expiryDate.trim().isEmpty ? '12/28' : expiryDate;

    return Container(
      height: 188,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF184F96), Color(0xFF1E7AE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Debit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                'ESCO bank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formattedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CardMeta(
                  label: 'Card Holder',
                  value: name,
                ),
              ),
              Expanded(
                child: _CardMeta(
                  label: 'Expiry Date',
                  value: expiry,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
