# Coco
Some usefull additions to Choco: backup &amp; restore, installed, clean-up and reinstall:

```
λ coco -h

=== ( ͡° ͜ʖ ͡°) ============================================
=            Watch out! Hot coco overhere!!!            =
============================================ ( ͡° ͜ʖ ͡°) ===

COCO is a set of customizations to Chocolatey.
For suggestions, you can reach me @zarcolio on Twitter or Github.

Usage:

 COCO backup [batch]            Creates a backup of installed packages to text (default) or batch file.
 COCO cleanup                   Cleans the Chocolatey environment from temp and other useless files.
 COCO installed <package>       Lists which packages have been installed.
 COCO reinstall <package> [-y]  Reinstall this package by uninstalling and installing this package.
 COCO restore <file>            Restore a backup from file.
 COCO setup                     Sets up Coco (installs choco-cleaner)
 
