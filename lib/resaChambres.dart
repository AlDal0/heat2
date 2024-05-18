import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instanceFor(bucket: "gs://heat-e9529.appspot.com").ref();

Map<DateTime, List<Event>> resaMapping= {DateTime(2021,1,1): [const Event('chambre')]};
List<Event> chambreList = [];
List<String> chambreSelectedList = [];
List<DateTime> resaDateList = [];
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

ScrollController _mainController = new ScrollController();


var result;

List<String> imgList = [
  ];

//var imgMini = '';

var imgMini;


// var _kEventSource;
//  var kEvents;

var kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

var _kEventSource = {
  for (var item in List.generate(50, (index) => index))
  DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5) : List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')) }
  ..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

/// Example event class.
class Event {
  final String chambre;

  const Event(this.chambre);

  @override
  String toString() => chambre;
}

class ListItem<T> {
bool isSelected = false; //Selection property to highlight or not
T data; //Data of the user
ListItem(this.data); //Constructor to assign the data
}



int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

Map<DateTime, List<Event>> getResa(reservationSnapshotData, chambreSnapshotData) {

      List<Event> resaMappingVar = [Event('chambre')];
      List<DateTime> dateRange = [];

      final Map<DateTime, List<Event>> date_chambre = {DateTime(2021,1,1): resaMappingVar};

      date_chambre.remove(DateTime(2021,1,1));

      for (var j = 0; j < resaDateList.length; j++) { 

        resaMappingVar = [];

        for (final document in reservationSnapshotData.docs) {
        
          final data = document.data();
          final chambre = data['chambre'].toString().replaceAllMapped('DocumentReference<Map<String, dynamic>>(chambre/', (match) => '').replaceAllMapped(')', (match) => '');
          DateTime tsdateStart = DateTime.utc(data['dateStart'].toDate().year,data['dateStart'].toDate().month,data['dateStart'].toDate().day);
          DateTime tsdateEnd = DateTime.utc(data['dateEnd'].toDate().year,data['dateEnd'].toDate().month,data['dateEnd'].toDate().day);

          dateRange = daysInRange(tsdateStart,tsdateEnd);

          if (dateRange.contains(resaDateList[j])) {

            for (final document1 in chambreSnapshotData.docs) {

              final data1 = document1.data();

              if (chambre.contains(document1.id)) {
      
                resaMappingVar.add(Event(data1['nom']));

              }
          
            }

          }

      }

      date_chambre[resaDateList[j]] = resaMappingVar;

      }

    return date_chambre;
    
  }

List<DateTime> getResaDate(reservationSnapshotData) {

      List<DateTime> datelist = [];
      List<DateTime> datelist1 = [];
      for (final document in reservationSnapshotData.docs) {

      final data = document.data() as Map<String, dynamic>;
     
      DateTime tsdateStart = DateTime.utc(data['dateStart'].toDate().year,data['dateStart'].toDate().month,data['dateStart'].toDate().day);
      DateTime tsdateEnd = DateTime.utc(data['dateEnd'].toDate().year,data['dateEnd'].toDate().month,data['dateEnd'].toDate().day);
      datelist1 = daysInRange(tsdateStart,tsdateEnd);  

      for (var j = 0; j < datelist1.length; j++) {
      datelist.add(datelist1[j]);

      };
       
    }

    datelist = datelist.toSet().toList();
    
    datelist.sort();

    return datelist;
    
}

getoccurences(DateTime date) {

    var a = resaMapping[date]!.length;

    return a;
  
}

List<Event> getChambres(chambreSnapshotData) {
  //final snapshot = await db.collection('chambre').get();

  List<Event> getChambres = [];

  for (final document in chambreSnapshotData.docs) {
    var data = document.data();

    getChambres.add(Event(data['nom']));
  }

  return getChambres;

}

class ResaChambreHome extends StatelessWidget {
  const ResaChambreHome({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text('Réservation Chambre'),
          toolbarHeight: 30,
          scrolledUnderElevation: 0),
        body: SingleChildScrollView(
          controller: _mainController,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: const Center(child: ResaChambre())
          )
        ),
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
              title: const Text('Accueil'),
                    onTap: () {

                      Navigator.pushNamed(context, '/accueil');
                      
                    },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('Mes Réservations'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/mesreservations');
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Actualité'),
                    onTap: () {

                      Navigator.pushNamed(context, '/actualite');
                      
                    },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Chambres'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer

                Navigator.pushNamed(context, '/resachambres');
               
                //Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_restaurant),
              title: const Text('Restauration'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/resarestauration');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
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

class ResaChambre extends StatefulWidget {

  const ResaChambre({Key? key}) : super(key: key);
  @override
    _ResaChambreState createState() => _ResaChambreState();
}

class _ResaChambreState extends State<ResaChambre> {

  final Stream<QuerySnapshot> reservationStream = FirebaseFirestore.instance.collection('reservation').snapshots();
  final Stream<QuerySnapshot> chambreStream = FirebaseFirestore.instance.collection('chambre').snapshots();

  List<ListItem<String>> listDate = [];
  List<ListItem<String>> listChambre = [];
  late final ValueNotifier<List<Event>> _bookedChambres;
  late final ValueNotifier<List<DateTime?>> _selectedDate;
  late bool isSelected;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  bool buttonenabled = false;

  @override
  void initState() {
    super.initState();

    isSelected = false;
    populateData();

    _selectedDay = _focusedDay;
    _bookedChambres = ValueNotifier(_getEventsForDay(_selectedDay!));
    _selectedDate = ValueNotifier(_getDatesForDay(_selectedDay!,_selectedDay!));

   
    
  }

  @override
  void dispose() {
    _bookedChambres.dispose();
    super.dispose();
  }

  void populateData() {
  listChambre = [];
    for (int i = 0; i < 5; i++) {
      listChambre.add(ListItem<String>("item $i"));
    }

  listDate = [];
  for (int i = 0; i < 2; i++) {
    listDate.add(ListItem<String>("item $i"));
  }
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<DateTime?> _getDatesForDay(DateTime? start,DateTime? end) {
    return [start,end];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {

    if (!isSameDay(_selectedDay, selectedDay)) {
      
      setState(() {
        chambreSelectedList = [];
        for (var element in listChambre) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null; 
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        
      });

      _bookedChambres.value = _getEventsForDay(selectedDay);
      _selectedDate.value = _getDatesForDay(selectedDay,selectedDay);

    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {

    if ((start != null && end != null) && (start.isAfter(end))) {

      setState(() {
        chambreSelectedList = [];
        for (var element in listChambre) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = focusedDay;
        _focusedDay = focusedDay;
        _rangeStart = start;
        _rangeEnd = start;
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
        
      });

      // `start` or `end` could be null
      if (start != null && end != null) {
        var a = _getEventsForRange(start, start);

        var sorted = a;

        sorted.sort((a, b) => a.chambre.compareTo(b.chambre));

        var seen = Set<String>();
        List<Event> uniquelist = sorted.where((event) =>
            seen.add(event.chambre)).toList();

        _bookedChambres.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (start != null) {
        _bookedChambres.value = _getEventsForDay(start);
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (end != null) {
        _bookedChambres.value = _getEventsForDay(end);
        _selectedDate.value = _getDatesForDay(end, end);
      }
    }
    else {
      setState(() {
        chambreSelectedList = [];
        for (var element in listChambre) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = focusedDay;
        _selectedDay = focusedDay;
        _focusedDay = focusedDay;
        _rangeStart = start;
        _rangeEnd = end;
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
      });
      if (start != null && end != null) {
        var a = _getEventsForRange(start, end);

        var sorted = a;

        sorted.sort((a, b) => a.chambre.compareTo(b.chambre));

        var seen = Set<String>();
        List<Event> uniquelist = sorted.where((event) =>
            seen.add(event.chambre)).toList();

        _bookedChambres.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, end);
      } else if (start != null) {
        _bookedChambres.value = _getEventsForDay(start);
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (end != null) {
        _bookedChambres.value = _getEventsForDay(end);
        _selectedDate.value = _getDatesForDay(end, end);
      }
    }

  }

  void updateColorAfterSelection(int index, String chambreSelected) {

    if (listChambre[index].isSelected == true) {
      ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text('$chambreSelected déjà sélectionnée'), duration: const Duration(milliseconds: 1000)));
    }
    else {
    setState(() {

      listChambre[index].isSelected = true;
      chambreSelectedList.add(chambreSelected);
      buttonenabled = true;
    });
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? date_selected) async {
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: date_selected,
      firstDate: DateTime(2023),
      lastDate: DateTime(2024),
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.fr,
      looping: true,
    );

    return datePicked;
  }

  Widget _getListDateContainer(BuildContext context, int index, List<DateTime?> date_selected) {

    var a =['Début : ','Fin : '];

    return InkWell(
        onTap: () async {
       

          date_selected[index] = await _selectDate(context,date_selected[index]);

          if (index == 0) {
            if (date_selected[index] != null) {
              _onRangeSelected(date_selected[index], _rangeEnd, _focusedDay);
            }

            else {

              _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);

            }

          }

          else {
            if (date_selected[index] != null) {
              _onRangeSelected(_rangeStart, date_selected[index], _focusedDay);
            }

            else {

              _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);

            }
          }

          setState(() {
            listDate[index].isSelected = !listDate[index].isSelected;
          });
        },
        child: Container(
            padding: const EdgeInsets.all(6.0),
            //width: 190,
            margin: const EdgeInsets.symmetric(
              horizontal: 7.0,
              // vertical: 4.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12.0),
              //color: const Color.fromARGB(255, 200, 229, 255),
              color: Colors.indigo.shade400,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_right_outlined, color: Colors.white),
                Text(a[index],style: const TextStyle(color: Colors.white)),
                Text('${date_selected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(8,10)} / ${date_selected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(5,7)} / ${date_selected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(0,4)}', style: const TextStyle(color: Colors.white))
              ])
        )
    );
  }

  Widget _getListItemTile(BuildContext context, int index, String chambreSelected, chambreSnapshot, snapshotImage, ScrollController scrollController) {

    var key = GlobalKey();

    

    return InkWell(
      onTap: () {

        Scrollable.ensureVisible(key.currentContext!, alignment: 0.5, duration: const Duration(seconds: 1));

        if (listChambre[index].isSelected == true) {

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(content: Text('$chambreSelected retirée'), duration: const Duration(milliseconds: 1000)));
          

        setState(() {

          listChambre[index].isSelected = !listChambre[index].isSelected;
          chambreSelectedList.remove(chambreSelected);
        
          var result = listChambre.any((element) => element.isSelected);
          if (result == false) {
            buttonenabled = false;
          }

        });
        }
        else {

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(
          //     content: Text('$chambreSelected sélectionnée'),             
          //     duration: const Duration(milliseconds: 1000)
          // ));
          

          setState(() {

            listChambre[index].isSelected = true;

            chambreSelectedList.add(chambreSelected);

            buttonenabled = true;

            //_mainController.jumpTo(_mainController.positions.last.maxScrollExtent);
            //if (index > 2) {

            //scrollController.animateTo(scrollController.positions.last.maxScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease);

            //scrollController.animateTo(index * 90, duration: Duration(seconds: 1), curve: Curves.ease);
            //}

            

            _mainController.animateTo(_mainController.positions.last.maxScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease);
            //Duration(seconds: 1), Curves.ease
            
          });
        }
      },
      child: Container(
        key: key,
        //margin: EdgeInsets.symmetric(vertical: 4),
        height: 90,
        margin: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        //color: list[index].isSelected ? Colors.red[100] : Color.fromARGB(255, 236, 249, 221),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(snapshotImage.toString()),
            alignment: Alignment.center,
            fit: BoxFit.fitWidth,
            opacity: 0.5
            ),
          border: Border.all(),
          borderRadius: BorderRadius.circular(12.0),
          color: listChambre[index].isSelected ? Colors.red[100] : const Color.fromARGB(255, 221, 248, 249),
          //color: listChambre[index].isSelected ? Colors.red[100] : const Color.fromARGB(255, 236, 249, 221),
        //  color: isSelected ? Colors.blue : null,
        ),
        child:
          Center(
            child: 
            ListTile(

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(chambreSelected,style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                DetailsButton(index, chambreSelected, updateColorAfterSelection, chambreSnapshot),
            ]),
            
          ),

          )
      )
                              
      );
}

addResa(DateTime? dateStart, DateTime? dateEnd, List<String> chambreSelectedListToBook, void onRangeSelectedFunction(DateTime? start, DateTime? end, DateTime focusedDay)) async {
    CollectionReference reservation = FirebaseFirestore.instance.collection('reservation');
    final snapshot1 = await db.collection('chambre').get();
    final snapshot2 = await db.collection('client').get();
    List<DocumentReference> chambreId = [];
    List<DateTime> dateRange = [];
    late DocumentReference clientId;

    //if (dateStart != null && dateEnd != null) {

    var date = DateTime(dateStart!.year, dateStart.month, dateStart.day);

    var clientNameEmail;
    var clientSurnameEmail;

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

      if (chambreSelectedListToBook.contains(data1['nom'])) {

        chambreId.add(db.doc('/chambre/${document1.id}'));

      }

    }

    for (final document2 in snapshot2.docs) {

      final data2 = document2.data();

      if (FirebaseAuth.instance.currentUser!.email!.contains(data2['email'])) {

        clientId = db.doc('/client/${document2.id}');
        clientNameEmail = data2['nom'];
        clientSurnameEmail = data2['prénom'];

      }

    }

    var mappingAdded = {
      for (var item in List.generate(dateRange.length, (index) => index)) dateRange[item] : List.generate(chambreSelectedListToBook.length,(i) {
          return Event(chambreSelectedListToBook[i]);
        })
          ..addAll({})
    };


    for (var j = 0; j < dateRange.length; j++) {
      if (kEvents[dateRange[j]] != null) {

        for (var k = 0; k < mappingAdded[dateRange[j]]!.length; k++) {

            kEvents[dateRange[j]]!.add(mappingAdded[dateRange[j]]![k]);

        }

      }
      else {
        var listEvent = List.generate(chambreSelectedListToBook.length,(i) {
          return Event(chambreSelectedListToBook[i]);
        });
          kEvents[dateRange[j]] = listEvent;

      }

    }

    //DateTime.utc(dateStart.toDate().year,data['dateStart'].toDate().month,data['dateStart'].toDate().day);

    final dateStartEmail = DateFormat.yMMMMd('fr_FR').format(dateStart);
    final dateEndEmail = DateFormat.yMMMMd('fr_FR').format(dateEnd!);


    await reservation.add({
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'chambre': chambreId,
      'client': clientId,
      'status': 'created',
      'publisher': 'client',
      'to': [FirebaseAuth.instance.currentUser!.email],
      'message': {
        'subject': 'Réservation chez Heat du $dateStartEmail au $dateEndEmail confirmée',
        'html': '<code><body style="text-align:center; font-family:Verdana;"><h1>Merci $clientSurnameEmail pour votre réservation !</h1> <br> Date début : $dateStartEmail <br></br> Date fin : $dateEndEmail <br></br> Chambres : ${chambreSelectedListToBook.join(', ')}</body></code>',
      }
    });
    
    onRangeSelectedFunction(dateStart, dateEnd, dateStart);

  }

  Future<String> getChambreMiniImage(String chambreSelectedToGetImage, chambreSnapshotData) async {

  imgMini = '';

  for (final document in chambreSnapshotData.docs) {
    var data = document.data();
      if (data['nom'].toString() == chambreSelectedToGetImage) {

        try {

          final image1Url = await storageRef.child(data['image1']).getDownloadURL();

          imgMini = image1Url;

          // Data for "images/island.jpg" is returned, use this as needed.
        } on FirebaseException catch (e) {
        // Handle any errors.
        }
 
      }
  }
  return imgMini;
}


  @override
  Widget build(BuildContext context) {
    var pixelRatio = MediaQuery.of(context).devicePixelRatio;
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
      stream: chambreStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> chambreSnapshot) {

        print(pixelRatio);

        if (chambreSnapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (!chambreSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        resaDateList = getResaDate(reservationSnapshot.requireData);
        resaMapping = getResa(reservationSnapshot.requireData, chambreSnapshot.requireData);
        chambreList = getChambres(chambreSnapshot.requireData);

        _kEventSource = Map.fromIterable(List.generate(resaDateList.length, (index) => index),
             key: (item) => resaDateList[item],
             value: (item) => List.generate(getoccurences(resaDateList[item]),(i) {
               return resaMapping[resaDateList[item]]![i];
               })
           ..addAll({}));

         kEvents = LinkedHashMap<DateTime, List<Event>>(
           equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(_kEventSource);

        return Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child:
              Container(
                padding: const EdgeInsets.only(right: 15.0),
                //margin: const EdgeInsets.only(bottom: 15.0),
                //height: 340,
                child:
                TableCalendar<Event>(
                  locale: 'fr_FR',           
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>isSameDay(day, _selectedDay),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: _rangeSelectionMode,
                  eventLoader:_getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: MediaQuery.of(context).size.height * 0.045,
                  calendarStyle: const CalendarStyle(
                    // Use `CalendarStyle` to customize the UI
                    outsideDaysVisible: false,
                    isTodayHighlighted: false,
                    markersAlignment: Alignment.bottomRight,
                    defaultTextStyle: TextStyle(fontSize: 10)
                    //weekendDecoration: BoxDecoration(
                    //  shape: BoxShape.rectangle,
                    //  color: Color.fromARGB(255, 239, 241, 236),
                      //color: Color.fromARGB(255, 236, 249, 221),
                    //),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false
                  ),
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
                      if (chambreList.length - _getEventsForDay(day).length == 0) {
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.red)
                          ),
                        );
                      }
                    },
                    markerBuilder: (BuildContext context, date, events) {
                    if (chambreList.length - events.length == 0) {
                      return Container(

                      );
                    }
                    else {
                    return Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Text(
                        '${chambreList.length - events.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                    }
                    }
                  ),
                ),
              )
          ),
          
          //const SizedBox(height: 8.0),

          // Flexible(
          //   flex: 1,
          //   child:
          //   Container(child: 

          //     const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //       Text('Dates :'),
          //     ]),
          //   )
          // ),

          Expanded(
            flex: 1,
            child:
            ValueListenableBuilder<List<DateTime?>>(
                valueListenable: _selectedDate,
                builder: (context, value, _) {
            
                  final List<DateTime?> result = [_rangeStart,_rangeEnd];
            
                  for (int i = 0; i < result.length; i++) {
                    listDate.add(ListItem<String>("item $i"));
                  }
            
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return _getListDateContainer(context, index, value);
            
                    },
                  );
                },
              )
          ),

          //const SizedBox(height: 8.0),
          Expanded(
            flex: 1,
            child:
            Container(
              //padding: const EdgeInsets.only(top: 15.0),
              child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chambres disponibles : ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Text(
                        '${chambreList.length - _bookedChambres.value.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    //Text('${chambreList.length - _bookedChambres.value.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                ],)
            )
          ),

          //const SizedBox(height: 8.0),
          Expanded(
            flex: 1,
            child:
            Container(
              padding: const EdgeInsets.only(top: 15.0),
              child:
              const Text('Cliquer pour sélectionner', style: TextStyle(fontStyle: FontStyle.italic))
          )
          ),
          
          // SizedBox(
          //   height:175,
          //   child:
          Expanded(
            flex: 6,
            child:
              ValueListenableBuilder<List<Event>>(
                  valueListenable: _bookedChambres,
                  builder: (context, value, _) {
                    //print(_bookedChambres);
              
                    final List<Event> result = [];
                      
                    for (var j = 0; j < chambreList.length; j++) {
              
                      if (value.toString().contains(chambreList[j].toString())) {
              
                      }
                      else {
                        result.add(chambreList[j]);
                        
                      }
                    };
              
                    for (int i = 0; i < result.length; i++) {
                      listChambre.add(ListItem<String>("item $i"));
                    }
              
                    final ScrollController scrollControllerList = ScrollController();
              
                    if (result.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucune chambre disponible sur la période donnée',
                          style: TextStyle(color: Colors.red, fontSize: 15))
                          //margin: EdgeInsets.symmetric(vertical: 4)
                      );
                    }
                    else {
                      
                    return Scrollbar(
                      thumbVisibility: true,
                      thickness: 10.0,
                      controller: scrollControllerList,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: result.length,
                        controller: scrollControllerList,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: getChambreMiniImage(result[index].toString(), chambreSnapshot.requireData),
                            builder: (context, AsyncSnapshot<String> snapshot){
                              if (snapshot.hasData) {
                          //getChambreMiniImage(result[index].toString(), chambreSnapshot.requireData);
                          //print(result[index]);
                          //getChambreImages(result[index].toString(), chambreSnapshot.requireData);
                                return _getListItemTile(context, index, result[index].toString(), chambreSnapshot, snapshot.data, scrollControllerList);
                              }
                              else {
                                return const CircularProgressIndicator();
                              }
                        },
                    );
                        }
                    )
                    );
                    }
                  },
                ),
          ),
          //const SizedBox(height: 10.0),
          Expanded(
            flex: 1,
            child:
            Container(
              //padding: const EdgeInsets.only(top: 15.0),
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chambres sélectionnées : '),
                  Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        '${chambreSelectedList.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  //Text('${chambreSelectedList.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, backgroundColor: Color.fromARGB(255, 240, 199, 196))),
              ])
          )
          ),

          //const SizedBox(height: 10.0),
          Expanded(
            flex: 1,
            child:
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                width: MediaQuery.of(context).size.width * 0.7,
                child:
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade400,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.black.withOpacity(0.38),
                      disabledBackgroundColor: Colors.black.withOpacity(0.12)),
                    // ButtonStyle(
                    //   backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo.shade400),
                    //   foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
                      
                    onPressed:buttonenabled?(){ //if buttonenabled == true then pass a function otherwise pass "null"
                        if(_rangeStart == null && _rangeEnd == null) {
                          addResa(_selectedDay, _selectedDay, chambreSelectedList, _onRangeSelected);
                        }
                        else if (_rangeEnd == null) {
                          _rangeEnd = _rangeStart;
                          addResa(_rangeStart, _rangeEnd, chambreSelectedList, _onRangeSelected);
                        }
                        else {
                          addResa(_rangeStart, _rangeEnd, chambreSelectedList, _onRangeSelected);
                        }
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(content: Text('Réservation enregistrée'),duration: Duration(milliseconds: 1000)));
                        

                        chambreSelectedList = [];

                        //listChambre[0].isSelected == true;
                        setState(() {
                          for (var j = 0; j < listChambre.length; j++) {
                            listChambre[j].isSelected = false;
                          }
                        });

                    }:null,
                    child: const Text('Réserver'),
                  )
              )
            )
             
        ],
      );
      }
      );
    }
    );
  }
}

class DetailsButton extends StatefulWidget {

  final String chambreSelected;
  //final List<ListItem<String>> list;
  final dynamic updateContainerColor;
  final int index;
  final dynamic chambreSnapshot;
  const DetailsButton(this.index, this.chambreSelected, this.updateContainerColor, this.chambreSnapshot, {super.key});

  @override
  State<DetailsButton> createState() => _DetailsButtonState();
}

class _DetailsButtonState extends State<DetailsButton> {

  getChambreImages(String chambreSelectedToGetImage, chambreSnapshotData) async {

  imgList = [];

  for (final document in chambreSnapshotData.docs) {
    var data = document.data();
      if (data['nom'].toString() == chambreSelectedToGetImage) {
        

        try {

          final image1Url = await storageRef.child(data['image1']).getDownloadURL();
          final image2Url = await storageRef.child(data['image2']).getDownloadURL();
          final image3Url = await storageRef.child(data['image3']).getDownloadURL();
          final image4Url = await storageRef.child(data['image4']).getDownloadURL();
          final image5Url = await storageRef.child(data['image5']).getDownloadURL();

          imgList.add(image1Url);
          imgList.add(image2Url);
          imgList.add(image3Url);
          imgList.add(image4Url);
          imgList.add(image5Url);

          // Data for "images/island.jpg" is returned, use this as needed.
        } on FirebaseException catch (e) {
        // Handle any errors.
        }
 
      }
  }
}
  @override
  Widget build(BuildContext context) {
    
    return ElevatedButton(
      onPressed: () async {
        await getChambreImages(widget.chambreSelected, widget.chambreSnapshot.requireData);
        //globals.widgetlist = getListWidget(widget.chambre_selected);

        _navigateAndDisplaySelection();
      },
      child: const Text('Détails'),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  Future<void> _navigateAndDisplaySelection() async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarouselWithIndicatorDemo(widget.chambreSelected)),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    
    if (result != null) {
    
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result'),duration: const Duration(milliseconds: 1000)));
      
    
    widget.updateContainerColor(widget.index, widget.chambreSelected);
    }
      
  }
}

class CarouselWithIndicatorDemo extends StatefulWidget {

  final String chambreSelected;
  const CarouselWithIndicatorDemo(this.chambreSelected, {super.key});


  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        scrolledUnderElevation: 0),
      body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        //Expanded(
          CarouselSlider(
            items: getListWidget(widget.chambreSelected),
            carouselController: _controller,
            options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                aspectRatio: 2,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
       // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(_current == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
        ElevatedButton(
                onPressed: () {
                  // Close the screen and return "Yep!" as the result.
                  Navigator.pop(context, '${widget.chambreSelected} sélectionnée');
                },
                child: const Text('Sélectionner'),
              ),
      ]),
    )
    );
  }
}

List<Widget> getListWidget(String chambreSelected) {

List<Widget> imageSliders = imgList
    .map((item) => Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network(item, fit: BoxFit.cover, width: 1000.0),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    chambreSelected,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )),
    ))
    .toList();
    return imageSliders;
}