import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instanceFor(bucket: "gs://heat-e9529.appspot.com").ref();


String imgList = '';


class MesReservationsHome extends StatelessWidget {
  const MesReservationsHome({super.key});

  @override
  Widget build(BuildContext context) {

    //print(FirebaseAuth.instance.currentUser);

    return Scaffold(
        appBar: AppBar(
          title: const Text('My Reservation'),
          scrolledUnderElevation: 0),
        body: const MesReservations(),
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
              title: const Text('Reservations'),
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
              title: const Text('Rooms'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer

                Navigator.pushNamed(context, '/rooms');
               
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


class MesReservations extends StatefulWidget {

  const MesReservations({Key? key}) : super(key: key);
  @override
    _MesReservationsState createState() => _MesReservationsState();
}

class _MesReservationsState extends State<MesReservations> {
  final Stream<QuerySnapshot> clientStream = FirebaseFirestore.instance.collection('client').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots();
  
  final Stream<QuerySnapshot> roomStream = FirebaseFirestore.instance.collection('room').snapshots();

  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: clientStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> clientSnapshot) {
        if (clientSnapshot.hasError) {
                  return const Text('Something went wrong');
                }
        if (!clientSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
        
        DocumentReference<Map<String, dynamic>> clientRef;
        final clientData = clientSnapshot.requireData;
        clientRef = db.collection('client').doc(clientData.docs[0].id);

        final Stream<QuerySnapshot> reservationStream = FirebaseFirestore.instance.collection('reservation').where('client', isEqualTo: clientRef).snapshots();

        return StreamBuilder<QuerySnapshot>(
          stream: reservationStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> reservationSnapshot) {

            if (reservationSnapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (!reservationSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }


            return StreamBuilder<QuerySnapshot>(
              stream: roomStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> roomSnapshot) {
            
                if (roomSnapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (!roomSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                final reservationData = reservationSnapshot.requireData;
                final roomData = roomSnapshot.requireData;

                final ScrollController scrollController = ScrollController();

                return Scrollbar(
                thumbVisibility: true,
                thickness: 8.0,
                controller: scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reservationData.size,
                  controller: scrollController,
                  //restorationId: 'list_demo_list_view',
                  //padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    
                      var tempList = [];

                      for (var j = 0; j < reservationData.docs[index].get('room').length; j++) {

                      for (var element in roomData.docs) {
                        if (element.id == reservationData.docs[index].get('room')[j].toString().replaceAllMapped('DocumentReference<Map<String, dynamic>>(room/', (match) => '').replaceAllMapped(')', (match) => '')) {
                          tempList.add(element.get('name'));
                        }
                      }
                      }
                      
                      return ResaContent(context: context,index: index,reservationData: reservationData, roomData: roomData, tempList: tempList);
                    }
                )
                );
              },
            );
          },
        );
    }
    );
  }

}

class ResaContent extends StatelessWidget {
  const ResaContent({super.key, required this.context, required this.index, required this.reservationData, required this.roomData, required this.tempList});

  final BuildContext context;
  final int index;
  final dynamic reservationData;
  final dynamic roomData;
  final List<dynamic> tempList;

  Future<String> getRoomImages(String roomSelectedToGetImage, roomSnapshotData) async {

  imgList = '';

  for (final document in roomSnapshotData.docs) {
    var data = document.data();

   

      if (data['name'].toString() == roomSelectedToGetImage) {

        try {

          final image1Url = await storageRef.child(data['image1']).getDownloadURL();
          // final image2Url = await storageRef.child(data['image2']).getDownloadURL();
          // final image3Url = await storageRef.child(data['image3']).getDownloadURL();

          imgList = image1Url;
          // imgList.add(image2Url);
          // imgList.add(image3Url);

        } on FirebaseException catch (e) {
        // Handle any errors.
        }
 
      }

    }
    return imgList;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final titleStyle = theme.textTheme.headlineSmall!.copyWith(
    //   color: Colors.white,
    // );
    final descriptionStyle = theme.textTheme.titleMedium!;

    final tsdateStart = DateFormat.yMMMMd('fr_FR').format(reservationData.docs[index].data()['dateStart'].toDate());
    final tsdateEnd = DateFormat.yMMMMd('fr_FR').format(reservationData.docs[index].data()['dateEnd'].toDate());

    return FutureBuilder<String>(
      future: getRoomImages(tempList[0].toString(), roomData),
      builder: (context, AsyncSnapshot<String> snapshot){
         if (snapshot.hasData) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SizedBox(
                    height: 370,
                    child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 184,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                // In order to have the ink splash appear above the image, you
                                // must use Ink.image. This allows the image to be painted as
                                // part of the Material and display ink effects above it. Using
                                // a standard Image will obscure the ink splash.
                                child: Ink.image(
                                  image: CachedNetworkImageProvider(snapshot.data.toString()),
                                  fit: BoxFit.cover,
                                  child: Container(),
                                ),
                              ),
                              // Positioned(
                              //   bottom: 16,
                              //   left: 16,
                              //   right: 16,
                              //   child: FittedBox(
                              //     fit: BoxFit.scaleDown,
                              //     alignment: Alignment.centerLeft,
                              //     child: Semantics(
                              //       container: true,
                              //       header: true,
                              //       child: Text(
                              //         'Réservation : ${reservationData.docs[index].id}',
                              //         style: titleStyle,
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
                                      'Reservation : ${reservationData.docs[index].id}',
                                      style: descriptionStyle.copyWith(color: Colors.black54),
                                    ),
                                  ),
                                  Text('Start : $tsdateStart -> End : $tsdateEnd'),
                                  //Text('Fin : $tsdateEnd'),
                                ],
                              ),
                            ),
                          ),
                        ),
                          // share, explore buttons
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: OverflowBar(
                              alignment: MainAxisAlignment.start,
                              //spacing: 8,
                              children: [
                                Row(children: [

                                
                                for (var i = 0; i < 3; i++)
                      
                                if (i < tempList.length)
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 15),
                                  ),
                                  child: Text(tempList[i]),
                                )
                                ]),
                                Row(children: [
                                for (var j = 3; j < tempList.length; j++)
                        
                                if (j < tempList.length)
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 15),
                                  ),
                                  child: Text(tempList[j]),
                                )
                                ])
                              ],
                            ),
                          ),
                      ],
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
}