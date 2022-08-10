## Open Issues

### **MP001**. Too Eeager Copying
Mousepaste is copying anything catched as AXSelectedText or via `Cmd+C`. This is due to
* all double/multi clicks being catched,
* all shift clicks being catched,
* all drag-end being catched,

regardless of
* the type of focussed App,
* the type of focussed UIElement

### **MP002**. Respect Copying Disabled
Mousepaste sends `Cmd+C` even when copying is disabled. In the Edit menu the "Copy" option may be disabled. This is
* not detected yet and
* not detected yet for multiple languages (option not named "Copy")
* however AX based selections must still work, e.g, when selecting non-editable text

### **MP003**. App-specific Settings
Some Apps may need workarounds or tweaking to copy actually usable "selected text".
For instance Finder copies the filenames when selecting files.

### **MP004**. VSCode Terminal Warnings
The embedded Terminal will complain that *The terminal has no selection to copy*
when copying an empty selection via `Cmd+C`.
To solve that Mousepaste needs to safely detect if there is an actual selection in the terminal.

### **MP005**. Allowed Apps List
The user should be able to add and remove apps for which she wants to use Mousepaste.
This way anyone can remove his imcompatible app or limit Mousepaste's scope to a specific set of apps.

### **MP006**. No Prefs Panic
Accessing User Defaults may be forbidden.
Do not crash!

### **MP007**. Broken Screenshots
Shift + Print screenshots in the pasteboard are deleted by Mousepaste.
Mousepaste must correctly restore those.
