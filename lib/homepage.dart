import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create a connector
  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: PeerMeta(
      name: 'WalletConnect',
      description: 'WalletConnect Developer App',
      url: 'https://walletconnect.org',
      icons: [
        'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
      ],
    ),
  );

  var _session, session, uri;
  connectMetamaskWallet(BuildContext context) async {
    if (!connector.connected) {
      try {
        session = await connector.createSession(onDisplayUri: (_uri) async {
          uri = _uri;
          await launchUrlString(_uri, mode: LaunchMode.externalApplication);
        });
        setState(() {
          _session = session;
        });
        print(session);
        print(uri);
      } catch (e) {
        print("Error in connecting $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to events
    connector.on(
        'connect',
        (session) => setState(() {
              _session = session;
            }));
    connector.on(
        'session_update',
        (payload) => setState(() {
              _session = session;
            }));
    connector.on(
        'disconnect',
        (session) => setState(() {
              _session = session;
            }));

    var account = session?.accounts[0];
    var chainId = session?.chainId;
    return Scaffold(
        appBar: AppBar(title: const Text('Wallet Connect')),
        body: session == null
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                          'Please click the button to connect to metamask wallet'),
                    ),
                    TextButton(
                      onPressed: () async {
                        connectMetamaskWallet(context);
                        print('Wallet connected');
                      },
                      child: const Text('Connect Wallet'),
                    ),
                  ],
                ),
              )
            : account != null
                ? Column(
                    children: [
                      Text("You are connected $account"),
                      Text("ChainId is $chainId"),
                    ],
                  )
                : Text('No account'));
  }
}
