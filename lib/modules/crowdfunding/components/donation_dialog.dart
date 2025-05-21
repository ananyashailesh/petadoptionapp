import 'package:flutter/material.dart';
import 'package:adoption_ui_app/modules/crowdfunding/components/color.dart';

class DonationDialog extends StatefulWidget {
  final String title;
  final double targetAmount;
  final double currentAmount;

  const DonationDialog({
    Key? key,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
  }) : super(key: key);

  @override
  _DonationDialogState createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Bank Transfer',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildPaymentFields() {
    switch (_selectedPaymentMethod) {
      case 'Credit Card':
      case 'Debit Card':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                counterText: "",
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'MM/YY',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      counterText: "",
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 'PayPal':
        return Text(
          'You will be redirected to PayPal to complete your payment.',
          style: TextStyle(color: AppColor.textColor),
        );
      case 'Bank Transfer':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Details:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.mainColor,
              ),
            ),
            SizedBox(height: 10),
            Text('Bank Name: Example Bank'),
            Text('Account Number: XXXX-XXXX-XXXX'),
            Text('SWIFT Code: EXAMPLEXX'),
            SizedBox(height: 10),
            Text(
              'Please include your name as reference when making the transfer.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  void _processDonation() {
    if (_amountController.text.isEmpty || _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an amount and select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((_selectedPaymentMethod == 'Credit Card' || 
         _selectedPaymentMethod == 'Debit Card') && 
        (_cardNumberController.text.isEmpty ||
         _cvvController.text.isEmpty ||
         _expiryController.text.isEmpty ||
         _nameController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all card details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
      });

      // Show thank you dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Icon(
              Icons.check_circle,
              color: AppColor.secondary,
              size: 50,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your donation of \$${_amountController.text} has been processed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.textColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close thank you dialog
                  Navigator.of(context).pop(); // Close donation dialog
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make a Donation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.title,
                style: TextStyle(fontSize: 16, color: AppColor.textColor),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.mainColor,
                ),
              ),
              ..._paymentMethods.map(
                (method) => RadioListTile<String>(
                  title: Text(method),
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
              ),
              if (_selectedPaymentMethod != null) ...[
                SizedBox(height: 20),
                _buildPaymentFields(),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _processDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text('Donate Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
