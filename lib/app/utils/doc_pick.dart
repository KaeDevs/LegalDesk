// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:cunning_document_scanner/cunning_document_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:get/get.dart';
// import 'package:cunning_document_scanner/cunning_document_scanner.dart';

// enum DocumentSourceType { files, scan, camera }

// class DocumentPickerResult {
//   final List<String> paths;
//   final DocumentSourceType source;
//   final String? error;

//   DocumentPickerResult({
//     required this.paths,
//     required this.source,
//     this.error,
//   });

//   bool get isSuccess => error == null && paths.isNotEmpty;
// }

// Future<void> _pickFiles() async {
//   try {
//     final sourceType = await _showDocumentSourcePicker();
//     if (sourceType == null) return;

//     // Show loading indicator
//     _showLoadingDialog();

//     final result = await _handleDocumentSelection(sourceType);
    
//     // Hide loading indicator
//     Navigator.of(context).pop();

//     if (result.isSuccess) {
//       await _processSelectedFiles(result.paths, result.source);
//       _showSuccessMessage(result.paths.length, result.source);
//     } else if (result.error != null) {
//       _showErrorMessage(result.error!);
//     }
//   } catch (e) {
//     // Hide loading indicator if still showing
//     if (Navigator.canPop(context)) Navigator.of(context).pop();
//     _showErrorMessage('An unexpected error occurred: ${e.toString()}');
//   }
// }

// Future<DocumentSourceType?> _showDocumentSourcePicker() async {
//   return await showModalBottomSheet<DocumentSourceType>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) => Container(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Select Document Source',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 16),
//           ListTile(
//             leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
//             title: const Text('Pick from Files'),
//             subtitle: const Text('Choose from device storage'),
//             onTap: () => Navigator.pop(context, DocumentSourceType.files),
//           ),
//           ListTile(
//             leading: const Icon(Icons.document_scanner, color: Colors.green),
//             title: const Text('Scan Document'),
//             subtitle: const Text('Scan with camera'),
//             onTap: () => Navigator.pop(context, DocumentSourceType.scan),
//           ),
//           ListTile(
//             leading: const Icon(Icons.camera_alt, color: Colors.orange),
//             title: const Text('Take Photo'),
//             subtitle: const Text('Capture with camera'),
//             onTap: () => Navigator.pop(context, DocumentSourceType.camera),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     ),
//   );
// }

// Future<DocumentPickerResult> _handleDocumentSelection(DocumentSourceType sourceType) async {
//   switch (sourceType) {
//     case DocumentSourceType.files:
//       return await _pickFromFiles();
//     case DocumentSourceType.scan:
//       return await _scanDocuments();
//     case DocumentSourceType.camera:
//       return await _captureFromCamera();
//   }
// }

// Future<DocumentPickerResult> _pickFromFiles() async {
//   try {
//     final result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
//     );

//     if (result == null) {
//       return DocumentPickerResult(
//         paths: [],
//         source: DocumentSourceType.files,
//       );
//     }

//     final files = result.paths.whereType<String>().toList();
//     return DocumentPickerResult(
//       paths: files,
//       source: DocumentSourceType.files,
//     );
//   } catch (e) {
//     return DocumentPickerResult(
//       paths: [],
//       source: DocumentSourceType.files,
//       error: 'Failed to pick files: ${e.toString()}',
//     );
//   }
// }

// Future<DocumentPickerResult> _scanDocuments() async {
//   try {
//     final scannedFiles = await CunningDocumentScanner.getPictures();
    
//     if (scannedFiles == null || scannedFiles.isEmpty) {
//       return DocumentPickerResult(
//         paths: [],
//         source: DocumentSourceType.scan,
//       );
//     }

//     return DocumentPickerResult(
//       paths: scannedFiles,
//       source: DocumentSourceType.scan,
//     );
//   } catch (e) {
//     return DocumentPickerResult(
//       paths: [],
//       source: DocumentSourceType.scan,
//       error: 'Failed to scan documents: ${e.toString()}',
//     );
//   }
// }

// Future<DocumentPickerResult> _captureFromCamera() async {
//   try {
//     // Assuming you have image_picker package
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 80,
//     );

//     if (image == null) {
//       return DocumentPickerResult(
//         paths: [],
//         source: DocumentSourceType.camera,
//       );
//     }

//     return DocumentPickerResult(
//       paths: [image.path],
//       source: DocumentSourceType.camera,
//     );
//   } catch (e) {
//     return DocumentPickerResult(
//       paths: [],
//       source: DocumentSourceType.camera,
//       error: 'Failed to capture image: ${e.toString()}',
//     );
//   }
// }

// Future<void> _processSelectedFiles(List<String> files, DocumentSourceType source) async {
//   try {
//     // Validate files before processing
//     final validFiles = await _validateFiles(files);
//     if (validFiles.isEmpty) {
//       throw Exception('No valid files selected');
//     }

//     final localPaths = await saveFilesToLocalStorage(validFiles);
    
//     setState(() {
//       _attachedFiles.addAll(localPaths);
//     });
//   } catch (e) {
//     throw Exception('Failed to process files: ${e.toString()}');
//   }
// }

// Future<List<String>> _validateFiles(List<String> files) async {
//   final validFiles = <String>[];
//   const maxFileSize = 10 * 1024 * 1024; // 10MB limit
  
//   for (final filePath in files) {
//     try {
//       final file = File(filePath);
//       if (await file.exists()) {
//         final fileSize = await file.length();
//         if (fileSize <= maxFileSize) {
//           validFiles.add(filePath);
//         } else {
//           print('File too large: ${file.path}');
//         }
//       }
//     } catch (e) {
//       print('Error validating file: $filePath, Error: $e');
//     }
//   }
  
//   return validFiles;
// }

// void _showLoadingDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => const Center(
//       child: CircularProgressIndicator(),
//     ),
//   );
// }

// void _showSuccessMessage(int fileCount, DocumentSourceType source) {
//   final sourceText = source == DocumentSourceType.files 
//       ? 'files selected' 
//       : source == DocumentSourceType.scan 
//         ? 'documents scanned'
//         : 'photo captured';
        
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('$fileCount $sourceText successfully'),
//       backgroundColor: Colors.green,
//       behavior: SnackBarBehavior.floating,
//     ),
//   );
// }

// void _showErrorMessage(String error) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(error),
//       backgroundColor: Colors.red,
//       behavior: SnackBarBehavior.floating,
//       action: SnackBarAction(
//         label: 'Dismiss',
//         textColor: Colors.white,
//         onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//       ),
//     ),
//   );
// }