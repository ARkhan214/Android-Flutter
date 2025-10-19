import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/entity/fixed_deposit.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/fixed_deposit_service.dart';

// The class name has been changed from ViewAllFdScreen to ViewFixedDepositPage.
class ViewFixedDepositPage extends StatefulWidget {
  const ViewFixedDepositPage({super.key});

  @override
  State<ViewFixedDepositPage> createState() => _ViewFixedDepositPageState();
}

class _ViewFixedDepositPageState extends State<ViewFixedDepositPage> {
  final FixedDepositService _fdService = FixedDepositService();
  late Future<List<FixedDepositForView>> _futureFds;
  late AccountService accountService;

  @override
  void initState() {
    super.initState();
    _futureFds = _fdService.getMyFD().then((fds) {
      // Logic for sorting 'CLOSED' FDs to the end
      fds.sort((a, b) {
        if (a.status == 'CLOSED' && b.status != 'CLOSED') {
          return 1;
        } else if (a.status != 'CLOSED' && b.status == 'CLOSED') {
          return -1;
        }
        // Sort by ID otherwise
        return a.id.compareTo(b.id);
      });
      return fds;
    });
    accountService = AccountService();
  }

  // Equivalent to Angular's loadFDs()
  void _loadFDs() {
    setState(() {
      _futureFds = _fdService.getMyFD().then((fds) {
        // Sorting logic applied after loading
        fds.sort((a, b) {
          if (a.status == 'CLOSED' && b.status != 'CLOSED') {
            return 1;
          } else if (a.status != 'CLOSED' && b.status == 'CLOSED') {
            return -1;
          }
          return a.id.compareTo(b.id);
        });
        return fds;
      });
    });
  }

  // Equivalent to Angular's confirmClose()
  Future<void> _confirmClose(int fdId, int? accountId) async {
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account ID not available!')),
      );
      return;
    }

    // Confirmation Dialogue
    bool confirmResult = (await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Closure'),
        content: Text('Are you sure you want to close FD #$fdId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close'),
          ),
        ],
      ),
    )) ??
        false; // Handle null result from dialog

    if (confirmResult == true) {
      try {
        await _fdService.closeFD(fdId, accountId);
        _loadFDs(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FD closed successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('My Fixed Deposits'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final profile = await accountService.getAccountsProfile();
            if (profile != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountsProfile(profile: profile),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to load profile for back navigation.')),
              );
            }
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final profile = await accountService.getAccountsProfile();
              if (profile != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountsProfile(profile: profile),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to load user profile or profile is null.')),
                );
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<List<FixedDepositForView>>(
        future: _futureFds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Added padding for better look on small screens
                child: Text(
                  snapshot.error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center, // Center text on small screens
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Fixed Deposits found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          } else if (snapshot.hasData) {
            final fds = snapshot.data!;
            // Responsive Grid View logic is already robust using LayoutBuilder
            return LayoutBuilder(
              builder: (context, constraints) {
                // Adaptive crossAxisCount based on screen width
                int crossAxisCount = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 600
                    ? 2
                    : 1;

                return GridView.builder(
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    // Adjusted childAspectRatio for smaller, wider cards, suitable for responsiveness
                    //childAspectRatio: crossAxisCount == 1 ? 4.5 / 3.0 : 3.0 / 2.5,
                   // childAspectRatio: crossAxisCount == 1 ? 4.5 / 3.8 : 3.0 / 2.8,


                  ),
                  itemCount: fds.length,
                  itemBuilder: (context, index) {
                    final fd = fds[index];
                    return _buildFdCard(fd, crossAxisCount == 1); // Pass crossAxisCount check to card
                  },
                );
              },
            );
          }
          return const Center(child: Text('An unexpected error occurred.'));
        },
      ),
    );
  }

  // Modified _buildFdCard to take a flag for single column mode
  Widget _buildFdCard(FixedDepositForView fd, bool isSingleColumn) {
    Color statusColor;
    switch (fd.status) {
      case 'ACTIVE':
        statusColor = Colors.green;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'CLOSED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    final DateFormat formatter = DateFormat('MMM d, y');
    // Using a more flexible currency format
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),


        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: const Border(left: BorderSide(color: Colors.blue, width: 5)),
            color: const Color(0xfff8f9fa),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Title Size
              Text(
                'FD #${fd.id}',
                style: TextStyle(
                    fontSize: isSingleColumn ? 20 : 18, // Slightly larger on mobile
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const Divider(height: 10, thickness: 1),

              // Details are now wrapped in a flexible column/row structure if needed,
              // but _buildDetailRow already uses Expanded which helps responsiveness.

              _buildDetailRow(
                  'Deposit Amount:', currencyFormatter.format(fd.depositAmount),
                  Colors.green),
              _buildDetailRow('Duration:', '${fd.durationInMonths} months',
                  Colors.indigo),
              _buildDetailRow('Interest Rate:', '${fd.interestRate}%',
                  Colors.orange),
              _buildDetailRow('Maturity Amount:',
                  currencyFormatter.format(fd.maturityAmount), Colors.green),
              _buildDetailRow('Status:', fd.status, statusColor),
              _buildDetailRow('Start Date:', formatter.format(fd.startDate),
                  Colors.black54),
              _buildDetailRow('Maturity Date:', formatter.format(fd.maturityDate),
                  Colors.black54),

              // Flexible spacing before button
              // const Spacer(),
                SizedBox(height: 10,),
              // Close Button Logic
              if (fd.status == 'ACTIVE' && fd.accountId != null)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () => _confirmClose(fd.id, fd.accountId),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Close FD'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),


                ),
            ],
          ),
        ),




    );
  }

  // Helper Widget for Detail Row
  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // Removed fixed width (140) and replaced with Flexible for better responsiveness
            // A fixed width can break layout on very small screens.
            width: 130, // Using a slightly smaller fixed width as a compromise for clarity
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis, // Added for small screens
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  color: valueColor, fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right, // Align value to the right for clarity
            ),
          ),
        ],
      ),
    );
  }
}