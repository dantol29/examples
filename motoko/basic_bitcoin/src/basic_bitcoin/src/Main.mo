import Text "mo:base/Text";

import BitcoinApi "BitcoinApi";
import P2pkh "P2pkh";
import P2trRawKeySpend "P2trRawKeySpend";
import P2trScriptSpend "P2trScriptSpend";
import Types "Types";
import Utils "Utils";

actor class BasicBitcoin(_network : Types.Network) {
  type GetUtxosResponse = Types.GetUtxosResponse;
  type MillisatoshiPerVByte = Types.MillisatoshiPerVByte;
  type SendRequest = Types.SendRequest;
  type Network = Types.Network;
  type BitcoinAddress = Types.BitcoinAddress;
  type Satoshi = Types.Satoshi;
  type TransactionId = Text;

  // The Bitcoin network to connect to.
  //
  // When developing locally this should be `regtest`.
  // When deploying to the IC this should be `testnet`.
  // `mainnet` is currently unsupported.
  stable let NETWORK : Network = _network;

  // The derivation path to use for ECDSA secp256k1.
  let DERIVATION_PATH : [[Nat8]] = [];

  // The ECDSA key name.
  let KEY_NAME : Text = switch NETWORK {
    // For local development, we use a special test key with dfx.
    case (#regtest) "dfx_test_key";
    // On the IC we're using a test ECDSA key.
    case _ "test_key_1";
  };

  /// Returns the balance of the given Bitcoin address.
  public func get_balance(address : BitcoinAddress) : async Satoshi {
    await BitcoinApi.get_balance(NETWORK, address);
  };

  /// Returns the UTXOs of the given Bitcoin address.
  public func get_utxos(address : BitcoinAddress) : async GetUtxosResponse {
    await BitcoinApi.get_utxos(NETWORK, address);
  };

  /// Returns the 100 fee percentiles measured in millisatoshi/vbyte.
  /// Percentiles are computed from the last 10,000 transactions (if available).
  public func get_current_fee_percentiles() : async [MillisatoshiPerVByte] {
    await BitcoinApi.get_current_fee_percentiles(NETWORK);
  };

  /// Returns the P2PKH address of this canister at a specific derivation path.
  public func get_p2pkh_address() : async BitcoinAddress {
    await P2pkh.get_address(NETWORK, KEY_NAME, DERIVATION_PATH);
  };

  /// Sends the given amount of bitcoin from this canister to the given address.
  /// Returns the transaction ID.
  public func send_from_p2pkh_address(request : SendRequest) : async TransactionId {
    Utils.bytesToText(await P2pkh.send(NETWORK, DERIVATION_PATH, KEY_NAME, request.destination_address, request.amount_in_satoshi));
  };

  public func get_p2tr_raw_key_spend_address() : async BitcoinAddress {
    await P2trRawKeySpend.get_address(NETWORK, KEY_NAME, DERIVATION_PATH);
  };

  public func send_from_p2tr_raw_key_spend_address(request : SendRequest) : async TransactionId {
    Utils.bytesToText(await P2trRawKeySpend.send(NETWORK, DERIVATION_PATH, KEY_NAME, request.destination_address, request.amount_in_satoshi));
  };

  public func get_p2tr_script_spend_address() : async BitcoinAddress {
    await P2trScriptSpend.get_address(NETWORK, KEY_NAME, DERIVATION_PATH);
  };

  public func send_from_p2tr_script_spend_address(request : SendRequest) : async TransactionId {
    Utils.bytesToText(await P2trScriptSpend.send(NETWORK, DERIVATION_PATH, KEY_NAME, request.destination_address, request.amount_in_satoshi));
  };
};
