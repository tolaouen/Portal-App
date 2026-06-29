import 'package:flutter/material.dart';

import '../models/payment_option.dart';
import '../state/store_controller.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';
import 'order_success_screen.dart';
import 'payment_details_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final selectedPayment = controller.selectedPayment;
    final needsPaymentForm = controller.requiresPaymentForm(selectedPayment);
    final hasSavedPaymentDetails = controller.hasSavedPaymentDetails(
      selectedPayment,
    );
    final paymentSummary = controller.selectedPaymentDetailsSummary();
    final canPlaceOrder =
        controller.activeCheckoutItems.isNotEmpty &&
        !controller.isProcessingCheckout;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.clearBuyNowCheckout();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              controller.clearBuyNowCheckout();
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Text(
                        'Shipping Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        onTap: () => _showAddressForm(context, controller),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(
                          controller.shippingAddressLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(controller.shippingAddress),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...PaymentOption.values.map((option) {
                        return PaymentOptionTile(
                          option: option,
                          groupValue: controller.selectedPayment,
                          onChanged: (selected) {
                            controller.setPaymentOption(selected);
                            setState(() {});
                          },
                        );
                      }),
                      if (needsPaymentForm) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPayment == PaymentOption.card
                                    ? 'Card Payment'
                                    : '${selectedPayment.label} Payment',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hasSavedPaymentDetails
                                    ? (paymentSummary ??
                                          'Payment information saved successfully.')
                                    : 'Please complete and save your payment form before placing the order.',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              PrimaryButton(
                                label: hasSavedPaymentDetails
                                    ? 'Edit Payment Details'
                                    : 'Add Payment Details',
                                onPressed: () async {
                                  final saved = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => PaymentDetailsScreen(
                                        option: selectedPayment,
                                        controller: controller,
                                      ),
                                    ),
                                  );
                                  if (saved == true && context.mounted) {
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 24),
                _CheckoutRow(label: 'Subtotal', value: controller.subtotal),
                const SizedBox(height: 12),
                _CheckoutRow(
                  label: 'Total',
                  value: controller.total,
                  bold: true,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Place Order',
                  isLoading: controller.isProcessingCheckout,
                  onPressed: canPlaceOrder
                      ? () async {
                          if (needsPaymentForm && !hasSavedPaymentDetails) {
                            final saved = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => PaymentDetailsScreen(
                                  option: selectedPayment,
                                  controller: controller,
                                ),
                              ),
                            );
                            if (saved != true || !context.mounted) {
                              return;
                            }
                          }

                          final paymentDetails =
                              controller.selectedPaymentDetailsSummary();
                          try {
                            final order = await controller.placeOrder(
                              paymentDetails: paymentDetails,
                            );
                            if (!context.mounted) return;
                            await Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => OrderSuccessScreen(order: order),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            final message =
                                controller.orderErrorMessage ??
                                error.toString().replaceFirst('Exception: ', '');
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                          }
                        }
                      : () {
                          if (controller.isProcessingCheckout) {
                            return;
                          }
                          if (needsPaymentForm && !hasSavedPaymentDetails) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete and save payment details first.',
                                ),
                              ),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddressForm(
    BuildContext context,
    StoreController controller,
  ) async {
    final labelController = TextEditingController(
      text: controller.shippingAddressLabel,
    );
    final address = controller.shippingAddress;
    final addressParts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    final streetController = TextEditingController(
      text: addressParts.isNotEmpty ? addressParts.first : '',
    );
    final cityController = TextEditingController(
      text: addressParts.length > 1 ? addressParts[1] : '',
    );
    final countryController = TextEditingController(
      text: addressParts.length > 2
          ? addressParts.sublist(2).join(', ')
          : 'Cambodia',
    );
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Shipping Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Address Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter address name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street / House / Village',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter street address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City / District / Province',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter city or province';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter country';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Save Address',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      final fullAddress = [
                        streetController.text.trim(),
                        cityController.text.trim(),
                        countryController.text.trim(),
                      ].join(', ');
                      await controller.setShippingAddress(
                        label: labelController.text.trim(),
                        address: fullAddress,
                      );
                      if (!sheetContext.mounted) {
                        return;
                      }
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 24 : 16,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
