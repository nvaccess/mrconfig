mrconfig
========

(manage repo configuration) mrconfig


This repository is pulled down onto an NV Access server, and used to manage the updates of translations for NVDA and and NVDA add-ons

When enabling translations for an addon, add a file for it to available.d, then once merged an admin can create a symlink to it on the server. For admins:
- cd enabled.d
- ln -st ./ ../available.d/10_XYZ

These symlinks should not be added to the repository.
