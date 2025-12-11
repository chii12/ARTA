import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_scaffold.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('user_id, full_name, email, role, department_id, phone_number')
          .order('full_name');
      
      // Get departments separately
      final departments = await Supabase.instance.client
          .from('departments')
          .select('department_id, department_name');
      
      final deptMap = Map.fromEntries(
        departments.map((d) => MapEntry(d['department_id'], d['department_name']))
      );
      
      final users = response.map<Map<String, dynamic>>((user) => {
        'id': user['user_id'] ?? '',
        'name': user['full_name'] ?? 'Unknown',
        'email': user['email'] ?? '',
        'role': user['role'] ?? 'user',
        'phone': user['phone_number'] ?? 'N/A',
        'dept': deptMap[user['department_id']] ?? 'No Department',
      }).toList();
      
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      print('User loading error: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _query = '';

  List<Map<String, dynamic>> get _filtered => _users.where((u) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return u.values.any((v) => v.toString().toLowerCase().contains(q));
  }).toList();

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    return AdminScaffold(
      selectedRoute: '/admin/users',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('User Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 280,
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: Colors.blue),
                          hintText: 'Search users...',
                          filled: true,
                          fillColor: Colors.blue[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Text('Failed to load users', style: TextStyle(color: Colors.red)),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _loadUsers, child: const Text('Retry'))
                            ]))
                          : SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 20,
                                columns: const [
                                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: rows.map((u) => DataRow(
                                  cells: [
                                    DataCell(Text(u['name']?.toString() ?? '')),
                                    DataCell(Text(u['email']?.toString() ?? '')),
                                    DataCell(Text(u['role']?.toString() ?? '')),
                                    DataCell(Text(u['dept']?.toString() ?? '')),
                                    DataCell(Text(u['phone']?.toString() ?? '')),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.more_vert, size: 20),
                                        onPressed: () => _showUserActions(context, u),
                                      ),
                                    ),
                                  ],
                                )).toList(),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserActions(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('User Actions: ${user['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _actionButton('Edit User', Icons.edit, Colors.blue, () {
              Navigator.pop(context);
              _showEditUserDialog(context, user);
            }),
            _actionButton('Reset Password', Icons.lock_reset, Colors.orange, () {
              Navigator.pop(context);
              _showResetPasswordDialog(context, user);
            }),
            _actionButton('Deactivate User', Icons.person_off, Colors.red, () {
              Navigator.pop(context);
              _showDeactivateDialog(context, user);
            }),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: color),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);
    String selectedRole = user['role'] ?? 'user';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 16),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 16),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'superadmin', child: Text('Super Admin')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client.from('users').update({
                    'full_name': nameController.text,
                    'email': emailController.text,
                    'phone_number': phoneController.text,
                    'role': selectedRole,
                  }).eq('user_id', user['id']);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User ${user['name']} updated successfully')),
                  );
                  _loadUsers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating user: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, Map<String, dynamic> user) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reset password for ${user['name']}?'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a new password')),
                );
                return;
              }
              
              try {
                // Update password in custom users table
                await Supabase.instance.client.from('users').update({
                  'password': passwordController.text,
                }).eq('user_id', user['id']);
                
                // Send reset email with redirect to reset page
                await Supabase.instance.client.auth.resetPasswordForEmail(
                  user['email'],
                  redirectTo: 'https://your-app.com/reset-password',
                );
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password updated in database and reset email sent to ${user['email']}')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate ${user['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await Supabase.instance.client.from('users').update({
                  'role': 'inactive'
                }).eq('user_id', user['id']);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ${user['name']} deactivated')),
                );
                _loadUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deactivating user: $e')),
                );
              }
            },
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}