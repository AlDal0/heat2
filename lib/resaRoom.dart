import 'resaHome.dart';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';


Map<DateTime, List<Event>> resaMapping= {DateTime(2021,1,1): [const Event('room')]};

List<Event> roomList = [];
List<String> roomSelectedList = [];
List<DateTime> resaDateList = [];
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 1, kToday.day);
final kLastDay = DateTime(kToday.year + 5, kToday.month, kToday.day);


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
  final String room;

  const Event(this.room);

  @override
  String toString() => room;
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

Map<DateTime, List<Event>> getResa(reservationSnapshotData, roomSnapshotData) {

      List<Event> resaMappingVar = [Event('room')];
      List<DateTime> dateRange = [];

      final Map<DateTime, List<Event>> dateRoom = {DateTime(2021,1,1): resaMappingVar};

      dateRoom.remove(DateTime(2021,1,1));

      for (var j = 0; j < resaDateList.length; j++) { 

        resaMappingVar = [];

        for (final document in reservationSnapshotData.docs) {
        
          final data = document.data();
          final room = data['room'].toString().replaceAllMapped('DocumentReference<Map<String, dynamic>>(room/', (match) => '').replaceAllMapped(')', (match) => '');
          DateTime tsdateStart = DateTime.utc(data['dateStart'].toDate().year,data['dateStart'].toDate().month,data['dateStart'].toDate().day);
          DateTime tsdateEnd = DateTime.utc(data['dateEnd'].toDate().year,data['dateEnd'].toDate().month,data['dateEnd'].toDate().day);

          dateRange = daysInRange(tsdateStart,tsdateEnd);

          if (dateRange.contains(resaDateList[j])) {

            for (final document1 in roomSnapshotData.docs) {

              final data1 = document1.data();

              if (room.contains(document1.id)) {
      
                resaMappingVar.add(Event(data1['name']));

              }
          
            }

          }

      }

      dateRoom[resaDateList[j]] = resaMappingVar;

      }

    return dateRoom;
    
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

List<Event> getRooms(roomSnapshotData) {
  //final snapshot = await db.collection('room').get();

  List<Event> getRooms = [];

  for (final document in roomSnapshotData.docs) {
    var data = document.data();

    getRooms.add(Event(data['name']));
  }

  return getRooms;

}

int getRoomPrice(roomSnapshotData, roomSelected) {

  int roomSelectedPrice = 0;

  for (final document in roomSnapshotData.docs) {
    var data = document.data();

    if (data['name'] == roomSelected) {
      roomSelectedPrice = data['price'];
    }

  }

  return roomSelectedPrice;

}

String getRoomCurrency(roomSnapshotData, roomSelected) {

  String roomSelectedCurrency = "";

  for (final document in roomSnapshotData.docs) {
    var data = document.data();

    if (data['name'] == roomSelected) {
      roomSelectedCurrency = data['currency'];
    }

  }

  return roomSelectedCurrency;

}

addResa(DateTime? dateStart, DateTime? dateEnd, List<String> roomSelectedListToBook, void onRangeSelectedFunction(DateTime? start, DateTime? end, DateTime focusedDay)) async {
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

    var mappingAdded = {
      for (var item in List.generate(dateRange.length, (index) => index)) dateRange[item] : List.generate(roomSelectedListToBook.length,(i) {
          return Event(roomSelectedListToBook[i]);
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
        var listEvent = List.generate(roomSelectedListToBook.length,(i) {
          return Event(roomSelectedListToBook[i]);
        });
          kEvents[dateRange[j]] = listEvent;

      }

    }

    final dateStartEmail = DateFormat.yMMMMd('en_EN').format(dateStart);
    final dateEndEmail = DateFormat.yMMMMd('en_EN').format(dateEnd!);
    final length = dateRange.length-1;

    final resaAmountTotal = resaAmountDay * length;

    if (length == 1) {
      await reservation.add({
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
    }
    else {
      await reservation.add({
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
    }
    
    onRangeSelectedFunction(dateStart, dateEnd, dateStart);

  }

  Future<String> getRoomMiniImage(String roomSelectedToGetImage, roomSnapshotData) async {

  imgMini = '';

  for (final document in roomSnapshotData.docs) {
    var data = document.data();
      if (data['name'].toString() == roomSelectedToGetImage) {

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

List<Widget> getListWidget(String roomSelected) {

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
                    roomSelected,
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


class ResaRoom extends StatefulWidget {

  final ScrollController mainControllerRoom;

  const ResaRoom(this.mainControllerRoom, {Key? key}) : super(key: key);
  @override
    _ResaRoomState createState() => _ResaRoomState();
}

class _ResaRoomState extends State<ResaRoom> {

  final Stream<QuerySnapshot> reservationStream = FirebaseFirestore.instance.collection('reservation').snapshots();
  final Stream<QuerySnapshot> roomStream = FirebaseFirestore.instance.collection('room').snapshots();

  List<ListItem<String>> listDate = [];
  List<ListItem<String>> listRoom = [];
  late final ValueNotifier<List<Event>> _bookedRooms;
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
    _bookedRooms = ValueNotifier(_getEventsForDay(_selectedDay!));
    _selectedDate = ValueNotifier(_getDatesForDay(_selectedDay!,_selectedDay!));
    roomSelectedList = [];
    
  }

  @override
  void dispose() {
    _bookedRooms.dispose();
    super.dispose();
  }

  void populateData() {
  listRoom = [];
    for (int i = 0; i < 5; i++) {
      listRoom.add(ListItem<String>("item $i"));
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
        roomSelectedList = [];
        for (var element in listRoom) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = selectedDay; // Important to clean those
        _rangeEnd = DateTime(selectedDay.year, selectedDay.month, selectedDay.day + 1); 
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        
      });

      _bookedRooms.value = _getEventsForDay(selectedDay);
      _selectedDate.value = _getDatesForDay(selectedDay,DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day + 1));

    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {

    if ((start != null && end != null) && (start.isAfter(end))) {

      setState(() {
        roomSelectedList = [];
        for (var element in listRoom) { element.isSelected = false; buttonenabled = false; }
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

        sorted.sort((a, b) => a.room.compareTo(b.room));

        var seen = Set<String>();
        List<Event> uniquelist = sorted.where((event) =>
            seen.add(event.room)).toList();

        _bookedRooms.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (start != null) {
        _bookedRooms.value = _getEventsForDay(start);
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (end != null) {
        _bookedRooms.value = _getEventsForDay(end);
        _selectedDate.value = _getDatesForDay(end, end);
      }
    }
    else {
      if (start != null && end != null) {

        setState(() {
          roomSelectedList = [];
          for (var element in listRoom) { element.isSelected = false; buttonenabled = false; }
          _selectedDay = focusedDay;
          _selectedDay = focusedDay;
          _focusedDay = focusedDay;
          _rangeStart = start;
          _rangeEnd = end;
          _rangeSelectionMode = RangeSelectionMode.toggledOn;
        });

        var a = _getEventsForRange(start, end);

        var sorted = a;

        sorted.sort((a, b) => a.room.compareTo(b.room));

        var seen = Set<String>();
        List<Event> uniquelist = sorted.where((event) =>
            seen.add(event.room)).toList();

        _bookedRooms.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, end);
      } else if (start != null) {

        setState(() {
          roomSelectedList = [];
          for (var element in listRoom) { element.isSelected = false; buttonenabled = false; }
          _selectedDay = focusedDay;
          _selectedDay = focusedDay;
          _focusedDay = focusedDay;
          _rangeStart = start;
          _rangeEnd = DateTime.utc(start.year, start.month, start.day + 1);
          _rangeSelectionMode = RangeSelectionMode.toggledOn;
        });

        var a = _getEventsForRange(start, DateTime.utc(start.year, start.month, start.day + 1));

        var sorted = a;

        sorted.sort((a, b) => a.room.compareTo(b.room));

        var seen = Set<String>();
        List<Event> uniquelist = sorted.where((event) =>
            seen.add(event.room)).toList();
        
        _bookedRooms.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, DateTime(start!.year, start!.month, start!.day + 1));
      } else if (end != null) {
        _bookedRooms.value = _getEventsForDay(end);
        _selectedDate.value = _getDatesForDay(end, end);
      }
    }

  }

  void updateColorAfterSelection(int index, String roomSelected) {

    if (listRoom[index].isSelected == true) {
      ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text('$roomSelected already selected'), duration: const Duration(milliseconds: 1000)));
    }
    else {
    setState(() {

      listRoom[index].isSelected = true;
      roomSelectedList.add(roomSelected);
      buttonenabled = true;
    });
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? dateSelected) async {
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: dateSelected,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.en_us,
      looping: true,
    );

    return datePicked;
  }

  Widget _getListDateContainer(BuildContext context, int index, List<DateTime?> dateSelected) {

    var a =['Start : ','End : '];

    return InkWell(
        onTap: () async {
       

          dateSelected[index] = await _selectDate(context,dateSelected[index]);

          if (index == 0) {
            if (dateSelected[index] != null) {
              _onRangeSelected(dateSelected[index], _rangeEnd, _focusedDay);
            }

            else {

              _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);

            }

          }

          else {
            if (dateSelected[index] != null) {
              _onRangeSelected(_rangeStart, dateSelected[index], _focusedDay);
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
                Text('${dateSelected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(8,10)} / ${dateSelected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(5,7)} / ${dateSelected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(0,4)}', style: const TextStyle(color: Colors.white))
              ])
        )
    );
  }

  Widget _getListItemTile(BuildContext context, int index, String roomSelected, roomSnapshot, snapshotImage, ScrollController mainScrollController) {

    var key = GlobalKey();

    var roomPrice = getRoomPrice(roomSnapshot.requireData, roomSelected);

    var roomCurrency = getRoomCurrency(roomSnapshot.requireData, roomSelected);

    return InkWell(
      onTap: () {

        Scrollable.ensureVisible(key.currentContext!, alignment: 0.5, duration: const Duration(seconds: 1));

        if (listRoom[index].isSelected == true) {

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(content: Text('$roomSelected retirée'), duration: const Duration(milliseconds: 1000)));
          

        setState(() {

          listRoom[index].isSelected = !listRoom[index].isSelected;
          roomSelectedList.remove(roomSelected);
        
          var result = listRoom.any((element) => element.isSelected);
          if (result == false) {
            buttonenabled = false;
          }

        });
        }
        else {

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(
          //     content: Text('$roomSelected sélectionnée'),             
          //     duration: const Duration(milliseconds: 1000)
          // ));
          

          setState(() {

            listRoom[index].isSelected = true;

            roomSelectedList.add(roomSelected);

            buttonenabled = true;

            //_mainController.jumpTo(_mainController.positions.last.maxScrollExtent);
            //if (index > 2) {

            //scrollController.animateTo(scrollController.positions.last.maxScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease);

            //scrollController.animateTo(index * 90, duration: Duration(seconds: 1), curve: Curves.ease);
            //}

            

            mainScrollController.animateTo(mainScrollController.positions.last.maxScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease);
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
          color: listRoom[index].isSelected ? Colors.red[100] : const Color.fromARGB(255, 221, 248, 249),
          //color: listRoom[index].isSelected ? Colors.red[100] : const Color.fromARGB(255, 236, 249, 221),
        //  color: isSelected ? Colors.blue : null,
        ),
        child:
          Center(
            child: 
            ListTile(

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$roomSelected : $roomPrice $roomCurrency / night", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                DetailsButton(index, roomSelected, updateColorAfterSelection, roomSnapshot),
            ]),
            
          ),

          )
      )
                              
      );
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
      stream: roomStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> roomSnapshot) {

        if (roomSnapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (!roomSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        resaDateList = getResaDate(reservationSnapshot.requireData);
        resaMapping = getResa(reservationSnapshot.requireData, roomSnapshot.requireData);
        roomList = getRooms(roomSnapshot.requireData);

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
            flex: 7,
            child:
              Container(
                padding: const EdgeInsets.only(right: 15.0),
                //margin: const EdgeInsets.only(bottom: 15.0),
                //height: 340,
                child:
                TableCalendar<Event>(
                  locale: 'en_EN',           
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
                    defaultTextStyle: TextStyle(fontSize: 15)
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
                      if (roomList.length - _getEventsForDay(day).length == 0) {
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.red)
                          ),
                        );
                      }
                    },
                    markerBuilder: (BuildContext context, date, events) {
                    if (roomList.length - events.length == 0) {
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
                        '${roomList.length - events.length}',
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
                    const Text('Available rooms : ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Text(
                        '${roomList.length - _bookedRooms.value.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    //Text('${roomList.length - _bookedRooms.value.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
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
              const Text('Click to select', style: TextStyle(fontStyle: FontStyle.italic))
          )
          ),
          
          // SizedBox(
          //   height:175,
          //   child:
          Expanded(
            flex: 6,
            child:
              ValueListenableBuilder<List<Event>>(
                  valueListenable: _bookedRooms,
                  builder: (context, value, _) {

                    final List<Event> result = [];
                      
                    for (var j = 0; j < roomList.length; j++) {
              
                      if (value.toString().contains(roomList[j].toString())) {
              
                      }
                      else {
                        result.add(roomList[j]);
                        
                      }

                    };
              
                    for (int i = 0; i < result.length; i++) {
                      listRoom.add(ListItem<String>("item $i"));
                    }
              
                    final ScrollController scrollControllerList = ScrollController();
              
                    if (result.isEmpty) {
                      return const Center(
                        child: Text(
                          'No available room in the selected period',
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
                            future: getRoomMiniImage(result[index].toString(), roomSnapshot.requireData),
                            builder: (context, AsyncSnapshot<String> snapshot){
                              if (snapshot.hasData) {
                          //getRoomMiniImage(result[index].toString(), roomSnapshot.requireData);

                          //getRoomImages(result[index].toString(), roomSnapshot.requireData);
                                return _getListItemTile(context, index, result[index].toString(), roomSnapshot, snapshot.data, widget.mainControllerRoom);
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
                  const Text('Selected rooms : '),
                  Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        '${roomSelectedList.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  //Text('${roomSelectedList.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, backgroundColor: Color.fromARGB(255, 240, 199, 196))),
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
                          addResa(_selectedDay, _selectedDay, roomSelectedList, _onRangeSelected);
                        }
                        else if (_rangeEnd == null) {
                          _rangeEnd = _rangeStart;
                          addResa(_rangeStart, _rangeEnd, roomSelectedList, _onRangeSelected);
                        }
                        else {
                          addResa(_rangeStart, _rangeEnd, roomSelectedList, _onRangeSelected);
                        }
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(content: Text('Reservation confirmed'),duration: Duration(milliseconds: 1000)));
                        

                        roomSelectedList = [];

                        //listRoom[0].isSelected == true;
                        setState(() {
                          for (var j = 0; j < listRoom.length; j++) {
                            listRoom[j].isSelected = false;
                          }
                        });

                    }:null,
                    child: const Text('Book'),
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

  final String roomSelected;
  //final List<ListItem<String>> list;
  final dynamic updateContainerColor;
  final int index;
  final dynamic roomSnapshot;
  const DetailsButton(this.index, this.roomSelected, this.updateContainerColor, this.roomSnapshot, {super.key});

  @override
  State<DetailsButton> createState() => _DetailsButtonState();
}

class _DetailsButtonState extends State<DetailsButton> {

  getRoomImages(String roomSelectedToGetImage, roomSnapshotData) async {

  imgList = [];

  for (final document in roomSnapshotData.docs) {
    var data = document.data();
      if (data['name'].toString() == roomSelectedToGetImage) {
        

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
        await getRoomImages(widget.roomSelected, widget.roomSnapshot.requireData);
        //globals.widgetlist = getListWidget(widget.room_selected);

        _navigateAndDisplaySelection();
      },
      child: const Text('Details'),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  Future<void> _navigateAndDisplaySelection() async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarouselWithIndicatorDemo(widget.roomSelected)),
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
      
    
    widget.updateContainerColor(widget.index, widget.roomSelected);
    }
      
  }
}

class CarouselWithIndicatorDemo extends StatefulWidget {

  final String roomSelected;
  const CarouselWithIndicatorDemo(this.roomSelected, {super.key});


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
            items: getListWidget(widget.roomSelected),
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
                  Navigator.pop(context, '${widget.roomSelected} selected');
                },
                child: const Text('Select'),
              ),
      ]),
    )
    );
  }
}

