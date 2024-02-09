class WalletModel {
  double balance;

  WalletModel({required this.balance});

  // Getter for the balance
  double getBalance() {
    return balance;
  }

  // Method to add funds
  void addFunds(double amount) {
    balance += amount;
  }
}