# NVim Statusbar Plugin

This is a Neovim plugin that provides a highly customizable and visually appealing statusbar inspired by [Zellij](https://zellij.dev/). The plugin leverages the same logic as [mini.clue](https://github.com/siduck76/mini.clue) (similar to [which-key](https://github.com/folke/which-key.nvim)) to display contextual keybindings and modes in a clean and intuitive way.

## Features

- **Z Mode**: A mode inspired by Zellij's keybinding hints, providing a quick overview of available commands.
- **Insert Mode**: Displays relevant keybindings and information while in insert mode.
- **Builtin Completion Mode**: Shows suggestions and completions directly in the statusbar.
- **Register Mode**: Provides a quick view of available registers and their contents.
- **Windows Mode**: Displays keybindings and information related to window management.

## Installation

You can install this plugin using your favorite plugin manager. For example, using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'iodize13/no-pain',
  requires = { 'iodize13/no-pain' } -- or any other dependencies
}
```

## Screenshots

### Z Mode
![Z Mode](images/fold.png)

### Insert Mode
![Insert Mode](images/insert.png)

### Builtin Completion Mode
![Builtin Completion Mode](images/completion.png)

### Register Mode
![Register Mode](images/register.png)

### Windows Mode
![Windows Mode](images/windows.png)

## Usage

Once installed and configured, the statusbar will automatically display the relevant information based on the current mode and context. You can customize the appearance and behavior through the setup function.
