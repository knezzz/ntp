part of ntp;

enum DnsApiProvider { google, cloudflare }

///
/// Base url for each dns resolver
///
const _dnsApiProviderUrl = {
  DnsApiProvider.google: 'https://dns.google.com/resolve',
  DnsApiProvider.cloudflare: 'https://cloudflare-dns.com/dns-query',
};

const _defaultLookup = 'time.google.com';

RegExp _ipRegex = RegExp(
    r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");

class NTP {
  /// Return NTP delay in milliseconds
  static Future<int> getNtpOffset({
    String lookUpAddress = 'pool.ntp.org',
    int port = 123,
    DateTime localTime,
    Duration timeout,
    DnsApiProvider dnsProvider = DnsApiProvider.google,
  }) async {
    final ntpServerAddress = await _lookupDoH(lookUpAddress, dnsProvider);

    InternetAddress clientAddress = InternetAddress.anyIPv4;
    if (ntpServerAddress.type == InternetAddressType.IPv6) {
      clientAddress = InternetAddress.anyIPv6;
    }

    // Init datagram socket to anyIPv4 and to port 0
    final RawDatagramSocket _datagramSocket = await RawDatagramSocket.bind(clientAddress, 0);

    final _NTPMessage _ntpMessage = _NTPMessage();
    final List<int> buffer = _ntpMessage.toByteArray();
    final DateTime time = localTime ?? DateTime.now();
    _ntpMessage.encodeTimestamp(buffer, 40, (time.millisecondsSinceEpoch / 1000.0) + _ntpMessage.timeToUtc);

    // Send buffer packet to the address from [addressArray] and port [port]
    _datagramSocket.send(buffer, ntpServerAddress, port);
    // Receive packet from socket
    Datagram packet;

    final _receivePacket = (RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        packet = _datagramSocket.receive();
      }
      return packet != null;
    };

    try {
      if (timeout != null) {
        await _datagramSocket.timeout(timeout).firstWhere(_receivePacket);
      } else {
        await _datagramSocket.firstWhere(_receivePacket);
      }
    } catch (e) {
      rethrow;
    } finally {
      _datagramSocket.close();
    }

    if (packet == null) {
      return Future<int>.error('Error: Packet is empty!');
    }

    final int offset = _parseData(packet.data, DateTime.now());
    return offset;
  }

  /// Get current NTP time
  static Future<DateTime> now({
    String lookUpAddress = _defaultLookup,
    int port = 123,
    Duration timeout,
    DnsApiProvider dnsProvider = DnsApiProvider.google,
  }) async {
    final DateTime localTime = DateTime.now();
    final int offset = await getNtpOffset(
      lookUpAddress: lookUpAddress,
      port: port,
      localTime: localTime,
      timeout: timeout,
      dnsProvider: dnsProvider,
    );

    return localTime.add(Duration(milliseconds: offset));
  }

  /// Parse data from datagram socket.
  static int _parseData(List<int> data, DateTime time) {
    final _NTPMessage _ntpMessage = _NTPMessage(data);
    final double destinationTimestamp = (time.millisecondsSinceEpoch / 1000.0) + 2208988800.0;
    final double localClockOffset = ((_ntpMessage._receiveTimestamp - _ntpMessage._originateTimestamp) +
            (_ntpMessage._transmitTimestamp - destinationTimestamp)) /
        2;

    return (localClockOffset * 1000).toInt();
  }

  /// Utility to read data from HttpClientResponse
  static Future<String> _readResponse(HttpClientResponse response) {
    final completer = Completer<String>();
    final contents = StringBuffer();
    response.transform(utf8.decoder).listen((data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

  /// Utility to resolve DNS over HTTPs (DoH)
  static Future<InternetAddress> _lookupDoH(String host, DnsApiProvider provider) async {
    final _provider = _dnsApiProviderUrl[provider];
    final httpClient = HttpClient();
    final query = '$_provider?name=$host&type=a&do=1';
    final request = await httpClient.getUrl(Uri.parse(query));
    final response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      // HTTP OK
      final String jsonContent = await _readResponse(response);
      final Map<String, dynamic> map = json.decode(jsonContent) as Map<String, dynamic>;

      final addresses = (map['Answer'] as List<dynamic>)
          .map((dynamic answer) => answer['data'] as String)
          .toList()
          .firstWhere((element) => _ipRegex.hasMatch(element), orElse: () => null);

      return InternetAddress(addresses);
    }

    return null;
  }
}
