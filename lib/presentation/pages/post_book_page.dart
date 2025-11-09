import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:book_swap/core/providers/app_providers.dart';
import 'package:book_swap/data/models/book_model.dart';
import 'package:book_swap/data/services/firebase_service.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class PostBookPage extends ConsumerStatefulWidget {
  final BookModel? bookToEdit;

  const PostBookPage({super.key, this.bookToEdit});

  @override
  ConsumerState<PostBookPage> createState() => _PostBookPageState();
}

class _PostBookPageState extends ConsumerState<PostBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
  BookCondition _selectedCondition = BookCondition.good;
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _selectedCondition = widget.bookToEdit!.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = File(image.path); // Keep for reference
        });
      } else {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null && _webImage == null) return null;

    try {
      
      Uint8List imageBytes;
      if (kIsWeb && _webImage != null) {
        imageBytes = _webImage!;
      } else {
        imageBytes = await _selectedImage!.readAsBytes();
      }
      
      // Convert to base64
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';
      
      return dataUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseService.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null || _webImage != null) {
        // Show uploading message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploading image...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        imageUrl = await _uploadImage();
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }
      } else if (widget.bookToEdit != null) {
        imageUrl = widget.bookToEdit!.imageUrl;
      }

      final book = BookModel(
        id: widget.bookToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageUrl: imageUrl,
        ownerId: currentUser.uid,
        ownerEmail: currentUser.email ?? '',
        createdAt: widget.bookToEdit?.createdAt ?? DateTime.now(),
        status: widget.bookToEdit?.status ?? SwapStatus.available,
      );

      
      if (widget.bookToEdit != null) {
        await FirebaseService.updateBook(book);
      } else {
        await FirebaseService.createBook(book);
      }
      

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bookToEdit != null 
                ? 'Book updated successfully!' 
                : 'Book posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save book: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Post a Book')),
            body: const Center(child: Text('Please log in to post a book')),
          );
        }
        
        return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.bookToEdit != null ? 'Edit Book' : 'Post a Book'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Image Section
            _ImageSection(
              selectedImage: _selectedImage,
              webImage: _webImage,
              existingImageUrl: widget.bookToEdit?.imageUrl,
              onImageTap: _pickImage,
            ),
            const SizedBox(height: 32),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book Title',
                prefixIcon: Icon(Icons.book),
                hintText: 'Enter the book title',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the book title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Author Field
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                prefixIcon: Icon(Icons.person),
                hintText: 'Enter the author name',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the author name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Condition Section
            Text(
              'Book Condition',
              style: AppStyles.headline3,
            ),
            const SizedBox(height: 12),
            _ConditionSelector(
              selectedCondition: _selectedCondition,
              onConditionChanged: (condition) {
                setState(() {
                  _selectedCondition = condition;
                });
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textLight,
                      ),
                    )
                  : Text(
                      widget.bookToEdit != null ? 'Update Book' : 'Post Book',
                      style: AppStyles.buttonText,
                    ),
            ),
          ],
        ),
      ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const Scaffold(
        body: Center(child: Text('Authentication error')),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final File? selectedImage;
  final Uint8List? webImage;
  final String? existingImageUrl;
  final VoidCallback onImageTap;

  const _ImageSection({
    this.selectedImage,
    this.webImage,
    this.existingImageUrl,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onImageTap,
        child: Container(
          width: 200,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 2,
              style: BorderStyle.solid,
            ),
            color: AppColors.card,
          ),
          child: (selectedImage != null || webImage != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: kIsWeb && webImage != null
                      ? Image.memory(
                          webImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                )
              : existingImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        existingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _PlaceholderContent();
                        },
                      ),
                    )
                  : _PlaceholderContent(),
        ),
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: AppColors.textDark.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 12),
        Text(
          'Add Book Cover',
          style: AppStyles.bodyText1.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to select image',
          style: AppStyles.bodyTextSmall.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _ConditionSelector extends StatelessWidget {
  final BookCondition selectedCondition;
  final ValueChanged<BookCondition> onConditionChanged;

  const _ConditionSelector({
    required this.selectedCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: BookCondition.values.map((condition) {
        final isSelected = condition == selectedCondition;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onConditionChanged(condition),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.1) 
                    : AppColors.card,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.primary : AppColors.textDark.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getConditionTitle(condition),
                        style: AppStyles.bodyText1.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                        ),
                      ),
                      Text(
                        _getConditionDescription(condition),
                        style: AppStyles.bodyTextSmall.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getConditionTitle(BookCondition condition) {
    switch (condition) {
      case BookCondition.newBook:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }

  String _getConditionDescription(BookCondition condition) {
    switch (condition) {
      case BookCondition.newBook:
        return 'Brand new, never used';
      case BookCondition.likeNew:
        return 'Minimal wear, excellent condition';
      case BookCondition.good:
        return 'Some wear but fully functional';
      case BookCondition.used:
        return 'Well-used but readable';
    }
  }
}
