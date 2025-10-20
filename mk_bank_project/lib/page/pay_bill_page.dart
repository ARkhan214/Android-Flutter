import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/service/account_service.dart';

// ⚠️ আপনার আসল ফাইল পাথ অনুযায়ী অন্যান্য পেজগুলো ইম্পোর্ট করুন
import 'credit_card_bill_page.dart';
import 'electricity_bill_page.dart';
import 'water_bill_page.dart';
import 'gas_bill_page.dart';
import 'internet_bill_page.dart';


// ----------------------------------------------------------------------
// 1. MenuOption মডেল (Cleaner Code-এর জন্য ব্যবহার করা হলো)
// ----------------------------------------------------------------------

class MenuOption {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;

  const MenuOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.page,
  });
}

// ----------------------------------------------------------------------
// 2. বিল পেমেন্ট অপশন ডেটা (সহজে নতুন অপশন যোগ করুন)
// ----------------------------------------------------------------------

final List<MenuOption> billPaymentOptions = [
  // সব আইকন এবং কালারকে আলাদা করা হলো AccountsProfile-এর মতো দেখতে
  const MenuOption(
    title: 'Credit Card Bill',
    icon: Icons.credit_card,
    color: Color(0xFFE91E63), // kPrimaryPink
    page: CreditCardBillPage(),
  ),
  const MenuOption(
    title: 'Electricity Bill',
    icon: Icons.flash_on,
    color: Color(0xFFE8112D), // kSecondaryRed
    page: ElectricityBillPage(),
  ),
  const MenuOption(
    title: 'Water Bill',
    icon: Icons.water_drop,
    color: Color(0xFF0dcaf0), // Bootstrap Info Blue
    page: WaterBillPage(),
  ),
  const MenuOption(
    title: 'Gas Bill',
    icon: Icons.local_fire_department,
    color: Color(0xFF0d6efd), // Bootstrap Primary Blue
    page: GasBillPage(),
  ),
  const MenuOption(
    title: 'Internet Bill',
    icon: Icons.language,
    color: Colors.teal, // Teal
    page: InternetBillPage(),
  ),
  // আপনি এখানে সহজে নতুন অপশন যোগ করতে পারেন
  const MenuOption(
    title: 'DTH/Cable TV',
    icon: Icons.live_tv,
    color: Colors.purple,
    page: CreditCardBillPage(), // Placeholder
  ),
  const MenuOption(
    title: 'Education Fees',
    icon: Icons.book,
    color: Colors.orange,
    page: CreditCardBillPage(), // Placeholder
  ),
];

// ----------------------------------------------------------------------
// 3. PayBillPage উইজেট (AccountsProfile স্টাইল)
// ----------------------------------------------------------------------

class PayBillPage extends StatefulWidget {
  const PayBillPage({super.key});

  @override
  State<PayBillPage> createState() => _PayBillPageState();
}

class _PayBillPageState extends State<PayBillPage> {
  late AccountService accountService;

  // AccountsProfile-এর মতো responsiveness-এর জন্য
  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // AccountsProfile-এর মতো 4 কলাম ব্যবহার করা হলো
    if (width > 800) {
      return 5;
    } else {
      return 4; // মোবাইল এবং ছোট স্ক্রিনের জন্য 4 কলাম
    }
  }


  @override
  void initState() {
    accountService = AccountService();
  } // Helper Widget for a single Menu Item (AccountsProfile-এর _buildMenuItem-এর মতো)
  Widget _buildMenuItem(BuildContext context, MenuOption option, double fontScale) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => option.page));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12 * fontScale),
            decoration: BoxDecoration(
              color: option.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(option.icon, size: 25 * fontScale, color: option.color),
          ),
          SizedBox(height: 5 * fontScale),
          Expanded(
            child: Text(
              option.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12 * fontScale,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontScale = screenWidth / 390;

    return Scaffold(

      // appBar: AppBar(
      //   title: const Text('পে বিল'),
      //   backgroundColor: Colors.indigo,
      //   elevation: 0, // AccountsProfile-এর ডিজাইনের সাথে মিল রাখার জন্য
      // ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        // Title
        title: Text(
          'Bill Payment Service',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xffd63384), // Deep Pink
          ),
        ),
        centerTitle: true,

        // Leading: The back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // Little padding
          child: IconButton(
            icon:  const Icon(Icons.arrow_back_rounded, // A softer, modern back icon
              color: Color(0xFFFD8E3D),
              size: 28,
            ), // Orange accent color

            onPressed: () async{
              final profile = await accountService.getAccountsProfile();
              if (profile != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountsProfile(profile: profile),
                  ),
                );
              }
            },
          ),
        ),
      ),
      //=====

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // একটি ছোট স্পেসার বা মেনু হেডার যোগ করা যেতে পারে
            // Container(
            //   padding: EdgeInsets.symmetric(vertical: 15 * fontScale, horizontal: 16),
            //   child: Text(
            //     'বিল পেমেন্ট সার্ভিসেস',
            //     style: TextStyle(
            //       fontSize: 18 * fontScale,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black87,
            //     ),
            //   ),
            // ),

            // ------------------ বিল মেনু গ্রিড ------------------
            Padding(
              // AccountsProfile-এর মেনুর মতো করে প্যাডিং ব্যবহার করা হলো
              padding: EdgeInsets.symmetric(horizontal: 10 * fontScale, vertical: 10 * fontScale),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // ScrollView এর ভিতরে ফিক্স
                shrinkWrap: true,
                itemCount: billPaymentOptions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  childAspectRatio: 0.75, // AccountsProfile-এর মতো Aspect Ratio
                  crossAxisSpacing: 5 * fontScale,
                  mainAxisSpacing: 10 * fontScale,
                ),
                itemBuilder: (context, index) {
                  final option = billPaymentOptions[index];
                  return _buildMenuItem(context, option, fontScale);
                },
              ),
            ),

            SizedBox(height: 20 * fontScale),
          ],
        ),
      ),
    );
  }
}