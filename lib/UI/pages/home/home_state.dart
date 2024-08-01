part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({this.wallet, this.balance, this.txs = const []});

  final Wallet? wallet;
  final Balance? balance;
  final List<TxData> txs;

  @override
  List<Object?> get props => [wallet, balance, txs];

  HomeState copyWith({Wallet? wallet, Balance? balance, List<TxData>? txs}) {
    return HomeState(
      wallet: wallet ?? this.wallet,
      balance: balance ?? this.balance,
      txs: txs ?? this.txs,
    );
  }
}

class Balance {
  double bnb;
  double usdt;

  Balance(
    this.bnb,
    this.usdt,
  );
}

class TxData {
  String txHash;
  String nonce;
  int timestamp;

  TxData({
    required this.timestamp,
    required this.txHash,
    required this.nonce,
  });

  factory TxData.fromJson(Map<String, dynamic> json) {
    return TxData(
        txHash: json['hash'],
        nonce: json['nonce'],
        timestamp: int.tryParse(json['timeStamp']) ??
            DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }
}
