part of ntp;

class NTP{
  NTPMessage _ntpMessage;

  /// Return NTP delay in milliseconds
  Future<int> getNtpTime({
    String lookUpAddress: 'pool.ntp.org',
    int port: 123,
    DateTime localTime
  }) async {
    DateTime time = localTime ?? new DateTime.now().toLocal();

    _ntpMessage = new NTPMessage();

    List<InternetAddress> addressArray = await InternetAddress.lookup(lookUpAddress);

    List<int> buffer = _ntpMessage.toByteArray();
    _ntpMessage.encodeTimestamp(buffer, 40, (time.millisecondsSinceEpoch / 1000.0) + _ntpMessage.timeToUtc);

    // Init datagram socket to ANY_IP_V4 and to port 0
    RawDatagramSocket _datagramSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0, reuseAddress: true);

    // Send buffer packet to the address from [addressArray] and port [_ntpPort]
    _datagramSocket.send(buffer, addressArray.first, port);

    // Receive packet from socket
    Datagram packet;
    await _datagramSocket.firstWhere((event){
      if(event == RawSocketEvent.read){
        packet = _datagramSocket.receive();
      }

      return packet != null;
    });

    if (packet == null) return new Future.error('Error: Packet is empty!');

    int offset = _parseData(packet.data, time);
    
    return new Future.value(offset);
  }

  int _parseData(List<int> data, DateTime time){
    _ntpMessage = new NTPMessage(data);
    double destinationTimestamp = (time.millisecondsSinceEpoch / 1000.0) + 2208988800.0;
    double localClockOffset = ((_ntpMessage.receiveTimestamp - _ntpMessage.originateTimestamp) + (_ntpMessage.transmitTimestamp - destinationTimestamp)) / 2;

    print('NTP Clock offset: $localClockOffset seconds');

    return (localClockOffset * 1000).toInt();
  }
}
