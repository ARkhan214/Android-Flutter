import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ** Import the carousel_slider package **
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mk_bank_project/account/profile_page.dart';
import 'package:mk_bank_project/page/credit_card_bill_page.dart';
import 'package:mk_bank_project/page/dps_page.dart';
import 'package:mk_bank_project/page/electricity_bill_page.dart';
import 'package:mk_bank_project/page/fixed_deposit_page.dart';
import 'package:mk_bank_project/page/gas_bill_page.dart';
import 'package:mk_bank_project/page/internet_bill_page.dart';
import 'package:mk_bank_project/page/last_transaction_statement_page.dart';
import 'package:mk_bank_project/page/loan_apply_page.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:mk_bank_project/page/mobile_recharge_page.dart';
import 'package:mk_bank_project/page/pay_bill_page.dart';
import 'package:mk_bank_project/page/pay_dps_page.dart';
import 'package:mk_bank_project/page/pay_loan_page.dart';
import 'package:mk_bank_project/page/statement_page.dart';
import 'package:mk_bank_project/page/transfer_money_page.dart';
import 'package:mk_bank_project/page/view_all_dps_page.dart';
import 'package:mk_bank_project/page/view_fixed_deposit_page.dart';
import 'package:mk_bank_project/page/view_loan_page.dart';
import 'package:mk_bank_project/page/view_policy_page.dart';
import 'package:mk_bank_project/page/water_bill_page.dart';
import 'package:mk_bank_project/page/withdraw_page.dart';
import 'package:mk_bank_project/service/authservice.dart';

// ----------------------------------------------------------------------
// Custom Color Setup (Matching the bKash-like UI)
// ----------------------------------------------------------------------

// Primary Pink Color
const Color kPrimaryPink = Color(0xFFE91E63);
// Secondary Reddish/Orange Color
const Color kSecondaryRed = Color(0xFFE8112D);
// Yellow for offers/highlights
const Color kAccentYellow = Color(0xFFF9B208);

// ----------------------------------------------------------------------

// Changed to StatefulWidget to manage balance visibility
class AccountsProfile extends StatefulWidget {
  final Map<String, dynamic> profile;

  const AccountsProfile({
    super.key,
    required this.profile,
  }); // ** FIX 1: Colon (:) removed and changed to dot (.) **

  @override
  State<AccountsProfile> createState() => _AccountsProfileState();
}

class _AccountsProfileState extends State<AccountsProfile> {
  final AuthService _authService =
      AuthService(); // ** FIX 2: Added const for AuthService initialization **

  // State to manage balance visibility
  bool _showBalance = false;

  // ** NEW STATE: To manage the visibility of the full menu **
  bool _showFullMenu = false;

  // Image URLs for the Carousel (Now used in _buildCarouselPlaceholder)
  final List<String> carouselImageUrls = const [
    // ** FIX 3: Added const to the list initialization **
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkionStkOAGZhKzpA9hGZaE86WOoovUE78PA&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsUEUO1fH9kKByWeZ2ruXkcUe18kIJhDNmYg&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_lq2Naa6vSwErDy2s7I70MttZyNwb7nzD8g&s',
  ];

  // List of all menu items (Total 12 items as per your images)
  final List<Map<String, dynamic>> _allMenuItems = const [
    // ** FIX 4: Added const to the list initialization **
    {
      'title': 'ট্রান্সফার মানি',
      'icon': Icons.send_outlined,
      'color': Colors.redAccent,
      'page': const TransferMoneyPage(),
    },
    {
      'title': 'স্টেটমেন্ট',
      'icon': Icons.description_outlined,
      'color': Colors.teal,
      'page': const StatementPage(),
    },
    {
      'title': 'শেষ লেনদেন',
      'icon': Icons.receipt_outlined,
      'color': Colors.deepOrange,
      'page': const LastTransactionStatementPage(),
    },

    //{'title': 'ক্যাশ আউট', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.teal, 'page': const WithdrawPage()},
    {
      'title': 'মোবাইল রিচার্জ',
      'icon': Icons.phone_android,
      'color': Colors.lightGreen,
      'page': const MobileRechargePage(),
    },
    // ** Fixed Deposit এবং DPS যোগ করা হলো **
    {
      'title': 'ফিক্সড ডিপোজিট',
      'icon': Icons.lock_clock_outlined,
      'color': Colors.deepOrange,
      'page': const FixedDepositPage(),
    },
    // Fixed Deposit
    {
      'title': 'ভিউ ফিক্সড ডিপোজিট',
      'icon': Icons.view_agenda_outlined,
      'color': Colors.brown,
      'page': const ViewFixedDepositPage(),
    },
    // Fixed Deposit
    {
      'title': 'ডিপিএস',
      'icon': Icons.savings_outlined,
      'color': Colors.pink,
      'page': const DPSPage(),
    },

    {
      'title': 'ভিউ ডিপিএস',
      'icon': Icons.visibility,
      'color': Colors.indigo,
      'page': const ViewAllDPSPage(),
    },

    {
      'title': 'পে ডিপিএস',
      'icon': Icons.payment,
      'color': Colors.indigo,
      'page': const PayDpsPage(),
    },

    // DPS (আপাতত WithdrawPage ব্যবহার করা হলো)
    {
      'title': 'লোন',
      'icon': Icons.request_page_outlined,
      'color': Colors.brown,
      'page': const LoanApplyPage(),
    },
    {
      'title': 'ভিউ লোন',
      'icon': Icons.description,
      'color': Colors.brown,
      'page': const ViewLoanPage(),
    },
    {
      'title': 'পে লোন',
      'icon': Icons.receipt_long,
      'color': Colors.brown,
      'page': const PayLoanPage(),
    },

    // {
    //   'title': 'পেমেন্ট',
    //   'icon': Icons.payment_outlined,
    //   'color': Colors.purpleAccent,
    //   'page': const WithdrawPage(),
    // },
    // {
    //   'title': 'অ্যাড মানি',
    //   'icon': Icons.add_card,
    //   'color': Colors.blueAccent,
    //   'page': const TransferMoneyPage(),
    // },
    {
      'title': 'পে বিল',
      'icon': Icons.lightbulb_outline,
      'color': Colors.indigo,
      'page': const PayBillPage(),
    },
    //
    // {'title': 'Credit Card Bill', 'icon': Icons.lightbulb_outline, 'color': Colors.indigo, 'page': const CreditCardBillPage()},
    // {'title': 'Electricity Bill', 'icon': Icons.lightbulb_outline, 'color': Colors.indigo, 'page': const ElectricityBillPage()},
    // {'title': 'Water Bill', 'icon': Icons.lightbulb_outline, 'color': Colors.indigo, 'page': const WaterBillPage()},
    // {'title': 'Gas Bill', 'icon': Icons.lightbulb_outline, 'color': Colors.indigo, 'page': const GasBillPage()},
    // {'title': 'Internet Bill', 'icon': Icons.lightbulb_outline, 'color': Colors.indigo, 'page': const InternetBillPage()},
    //
    // {
    //   'title': 'সেভিংস',
    //   'icon': Icons.savings_outlined,
    //   'color': Colors.pink,
    //   'page': const WithdrawPage(),
    // },

    // ** Extra 4 items for the 'See More' section **
    // {
    //   'title': 'ইনস্যুরেন্স',
    //   'icon': Icons.health_and_safety_outlined,
    //   'color': Colors.cyan,
    //   'page': const WithdrawPage(),
    // },

    {
      'title': 'ইনস্যুরেন্স',
      'icon': Icons.health_and_safety_outlined,
      'color': Colors.cyan,
      'page': const ViewPolicyPage(),
    },

    // {
    //   'title': 'বিকাশ টু ব্যাংক',
    //   'icon': Icons.account_balance_outlined,
    //   'color': Colors.green,
    //   'page': const WithdrawPage(),
    // },
    // {
    //   'title': 'এডুকেশন ফি',
    //   'icon': Icons.book_outlined,
    //   'color': Colors.orange,
    //   'page': const WithdrawPage(),
    // },
    // {
    //   'title': 'মাইক্রোফাইন্যান্স',
    //   'icon': Icons.paid_outlined,
    //   'color': Colors.deepPurple,
    //   'page': const WithdrawPage(),
    // },

    // You can add more items if needed for the third row, but we'll stick to 12 for 3 rows of 4
  ];

  @override
  Widget build(BuildContext context) {
    // Access profile using widget.profile
    final double screenWidth = MediaQuery.of(context).size.width;
    // ** Optimized fontScale **
    final double fontScale = screenWidth / 390;

    final String baseUrl = "http://localhost:8085/images/account/";
    final String? photoName = widget.profile['photo'];
    final String? photoUrl = (photoName != null && photoName.isNotEmpty)
        ? "$baseUrl$photoName"
        : null;

    // ... (balance and status logic is unchanged) ...
    final String id = widget.profile['id'].toString();
    final String balance =
        widget.profile['balance']?.toStringAsFixed(2) ?? '0.00';
    final String maskedBalance = '৳ *****';
    final String displayBalance = _showBalance ? '৳ $balance' : maskedBalance;

    final bool isActive = widget.profile['accountActiveStatus'] == true;
    final String statusText = isActive ? 'Active' : 'Inactive';
    final Color statusColor = isActive
        ? Colors.green.shade600
        : Colors.red.shade600;

    return WillPopScope(
      onWillPop: () async {
        // ** FIX 5: Added return type casting for WillPopScope **
        Navigator.pop(context, true);
        return Future.value(false); // Should return Future<bool>
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        // ** Used Builder to get a context that can open the Drawer **
        body: Builder(
          builder: (context) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ** 1. Top Header Section (Pass context for Drawer opening) **
                  _buildTopHeader(context, photoUrl, fontScale),

                  // ** 2. Dashboard Menu Icons **
                  _buildDashboardMenu(context, fontScale),

                  // ** 3. See More Button **
                  _buildSeeMoreButton(fontScale),

                  const Divider(height: 1, thickness: 0.5, color: Colors.grey),

                  const SizedBox(height: 10),

                  // ** 4. Carousel Slider Section (Now implemented) **
                  _buildCarouselSlider(fontScale),

                  // Changed function name
                  const SizedBox(height: 20),

                  // ** 5. Offer/Shortcut Section **
                  _buildOfferShortcutSection(fontScale),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),

        // ** Drawer Menu (Used your provided Drawer code structure) **
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                // Note: Replaced primaryColor.shade700 with kPrimaryPink
                decoration: const BoxDecoration(color: kPrimaryPink),
                // ** FIX 6: Added const here **
                accountName: Text(
                  widget.profile['name'] ?? 'Unknown User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17 * fontScale,
                  ),
                ),
                accountEmail: Text(
                  widget.profile['user']?['email'] ?? 'N/A',
                  style: TextStyle(fontSize: 14 * fontScale),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: (photoUrl != null)
                        ? NetworkImage(photoUrl)
                        : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                  ),
                ),
              ),
              ListTile(
                // Note: Replaced primaryColor with kPrimaryPink
                leading: const Icon(Icons.person, color: kPrimaryPink),
                title: Text(
                  'View Profile',
                  style: TextStyle(fontSize: 15 * fontScale),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              ListTile(
                // Note: Replaced accentColor with kSecondaryRed
                leading: const Icon(Icons.logout, color: kSecondaryRed),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: kSecondaryRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * fontScale,
                  ),
                ),
                onTap: () async {
                  await _authService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(),
                    ), // ** FIX 7: Added const here **
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ 1. Top Header Section ------------------
  // Includes Profile Photo (Now clickable to open Drawer)
  Widget _buildTopHeader(
    BuildContext context,
    String? photoUrl,
    double fontScale,
  ) {
    return Container(
      // ** Using fixed padding for edge responsiveness **
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        20,
      ),
      color: kPrimaryPink, // Pink background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ** Profile Photo (Clickable for Drawer) **
              GestureDetector(
                // ** FIX: Added onTap to open the drawer when photo is clicked **
                onTap: () => Scaffold.of(context).openDrawer(),
                child: CircleAvatar(
                  radius: 25 * fontScale,
                  backgroundColor: Colors.white,
                  backgroundImage: (photoUrl != null)
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                ),
              ),
              // ** Top Right Icons **
              Row(
                children: [
                  Icon(
                    Icons.star_border,
                    color: Colors.white,
                    size: 24 * fontScale,
                  ),
                  SizedBox(width: 15 * fontScale),
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 24 * fontScale,
                  ),
                  SizedBox(width: 5 * fontScale),
                ],
              ),
            ],
          ),

          SizedBox(height: 10 * fontScale),

          // ** Name and Balance Section **
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ** User Name **
              Text(
                widget.profile['name'] ?? 'MK Bank User',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // ** Notification Icon **
              Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 24 * fontScale,
              ),
            ],
          ),
          SizedBox(height: 10 * fontScale),
          Row(
            children: [
              Text(
                'Account ID - ',
                style: GoogleFonts.poppins(
              color: Colors.white, // লেবেল হালকা সাদা রং
                fontSize: 18 * fontScale, // ছোট ফন্ট সাইজ
                fontWeight: FontWeight.w400
          )
              ),
              Text(
                // ✅ activeProfile থেকে 'id' ব্যবহার করা হলো এবং স্ট্রিং এ রূপান্তর করা হলো
                widget.profile['id']?.toString() ?? 'ID: N/A',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * fontScale),

          // ** Balance Section with Hide/Show Functionality **
          GestureDetector(
            onTap: () {
              setState(() {
                _showBalance = !_showBalance;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * fontScale,
                vertical: 8 * fontScale,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20 * fontScale),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showBalance
                        ? '৳ ${widget.profile['balance']?.toStringAsFixed(2) ?? '0.00'}'
                        : '৳ *****',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8 * fontScale),

                  Text(
                    "ব্যালেন্স দেখুন", // "View Balance" in Bangla
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14 * fontScale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Icon(
                    _showBalance ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                    size: 18 * fontScale,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ 2. Dashboard Menu Icons (Toggleable) ------------------
  Widget _buildDashboardMenu(BuildContext context, double fontScale) {
    // Show 8 items by default, or all items if _showFullMenu is true
    final int itemCount = _showFullMenu ? _allMenuItems.length : 8;
    final List<Map<String, dynamic>> displayedItems = _allMenuItems.sublist(
      0,
      itemCount,
    );

    return Padding(
      // ** Responsive Padding **
      padding: EdgeInsets.symmetric(
        horizontal: 10 * fontScale,
        vertical: 10 * fontScale,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        // Disable GridView scrolling
        shrinkWrap: true,
        itemCount: displayedItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          // ** Optimized Aspect Ratio for better fit on small screens **
          childAspectRatio: 0.75, // Changed from 0.8 to 0.75
          crossAxisSpacing: 5 * fontScale,
          mainAxisSpacing: 10 * fontScale,
        ),
        itemBuilder: (context, index) {
          final item = displayedItems[index];
          return _buildMenuItem(
            context,
            item['title'] as String, // Type cast added for safety
            item['icon'] as IconData, // Type cast added for safety
            item['color'] as Color, // Type cast added for safety
            fontScale,
            item['page'] as Widget, // Type cast added for safety
          );
        },
      ),
    );
  }

  // Helper Widget for a single Menu Item
  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    double fontScale,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12 * fontScale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25 * fontScale, color: color),
          ),
          SizedBox(height: 5 * fontScale),
          // ** MaxLines added to prevent overflow on small screens **
          Expanded(
            child: Text(
              title,
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

  // ------------------ 3. See More Button (Toggle Logic) ------------------
  Widget _buildSeeMoreButton(double fontScale) {
    // Only show the button if there are more items to show (total items > 8)
    if (_allMenuItems.length <= 8) return const SizedBox.shrink();

    final String buttonText = _showFullMenu ? "বন্ধ করুন" : "আরো দেখুন";
    final IconData buttonIcon = _showFullMenu
        ? Icons.keyboard_arrow_up
        : Icons.keyboard_arrow_down;

    return Padding(
      // ** Responsive Vertical Padding **
      padding: EdgeInsets.symmetric(vertical: 5 * fontScale),
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _showFullMenu = !_showFullMenu; // Toggle the state
          });
        },
        icon: Icon(buttonIcon, size: 20 * fontScale, color: kPrimaryPink),
        label: Text(
          buttonText,
          style: TextStyle(
            color: kPrimaryPink,
            fontWeight: FontWeight.bold,
            fontSize: 14 * fontScale,
          ),
        ),
      ),
    );
  }

  // ------------------ 4. Carousel Slider Implementation ------------------
  Widget _buildCarouselSlider(double fontScale) {
    return Padding(
      // ** Removed Padding/Margin from here as CarouselOptions handles it (ViewportFraction)**
      padding: EdgeInsets.zero,
      child: CarouselSlider(
        options: CarouselOptions(
          // ** Height scaled **
          height: 120 * fontScale,
          autoPlay: true,
          enlargeCenterPage: true,
          // ** Keeps 90% of screen width **
          viewportFraction: 0.9,
          autoPlayInterval: const Duration(seconds: 4),
          // Added a standard interval
          aspectRatio: 2.0,
        ),
        items: carouselImageUrls.map((imageUrl) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                // ** Fixed horizontal margin for spacing between cards **
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: kPrimaryPink,
                              ),
                            ),
                          );
                        },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // ------------------ 5. Offer/Shortcut Section ------------------
  Widget _buildOfferShortcutSection(double fontScale) {
    return Padding(
      // ** Responsive horizontal padding **
      padding: EdgeInsets.symmetric(horizontal: 16 * fontScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "আমার অফারস", // "My Offers" in Bangla
                style: GoogleFonts.poppins(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.edit,
                  size: 16 * fontScale,
                  color: Colors.grey.shade600,
                ),
                label: Text(
                  "এডিট", // "Edit" in Bangla
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),

          SizedBox(height: 10 * fontScale),

          // ** Horizontal List of Shortcuts (as seen in the image) **
          SizedBox(
            // ** Height scaled **
            height: 110 * fontScale,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildShortcutCard(
                  "মাই অফারস\নদেখতে ট্যাপ করুন",
                  Icons.card_giftcard,
                  kPrimaryPink,
                  fontScale,
                ),
                // ** Fixed gap for consistent spacing (better than scaled) **
                const SizedBox(width: 15),
                _buildShortcutCard(
                  "NSI Ass. Direct...",
                  Icons.access_time_filled,
                  Colors.lightGreen,
                  fontScale,
                ),
                const SizedBox(width: 15),
                _buildShortcutCard(
                  "বিকাশ বান্ডেল",
                  Icons.shopping_basket_outlined,
                  Colors.purple,
                  fontScale,
                ),
                const SizedBox(width: 15),
                _buildShortcutCard(
                  "জিপি মাই অফার",
                  Icons.local_offer_outlined,
                  Colors.blue,
                  fontScale,
                ),
                const SizedBox(width: 15), // End padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Shortcut Cards
  Widget _buildShortcutCard(
    String title,
    IconData icon,
    Color iconColor,
    double fontScale,
  ) {
    return Container(
      // ** Minimized width scaling to allow more flexibility with ListView **
      width: 100 * fontScale,
      padding: EdgeInsets.all(8 * fontScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, color: iconColor, size: 24 * fontScale),
          ),
          SizedBox(height: 10 * fontScale),
          Text(
            title,
            // ** Added maxLines and overflow for responsiveness **
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
