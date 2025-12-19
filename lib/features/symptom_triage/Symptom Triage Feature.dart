import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_health_companion/features/symptoms/presentation/bloc/symptom_bloc.dart';

class SymptomInputForm extends StatefulWidget {
  final String petId;

  const SymptomInputForm({Key? key, required this.petId}) : super(key: key);

  @override
  _SymptomInputFormState createState() => _SymptomInputFormState();
}

class _SymptomInputFormState extends State<SymptomInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  List<XFile> _selectedMedia = [];

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? media = await ImagePicker().pickImage(source: source);
      if (media != null) {
        setState(() {
          _selectedMedia.add(media);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: $e')),
      );
    }
  }

  void _analyzeSymptoms() {
    if (_formKey.currentState!.validate()) {
      context.read<SymptomBloc>().add(
            AnalyzeSymptoms(
              petId: widget.petId,
              description: _descriptionController.text,
              mediaFiles: _selectedMedia,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SymptomBloc, SymptomState>(
      listener: (context, state) {
        if (state is SymptomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is SymptomAnalysisSuccess) {
          _showTriageResult(state.triageResult);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Describe your pet\'s symptoms',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the symptoms';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Media picker UI
              _buildMediaPicker(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: state is SymptomLoading ? null : _analyzeSymptoms,
                child: state is SymptomLoading
                    ? CircularProgressIndicator()
                    : Text('Analyze Symptoms'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add photos/videos (optional)'),
        Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => _pickMedia(ImageSource.gallery),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () => _pickMedia(ImageSource.camera),
            ),
          ],
        ),
        // Display selected media previews
      ],
    );
  }

  void _showTriageResult(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Triage Result'),
        content: Text('Recommendation: $result'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}