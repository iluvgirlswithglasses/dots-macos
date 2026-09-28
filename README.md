
# Teto MacOS

Made with OmniWM, SketchyBar, JankyBorders, and more...

<img width="1238" height="800" alt="desktop-1-800-sharp" src="https://github.com/user-attachments/assets/170fb02f-9477-4d86-96ea-c67dbc1a3394" />
<img width="1238" height="800" alt="desktop-2-800-sharp" src="https://github.com/user-attachments/assets/ed51d5f6-c73a-4261-8e5c-42acf669c10a" />

## Dependencies

You might need to run `brew update` and `brew upgrade` first.

```sh
xcode-select --install
brew tap FelixKratz/formulae
brew tap albertlauncher/albert

brew install coreutils fish python lua neovim macchina media-control jq \
  koekeishiya/formulae/skhd \
  FelixKratz/formulae/borders \
  FelixKratz/formulae/sketchybar
brew install --cask alacritty omniwm albert \
  font-space-mono-nerd-font font-gabarito
```

## Installation

```sh
# clone this repo
git clone --recurse-submodules https://github.com/iluvgirlswithglasses/dots-macos
cd dots-macos

# copy config
mkdir -p ~/.config
cp -r .config/* ~/.config/

# build lua sketchybar
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
chmod +x ~/.config/borders/bordersrc ~/.config/sketchybar/sketchybarrc

# run services
open -a OmniWM
brew services start sketchybar
brew services start borders
skhd --start-service
```

- You'd need to grant permissions to OmniWM, SketchyBar, JankyBorders, skhd, and Albert at **Settings > Privacy & Security > Accessibility**.
- You'd want to launch them on startup too: **Settings > General > Login Items & Extensions**.

## Notes

- Check [skhd config](./.config/skhd/skhdrc) for hotkeys.
- Check [fish config](./.config/fish/config.fish) for expected dirs in `$PATH` variables.

