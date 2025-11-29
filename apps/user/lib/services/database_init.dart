import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseInit {
  static Future<void> ensureDefaultData() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Create default department if not exists
      final deptExists = await supabase
          .from('departments')
          .select()
          .eq('department_id', '00000000-0000-0000-0000-000000000000')
          .maybeSingle();
      
      if (deptExists == null) {
        await supabase.from('departments').insert({
          'department_id': '00000000-0000-0000-0000-000000000000',
          'department_name': 'ARTA Default Department',
        });
      }
      
      // Don't auto-create users - use existing users from departments
    } catch (e) {
      print('Database initialization error: $e');
    }
  }
}