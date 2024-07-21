import 'package:firebase_auth/firebase_auth.dart';
import 'package:heat/home.dart';
import 'registerScreen.dart';
import 'package:flutter/material.dart';

FirebaseAuth auth = FirebaseAuth.instance;

var user;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

   

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Log in'),
        automaticallyImplyLeading: false
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
        child: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              color: const Color.fromARGB(255, 117, 135, 145).withOpacity(0.7),
              child: const LoginForm(),
            ),
          ),
        ),
    )
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<LoginForm> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;

  double _formProgress = 0;

  @override
  Widget build(BuildContext context) {
    

    Future<void> signIn() async {

      await FirebaseAuth.instance.signOut();
      
        if (_formKey.currentState!.validate()) {
          try {
          await auth
            .signInWithEmailAndPassword(
                email: _emailTextController.text, password: _passwordTextController.text)
            .then((value) { setState(() {

              user = FirebaseAuth.instance.currentUser;

            });

             Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Accueil(),
                      ),
                    );
                ScaffoldMessenger.of(context)
                  .showSnackBar(
                    const SnackBar(
                      content: Text("Successfully logged in"),
                    ),
                  )
                  .closed;
              }
            )
            .onError((error, stackTrace) {
                
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                      const SnackBar(
                        content: Text('Wrong data submitted'),
                      ),
                    )
                    .closed;
                throw('Failed with error code: $error / $stackTrace');
              });
           } on FirebaseAuthException catch  (e) {
            throw('Failed with error code: ${e.code} / ${e.message}');
          }
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _formProgress),
          const Text('Log in',
            style: TextStyle(fontSize: 25, color: Colors.white)
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
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _passwordTextController,
              //decoration: const InputDecoration(hintText: 'Mot de passe', hintStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
              obscureText: passwordVisible,
              //keyboardType: TextInputType.,
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
                if (value == null || value.isEmpty) {
                return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
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
            onPressed: signIn,
            child: const Text('Log in'),
          ),
          const Divider(
              color: Colors.grey
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
              onPressed: () => (
                
                Navigator.push(context, MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
                ),),
              ),
              child: const Text('Sign up'),
            ),
          ),
        ],
      ),
    );
  }
}
