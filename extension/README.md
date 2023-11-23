# DevOn Hangar CI/CD pipeline extension

## Features

This extension is meant to show different Hangar executions CI/CD scripts.

## Available scripts
- 🆙 Create repo
- ⏩ Pipeline generator

## Requirements

VS Code must be version **1.83.0** or higher!

---

# HOW TO?
## 1) Exporting the Extension for Sharing

To share this extension with others without publishing it to the **VS Code Extension Marketplace**, you can package it into a `.vsix` file.
Here are the steps to do so:

1. Install the `vsce` command line tool globally with **super user permissions**. This tool is used for managing VS Code extensions. You can install it using npm: `sudo npm install --global vsce`
2. Open a terminal and navigate to the root directory of this extension.
3. Run the following command to package the extension: `vsce package`

This will create a `.vsix` file in the extension's directory.

Now you can share this file with others.

## 2) Installing the Extension from a `.vsix` File

To install the extension from a `.vsix` file, follow these steps:

1. Open VS Code.
2. Go to the Extensions view (*you can use the `Ctrl+Shift+X` shortcut*).
3. Click on the `...` at the top right of the Extensions view, select `Install from VSIX...` and choose the `.vsix` file.

Now the extension will be installed and ready to use.

---

# Release Notes

## 1.0.0

- Initial release


--- 

# Bugs?

Email to: hector-antonio.santana-beneyto@capgemini.com