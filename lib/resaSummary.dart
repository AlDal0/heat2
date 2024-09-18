import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'resaSummaryArguments.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<dynamic> createPaymentIntent(int totalAmount, String currency) async {
  http.Response response;
  try {
    response = await http.post(
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
  } catch (err) {
      print('Error charging user: ${err.toString()}');
  }
  
  
}

Future<void> initPaymentSheet(String clientSecret) async {
    try {

      // 2. initialize the payment sheet
     await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Set to true for custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: clientSecret,
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
      print("exception $e");

      if (e is StripeConfigException) {
        print("Stripe exception ${e.message}");
      } else {
        print("exception $e");
      }
      rethrow;
    }
}

Future<void> presentPaymentSheet(BuildContext context) async {
    try {
      // 2. display the payment sheet
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(const SnackBar(content: Text('Reservation confirmed'),duration: Duration(milliseconds: 1000)));
      }
    } on StripeException catch (e) {
      // If any error comes during payment 
      // so payment will be cancelled
      print('Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(" Payment Cancelled")),
        );
      }
    } catch (e) {
      print("Error in displaying");
      print('$e');
    }
}

Future<String> addResa(DateTime? dateStart, DateTime? dateEnd, List<String> roomSelectedListToBook) async {
    CollectionReference reservation = FirebaseFirestore.instance.collection('reservation');
    final snapshot1 = await db.collection('room').get();
    final snapshot2 = await db.collection('client').get();
    List<DocumentReference> roomId = [];
    List<DateTime> dateRange = [];
    List<String> roomSelectedListToBookAndPrice = [];
    late DocumentReference clientId;
    num resaAmountDay = 0;
    String resaCurrency = "";

    var date = DateTime(dateStart!.year, dateStart.month, dateStart.day);

    String clientNameEmail = "";
    String clientSurnameEmail = "";

    dateRange.add(date);

    if (dateStart != dateEnd) {
      do {

        date = DateTime(date.year, date.month, date.day + 1);

        dateRange.add(date);

      }
      while (DateTime(date.year, date.month, date.day) != DateTime(dateEnd!.year, dateEnd.month, dateEnd.day));

    }

    for (final document1 in snapshot1.docs) {

      final data1 = document1.data();
      if (resaCurrency == "") {
        resaCurrency = data1['currency'];
      }

      if (roomSelectedListToBook.contains(data1['name'])) {

        roomId.add(db.doc('/room/${document1.id}'));

        resaAmountDay = resaAmountDay + data1['price'];
        
        roomSelectedListToBookAndPrice.add(data1['name']+ ' (' + data1['price'].toString() + ' $resaCurrency / night)');

      }

    }

    for (final document2 in snapshot2.docs) {

      final data2 = document2.data();

      if (FirebaseAuth.instance.currentUser!.email!.contains(data2['email'])) {

        clientId = db.doc('/client/${document2.id}');
        clientNameEmail = data2['surname'];
        clientSurnameEmail = data2['firstName'];

      }

    }

    final dateStartEmail = DateFormat.yMMMMd('en_EN').format(dateStart);
    final dateEndEmail = DateFormat.yMMMMd('en_EN').format(dateEnd!);
    final length = dateRange.length-1;

    final resaAmountTotal = resaAmountDay * length;

    

    if (length == 1) {
      var resa = await reservation.add({
        'dateStart': dateStart,
        'dateEnd': dateEnd,
        'length': "$length night",
        'room': roomId,
        'client': clientId,
        'type': 'Room',
        'totalAmount': resaAmountTotal,
        'currency': resaCurrency,
        'status': 'created',
        'publisher': 'client',
        'to': [FirebaseAuth.instance.currentUser!.email],
        'message': {
          'subject': 'Reservation at Heat from $dateStartEmail to $dateEndEmail confirmed',
          'html': '<code><body style="text-align:center; font-family:Verdana;"><h1>Thank you $clientSurnameEmail $clientNameEmail for your reservation !</h1>  <br></br> Please find the details: <br></br> Start date: $dateStartEmail / End date: $dateEndEmail <br></br> Total length of stay: $length night <br></br> Rooms : ${roomSelectedListToBookAndPrice.join(', ')} <br></br><br></br> Total amount: $resaAmountTotal $resaCurrency <br></body></code>',
        }
      });
      return resa.id;
    }
    else {
      var resa = await reservation.add({
        'dateStart': dateStart,
        'dateEnd': dateEnd,
        'length': "$length nights",
        'room': roomId,
        'client': clientId,
        'type': 'Room',
        'totalAmount': resaAmountTotal,
        'currency': resaCurrency,
        'status': 'created',
        'publisher': 'client',
        'to': [FirebaseAuth.instance.currentUser!.email],
        'message': {
          'subject': 'Reservation at Heat from $dateStartEmail to $dateEndEmail confirmed',
          'html': '<code><body style="text-align:center; font-family:Verdana;"><h1>Thank you $clientSurnameEmail $clientNameEmail for your reservation !</h1>  <br></br> Please find the details: <br></br> Start date: $dateStartEmail / End date: $dateEndEmail <br></br> Total length of stay: $length nights <br></br> Rooms : ${roomSelectedListToBookAndPrice.join(', ')} <br></br><br></br> Total amount: $resaAmountTotal $resaCurrency <br></body></code>',
        }
      });
      return resa.id;
    }

  }

class ResaSummary extends StatelessWidget {
  const ResaSummary({super.key});

  @override
  Widget build(BuildContext context) {
    
    const String appTitle = 'Reservation summary';

    // We pick up arguments coming from resaHome
    final args = ModalRoute.of(context)!.settings.arguments as ResaSummaryArguments;

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
            const SizedBox(height: 16),
            Expanded(
              child: 
              // ListView.builder(
              //   itemCount: orderItems.length,
              //   itemBuilder: (context, index) {
              //     final item = orderItems[index];
              //     return 
                  ListTile(
                    title: Text(args.room.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    subtitle: Text('Nights: ${args.length}', style: const TextStyle(fontSize: 15)),
                    trailing: Text('${args.resaAmountTotal} ${args.resaCurrency}',style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  )
                //},
              //),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Total amount                            : \$${args.resaAmountTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final data = await createPaymentIntent(args.resaAmountTotal*100, args.resaCurrency);
                  await initPaymentSheet(data['client_secret']);

                  try {
                    // 2. display the payment sheet
                    await Stripe.instance.presentPaymentSheet();
                    String resaId = await addResa(args.dateStart, args.dateEnd, args.room);
                    
                    if (context.mounted) {
                      
                      showDialog(
                        barrierDismissible: false,
                        context: context,builder: (BuildContext context) => AlertDialog(
                        title: const Center(
                          child: Row(
                          children: [
                            Text('Confirmed   '),
                            Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24.0
                            )
                          ]
                        ),
                        ),
                        content: RichText(
                          text: TextSpan(
                            text: 'Your payment has been successful, your reservation ',
                            style: const TextStyle(fontSize: 15, color:Colors.black),
                            children: <TextSpan>[
                              TextSpan(text: resaId, style: TextStyle(color: Colors.indigo.shade400, fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' is now confirmed')
                            ]
                          )
                        ),
                        actions: <Widget>[
                          
                          Center(
                            child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/myResaHome'),
                            child: const Text('My Reservations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                        )
                      );
                    }

                  } on StripeException catch (e) {
                    // If any error comes during payment 
                    // so payment will be cancelled
                    print('Error: $e');

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(" Payment Cancelled")),
                      );
                    }
                  } catch (e) {
                    print("Error in displaying");
                    print('$e');
                  }

                  
                },
                child: const Text('Go to payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            ],
          ),
        ),
        // #enddocregion add-widget
      );
  }
}