import 'package:flutter/material.dart';
import 'resaSummaryArguments.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future createTestPaymentSheet(int totalAmount, String currency) async {
    var response = await http.post(
    Uri.parse('https://api.stripe.com/v1/payment_intents'),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer sk_test_51N1cxbEPzWoM6U0uJLDPfFd3WV07cn7SQYd9QQj4IzgYLrfWzeNhjauVL20NdF9s227MGhSE57LyJuLNLm72CPAl00veDbM0iV'
    },
    body: {
      'amount': totalAmount.toString(),
      'currency': currency,
      'automatic_payment_methods[enabled]': 'true'
    },
  );
  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
  return decodedResponse;
}

class ResaSummary extends StatelessWidget {
  const ResaSummary({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Reservation summary';

    final args = ModalRoute.of(context)!.settings.arguments as ResaSummaryArguments;

    Future<void> initPaymentSheet() async {
    try {
      // 1. create payment intent on the server
      final data = await createTestPaymentSheet(args.resaAmountTotal*100, args.resaCurrency);

      // 2. initialize the payment sheet
     await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Set to true for custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: data['client_secret'],
          // Customer keys
          //customerEphemeralKeySecret: data['ephemeralKey'],
          //customerId: data['customer'],
          // Extra options
          // applePay: const PaymentSheetApplePay(
          //   merchantCountryCode: 'US',
          // ),
          // googlePay: const PaymentSheetGooglePay(
          //   merchantCountryCode: 'US',
          //   testEnv: true,
          // ),
          style: ThemeMode.dark,
        ),
      );
      // setState(() {
      //   _ready = true;
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
}

    return Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        // #docregion add-widget
        body: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text(
              'Your order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: 
              // ListView.builder(
              //   itemCount: orderItems.length,
              //   itemBuilder: (context, index) {
              //     final item = orderItems[index];
              //     return 
                  ListTile(
                    title: Text(args.room.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    subtitle: Text('Nights: ${args.length}', style: TextStyle(fontSize: 15)),
                    trailing: Text('${args.resaAmountTotal} ${args.resaCurrency}',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  )
                //},
              //),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Montant Total: \$${args.resaAmountTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await initPaymentSheet();
                  await Stripe.instance.presentPaymentSheet();
                },
                child: const Text('Procéder au Paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
              
          
              // TextSection(
              //   description:
              //       'Your reservation is now ready to be paid, please click in the button below',
              // ),
              // ElevatedButton(
              //   onPressed: () async {
              //     await initPaymentSheet();
              //     await Stripe.instance.presentPaymentSheet();

              //   },
              //   child: const Text('Payer')
              // )
            ],
          ),
        ),
        // #enddocregion add-widget
      );
  }
}

// class TextSection extends StatelessWidget {
//   const TextSection({
//     super.key,
//     required this.description,
//   });

//   final String description;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(32),
//       child: Text(
//         description,
//         softWrap: true,
//       ),
//     );
//   }
// }