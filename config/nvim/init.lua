-- VSCode Neovim Configuration
-- VSCode Neovim Configuration
-- Leader key
vim.g.mapleader = " "      -- Space
vim.g.maplocalleader = "," -- Comma

-- Global settings
vim.opt.fileformats = { "unix", "dos" }
vim.opt.clipboard = "unnamedplus" -- System clipboard sync
vim.opt.ignorecase = true         -- Search ignore case
vim.opt.smartcase = true          -- Smart case for uppercase
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Incremental search

-- Mouse settings
vim.opt.mouse = "a"

-- Basic vim mappings
vim.keymap.set("n", "'", ";")                       -- Repeat f/t movement
vim.keymap.set("v", "p", '"_dP')                    -- Paste without overwriting clipboard
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>") -- Clear search highlight

-- Movement improvements
vim.cmd("nmap j gj") -- Skip folds down
vim.cmd("nmap k gk") -- skip folds up

if vim.g.vscode then
  require("vs.lazy")
  local opts = { noremap = true, silent = true }

  local mappings = {
    -- Basic actions
    { "n", "u",                "undo" },                 -- Undo
    { "n", "U",                "redo" },                 -- Redo
    { "i", "jk",               "vscode-neovim.escape" }, -- Escape insert mode
    { "i", "kj",               "vscode-neovim.escape" }, -- Escape insert mode

    -- File operations
    { "n", "<localleader>,",   "workbench.action.files.save" },                    -- Save file
    { "v", "<localleader>,",   "workbench.action.files.save" },                    -- Save file
    { "n", "<leader>ef",       "workbench.view.explorer" },                        -- Open explorer
    { "n", "<leader>ec",       "workbench.files.action.collapseExplorerFolders" }, -- Collapse folders
    { "n", "<leader><leader>", "workbench.action.quickOpen" },                     -- Quick open

    -- Text editing
    { "n", "<leader>wu",       "editor.action.transformToUppercase" }, -- Word to UPPERCASE
    { "n", "<leader>wl",       "editor.action.transformToLowercase" }, -- Word to lowercase

    -- Comments
    -- { "n", "gc",                         "editor.action.commentLine" },  -- Comment line
    -- { "v", "gc",                         "editor.action.commentLine" },  -- Comment selection
    -- { "n", "gcp",                        "editor.action.blockComment" }, -- Block comment
    -- { 'n', 'gca',                        "editor.action.addCommentLine" }, -- add comment line end

    -- Multi cursor
    { "n", "<leader>ma",       "editor.action.selectAllMatches" }, -- Select all matches
    { "n", "<leader>mh",       "editor.action.selectHighlights" }, -- Select all matches

    -- Emmet
    { "n", "<leader>mw",       "editor.emmet.action.wrapWithAbbreviation" }, -- Wrap with emmet
    { "n", "<leader>mk",       "editor.emmet.action.updateTag" },            -- Update tag
    { "n", "<leader>mm",       "editor.emmet.action.matchTag" },             -- Match tag

    -- Smart selection
    { "n", "<leader>se",       "editor.action.smartSelect.expand" },          -- Expand selection
    { "n", "<leader>an",       "editor.action.addSelectionToNextFindMatch" }, -- Add next match

    -- Problems & diagnostics
    { "n", "<leader>pr",       "workbench.actions.view.problems" }, -- Problems panel

    -- Change case
    { "n", "<leader>wt",       "editor.action.transformToTitlecase" },  -- Title Case
    { "n", "<leader>ws",       "editor.action.transformToSnakecase" },  -- snake_case
    { "n", "<leader>wc",       "editor.action.transformToCamelcase" },  -- camelCase
    { "n", "<leader>wp",       "editor.action.transformToPascalcase" }, -- PascalCase
    { "n", "<leader>wk",       "editor.action.transformToKebabcase" },  -- kebab-case

    -- Code folding
    { "n", "zc",               "editor.fold" },      -- Fold
    { "n", "zo",               "editor.unfold" },    -- Unfold
    { "n", "zM",               "editor.foldAll" },   -- Fold all
    { "n", "zR",               "editor.unfoldAll" }, -- Unfold all

    -- Tab navigation
    { "n", "<leader>1",        "workbench.action.openEditorAtIndex1" }, -- Go to tab 1
    { "n", "<leader>2",        "workbench.action.openEditorAtIndex2" }, -- Go to tab 2
    { "n", "<leader>3",        "workbench.action.openEditorAtIndex3" }, -- Go to tab 3
    { "n", "gn",               "workbench.action.nextEditor" },         -- Next editor
    { "n", "gp",               "workbench.action.previousEditor" },     -- Previous editor

    -- Terminal navigation
    { "n", "<leader>tt",       "workbench.action.terminal.toggleTerminal" }, -- Toggle
    { "n", "<leader>tn",       "workbench.action.terminal.new" },            -- New terminal
    { "n", "<leader>tf",       "workbench.action.terminal.focus" },          -- Focus terminal

    -- Smart word navigation & windows
    { "n", "w",                "cursorWordPartRight" },               -- Word part right
    { "n", "b",                "cursorWordPartLeft" },                -- Word part left
    { "v", "w",                "cursorWordPartRightSelect" },         -- Select word part right
    { "v", "b",                "cursorWordPartLeftSelect" },          -- Select word part left
    { "n", "<leader>wv",       "workbench.action.splitEditor" },      -- Split vertical
    { "n", "<leader>wh",       "workbench.action.splitEditorDown" },  -- Split horizontal
    { "n", "<leader>ww",       "workbench.action.joinTwoGroups" },    -- Join groups
    { "n", "<leader>wa",       "workbench.action.evenEditorWidths" }, -- Even widths

    -- Code navigation & definitions
    { "n", "<leader>gd",       "editor.action.revealDefinition" },              -- Go to definition
    { "n", "<leader>gy",       "editor.action.goToTypeDefinition" },            -- Go to type def
    { "n", "<leader>gi",       "editor.action.goToImplementation" },            -- Go to implementation
    { "n", "<leader>gr",       "editor.action.goToReferences" },                -- Go to references
    { "n", "<leader>gs",       "workbench.action.gotoSymbol" },                 -- Go to symbol
    { "n", "<leader>gl",       "workbench.action.gotoLine" },                   -- Go to line
    { "n", "<leader>jf",       "workbench.action.navigateForward" },            -- Navigate forward
    { "n", "<leader>jb",       "workbench.action.navigateBack" },               -- Navigate back
    { "n", "<leader>je",       "workbench.action.navigateToLastEditLocation" }, -- Jump to last edit

    -- Quick search & peek actions
    { "n", "<leader>ss",       "workbench.action.showAllSymbols" },                 -- Show all symbols
    { "n", "<leader>sa",       "workbench.action.showCommands" },                   -- Show commands
    { "n", "<leader>so",       "workbench.action.quickOpen" },                      -- Show files
    { "n", "<leader>sf",       "workbench.action.navigateForwardInEditLocations" }, -- Show files
    { "n", "<leader>sb",       "workbench.action.navigateBackInEditLocations" },    -- Show files
    { "n", "<leader>vd",       "editor.action.peekDefinition" },                    -- Peek definition
    { "n", "<leader>vi",       "editor.action.peekImplementation" },                -- Peek implementation
    { "n", "<leader>vt",       "editor.action.peekTypeDefinition" },                -- Peek type definition
    { "n", "<leader>vh",       "editor.action.showHover" },                         -- Show hover
    { "n", "<leader>vr",       "references-view.findReferences" },                  -- Find references
    { "n", "<leader>sr",       "editor.action.referenceSearch.trigger" },           -- Reference search

    -- Find, replace & refactoring
    { "n", "<leader>ff",       "actions.find" },                         -- Find
    { "n", "<leader>fr",       "editor.action.startFindReplaceAction" }, -- Find & replace
    { "n", "<leader>fg",       "workbench.action.findInFiles" },         -- Find in files
    { "n", "<leader>rg",       "workbench.action.replaceInFiles" },      -- Replace in files
    { "n", "<leader>re",       "editor.action.rename" },                 -- Rename
    { "n", "<leader>rf",       "editor.action.refactor" },               -- Refactor
    { "n", "<leader>qf",       "editor.action.quickFix" },               -- Quick fix
    { "n", "<leader>sg",       "editor.action.triggerSuggest" },         -- Suggestions

    -- Line editing & code maintenance
    { "n", "<leader>lu",       "editor.action.copyLinesUpAction" },   -- Copy lines up
    { "n", "<leader>ld",       "editor.action.copyLinesDownAction" }, -- Copy lines down
    { "n", "<leader>mu",       "editor.action.moveLinesUpAction" },   -- Move lines up
    { "n", "<leader>md",       "editor.action.moveLinesDownAction" }, -- Move lines down
    { "n", "<leader>fm",       "editor.action.formatDocument" },      -- Format document
    { "n", "<leader>oi",       "editor.action.organizeImports" },     -- Organize imports
    { "n", "<leader>en",       "editor.action.marker.next" },         -- Next error
    { "n", "<leader>ep",       "editor.action.marker.prev" },         -- Previous error

    -- File & workspace management
    { "n", "<leader>cp",       "copyFilePath" },                             -- Copy file path
    { "n", "<leader>cr",       "copyRelativeFilePath" },                     -- Copy relative path
    { "n", "<leader>rl",       "workbench.action.openRecent" },              -- Recent files
    { "n", "<leader>nF",       "workbench.action.files.newUntitledFile" },   -- New file
    { "n", "<leader>cf",       "workbench.action.closeActiveEditor" },       -- Close file
    { "n", "<leader>fa",       "workbench.action.closeAllEditors" },         -- Close all files
    { "n", "<leader>of",       "workbench.action.files.openFile" },          -- Open file
    { "n", "<leader>rw",       "workbench.action.reloadWindow" },            -- Reload window
    { "n", "<leader>os",       "workbench.action.openSettingsJson" },        -- Open settings
    { "n", "<leader>th",       "workbench.action.toggleSidebarVisibility" }, -- Toggle sidebar
  }

  -- Movement mappings
  local movement_mappings = {
    { 'Space', '<Nop>' }, --Nop
    -- { "J",     "5j" },    -- Jump 5 lines down
    -- { "K",     "5k" },    -- Jump 5 lines up
    { "H",     "^" }, -- Go to line start
    { "L",     "$" }, -- Go to line end
  }
  -- Select, delete, copy all mappings
  vim.keymap.set("n", "vag", "ggVG", opts)  -- Select all
  vim.keymap.set("n", "dag", "ggVGd", opts) -- Delete all
  vim.keymap.set("n", "yag", "ggVGy", opts) -- Copy all


  -- Apply movement mappings to normal and visual modes
  for _, mapping in ipairs(movement_mappings) do
    local key, action = mapping[1], mapping[2]
    vim.keymap.set("n", key, action, opts)
    vim.keymap.set("v", key, action, opts)
  end

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("VSCodeYankHighlight", { clear = true }),
    pattern = "*",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
  })

  -- Visual star search
  vim.keymap.set("v", "*", function()
    local lines = vim.fn.getline("'<", "'>")
    local text = ""

    if type(lines) == "table" then
      if #lines == 1 then
        text = lines[1]:sub(vim.fn.col("'<"), vim.fn.col("'>"))
      else
        text = table.concat(lines, "\n")
      end
    else
      text = lines
    end

    vim.fn.setreg("/", text)
    vim.fn.VSCodeNotify("actions.find")
  end, opts)

  -- Apply all VSCode mappings
  for _, mapping in ipairs(mappings) do
    local mode, key, command = mapping[1], mapping[2], mapping[3]
    vim.keymap.set(mode, key, function()
      vim.fn.VSCodeNotify(command)
    end, opts)
  end
else
  require("config.lazy")
  -- Regular neovim mode
end

-- Leader key
vim.g.mapleader = " "      -- Space
vim.g.maplocalleader = "," -- Comma

-- Global settings
vim.opt.fileformats = { "unix", "dos" }
vim.opt.clipboard = "unnamedplus" -- System clipboard sync
vim.opt.ignorecase = true         -- Search ignore case
vim.opt.smartcase = true          -- Smart case for uppercase
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Incremental search

-- Mouse settings
vim.opt.mouse = "a"

-- Basic vim mappings
vim.keymap.set("n", "'", ";")                       -- Repeat f/t movement
vim.keymap.set("v", "p", '"_dP')                    -- Paste without overwriting clipboard
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>") -- Clear search highlight

-- Movement improvements
vim.cmd("nmap j gj") -- Skip folds down
vim.cmd("nmap k gk") -- skip folds up

if vim.g.vscode then
  require("vs.lazy")
  local opts = { noremap = true, silent = true }

  local mappings = {
    -- Basic actions
    { "n", "u",                "undo" },                 -- Undo
    { "n", "U",                "redo" },                 -- Redo
    { "i", "jk",               "vscode-neovim.escape" }, -- Escape insert mode
    { "i", "kj",               "vscode-neovim.escape" }, -- Escape insert mode

    -- File operations
    { "n", "<localleader>,",   "workbench.action.files.save" },                    -- Save file
    { "v", "<localleader>,",   "workbench.action.files.save" },                    -- Save file
    { "n", "<leader>ef",       "workbench.view.explorer" },                        -- Open explorer
    { "n", "<leader>ec",       "workbench.files.action.collapseExplorerFolders" }, -- Collapse folders
    { "n", "<leader><leader>", "workbench.action.quickOpen" },                     -- Quick open

    -- Text editing
    { "n", "<leader>wu",       "editor.action.transformToUppercase" }, -- Word to UPPERCASE
    { "n", "<leader>wl",       "editor.action.transformToLowercase" }, -- Word to lowercase

    -- Comments
    -- { "n", "gc",                         "editor.action.commentLine" },  -- Comment line
    -- { "v", "gc",                         "editor.action.commentLine" },  -- Comment selection
    -- { "n", "gcp",                        "editor.action.blockComment" }, -- Block comment
    -- { 'n', 'gca',                        "editor.action.addCommentLine" }, -- add comment line end

    -- Multi cursor
    { "n", "<leader>ma",       "editor.action.selectAllMatches" }, -- Select all matches
    { "n", "<leader>mh",       "editor.action.selectHighlights" }, -- Select all matches

    -- Emmet
    { "n", "<leader>mw",       "editor.emmet.action.wrapWithAbbreviation" }, -- Wrap with emmet
    { "n", "<leader>mk",       "editor.emmet.action.updateTag" },            -- Update tag
    { "n", "<leader>mm",       "editor.emmet.action.matchTag" },             -- Match tag

    -- Smart selection
    { "n", "<leader>se",       "editor.action.smartSelect.expand" },          -- Expand selection
    { "n", "<leader>an",       "editor.action.addSelectionToNextFindMatch" }, -- Add next match

    -- Problems & diagnostics
    { "n", "<leader>pr",       "workbench.actions.view.problems" }, -- Problems panel

    -- Change case
    { "n", "<leader>wt",       "editor.action.transformToTitlecase" },  -- Title Case
    { "n", "<leader>ws",       "editor.action.transformToSnakecase" },  -- snake_case
    { "n", "<leader>wc",       "editor.action.transformToCamelcase" },  -- camelCase
    { "n", "<leader>wp",       "editor.action.transformToPascalcase" }, -- PascalCase
    { "n", "<leader>wk",       "editor.action.transformToKebabcase" },  -- kebab-case

    -- Code folding
    { "n", "zc",               "editor.fold" },      -- Fold
    { "n", "zo",               "editor.unfold" },    -- Unfold
    { "n", "zM",               "editor.foldAll" },   -- Fold all
    { "n", "zR",               "editor.unfoldAll" }, -- Unfold all

    -- Tab navigation
    { "n", "<leader>1",        "workbench.action.openEditorAtIndex1" }, -- Go to tab 1
    { "n", "<leader>2",        "workbench.action.openEditorAtIndex2" }, -- Go to tab 2
    { "n", "<leader>3",        "workbench.action.openEditorAtIndex3" }, -- Go to tab 3
    { "n", "gn",               "workbench.action.nextEditor" },         -- Next editor
    { "n", "gp",               "workbench.action.previousEditor" },     -- Previous editor

    -- Terminal navigation
    { "n", "<leader>tt",       "workbench.action.terminal.toggleTerminal" }, -- Toggle
    { "n", "<leader>tn",       "workbench.action.terminal.new" },            -- New terminal
    { "n", "<leader>tf",       "workbench.action.terminal.focus" },          -- Focus terminal

    -- Smart word navigation & windows
    { "n", "w",                "cursorWordPartRight" },               -- Word part right
    { "n", "b",                "cursorWordPartLeft" },                -- Word part left
    { "v", "w",                "cursorWordPartRightSelect" },         -- Select word part right
    { "v", "b",                "cursorWordPartLeftSelect" },          -- Select word part left
    { "n", "<leader>wv",       "workbench.action.splitEditor" },      -- Split vertical
    { "n", "<leader>wh",       "workbench.action.splitEditorDown" },  -- Split horizontal
    { "n", "<leader>ww",       "workbench.action.joinTwoGroups" },    -- Join groups
    { "n", "<leader>wa",       "workbench.action.evenEditorWidths" }, -- Even widths

    -- Code navigation & definitions
    { "n", "<leader>gd",       "editor.action.revealDefinition" },              -- Go to definition
    { "n", "<leader>gy",       "editor.action.goToTypeDefinition" },            -- Go to type def
    { "n", "<leader>gi",       "editor.action.goToImplementation" },            -- Go to implementation
    { "n", "<leader>gr",       "editor.action.goToReferences" },                -- Go to references
    { "n", "<leader>gs",       "workbench.action.gotoSymbol" },                 -- Go to symbol
    { "n", "<leader>gl",       "workbench.action.gotoLine" },                   -- Go to line
    { "n", "<leader>jf",       "workbench.action.navigateForward" },            -- Navigate forward
    { "n", "<leader>jb",       "workbench.action.navigateBack" },               -- Navigate back
    { "n", "<leader>je",       "workbench.action.navigateToLastEditLocation" }, -- Jump to last edit

    -- Quick search & peek actions
    { "n", "<leader>ss",       "workbench.action.showAllSymbols" },                 -- Show all symbols
    { "n", "<leader>sa",       "workbench.action.showCommands" },                   -- Show commands
    { "n", "<leader>so",       "workbench.action.quickOpen" },                      -- Show files
    { "n", "<leader>sf",       "workbench.action.navigateForwardInEditLocations" }, -- Show files
    { "n", "<leader>sb",       "workbench.action.navigateBackInEditLocations" },    -- Show files
    { "n", "<leader>vd",       "editor.action.peekDefinition" },                    -- Peek definition
    { "n", "<leader>vi",       "editor.action.peekImplementation" },                -- Peek implementation
    { "n", "<leader>vt",       "editor.action.peekTypeDefinition" },                -- Peek type definition
    { "n", "<leader>vh",       "editor.action.showHover" },                         -- Show hover
    { "n", "<leader>vr",       "references-view.findReferences" },                  -- Find references
    { "n", "<leader>sr",       "editor.action.referenceSearch.trigger" },           -- Reference search

    -- Find, replace & refactoring
    { "n", "<leader>ff",       "actions.find" },                         -- Find
    { "n", "<leader>fr",       "editor.action.startFindReplaceAction" }, -- Find & replace
    { "n", "<leader>fg",       "workbench.action.findInFiles" },         -- Find in files
    { "n", "<leader>rg",       "workbench.action.replaceInFiles" },      -- Replace in files
    { "n", "<leader>re",       "editor.action.rename" },                 -- Rename
    { "n", "<leader>rf",       "editor.action.refactor" },               -- Refactor
    { "n", "<leader>qf",       "editor.action.quickFix" },               -- Quick fix
    { "n", "<leader>sg",       "editor.action.triggerSuggest" },         -- Suggestions

    -- Line editing & code maintenance
    { "n", "<leader>lu",       "editor.action.copyLinesUpAction" },   -- Copy lines up
    { "n", "<leader>ld",       "editor.action.copyLinesDownAction" }, -- Copy lines down
    { "n", "<leader>mu",       "editor.action.moveLinesUpAction" },   -- Move lines up
    { "n", "<leader>md",       "editor.action.moveLinesDownAction" }, -- Move lines down
    { "n", "<leader>fm",       "editor.action.formatDocument" },      -- Format document
    { "n", "<leader>oi",       "editor.action.organizeImports" },     -- Organize imports
    { "n", "<leader>en",       "editor.action.marker.next" },         -- Next error
    { "n", "<leader>ep",       "editor.action.marker.prev" },         -- Previous error

    -- File & workspace management
    { "n", "<leader>cp",       "copyFilePath" },                             -- Copy file path
    { "n", "<leader>cr",       "copyRelativeFilePath" },                     -- Copy relative path
    { "n", "<leader>rl",       "workbench.action.openRecent" },              -- Recent files
    { "n", "<leader>nF",       "workbench.action.files.newUntitledFile" },   -- New file
    { "n", "<leader>cf",       "workbench.action.closeActiveEditor" },       -- Close file
    { "n", "<leader>fa",       "workbench.action.closeAllEditors" },         -- Close all files
    { "n", "<leader>of",       "workbench.action.files.openFile" },          -- Open file
    { "n", "<leader>rw",       "workbench.action.reloadWindow" },            -- Reload window
    { "n", "<leader>os",       "workbench.action.openSettingsJson" },        -- Open settings
    { "n", "<leader>th",       "workbench.action.toggleSidebarVisibility" }, -- Toggle sidebar
  }

  -- Movement mappings
  local movement_mappings = {
    { 'Space', '<Nop>' }, --Nop
    -- { "J",     "5j" },    -- Jump 5 lines down
    -- { "K",     "5k" },    -- Jump 5 lines up
    { "H",     "^" }, -- Go to line start
    { "L",     "$" }, -- Go to line end
  }
  -- Select, delete, copy all mappings
  vim.keymap.set("n", "vag", "ggVG", opts)  -- Select all
  vim.keymap.set("n", "dag", "ggVGd", opts) -- Delete all
  vim.keymap.set("n", "yag", "ggVGy", opts) -- Copy all


  -- Apply movement mappings to normal and visual modes
  for _, mapping in ipairs(movement_mappings) do
    local key, action = mapping[1], mapping[2]
    vim.keymap.set("n", key, action, opts)
    vim.keymap.set("v", key, action, opts)
  end

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("VSCodeYankHighlight", { clear = true }),
    pattern = "*",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
  })

  -- Visual star search
  vim.keymap.set("v", "*", function()
    local lines = vim.fn.getline("'<", "'>")
    local text = ""

    if type(lines) == "table" then
      if #lines == 1 then
        text = lines[1]:sub(vim.fn.col("'<"), vim.fn.col("'>"))
      else
        text = table.concat(lines, "\n")
      end
    else
      text = lines
    end

    vim.fn.setreg("/", text)
    vim.fn.VSCodeNotify("actions.find")
  end, opts)

  -- Apply all VSCode mappings
  for _, mapping in ipairs(mappings) do
    local mode, key, command = mapping[1], mapping[2], mapping[3]
    vim.keymap.set(mode, key, function()
      vim.fn.VSCodeNotify(command)
    end, opts)
  end
else
  require("config.lazy")
  -- Regular neovim mode
end
