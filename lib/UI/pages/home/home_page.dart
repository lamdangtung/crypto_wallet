import 'dart:async';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:crypto_wallet/UI/pages/home/home_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;
  late Timer timer;

  @override
  void initState() {
    _cubit = context.read<HomeCubit>();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _cubit.refresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cubit.refresh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _createWallet,
                      child: const Text("Create Wallet"),
                    ),
                    ElevatedButton(
                      onPressed: _importWallet,
                      child: const Text("Import Wallet"),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 36,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "My wallet",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          if (state.wallet == null) {
                            return const Text(
                              "Ox0",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: Colors.blue),
                            );
                          }
                          return Text(
                            "${state.wallet?.privateKey.address}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: Colors.blue),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              if (state.balance == null) {
                                return const Text(
                                  "-1 BNB",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.green),
                                );
                              }

                              return Text(
                                "${state.balance?.bnb.toStringAsFixed(2)} BNB",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.green),
                              );
                            },
                          ),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              if (state.balance == null) {
                                return const Text(
                                  "-1 USDT",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.green),
                                );
                              }
                              return Text(
                                "${state.balance?.usdt.toStringAsFixed(2)} USDT",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.green),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _send,
                      child: const Text("Send"),
                    ),
                    ElevatedButton(
                      onPressed: _deposit,
                      child: const Text("Deposit"),
                    ),
                    ElevatedButton(
                      onPressed: _exchange,
                      child: const Text("Exchange"),
                    )
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  "Transactions",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      return ListView.builder(
                        itemCount: state.txs.length + 1,
                        itemBuilder: (_, index) {
                          if (index == 0) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 120,
                                  constraints:
                                      const BoxConstraints(maxWidth: 120),
                                  child: const Text(
                                    "TxHash",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  "Created at",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            );
                          }
                          final tx = state.txs[index - 1];
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 120),
                                child: Text(
                                  tx.txHash.substring(0, 12),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          tx.timestamp * 1000)
                                      .toLocal()
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await launchUrl(Uri.parse(
                                      "https://testnet.bscscan.com/tx/${tx.txHash}"));
                                },
                                child: Icon(Icons.open_in_browser),
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _createWallet() async {
    var rng = Random.secure();
    EthPrivateKey credentials = EthPrivateKey.createRandom(rng);
    Wallet wallet = Wallet.createNew(credentials, "password", rng);
    _cubit.updateWallet(wallet);
    showSimpleDialog(context, "Private Key",
        "0x${hex.encode(wallet.privateKey.privateKey)}");
  }

  Future<void> _importWallet() {
    final Completer completer = Completer();
    final controller = TextEditingController();
    showImportWallet(context, controller, () {
      EthPrivateKey credentials = EthPrivateKey.fromHex(controller.text.trim());
      var rng = Random.secure();
      Wallet wallet = Wallet.createNew(credentials, "password", rng);
      _cubit.updateWallet(wallet);
      Navigator.of(context).pop();
      completer.complete();
    });
    return completer.future;
  }

  void showSimpleDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content))
                    .then((value) => Navigator.of(context).pop());
              },
            ),
          ],
        );
      },
    );
  }

  void showImportWallet(BuildContext context, TextEditingController controller,
      VoidCallback onOK) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Import wallet"),
          content: TextFormField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                onOK.call();
              },
            ),
          ],
        );
      },
    );
  }

  void showSendTransactionDialog(
      BuildContext context,
      TextEditingController addressController,
      TextEditingController amountController,
      Balance balance,
      Function(String selectedCurrency, String amount, String address) onOK) {
    String selectedCurrency = 'BNB';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Send"),
            content: Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "${balance.bnb.toStringAsFixed(2)} BNB",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.green),
                      ),
                      Text(
                        "${balance.usdt.toStringAsFixed(2)} USDT",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.green),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Address"),
                  TextFormField(
                    controller: addressController,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Amount"),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedCurrency,
                        items: <String>['BNB', 'USDT'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCurrency = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  if (checkAmount(
                      selectedCurrency, amountController.text, balance)) {
                    onOK.call(selectedCurrency, amountController.text.trim(),
                        addressController.text.trim());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insufficient balance')),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  bool checkAmount(String currency, String amount, Balance balance) {
    double inputAmount = double.tryParse(amount) ?? 0;
    if (currency == 'BNB') {
      return inputAmount <= balance.bnb;
    } else if (currency == 'USDT') {
      return inputAmount <= balance.usdt;
    }
    return false;
  }

  Future<void> _send() {
    final Completer completer = Completer();
    final addressController = TextEditingController();
    final amountController = TextEditingController();
    if (_cubit.state.balance == null) {
      return Future.delayed(const Duration(seconds: 0));
    }
    showSendTransactionDialog(
        context, addressController, amountController, _cubit.state.balance!,
        (selectedCurrency, amount, address) async {
      try {
        if (address.isEmpty || amount.isEmpty) {
          return;
        }
        var ethAmount = double.tryParse(amount);
        if (ethAmount == null || ethAmount < 0) {
          return;
        }
        var tx;
        double scaledValue = ethAmount * pow(10, 18);
        double roundedValue = scaledValue.round().toDouble();
        if (selectedCurrency == "BNB") {
          tx = Transaction(
            to: EthereumAddress.fromHex(address),
            gasPrice: EtherAmount.fromBase10String(EtherUnit.gwei, "3"),
            maxGas: 21000,
            value: EtherAmount.inWei(BigInt.from(roundedValue)),
          );
        } else {
          tx = Transaction(
            to: EthereumAddress.fromHex(
                "0x337610d27c682E347C9cD60BD4b3b107C9d34dDd"),
            gasPrice: EtherAmount.fromBase10String(EtherUnit.gwei, "3"),
            maxGas: 100000,
            data: bep20.self.abi.functions[17].encodeCall([
              EthereumAddress.fromHex(address),
              EtherAmount.inWei(BigInt.from(roundedValue)).getInWei
            ]),
          );
        }
        if (_cubit.state.wallet == null) {
          return;
        }
        if (tx == null) {
          return;
        }
        final result = await ethClient.sendTransaction(
          _cubit.state.wallet!.privateKey,
          tx,
          chainId: 97,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tx hash: $result'),
          ),
        );
        completer.complete();
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${err.toString()}'),
          ),
        );
        completer.complete();
      }
    });
    return completer.future;
  }

  void _exchange() {}

  void _deposit() {
    if (_cubit.state.wallet == null) {
      return;
    }
    showQRCode(context, _cubit.state.wallet!.privateKey.address.hex);
  }

  void showQRCode(BuildContext context, String wallet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Address"),
          content: SizedBox(
            height: 300,
            width: 300,
            child: QrImageView(
              data: wallet,
              version: QrVersions.auto,
              size: 200,
              gapless: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
