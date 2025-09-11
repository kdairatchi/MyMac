#!/usr/bin/env python3
"""
Polyglot File Creator with Detector and CLI Interface
Supports creating and detecting polyglot files across multiple formats
"""

import argparse
import sys
import os
import magic
import hashlib
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import zipfile
import tarfile
import gzip
import bz2
import lzma
import json
from datetime import datetime

class PolyglotCreator:
    """Main class for polyglot file operations"""
    
    # Supported file signatures (magic numbers)
    FILE_SIGNATURES = {
        'zip': b'PK\x03\x04',
        'gzip': b'\x1f\x8b',
        'pdf': b'%PDF-',
        'png': b'\x89PNG\r\n\x1a\n',
        'jpg': b'\xff\xd8\xff',
        'gif': b'GIF87a',
        'gif89a': b'GIF89a',
        'bmp': b'BM',
        'webp': b'RIFF',
        'mp3': b'ID3',
        'wav': b'RIFF',
        'avi': b'RIFF',
        'mp4': b'\x00\x00\x00\x18ftyp',
        'elf': b'\x7fELF',
        'pe': b'MZ',
    }
    
    def __init__(self):
        self.mime_detector = magic.Magic(mime=True)
        self.type_detector = magic.Magic()
    
    def detect_file_type(self, file_path: str) -> Dict:
        """Detect file type using multiple methods"""
        try:
            with open(file_path, 'rb') as f:
                content = f.read(4096)  # Read first 4KB for analysis
            
            results = {
                'file_magic': self._detect_by_magic_numbers(content),
                'file_command': self.type_detector.from_file(file_path),
                'mime_type': self.mime_detector.from_file(file_path),
                'file_size': os.path.getsize(file_path),
                'sha256': hashlib.sha256(content).hexdigest()
            }
            
            # Additional checks for polyglot characteristics
            results['polyglot_score'] = self._calculate_polyglot_score(content)
            results['suspicious_patterns'] = self._find_suspicious_patterns(content)
            
            return results
            
        except Exception as e:
            return {'error': str(e)}
    
    def _detect_by_magic_numbers(self, content: bytes) -> List[str]:
        """Detect file types by magic numbers"""
        detected = []
        for file_type, signature in self.FILE_SIGNATURES.items():
            if content.startswith(signature):
                detected.append(file_type)
        return detected
    
    def _calculate_polyglot_score(self, content: bytes) -> int:
        """Calculate how many file types this content could be"""
        score = 0
        for signature in self.FILE_SIGNATURES.values():
            if content.startswith(signature):
                score += 1
        return score
    
    def _find_suspicious_patterns(self, content: bytes) -> List[str]:
        """Find patterns that might indicate polyglot files"""
        patterns = []
        
        # Check for embedded scripts
        script_patterns = [
            b'<?php', b'<script', b'#!/bin/', b'#!/usr/bin/',
            b'eval(', b'exec(', b'system('
        ]
        
        for pattern in script_patterns:
            if pattern in content:
                patterns.append(f"Script pattern: {pattern.decode('utf-8', errors='ignore')}")
        
        # Check for multiple file headers
        if self._calculate_polyglot_score(content) > 1:
            patterns.append("Multiple file signatures detected")
        
        return patterns
    
    def create_polyglot(self, output_path: str, combinations: List[str], 
                       content: Optional[str] = None, metadata: Optional[Dict] = None) -> bool:
        """Create a polyglot file with specified combinations"""
        try:
            polyglot_content = b''
            
            # Add content based on requested combinations
            for file_type in combinations:
                if file_type in self.FILE_SIGNATURES:
                    polyglot_content += self.FILE_SIGNATURES[file_type]
                else:
                    print(f"Warning: Unknown file type '{file_type}', skipping signature")
            
            # Add user content if provided
            if content:
                polyglot_content += content.encode('utf-8')
            
            # Add metadata as comment or hidden data
            if metadata:
                metadata_str = json.dumps(metadata).encode('utf-8')
                polyglot_content += b'\n<!-- ' + metadata_str + b' -->\n'
            
            # Write the polyglot file
            with open(output_path, 'wb') as f:
                f.write(polyglot_content)
            
            print(f"Created polyglot file: {output_path}")
            print(f"Size: {len(polyglot_content)} bytes")
            return True
            
        except Exception as e:
            print(f"Error creating polyglot file: {e}")
            return False
    
    def create_zip_polyglot(self, output_path: str, inner_files: List[str], 
                           disguise_as: str = 'jpg') -> bool:
        """Create a ZIP file that also appears as another file type"""
        try:
            # Create a ZIP file
            with zipfile.ZipFile(output_path, 'w') as zipf:
                for file_path in inner_files:
                    if os.path.exists(file_path):
                        zipf.write(file_path, os.path.basename(file_path))
            
            # Read the ZIP file and prepend another signature
            with open(output_path, 'rb') as f:
                zip_content = f.read()
            
            if disguise_as in self.FILE_SIGNATURES:
                disguised_content = self.FILE_SIGNATURES[disguise_as] + zip_content
                with open(output_path, 'wb') as f:
                    f.write(disguised_content)
            
            print(f"Created ZIP polyglot disguised as {disguise_as}: {output_path}")
            return True
            
        except Exception as e:
            print(f"Error creating ZIP polyglot: {e}")
            return False

def print_detection_results(results: Dict):
    """Pretty print detection results"""
    print("\n" + "="*60)
    print("FILE ANALYSIS RESULTS")
    print("="*60)
    
    if 'error' in results:
        print(f"Error: {results['error']}")
        return
    
    print(f"File Size: {results['file_size']} bytes")
    print(f"SHA256: {results['sha256']}")
    print(f"MIME Type: {results['mime_type']}")
    print(f"File Command: {results['file_command']}")
    
    if results['file_magic']:
        print(f"Magic Numbers: {', '.join(results['file_magic'])}")
    
    print(f"Polyglot Score: {results['polyglot_score']}")
    
    if results['suspicious_patterns']:
        print("\nSUSPICIOUS PATTERNS:")
        for pattern in results['suspicious_patterns']:
            print(f"  - {pattern}")
    
    print("="*60)

def main():
    parser = argparse.ArgumentParser(
        description="Polyglot File Creator and Detector",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Detect file type
  polyglot detect suspicious_file.bin
  
  # Create a simple polyglot
  polyglot create --output poly.jpg --combinations jpg zip pdf
  
  # Create ZIP polyglot
  polyglot create-zip --output hidden.zip --files document.txt --disguise jpg
  
  # Analyze multiple files
  polyglot detect *.bin *.exe *.jpg
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Detect command
    detect_parser = subparsers.add_parser('detect', help='Detect file types and polyglot characteristics')
    detect_parser.add_argument('files', nargs='+', help='Files to analyze')
    detect_parser.add_argument('--json', action='store_true', help='Output in JSON format')
    
    # Create command
    create_parser = subparsers.add_parser('create', help='Create a polyglot file')
    create_parser.add_argument('--output', '-o', required=True, help='Output file path')
    create_parser.add_argument('--combinations', '-c', nargs='+', required=True,
                             choices=PolyglotCreator.FILE_SIGNATURES.keys(),
                             help='File types to combine')
    create_parser.add_argument('--content', help='Additional content to include')
    create_parser.add_argument('--metadata', help='JSON metadata to embed')
    
    # Create ZIP polyglot command
    zip_parser = subparsers.add_parser('create-zip', help='Create a ZIP file polyglot')
    zip_parser.add_argument('--output', '-o', required=True, help='Output file path')
    zip_parser.add_argument('--files', '-f', nargs='+', required=True, help='Files to include in ZIP')
    zip_parser.add_argument('--disguise', '-d', default='jpg',
                          choices=PolyglotCreator.FILE_SIGNATURES.keys(),
                          help='File type to disguise as')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    creator = PolyglotCreator()
    
    if args.command == 'detect':
        for file_path in args.files:
            if not os.path.exists(file_path):
                print(f"Error: File not found - {file_path}")
                continue
            
            results = creator.detect_file_type(file_path)
            
            if args.json:
                print(json.dumps({file_path: results}, indent=2))
            else:
                print(f"\nAnalyzing: {file_path}")
                print_detection_results(results)
    
    elif args.command == 'create':
        metadata = None
        if args.metadata:
            try:
                metadata = json.loads(args.metadata)
            except json.JSONDecodeError:
                print("Error: Invalid JSON metadata")
                sys.exit(1)
        
        success = creator.create_polyglot(
            args.output, args.combinations, args.content, metadata
        )
        if success:
            # Auto-detect the created file
            print("\nAnalysis of created file:")
            results = creator.detect_file_type(args.output)
            print_detection_results(results)
    
    elif args.command == 'create-zip':
        success = creator.create_zip_polyglot(args.output, args.files, args.disguise)
        if success:
            print("\nAnalysis of created ZIP polyglot:")
            results = creator.detect_file_type(args.output)
            print_detection_results(results)

if __name__ == "__main__":
    # Check if python-magic is available
    try:
        import magic
    except ImportError:
        print("Error: python-magic library is required.")
        print("Install it with: pip install python-magic")
        print("On Linux, you may also need: sudo apt-get install libmagic1")
        sys.exit(1)
    
    main()
