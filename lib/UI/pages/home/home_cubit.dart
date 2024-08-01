import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crypto_wallet/abis/BEP20.g.dart';
import 'package:crypto_wallet/abis/BEP20.g.dart';
import 'package:crypto_wallet/abis/PancakeSwapRouter.g.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';

import 'package:web3dart/web3dart.dart';

part 'home_state.dart';

var apiUrl =
    "https://data-seed-prebsc-1-s1.binance.org:8545/"; //Replace with your API

var httpClient = Client();
var ethClient = Web3Client(apiUrl, httpClient);
final BEP20 bep20 = BEP20(
    address:
        EthereumAddress.fromHex("0x337610d27c682E347C9cD60BD4b3b107C9d34dDd"),
    client: ethClient);

final PancakeSwapRouter pancakeSwapRouter = PancakeSwapRouter(
    address:
        EthereumAddress.fromHex("0xd77c2afebf3dc665af07588bf798bd938968c72e"),
    client: ethClient);

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void updateWallet(Wallet wallet) {
    emit(state.copyWith(wallet: wallet));
    getBalanceOfAddress(wallet.privateKey.address.hex);
    updateTxData(wallet.privateKey.address.hex);
  }

  Future<void> updateTxData(String address) async {
    List<TxData> data = await getTransactionsOfAddress(address);
    emit(state.copyWith(txs: data));
  }

  Future<void> refresh() async {
    if (state.wallet == null) {
      return;
    }
    await getBalanceOfAddress(state.wallet!.privateKey.address.hex);
    await updateTxData(state.wallet!.privateKey.address.hex);
  }

  Future<void> getBalanceOfAddress(String address) async {
    EtherAmount ethBalance =
        await ethClient.getBalance(EthereumAddress.fromHex(address));
    final usdtBalance =
        await bep20.balanceOf((account: EthereumAddress.fromHex(address)));
    final ethAmount = double.tryParse(weiToEth(ethBalance.getInWei.toString()));
    if (ethAmount == null) {
      return;
    }

    final usdtAmount = double.tryParse(weiToEth(usdtBalance.toString()));
    if (usdtAmount == null) {
      return;
    }
    final balance = Balance(ethAmount, usdtAmount);
    emit(
      state.copyWith(balance: balance),
    );
  }

  Future<List<TxData>> getTransactionsOfAddress(String address) async {
    final dio = Dio();
    const String apiUrl = 'https://api-testnet.bscscan.com/api';
    try {
      final response = await dio.get(
        apiUrl,
        queryParameters: {
          'module': 'account',
          'action': 'txlist',
          'address': address,
          'startblock': '0',
          'endblock': '99999999',
          'page': '1',
          'offset': '50',
          'sort': 'desc',
          'apikey': 'WP1Z38V6BIIS1HHAHMA6AQ4YCYCKWQZUJ4',
        },
      );

      if (response.statusCode == 200) {
        return (response.data["result"] as List)
            .map((e) => TxData.fromJson(e))
            .toList();
      } else {
        print(
            'Failed to fetch transactions. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<bool> checkStatusPendingTransaction(String txHash) async {
    final dio = Dio();
    const String apiUrl = 'https://api-testnet.bscscan.com/api';
    try {
      final response = await dio.get(
        apiUrl,
        queryParameters: {
          'module': 'transaction',
          'action': 'gettxreceiptstatus',
          'txhash': txHash,
          'apikey': 'WP1Z38V6BIIS1HHAHMA6AQ4YCYCKWQZUJ4',
        },
      );

      if (response.statusCode == 200) {
        return response.data["result"]["status"] == "1";
      } else {
        return false;
      }
    } catch (e) {
      return true;
    }
  }
}

String weiToEth(String weiAmount) {
  final wei = Decimal.parse(weiAmount);
  final weiPerEth = Decimal.parse('1000000000000000000');
  final ethAmount = wei / weiPerEth;
  return ethAmount.toDecimal().toString();
}
