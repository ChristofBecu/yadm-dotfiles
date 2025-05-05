#!/usr/bin/env python3

import os
import re
import sys
import tkinter as tk
from tkinter import ttk, messagebox, font
from pathlib import Path
from collections import defaultdict

class KeybindingParser:
    def __init__(self, config_dir):
        self.config_dir = Path(config_dir)
        self.keybindings = defaultdict(list)
        self.categories = {}

    def parse_file(self, file_path, category=None):
        """Parse a single config file for keybindings."""
        print(f"Parsing: {file_path}", file=sys.stderr)
        
        try:
            with open(file_path, 'r') as f:
                lines = f.readlines()
                
            # Extract includes and process them
            for i, line in enumerate(lines):
                if 'include' in line:
                    include_match = re.search(r'include\s+"([^"]+)"', line)
                    if include_match:
                        include_path = include_match.group(1)
                        if not Path(include_path).is_absolute():
                            include_path = self.config_dir / include_path
                        
                        # Determine category from filename
                        cat_name = Path(include_path).stem.capitalize()
                        self.categories[str(include_path)] = cat_name
                        
                        self.parse_file(include_path, cat_name)
            
            # Extract bindsym definitions with preceding comments
            prev_line = ""
            prev_description = None
            
            for i, line in enumerate(lines):
                # Check if the current line is a bindsym definition
                if 'bindsym' in line:
                    bindsym_match = re.search(r'bindsym\s+(\$\w+\+\S+)\s+(.+?)(?:\s*#\s*(.+))?$', line)
                    
                    if bindsym_match:
                        key_combo, command, inline_comment = bindsym_match.groups()
                        
                        # Clean up the command part
                        command = command.strip()
                        
                        # Check if the previous line was a comment (description)
                        if prev_line.strip().startswith('#'):
                            # Remove the # character and strip whitespace
                            description = prev_line.strip()[1:].strip()
                        else:
                            # Use inline comment if available, otherwise use command
                            description = inline_comment if inline_comment else command
                        
                        # Determine the actual category (use filename if not provided)
                        actual_category = category
                        if actual_category is None:
                            actual_category = Path(file_path).stem.capitalize()
                        
                        self.keybindings[actual_category].append({
                            'key': key_combo,
                            'command': command,
                            'description': description
                        })
                
                # Save the current line for the next iteration
                prev_line = line
                
        except Exception as e:
            print(f"Error parsing {file_path}: {e}", file=sys.stderr)

    def parse_config(self):
        """Parse the main config and all included files."""
        main_config = self.config_dir / "keybindings.conf"
        
        # Fallback to config if keybindings.conf doesn't exist
        if not main_config.exists():
            main_config = self.config_dir / "config"
            
        self.parse_file(main_config)
        
    def display_keybindings(self):
        """Display keybindings in a formatted way."""
        if not self.keybindings:
            print("No keybindings found!")
            return
            
        print("\n\033[1m╔══════════════════════════════════════════════════════════════════╗")
        print("║                        i3 KEYBINDINGS                            ║")
        print("╚══════════════════════════════════════════════════════════════════╝\033[0m\n")
        
        for category, bindings in sorted(self.keybindings.items()):
            if not bindings:
                continue
                
            print(f"\033[1;36m╔═══ {category} ════{'═' * (50 - len(category))}\033[0m")
            
            for binding in bindings:
                key = binding['key'].replace('$mod', 'Mod')
                description = binding['description'] if binding['description'] else binding['command']
                
                # Truncate long descriptions
                if len(description) > 60:
                    description = description[:57] + "..."
                
                print(f"\033[1;33m{key:<20}\033[0m │ \033[0;37m{description}\033[0m")
            
            print("")
        
        # Show mod key meaning
        print("\033[1;32mNOTE\033[0m: 'Mod' refers to your configured modifier key (Alt or Windows key)")


class KeybindingsGUI:
    def __init__(self, root, keybindings):
        self.root = root
        self.keybindings = keybindings
        self.all_bindings = []
        self.setup_ui()
        self.populate_data()
        
    def setup_ui(self):
        # Configure root window
        self.root.title("i3 Keybindings Viewer")
        self.root.geometry("900x600")
        
        # Add main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(expand=True, fill=tk.BOTH)
        
        # Search frame
        search_frame = ttk.Frame(main_frame)
        search_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(search_frame, text="Search:").pack(side=tk.LEFT, padx=(0, 5))
        self.search_var = tk.StringVar()
        self.search_entry = ttk.Entry(search_frame, textvariable=self.search_var, width=30)
        self.search_entry.pack(side=tk.LEFT, padx=(0, 10))
        self.search_entry.bind("<KeyRelease>", self.filter_bindings)
        
        ttk.Label(search_frame, text="Category:").pack(side=tk.LEFT, padx=(10, 5))
        self.category_var = tk.StringVar(value="All")
        self.category_combo = ttk.Combobox(search_frame, textvariable=self.category_var, state="readonly", width=20)
        self.category_combo.pack(side=tk.LEFT)
        self.category_combo.bind("<<ComboboxSelected>>", self.filter_bindings)
        
        # Create the treeview
        columns = ("Key", "Description", "Command", "Category")
        self.tree = ttk.Treeview(main_frame, columns=columns, show="headings", selectmode="browse")
        
        # Define headings
        for col in columns:
            self.tree.heading(col, text=col, anchor=tk.W)
        
        # Set column widths
        self.tree.column("Key", width=150, minwidth=100)
        self.tree.column("Description", width=350, minwidth=200)
        self.tree.column("Command", width=250, minwidth=150)
        self.tree.column("Category", width=120, minwidth=100)
        
        # Add scrollbars
        vsb = ttk.Scrollbar(main_frame, orient="vertical", command=self.tree.yview)
        hsb = ttk.Scrollbar(main_frame, orient="horizontal", command=self.tree.xview)
        self.tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        
        # Grid the treeview and scrollbars
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        vsb.pack(side=tk.RIGHT, fill=tk.Y)
        hsb.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Status bar
        self.status_var = tk.StringVar()
        status_bar = ttk.Label(self.root, textvariable=self.status_var, anchor=tk.W, padding=(10, 2))
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Set note about mod key
        self.status_var.set("NOTE: 'Mod' refers to your configured modifier key (Alt or Windows key)")
        
        # Create a custom style with alternating row colors
        style = ttk.Style()
        style.map('Treeview', background=[('selected', '#3584e4')])
        style.configure("Treeview", font=('Monospace', 10))

    def populate_data(self):
        # Collect categories for filter dropdown
        categories = ["All"]
        
        # Flatten the keybindings dictionary to populate the treeview
        for category, bindings in self.keybindings.items():
            if category not in categories:
                categories.append(category)
                
            for binding in bindings:
                key = binding['key'].replace('$mod', 'Mod')
                description = binding['description']
                command = binding['command']
                
                # Store all bindings for filtering
                self.all_bindings.append({
                    'key': key,
                    'description': description,
                    'command': command,
                    'category': category
                })
                
                # Add to treeview
                self.tree.insert("", tk.END, values=(key, description, command, category))
        
        # Update category combobox
        self.category_combo['values'] = sorted(categories)
        
        # Update status with count
        self.status_var.set(f"Found {len(self.all_bindings)} keybindings. NOTE: 'Mod' refers to your configured modifier key.")
    
    def filter_bindings(self, event=None):
        # Clear the current treeview
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        # Get search text and selected category
        search_text = self.search_var.get().lower()
        category = self.category_var.get()
        
        count = 0
        # Reinsert filtered bindings
        for binding in self.all_bindings:
            key = binding['key']
            description = binding['description']
            command = binding['command']
            bind_category = binding['category']
            
            # Apply filters
            if category != "All" and category != bind_category:
                continue
                
            if search_text and search_text not in key.lower() and search_text not in description.lower() and search_text not in command.lower():
                continue
                
            # Add matching binding to treeview
            self.tree.insert("", tk.END, values=(key, description, command, bind_category))
            count += 1
            
        # Update status with count
        if count == 0:
            self.status_var.set("No keybindings match your filter.")
        else:
            plural = "s" if count != 1 else ""
            self.status_var.set(f"Showing {count} keybinding{plural}. NOTE: 'Mod' refers to your configured modifier key.")


if __name__ == "__main__":
    # Check command line arguments to decide if we should use GUI or CLI
    use_gui = "--cli" not in sys.argv
    
    parser = KeybindingParser('/home/bedawang/.config/i3')
    parser.parse_config()
    
    if use_gui:
        try:
            root = tk.Tk()
            app = KeybindingsGUI(root, parser.keybindings)
            root.mainloop()
        except Exception as e:
            print(f"Error starting GUI: {e}. Falling back to CLI mode.", file=sys.stderr)
            parser.display_keybindings()
    else:
        parser.display_keybindings()