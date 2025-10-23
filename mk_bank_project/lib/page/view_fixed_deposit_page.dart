import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/entity/fixed_deposit.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/fixed_deposit_service.dart';

class ViewFixedDepositPage extends StatefulWidget {
  const ViewFixedDepositPage({super.key});

  @override
  State<ViewFixedDepositPage> createState() => _ViewFixedDepositPageState();
}

class _ViewFixedDepositPageState extends State<ViewFixedDepositPage> {
  final FixedDepositService _fdService = FixedDepositService();
  late Future<List<FixedDepositForView>> _futureFds;
  late AccountService accountService;

  List<FixedDepositForView> _allFds = [];
  List<FixedDepositForView> _filteredFds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureFds = _fdService.getMyFD().then((fds) {
      fds.sort((a, b) {
        if (a.status == 'CLOSED' && b.status != 'CLOSED') return 1;
        if (a.status != 'CLOSED' && b.status == 'CLOSED') return -1;
        return a.id.compareTo(b.id);
      });
      _allFds = fds;
      _filteredFds = fds;
      return fds;
    });
    accountService = AccountService();
  }

  void _filterFDs(String query) {
    List<FixedDepositForView> temp;
    if (query.isEmpty) {
      temp = _allFds;
    } else {
      temp = _allFds.where((fd) {
        final idString = fd.id.toString();
        final amountString = fd.depositAmount.toString();
        return idString.contains(query) || amountString.contains(query);
      }).toList();
    }
    setState(() {
      _searchQuery = query;
      _filteredFds = temp;
    });
  }

  void _loadFDs() {
    setState(() {
      _futureFds = _fdService.getMyFD().then((fds) {
        fds.sort((a, b) {
          if (a.status == 'CLOSED' && b.status != 'CLOSED') return 1;
          if (a.status != 'CLOSED' && b.status == 'CLOSED') return -1;
          return a.id.compareTo(b.id);
        });
        _allFds = fds;
        _filteredFds = _allFds;
        return fds;
      });
    });
  }

  Future<void> _confirmClose(int fdId, int? accountId) async {
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account ID not available!')),
      );
      return;
    }

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
        false;

    if (confirmResult == true) {
      try {
        await _fdService.closeFD(fdId, accountId);
        _loadFDs();
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
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by FD ID or Deposit Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterFDs,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FixedDepositForView>>(
              future: _futureFds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ));
                } else if (_filteredFds.isEmpty) {
                  return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No Fixed Deposits found.'
                            : 'No results for "$_searchQuery"',
                        style: const TextStyle(color: Colors.grey),
                      ));
                } else {
                  final fds = _filteredFds;
                  return LayoutBuilder(
                    builder: (context, constraints) {
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
                        ),
                        itemCount: fds.length,
                        itemBuilder: (context, index) {
                          final fd = fds[index];
                          return _buildFdCard(fd, crossAxisCount == 1);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

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
    final NumberFormat currencyFormatter =
    NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Text(
              'FD #${fd.id}',
              style: TextStyle(
                  fontSize: isSingleColumn ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const Divider(height: 10, thickness: 1),
            _buildDetailRow(
                'Deposit Amount:', currencyFormatter.format(fd.depositAmount),
                Colors.green),
            _buildDetailRow('Duration:', '${fd.durationInMonths} months',
                Colors.indigo),
            _buildDetailRow('Interest Rate:', '${fd.interestRate}%', Colors.orange),
            _buildDetailRow('Maturity Amount:',
                currencyFormatter.format(fd.maturityAmount), Colors.green),
            _buildDetailRow('Status:', fd.status, statusColor),
            _buildDetailRow('Start Date:', formatter.format(fd.startDate),
                Colors.black54),
            _buildDetailRow('Maturity Date:', formatter.format(fd.maturityDate),
                Colors.black54),
            const SizedBox(height: 10),
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

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
              TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
