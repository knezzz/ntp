part of ntp;

class Ntp{
  Ntp._(){
    _fetchNtpTime();
  }

  factory Ntp.configure({String dnsAddress, int port}){
    _instance = Ntp._();
    return _instance;
  }

  int _offset;
  bool _gettingTime = false;

  static Ntp _instance;

  static Ntp get instance => _instance;

  int get offset => _offset;
  bool get isConfigured => !_gettingTime && _offset != null;

  DateTime get now => DateTime.now().add(Duration(milliseconds: offset));

  Future<void> _fetchNtpTime() async {
    if(_gettingTime){
      print('We are already getting the time offset!');
      return;
    }

    _gettingTime = true;

    try{
      _offset = await _getNtpOffset();
    } finally {
      _gettingTime = false;
    }
  }

  /// Return NTP delay in milliseconds
  Future<int> _getNtpOffset({String lookUpAddress = 'pool.ntp.org',
    int port = 123,
    DateTime localTime}) async {

    final DateTime time = localTime ?? DateTime.now();
    final NTPMessage _ntpMessage = NTPMessage();

    final List<InternetAddress> addressArray = await InternetAddress.lookup(lookUpAddress);
    final List<int> buffer = _ntpMessage.toByteArray();

    _ntpMessage.encodeTimestamp(buffer, 40, (time.millisecondsSinceEpoch / 1000.0) + _ntpMessage.timeToUtc);
    // Init datagram socket to anyIPv4 and to port 0
    final RawDatagramSocket _datagramSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0, reuseAddress: true);
    // Send buffer packet to the address from [addressArray] and port [port]
    _datagramSocket.send(buffer, addressArray.first, port);
    // Receive packet from socket
    Datagram packet;

    await _datagramSocket.firstWhere((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        packet = _datagramSocket.receive();
      }

      return packet != null;
    });

    if (packet == null) return Future<int>.error('Error: Packet is empty!');

    final int offset = _parseData(packet.data, time);
    return offset;
  }

  /// Parse data from datagram socket.
  int _parseData(List<int> data, DateTime time) {
    final NTPMessage _ntpMessage = NTPMessage(data);
    final double destinationTimestamp = (time.millisecondsSinceEpoch / 1000.0) + 2208988800.0;
    final double localClockOffset = ((_ntpMessage._receiveTimestamp - _ntpMessage._originateTimestamp) + (_ntpMessage._transmitTimestamp - destinationTimestamp)) / 2;

    return (localClockOffset * 1000).toInt();
  }
}