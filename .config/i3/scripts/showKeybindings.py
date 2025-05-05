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
        self.mod_key = "unknown"  # Default value if we can't find the definition
        
    def find_mod_key(self):
        """Find the $mod key definition in the config files."""
        # Check main config file first
        config_file = self.config_dir.parent / "config"
        if not config_file.exists():
            return "unknown"
            
        try:
            with open(config_file, 'r') as f:
                content = f.read()
                
            # Look for the mod key definition
            mod_pattern = re.compile(r'set\s+\$mod\s+(Mod[1-5]|mod[1-5])', re.IGNORECASE)
            match = mod_pattern.search(content)
            
            if match:
                mod_key = match.group(1)
                # Map Mod4 to a user-friendly name
                mod_mappings = {
                    'mod1': 'Alt',
                    'mod4': 'Super (Windows key)',
                    'mod5': 'AltGr'
                }
                
                # Convert to lowercase for comparison
                mod_key_lower = mod_key.lower()
                if mod_key_lower in mod_mappings:
                    return f"{mod_key} ({mod_mappings[mod_key_lower]})"
                return mod_key
        except Exception as e:
            print(f"Error reading config file: {e}", file=sys.stderr)
            
        return "unknown"
    
    def parse_file(self, file_path, category=None):
        """Parse a single config file for keybindings."""
        print(f"Parsing: {file_path}", file=sys.stderr)
        
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Process includes first
            include_pattern = re.compile(r'include\s+"([^"]+)"')
            for include_match in include_pattern.finditer(content):
                include_path = include_match.group(1)
                if not Path(include_path).is_absolute():
                    include_path = self.config_dir / include_path
                
                # Determine category from filename
                cat_name = Path(include_path).stem.capitalize()
                self.categories[str(include_path)] = cat_name
                
                self.parse_file(include_path, cat_name)
            
            # Extract mode definitions and nested bindsym definitions
            mode_pattern = re.compile(r'set\s+\$(\w+)\s+(.+)|mode\s+"(\$[^"]+)"\s*{([^}]+)}', re.DOTALL)
            mode_vars = {}
            
            # Find mode variable definitions
            for mode_match in re.finditer(r'set\s+\$(\w+)\s+(.+)', content):
                var_name, var_value = mode_match.groups()
                mode_vars[f"${var_name}"] = var_value.strip().strip('"')
            
            # Find mode blocks with bindings
            mode_blocks = re.finditer(r'mode\s+"(\$[^"]+|[^"]+)"\s*{([^}]+)}', content) # Fixed to catch all mode blocks
            for mode_block in mode_blocks:
                mode_name, mode_content = mode_block.groups()
                # Resolve mode variable to its description
                mode_desc = mode_vars.get(mode_name, mode_name)
                
                # Find the key combination that activates this mode
                mode_activator = self.find_mode_activator(content, mode_name)
                
                # Now parse bindings inside this mode
                prev_line = ""
                for line in mode_content.split('\n'):
                    line = line.strip()
                    if not line or line.startswith('#'):
                        prev_line = line
                        continue
                        
                    bindsym_match = re.search(r'bindsym\s+(\S+)\s+(.+?)(?:\s*#\s*(.+))?$', line)
                    if bindsym_match:
                        key_combo, command, inline_comment = bindsym_match.groups()
                        command = command.strip()
                        
                        # Check if previous line was a comment (description)
                        if prev_line.strip().startswith('#'):
                            description = prev_line.strip()[1:].strip()
                        else:
                            description = inline_comment if inline_comment else command
                        
                        # Form the hierarchical key combo: mod+key > mode_key
                        full_key_combo = f"{mode_activator} > {key_combo}" if mode_activator else key_combo
                        
                        # Store the binding with the special mode category
                        actual_category = category if category else Path(file_path).stem.capitalize()
                        
                        # Set is_mode to True for all bindings within a mode block
                        is_mode = True
                        
                        # Check if this is another mode activation
                        if "mode" in command and re.search(r'mode\s+"(\$[^"]+|[^"]+)"', command):
                            # This is a submenu mode activation
                            self.keybindings[actual_category].append({
                                'key': full_key_combo,
                                'command': command,
                                'description': f"Enter {description} mode",
                                'is_mode': True,
                                'mode_name': command.strip().strip('"'),
                                'is_submenu': True  # Mark as submenu for special styling
                            })
                        else:
                            self.keybindings[actual_category].append({
                                'key': full_key_combo,
                                'command': command,
                                'description': description,
                                'is_mode': True,  # Mark all bindings in a mode block
                                'is_action': True  # This is an action within a mode
                            })
                    
                    prev_line = line
            
            # Process normal bindsym definitions (outside of modes)
            lines = content.split('\n')
            prev_line = ""
            mode_section = False
            
            for i, line in enumerate(lines):
                # Skip lines inside mode blocks
                if '{' in line and 'mode' in line:
                    mode_section = True
                    continue
                if mode_section and '}' in line:
                    mode_section = False
                    continue
                if mode_section:
                    continue
                
                # Process regular bindsym lines
                if 'bindsym' in line:
                    bindsym_match = re.search(r'bindsym\s+(\$\w+\+\S+|\S+)\s+(.+?)(?:\s*#\s*(.+))?$', line)
                    
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
                        
                        # Check if this activates a mode
                        if "mode" in command and "$mode_" in command:
                            mode_name = command.strip().strip('"')
                            mode_desc = mode_vars.get(mode_name, mode_name)
                            
                            self.keybindings[actual_category].append({
                                'key': key_combo,
                                'command': command,
                                'description': f"Enter {mode_desc}",
                                'is_mode': True,
                                'mode_name': mode_name
                            })
                        else:
                            self.keybindings[actual_category].append({
                                'key': key_combo,
                                'command': command,
                                'description': description,
                                'is_mode': False
                            })
                
                # Save the current line for the next iteration
                prev_line = line
                
        except Exception as e:
            print(f"Error parsing {file_path}: {e}", file=sys.stderr)
        
    def find_mode_activator(self, content, mode_name):
        """Find the key binding that activates a specific mode."""
        activator_match = re.search(r'bindsym\s+(\$\w+\+\S+|\S+)\s+mode\s+"' + re.escape(mode_name) + '"', content)
        if activator_match:
            return activator_match.group(1)
        return None

    def parse_config(self):
        """Parse the main config and all included files."""
        # Find the mod key first
        self.mod_key = self.find_mod_key()
        
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
                
                # Highlight mode activations
                if binding.get('is_mode', False):
                    key_format = "\033[1;35m{:<30}\033[0m"  # Purple for mode keys
                else:
                    key_format = "\033[1;33m{:<30}\033[0m"  # Yellow for regular keys
                
                # Truncate long descriptions
                if len(description) > 50:
                    description = description[:47] + "..."
                
                print(f"{key_format.format(key)} │ \033[0;37m{description}\033[0m")
            
            print("")
        
        # Show mod key meaning
        print(f"\033[1;32mNOTE\033[0m: 'Mod' refers to {self.mod_key}")


class KeybindingsGUI:
    def __init__(self, root, keybindings, mod_key):
        self.root = root
        self.keybindings = keybindings
        self.mod_key = mod_key
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
        self.tree.column("Key", width=200, minwidth=150)  # Made wider for hierarchical keys
        self.tree.column("Description", width=300, minwidth=200)
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
        self.status_var.set(f"NOTE: 'Mod' refers to {self.mod_key}")
        
        # Create custom styles for the treeview
        style = ttk.Style()
        style.map('Treeview', background=[('selected', '#3584e4')])
        style.configure("Treeview", font=('Monospace', 10))
        
        # Mode binding style tag
        self.tree.tag_configure('mode', foreground='#9141ac')  # Purple for mode keys

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
                is_mode = binding.get('is_mode', False)
                
                # Store all bindings for filtering
                self.all_bindings.append({
                    'key': key,
                    'description': description,
                    'command': command,
                    'category': category,
                    'is_mode': is_mode
                })
                
                # Add to treeview with appropriate tags
                item_id = self.tree.insert("", tk.END, values=(key, description, command, category))
                if is_mode:
                    self.tree.item(item_id, tags=('mode',))
        
        # Update category combobox
        self.category_combo['values'] = sorted(categories)
        
        # Update status with count and mod key info
        self.status_var.set(f"Found {len(self.all_bindings)} keybindings. NOTE: 'Mod' refers to {self.mod_key}")
    
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
            is_mode = binding.get('is_mode', False)
            
            # Apply filters
            if category != "All" and category != bind_category:
                continue
                
            if search_text and search_text not in key.lower() and search_text not in description.lower() and search_text not in command.lower():
                continue
                
            # Add matching binding to treeview with appropriate tags
            item_id = self.tree.insert("", tk.END, values=(key, description, command, bind_category))
            if is_mode:
                self.tree.item(item_id, tags=('mode',))
            count += 1
            
        # Update status with count
        if count == 0:
            self.status_var.set("No keybindings match your filter.")
        else:
            plural = "s" if count != 1 else ""
            self.status_var.set(f"Showing {count} keybinding{plural}. NOTE: 'Mod' refers to {self.mod_key}")


if __name__ == "__main__":
    # Check command line arguments to decide if we should use GUI or CLI
    use_gui = "--cli" not in sys.argv
    
    parser = KeybindingParser('/home/bedawang/.config/i3/keybindings')
    parser.parse_config()
    
    if use_gui:
        try:
            root = tk.Tk()
            app = KeybindingsGUI(root, parser.keybindings, parser.mod_key)
            root.mainloop()
        except Exception as e:
            print(f"Error starting GUI: {e}. Falling back to CLI mode.", file=sys.stderr)
            parser.display_keybindings()
    else:
        parser.display_keybindings()