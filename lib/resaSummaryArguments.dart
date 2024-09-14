class ResaSummaryArguments {
  final DateTime dateStart;
  final DateTime dateEnd;
  final int length;
  final dynamic room;
  final dynamic client;
  final String type;
  final int resaAmountTotal;
  final String resaCurrency;


  ResaSummaryArguments(this.dateStart, this.dateEnd, this.length, this.room, this.client, this.type, this.resaAmountTotal, this.resaCurrency);
}