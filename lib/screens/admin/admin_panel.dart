import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stylehub/constants/app/app_colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const UsersScreen(),
    const ApprovalRequestsScreen(),
    const HelpDeskScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.appBGColor,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Approvals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.support_agent),
          label: 'Support',
        ),
      ],
    );
  }
}

// Users Screen
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Stylist') // Add this filter
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final user = snapshot.data!.docs[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('${user['firstName']} ${user['lastName']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['email']),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailScreen(userId: user.id),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// User Detail Screen
class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final user = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Email', user['email']),
                _buildDetailItem('Role', user['role'] ?? 'user'),
                _buildDetailItem('Registration Date', user['createdAt']?.toDate().toString() ?? 'N/A'),
                const SizedBox(height: 20),
                const Text('Profile Information:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildDetailItem('Profession', user['profession'] ?? 'Not set'),
                _buildDetailItem('Experience', user['experience'] ?? 'Not set'),
                _buildDetailItem('Status', user['status'] ?? 'Not set'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Approval Requests Screen (Updated)
class ApprovalRequestsScreen extends StatelessWidget {
  const ApprovalRequestsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Field Approval Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error ?? 'Unknown error'}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending requests.'));
          }

          // Collect all pending field updates from all users
          final List<Map<String, dynamic>> pendingRequests = [];
          for (final doc in snapshot.data!.docs) {
            final userData = doc.data() as Map<String, dynamic>;
            final userId = doc.id;

            // Check all possible field statuses
            const fieldKeys = ['profession', 'experience', 'city', 'address', 'bio', 'phone', 'previousWork', 'categories'];

            for (final field in fieldKeys) {
              final statusField = '${field}Status';
              if (userData[statusField] == 'pending') {
                pendingRequests.add({
                  'userId': userId,
                  'field': field,
                  'statusField': statusField,
                  'value': userData[field],
                  'email': userData['email'] ?? 'No email',
                });
              }
            }
          }

          if (pendingRequests.isEmpty) {
            return const Center(child: Text('No pending field updates.'));
          }

          return ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              return _buildApprovalItem(
                context,
                userId: request['userId'],
                field: request['field'],
                statusField: request['statusField'],
                value: request['value'],
                email: request['email'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildApprovalItem(
    BuildContext context, {
    required String userId,
    required String field,
    required String statusField,
    required dynamic value,
    required String email,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Field: ${field.toUpperCase()}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Image display for previous work
            if (field == 'previousWork')
              _buildImageGrid(value)
            else
              Text(
                'New Value: ${value.toString()}',
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 12),
            _buildApprovalButtons(userId, statusField),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(dynamic imageUrls) {
    List<String> urls = [];
    if (imageUrls is List) {
      urls = imageUrls.whereType<String>().toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Submitted Images:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    urls[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            Text('Failed to load'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalButtons(String userId, String statusField) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.check, color: Colors.green),
          label: const Text('Approve'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green),
          ),
          onPressed: () => _handleApproval(
            userId: userId,
            statusField: statusField,
            status: 'approved',
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.close, color: Colors.red),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () => _handleApproval(
            userId: userId,
            statusField: statusField,
            status: 'rejected',
          ),
        ),
      ],
    );
  }

  void _handleApproval({
    required String userId,
    required String statusField,
    required String status,
  }) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      statusField: status,
      'lastReviewed': FieldValue.serverTimestamp(),
    });
  }
}

// Help Desk Screen
class HelpDeskScreen extends StatelessWidget {
  const HelpDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('supportTickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final ticket = snapshot.data!.docs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.support_agent,
                  color: _getStatusColor(ticket['status']),
                ),
                title: Text(ticket['subject'], style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${ticket['userEmail']}'),
                    Text('Status: ${ticket['status']}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTicketDetails(context, ticket),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showTicketDetails(BuildContext context, DocumentSnapshot ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket['subject']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${ticket['userEmail']}'),
              const SizedBox(height: 12),
              Text('Message:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(ticket['message']),
              const SizedBox(height: 20),
              Text('Status: ${ticket['status']}', style: TextStyle(color: _getStatusColor(ticket['status']), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (ticket['status'] != 'closed') TextButton(onPressed: () => _updateTicketStatus(context, ticket.id, 'closed'), child: const Text('Mark Closed')),
        ],
      ),
    );
  }

  void _updateTicketStatus(context, String ticketId, String status) {
    FirebaseFirestore.instance.collection('supportTickets').doc(ticketId).update({'status': status});
    Navigator.pop(context);
  }
}

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';

// // class AdminPanel extends StatelessWidget {
// //   const AdminPanel({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Admin: All Users')),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: FirebaseFirestore.instance.collection('users').snapshots(), // <-- No filter, fetch all users
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           }
// //           if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error ?? 'Unknown error'}'));
// //           }
// //           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //             return Center(child: Text('No users found.'));
// //           }

// //           return ListView.builder(
// //             itemCount: snapshot.data!.docs.length,
// //             itemBuilder: (context, index) {
// //               final doc = snapshot.data!.docs[index];
// //               final user = doc.data() as Map<String, dynamic>;

// //               return ListTile(
// //                 title: Text(user['email'] ?? 'No email'),
// //                 subtitle: Text(
// //                   'Profession: ${user['profession'] ?? 'N/A'}\n'
// //                   'Status: ${user['status'] ?? 'unknown'}',
// //                 ),
// //                 trailing: user['status'] == 'pending'
// //                     ? Row(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           IconButton(
// //                             icon: Icon(Icons.check, color: Colors.green),
// //                             onPressed: () => _updateStatus(doc.id, 'approved'),
// //                           ),
// //                           IconButton(
// //                             icon: Icon(Icons.close, color: Colors.red),
// //                             onPressed: () => _updateStatus(doc.id, 'rejected'),
// //                           ),
// //                         ],
// //                       )
// //                     : null, // Only show buttons for pending users
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AdminPanel extends StatelessWidget {
//   const AdminPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Field Approval Requests')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error ?? 'Unknown error'}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No pending requests.'));
//           }

//           // Collect all pending field updates from all users
//           final List<Map<String, dynamic>> pendingRequests = [];
//           for (final doc in snapshot.data!.docs) {
//             final userData = doc.data() as Map<String, dynamic>;
//             final userId = doc.id;

//             // Check all possible field statuses
//             const fieldKeys = ['profession', 'experience', 'city', 'address', 'bio', 'phone', 'previousWork', 'categories'];

//             for (final field in fieldKeys) {
//               final statusField = '${field}Status';
//               if (userData[statusField] == 'pending') {
//                 pendingRequests.add({
//                   'userId': userId,
//                   'field': field,
//                   'statusField': statusField,
//                   'value': userData[field],
//                   'email': userData['email'] ?? 'No email',
//                 });
//               }
//             }
//           }

//           if (pendingRequests.isEmpty) {
//             return const Center(child: Text('No pending field updates.'));
//           }

//           return ListView.builder(
//             itemCount: pendingRequests.length,
//             itemBuilder: (context, index) {
//               final request = pendingRequests[index];
//               return _buildApprovalItem(
//                 context,
//                 userId: request['userId'],
//                 field: request['field'],
//                 statusField: request['statusField'],
//                 value: request['value'],
//                 email: request['email'],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildApprovalItem(
//     BuildContext context, {
//     required String userId,
//     required String field,
//     required String statusField,
//     required dynamic value,
//     required String email,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: ListTile(
//         title: Text(
//           email,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Field: ${field.toUpperCase()}'),
//             const SizedBox(height: 4),
//             Text('New Value: $value'),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.check, color: Colors.green),
//               onPressed: () => _handleApproval(
//                 userId: userId,
//                 statusField: statusField,
//                 status: 'approved',
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.red),
//               onPressed: () => _handleApproval(
//                 userId: userId,
//                 statusField: statusField,
//                 status: 'rejected',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleApproval({
//     required String userId,
//     required String statusField,
//     required String status,
//   }) {
//     FirebaseFirestore.instance.collection('users').doc(userId).update({
//       statusField: status,
//       'lastReviewed': FieldValue.serverTimestamp(),
//     });
//   }
// }

// //   void _updateStatus(String userId, String status) {
// //     FirebaseFirestore.instance.collection('users').doc(userId).update({
// //       'status': status,
// //       'statusUpdated': FieldValue.serverTimestamp(),
// //     });
// //   }
// // }

// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';

// // // class AdminPanel extends StatelessWidget {
// // //   const AdminPanel({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //         appBar: AppBar(title: Text('Admin Approvals')),
// // //         body: StreamBuilder<QuerySnapshot>(
// // //           stream: FirebaseFirestore.instance.collection('users').where('status', isEqualTo: 'pending').snapshots(),
// // //           builder: (context, snapshot) {
// // //             if (snapshot.connectionState == ConnectionState.waiting) {
// // //               return Center(child: CircularProgressIndicator());
// // //             }
// // //             if (snapshot.hasError) {
// // //               return Center(child: Text('Error: ${snapshot.error ?? 'Unknown error'}'));
// // //             }
// // //             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //               return Center(child: Text('No pending users.'));
// // //             }

// // //             return ListView.builder(
// // //               itemCount: snapshot.data!.docs.length,
// // //               itemBuilder: (context, index) {
// // //                 final doc = snapshot.data!.docs[index];
// // //                 final user = doc.data() as Map<String, dynamic>;
// // //                 return ListTile(
// // //                   title: Text(user['email']),
// // //                   subtitle: Text('Profession: ${user['profession']}'),
// // //                   trailing: Row(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       IconButton(
// // //                         icon: Icon(Icons.check, color: Colors.green),
// // //                         onPressed: () => _updateStatus(doc.id, 'approved'),
// // //                       ),
// // //                       IconButton(
// // //                         icon: Icon(Icons.close, color: Colors.red),
// // //                         onPressed: () => _updateStatus(doc.id, 'rejected'),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 );
// // //               },
// // //             );
// // //           },
// // //         ));
// // //   }

// // //   void _updateStatus(String userId, String status) {
// // //     FirebaseFirestore.instance.collection('users').doc(userId).update({
// // //       'status': status,
// // //       'statusUpdated': FieldValue.serverTimestamp(),
// // //     });
// // //   }
// // // }
