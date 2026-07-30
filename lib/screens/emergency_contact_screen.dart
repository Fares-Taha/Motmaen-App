// emergency_contact_screen.dart - FIXED with user data isolation (design unchanged)
import 'package:flutter/material.dart';
import 'package:motmaen/models/emergency_contact.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/models/user_profile.dart';
import 'package:motmaen/services/user_service.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final UserService _userService = UserService();
  List<EmergencyContact> _contacts = [];
  UserProfile? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await _userService.getCurrentUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final contacts = await _databaseHelper.getEmergencyContacts(userId);
      final user = await _databaseHelper.getUserById(userId);
      
      setState(() {
        _contacts = contacts;
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emergency,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Emergency Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'In case of emergency, show this information to medical personnel',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          _buildEmergencyInfo(),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _contacts.isEmpty
                      ? const Center(
                          child: Text(
                            'No emergency contacts added yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) => _buildContactCard(_contacts[index]),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _addContact,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Emergency Contact'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmergencyInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmergencyInfoItem(
            'Medical Conditions',
            _currentUser?.medicalConditions ?? 'None specified',
          ),
          _buildEmergencyInfoItem(
            'Medications', 
            _currentUser?.medications ?? 'None specified',
          ),
          _buildEmergencyInfoItem(
            'Allergies',
            _currentUser?.allergies ?? 'None known',
          ),
          
          const SizedBox(height: 8),
          const Text(
            'Emergency Instructions:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Check blood sugar immediately'),
          
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.bloodtype, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Blood Type: ${_currentUser?.bloodType ?? 'Not specified'}',
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.medical_services, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Target Glucose: ${_currentUser?.targetGlucoseMin ?? 80}-${_currentUser?.targetGlucoseMax ?? 120} mg/dL',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: contact.isPrimary ? Colors.red : Colors.blue,
          child: Text(
            contact.name.split(' ').map((e) => e[0]).take(2).join(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(contact.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.relationship),
            Text(contact.phone),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact.isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editContact(contact);
                } else if (value == 'delete') {
                  await _deleteContact(contact);
                } else if (value == 'primary') {
                  await _setAsPrimary(contact);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (!contact.isPrimary)
                  const PopupMenuItem(value: 'primary', child: Text('Set as Primary')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        onTap: () => _callContact(contact.phone),
      ),
    );
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        onSave: (contact) async {
          try {
            final userId = await _userService.getCurrentUserId();
            if (userId == null) {
              _showErrorSnackBar('Please login first');
              return;
            }

            final id = await _databaseHelper.insertEmergencyContact(contact, userId);
            final newContact = contact.copyWith(id: id);
            setState(() {
              _contacts.add(newContact);
            });
          } catch (e) {
            _showErrorSnackBar('Failed to add contact: $e');
          }
        },
      ),
    );
  }

  Future<void> _editContact(EmergencyContact contact) async {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        contact: contact,
        onSave: (updatedContact) async {
          try {
            final userId = await _userService.getCurrentUserId();
            if (userId == null) {
              _showErrorSnackBar('Please login first');
              return;
            }

            await _databaseHelper.updateEmergencyContact(updatedContact, userId);
            setState(() {
              final index = _contacts.indexWhere((c) => c.id == contact.id);
              if (index != -1) {
                _contacts[index] = updatedContact;
              }
            });
          } catch (e) {
            _showErrorSnackBar('Failed to update contact: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final userId = await _userService.getCurrentUserId();
                if (userId == null || contact.id == null) {
                  _showErrorSnackBar('Unable to delete contact');
                  return;
                }

                await _databaseHelper.deleteEmergencyContact(contact.id!, userId);
                setState(() {
                  _contacts.remove(contact);
                });
                Navigator.pop(context);
              } catch (e) {
                _showErrorSnackBar('Failed to delete contact: $e');
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setAsPrimary(EmergencyContact contact) async {
    try {
      final userId = await _userService.getCurrentUserId();
      if (userId == null || contact.id == null) {
        _showErrorSnackBar('Unable to set primary contact');
        return;
      }

      await _databaseHelper.setPrimaryContact(contact.id!, userId);
      await _loadData(); // Reload to refresh the list
    } catch (e) {
      _showErrorSnackBar('Failed to set primary contact: $e');
    }
  }

  void _callContact(String phone) {
    // Implement phone call functionality
    print('Calling $phone');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class AddContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onSave;

  const AddContactDialog({
    super.key,
    this.contact,
    required this.onSave,
  });

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _relationshipController.text = widget.contact!.relationship;
      _phoneController.text = widget.contact!.phone;
      _isPrimary = widget.contact!.isPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _relationshipController,
            decoration: const InputDecoration(
              labelText: 'Relationship',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Set as primary contact'),
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveContact,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveContact() {
    if (_nameController.text.isEmpty || 
        _relationshipController.text.isEmpty || 
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final contact = EmergencyContact(
      id: widget.contact?.id,
      name: _nameController.text,
      relationship: _relationshipController.text,
      phone: _phoneController.text,
      isPrimary: _isPrimary,
    );

    widget.onSave(contact);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}