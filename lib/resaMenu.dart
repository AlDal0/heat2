import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instanceFor(bucket: "gs://heat-e9529.appspot.com").ref();


String imgMenuMini = '';
List<String> imgMenu = [];

class ResaMenuHome extends StatelessWidget {
  const ResaMenuHome({super.key});

  @override
  Widget build(BuildContext context) {

    //print(FirebaseAuth.instance.currentUser);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Menus'),
          scrolledUnderElevation: 0),
        body: const Menus(),
        drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
            height: 200,
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                //color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('images/PXL_20230827_183250894.MP~2.jpg'),
                  //fit: BoxFit.fill
                  ), 
              ),
              child: Text(''),
            ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
                    onTap: () {

                      Navigator.pushNamed(context, '/home');
                      
                    },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('My Reservations'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/reservations');
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News'),
                    onTap: () {

                      Navigator.pushNamed(context, '/news');
                      
                    },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Room booking'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer

                Navigator.pushNamed(context, '/resaRoom');
               
                //Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_restaurant),
              title: const Text('Menus'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/menus');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamedAndRemoveUntil(context,'/login', (_) => false);
              },
            )
          ],
        ),
      ),
      );
  }
}

class Menus extends StatefulWidget {

  const Menus({Key? key}) : super(key: key);
  @override
    _MenusState createState() => _MenusState();
}

class _MenusState extends State<Menus> {
  
  final Stream<QuerySnapshot> menuStream = FirebaseFirestore.instance.collection('menu').snapshots();

  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: menuStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> menuSnapshot) {
            
                if (menuSnapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (!menuSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                final menuData = menuSnapshot.requireData;

                final ScrollController scrollController = ScrollController();

                return Scrollbar(
                thumbVisibility: true,
                thickness: 8.0,
                controller: scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: menuData.size,
                  controller: scrollController,
                  //restorationId: 'list_demo_list_view',
                  //padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
       
                    return MenuContent(context: context, index: index, menuData: menuData);
                  }
                )
                );
                      
                    }
                );
                
              }
 
    }

class MenuContent extends StatelessWidget {
  const MenuContent({super.key, required this.context, required this.index, required this.menuData});

  final BuildContext context;
  final int index;
  final QuerySnapshot<Object?> menuData;

  Future<String> getMenuImagesMini(int index, menuData) async {

    imgMenuMini = '';

          try {

            final image1Url = await storageRef.child(menuData.docs[index].get('image1')).getDownloadURL();
            
            imgMenuMini = image1Url;

          } on FirebaseException catch (e) {
          // Handle any errors.
          } 

      return imgMenuMini;
  }

  Future<List<String>> getMenuImages(int index, menuData) async {

    imgMenu = [];

          try {

            final image1Url = await storageRef.child(menuData.docs[index].get('image1')).getDownloadURL();
            final image2Url = await storageRef.child(menuData.docs[index].get('image2')).getDownloadURL();
            final image3Url = await storageRef.child(menuData.docs[index].get('image3')).getDownloadURL();

            imgMenu.add(image1Url);
            imgMenu.add(image2Url);
            imgMenu.add(image3Url);

          } on FirebaseException catch (e) {
          // Handle any errors.
          } 

      //}
      return imgMenu;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final descriptionStyle = theme.textTheme.titleMedium!;

    
    return FutureBuilder<List<String>>(
      future: getMenuImages(index, menuData),
      builder: (context, AsyncSnapshot<List<String>> snapshot1){
        if (snapshot1.hasData) {
        return FutureBuilder<String>(
          future: getMenuImagesMini(index, menuData),
          builder: (context, AsyncSnapshot<String> snapshot2){
            if (snapshot2.hasData) {
              return SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 350,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              print(index);
                              print(snapshot1);
                            },
                            splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                            highlightColor: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          // In order to have the ink splash appear above the image, you
                                          // must use Ink.image. This allows the image to be painted as
                                          // part of the Material and display ink effects above it. Using
                                          // a standard Image will obscure the ink splash.
                                          child: Ink.image(
                                            image: CachedNetworkImageProvider(snapshot2.data.toString()),
                                            fit: BoxFit.cover,
                                            child: Container(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Description and share/explore buttons.
                                  Semantics(
                                    container: true,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: DefaultTextStyle(
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: descriptionStyle,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // This array contains the three line description on each card
                                            // demo.
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Text(
                                                //'Rooms : ${tempList.join(', ')}',
                                                '${menuData.docs[index].get('name')} - ${menuData.docs[index].get('price')} ${menuData.docs[index].get('currency')}',
                                                style: descriptionStyle.copyWith(color: Colors.black54),
                                              ),
                                            ),
                                            Text('${menuData.docs[index].get('description')}'),
                                            //Text(
                                            //    //'Rooms : ${tempList.join(', ')}',
                                            //    '${menuData.docs[index].get('price')}',
                                            //    style: descriptionStyle.copyWith(color: Colors.black54),
                                            //  )                              
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          )
                        )
                      )
                    ]
              )
              )
              );
            } else {
              return const CircularProgressIndicator();
            }
          }
        );
        }
        else {
              return const CircularProgressIndicator();
            }
      }
    );
  }
}