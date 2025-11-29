import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef NavCallback = void Function(String route);

class AdminScaffold extends StatefulWidget {
  final Widget child;
  final String selectedRoute;
  final NavCallback onNavigate;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.selectedRoute,
    required this.onNavigate,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> with SingleTickerProviderStateMixin {
  // Sidebar is fixed (non-collapsible)
  static const double _sidebarWidth = 260.0;
  String _userName = 'Loading...';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select('full_name, email')
            .eq('user_id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _userName = response['full_name'] ?? 'Admin User';
            _userEmail = response['email'] ?? user.email ?? '';
          });
        }
      }
    } catch (e) {
      final user = Supabase.instance.client.auth.currentUser;
      if (mounted) {
        setState(() {
          _userName = 'Admin User';
          _userEmail = user?.email ?? '';
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    const width = _sidebarWidth;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: width,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Image.asset(
                          'assets/city_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => const Icon(Icons.location_city, size: 20, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Navigation Items
                // Use Bootstrap Icons (CDN SVGs)
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/graph-up.svg',
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  route: '/admin/analytics',
                  selected: widget.selectedRoute == '/admin/analytics',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/chat-left-text.svg',
                  icon: Icons.chat_bubble_outline,
                  label: 'Responses',
                  route: '/admin/responses',
                  selected: widget.selectedRoute == '/admin/responses',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
               
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/clipboard-data.svg',
                  icon: Icons.list_alt,
                  label: 'Survey Form',
                  route: '/admin/survey',
                  selected: widget.selectedRoute == '/admin/survey',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/qr-code.svg',
                  icon: Icons.qr_code,
                  label: 'QR Code',
                  route: '/admin/qr',
                  selected: widget.selectedRoute == '/admin/qr',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                const Spacer(),

                // User profile area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => widget.onNavigate('/admin/profile'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage('assets/profile_placeholder.png'),
                              backgroundColor: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(_userEmail, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFF263238),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String? iconSvg;
  final IconData icon;
  final String label;
  final String route;
  final bool selected;
  final bool collapsed;
  final NavCallback onTap;

  const _SidebarItem({
    this.iconSvg,
    required this.icon,
    required this.label,
    required this.route,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 6.0 : 12.0, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: selected
              ? BoxDecoration(
                  color: const Color(0xFF007BFF),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 8 : 12,
            vertical: 10,
          ),
          child: collapsed
              ? SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Center(
                    child: iconSvg != null
                        ? _maybeSvg(iconSvg!, selected)
                        : Icon(
                            icon,
                            color: selected ? Colors.white : Colors.black54,
                            size: 20,
                          ),
                  ),
                )
              : Row(
                  children: [
                    if (iconSvg != null)
                      _maybeSvg(iconSvg!, selected)
                    else
                      Icon(
                        icon,
                        color: selected ? Colors.white : Colors.black54,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (selected) const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _maybeSvg(String path, bool selected) {
    try {
      if (path.startsWith('http')) {
        return SvgPicture.network(
          path,
          width: 20,
          height: 20,
          color: selected ? Colors.white : Colors.black54,
          placeholderBuilder: (_) => const SizedBox(width: 20, height: 20),
        );
      }
      return SvgPicture.asset(
        path,
        width: 20,
        height: 20,
        color: selected ? Colors.white : Colors.black54,
      );
    } catch (_) {
      return Icon(
        icon,
        color: selected ? Colors.white : Colors.black54,
        size: 20,
      );
    }
  }
}