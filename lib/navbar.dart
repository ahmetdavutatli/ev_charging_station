import 'package:ev_charging_station/pages/login_page.dart';
import 'package:ev_charging_station/pages/profile_details_page.dart';
import 'package:ev_charging_station/pages/transaction_page.dart';
import 'package:ev_charging_station/pages/wallet_page.dart';
import 'package:ev_charging_station/services/wallet_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'language.dart';

class NavBar extends StatelessWidget {
  final Auth auth;

  NavBar({Key? key, required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Language> languages = Language.languageList();

    return Drawer(
      backgroundColor: Color(0xff262930),
      child: FutureBuilder(
        future: fetchData(), // Function to fetch data from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while fetching data
          } else {
            String accountName = snapshot.data?['name'];

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150',
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            accountName ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      _buildLanguageDropdown(languages),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileDetailsPage(auth: auth)),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.account_circle),
                            title: Text(
                              AppLocalizations.of(context)!.profileDetails,
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletPage(
                                    auth: auth,
                                    walletService: WalletService(auth: auth))),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.wallet),
                            title: Text(
                              AppLocalizations.of(context)!.wallet,
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          // Navigate to Transactions Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TransactionPage()),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.access_time_filled),
                            title: Text(
                              AppLocalizations.of(context)!.transactions,
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 20, color: Colors.lightGreen),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          // Navigate to About Us Page
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.info),
                            title: Text(
                              AppLocalizations.of(context)!.aboutUs,
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          // Navigate to Privacy and Complience Page
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.lock),
                            title: Text(
                              AppLocalizations.of(context)!.privacyPolicy,
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  // Wrap the ListTile in a Container to apply custom styling
                  tileColor: Colors.transparent,
                  // Set tileColor to transparent so the gradient background is visible
                  onTap: () async {
                    await auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(auth: Auth())),
                    );
                  },
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  // Adjust padding as needed
                  title: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      // Set the border radius as needed
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        // Set your gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text(
                        AppLocalizations.of(context)!.logout,
                        style: TextStyle(
                            color: Colors
                                .white), // Set text color to contrast with the gradient background
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLanguageDropdown(List<Language> languages) {
    return Builder(
      builder: (BuildContext context) {
        LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context);

        return PopupMenuButton<Language>(
          icon: Icon(Icons.language, color: Colors.white),
          onSelected: (Language selectedLanguage) {
            languageProvider.changeLanguage(
                Locale(selectedLanguage.languageCode));
            print('Selected language: ${selectedLanguage.languageCode}');
          },
          itemBuilder: (BuildContext context) => languages
              .map((Language language) => PopupMenuItem<Language>(
            value: language,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      language.flag,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      language.name,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                if (languageProvider.currentLocale.languageCode ==
                    language.languageCode)
                  Icon(Icons.check, color: Colors.green),
              ],
            ),
          ))
              .toList(),
        );
      },
    );
  }



  Future<Map<String, dynamic>> fetchData() async {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Use Firestore to get user data based on the current user's UID
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      return documentSnapshot.data()!;
    } else {
      // Handle the case when there is no current user
      return {};
    }
  }
}
