A custom fork of [fzf.xplr](https://github.com/twio142/fzf.xplr) with some additional features.

- Support custom name, so the plugin can be required multiple times with different setups.
- Support callback function to handle the selected path.

Examples:

```lua
-- default fzf, excluding unnecessary files, with preview
-- see: https://github.com/junegunn/fzf/blob/master/bin/fzf-preview.sh
require("fzf").setup{
  bin = "fd",
  args = "--hidden --follow --exclude .DS_Store --exclude .git . . | fzf -m --preview '$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}'",
  recursive = true,
  enter_dir = true,
}

-- fzf + autojump
-- see: https://github.com/wting/autojump
require("fzf").setup{
  name = "autojump",
  args = [[ --bind "start:reload:autojump --complete '' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --bind "change:reload:autojump --complete '{q}' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --disabled --preview 'tree -C {} -L 4' | xargs -I {} realpath "{}" ]],
  recursive = true,
  enter_dir = true,
  mode = "go_to",
  key = "j"
}

-- search file contents
-- see: https://github.com/junegunn/fzf/wiki/Examples#searching-file-contents
require("fzf").setup{
  name = "fif",
  bin = home .. "/bin/fif",
  args = "-o",
  recursive = true,
  mode = "search",
  key = "ctrl-s",
  callback = "custom.fif_callback"
}

-- open file in vim at the specific line
xplr.fn.custom.fif_callback = function(input)
  local path, line = input:match("^([^:]+):(%d+):")
  return {
    { BashExec = string.format("nvim +%s %s", line, path) },
    "PopMode",
  }
end
```

---

[![xplr-fzf.gif](https://s4.gifyu.com/images/xplr-fzf.gif)](https://gifyu.com/image/rG21)

## Requirements

- [fzf](https://github.com/junegunn/fzf)

## Installation

### Install manually

- Add the following line in `~/.config/xplr/init.lua`

  ```lua
  local home = os.getenv("HOME")
  package.path = home
  .. "/.config/xplr/plugins/?/init.lua;"
  .. home
  .. "/.config/xplr/plugins/?.lua;"
  .. package.path
  ```

- Clone the plugin

  ```bash
  mkdir -p ~/.config/xplr/plugins

  git clone https://github.com/sayanarijit/fzf.xplr ~/.config/xplr/plugins/fzf
  ```

- Require the module in `~/.config/xplr/init.lua`

  ```lua
  require("fzf").setup()

  -- Or

  require("fzf").setup{
    mode = "default",
    key = "ctrl-f",
    bin = "fzf",
    args = "--preview 'pistol {}'",
    recursive = false,  -- If true, search all files under $PWD
    enter_dir = false,  -- Enter if the result is directory
  }

  -- Press `ctrl-f` to spawn fzf in $PWD
  ```

## Features

- Search is done on the filtered sorted paths via xplr.
- Option to toggle into recursive search.
- Option to toggle enter directory.
