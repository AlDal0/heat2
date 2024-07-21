import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'account_screen.dart';
//import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:heat/loginScreen.dart';
//import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore db = FirebaseFirestore.instance;

Future<void> createLagoCustomer(String uid, String firstName, String surname, String email) async {

  var data = {
   "customer": {
      "external_id": uid,
      "currency": "EUR",
      "email": email,
      "name": "$firstName $surname"
   }
  };

  final String jsonString = jsonEncode(data);

  //final response = await http.get(
  //  Uri.parse('http://localhost:3000/api/v1/customers/cus01'));

  final response = await http.post(
    Uri.parse("http://localhost:3000/api/v1/customers"),
    headers: <String, String>{
      "Content-Type": "application/json",
      "Authorization": "Bearer ff446403-d8d3-44bf-b1cc-88a1c31722f7"
    },
    body: jsonString,
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    print(response.body);
    return jsonDecode(response.body);
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    print(jsonDecode(response.body));
    throw Exception('Failed to create user.');
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
     
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Registration'),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/PXL_20230903_184120923.MP~2.jpg"),
            fit: BoxFit.cover
            )
        ),
        child: 
        Center(
        child: SizedBox(
          width: 400,
          child: Card(
            color: const Color.fromARGB(255, 117, 135, 145).withOpacity(0.7),
            child: const RegisterForm(),
          ),
        ),
      ),
    )
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  

  @override
  State<RegisterForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<RegisterForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmpasswordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;

  var client;

  @override
  Widget build(BuildContext context) {

    Future<void> signUp() async {
        if (_formKey.currentState!.validate()) {
          try {
          await auth
              .createUserWithEmailAndPassword(
                  email: _emailTextController.text, password: _passwordTextController.text)
              .then((value) async {

                client = value.user;

                await createLagoCustomer(client.uid, _firstNameTextController.text, _lastNameTextController.text, _emailTextController.text);

                db
                  .collection("client")
                  .add({
                    'uid': client.uid,
                    'prénom': _firstNameTextController.text,
                    'nom': _lastNameTextController.text,
                    'email': _emailTextController.text,
                    'publisher': 'client',
                    'status': 'created',
                    'to': [_emailTextController.text],
                    'message': {
                      'subject': 'Bienvenue chez Heat ${_firstNameTextController.text} !',
                      'html': '<code><body style="text-align:center; font-family:Verdana;"><h1>Bravo ${_firstNameTextController.text} !</h1> <br> Votre compte chez Heat est bien créé. <br> Vous pouvez désormais vous connecter avec votre email et votre mot de passe afin de réaliser votre première réservation.</body></code>',
                    }});

                  Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                  ScaffoldMessenger.of(context)
                    .showSnackBar(
                      const SnackBar(
                        content: Text("Successfully registered"),
                      ),
                    )
                    .closed;

              } )
              .onError((error, stackTrace) {
                
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                      SnackBar(
                        content: Text('$error'),
                      ),
                    )
                    .closed;
                throw('Failed with error code: ${error} / ${stackTrace}');
              });
            
          } on FirebaseAuthException catch  (e) {
            print('Failed with error code: ${e.code}');
            print(e.message);
          }
        }
      }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please enter information:', style: TextStyle(fontSize: 20, color: Colors.white)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _firstNameTextController,
              decoration: const InputDecoration(hintText: 'Firstname', hintStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _lastNameTextController,
              decoration: const InputDecoration(hintText: 'Surname', hintStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _emailTextController,
              decoration: const InputDecoration(hintText: 'Email', hintStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (EmailValidator.validate(value) == false) {
                return 'Please enter a valid email';
              }
              
              return null;
            },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _passwordTextController,
              //decoration: const InputDecoration(hintText: 'Mot de passe', hintStyle: TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white),
              obscureText: passwordVisible,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                     icon: Icon(passwordVisible
                         ? Icons.visibility
                         : Icons.visibility_off),
                     onPressed: () {
                       setState(
                         () {
                           passwordVisible = !passwordVisible;
                         },
                       );
                     },
                   )
              ),
              validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Please enter 6 characters at minimum';
              }
              if (value != _passwordTextController.text) {
                return 'Please enter same passwords';
              }
              return null;
            },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _confirmpasswordTextController,
              //decoration: const InputDecoration(hintText: 'Confirmer mot de passe', hintStyle: TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white),
              obscureText: passwordVisible,
              decoration: InputDecoration(
                hintText: 'Confirm password',
                hintStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                     icon: Icon(passwordVisible
                         ? Icons.visibility
                         : Icons.visibility_off),
                     onPressed: () {
                       setState(
                         () {
                           passwordVisible = !passwordVisible;
                         },
                       );
                     },
                   )
              ),
              validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Please enter 6 characters at minimum';
              }
              if (value != _passwordTextController.text) {
                return 'Please enter same passwords';
              }
              return null;
            },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child:
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.white;
                }),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.blue;
                }),
              ),
              onPressed: signUp,
              child: const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }
}


