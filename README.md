# Coco
Some usefull additions to Chocolatey: backup &amp; restore, installed, clean-up and reinstall:

```
λ coco -h

    | ᶜᵒᶜᵒᵃ |
=== ( ° ͜ʖ ͡° ) ============================================
=            Watch out! Hot coco overhere!!! | ᶜᵒᶜᵒᵃ |   =
============================================ ( ° ͜ʖ ͡° ) ===

COCOA is a set of customizations to Chocolatey.
For suggestions, you can reach me @zarcolio on Twitter or GitHub.

Usage:

 COCOA backup [batch]            Creates a backup of installed packages to text (default) or batch file.
 COCOA cleanup                   Cleans the Chocolatey environment from temp and other useless files.
 COCOA installed [<package>]     Lists which packages have been installed.
 COCOA reinstall <package> [-y]  Reinstall this package by uninstalling and installing this package.
 COCOA restore <file>            Restore a backup from file.
 COCOA setup                     Sets up Coco (installs choco-cleaner and Coco itself).
 COCOA update [-y]               updates all packages but only shows updated packages. 
