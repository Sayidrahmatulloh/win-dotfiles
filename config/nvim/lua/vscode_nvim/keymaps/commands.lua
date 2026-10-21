return { -- VS Code command IDs
  { "n", "u", "undo" }, -- Undo
  { "n", "U", "redo" }, -- Redo
  { "i", "jk", "vscode-neovim.escape" }, -- Escape insert mode
  { "i", "kj", "vscode-neovim.escape" }, -- Escape insert mode
  -- File operations
  { "n", "<localleader>,", "workbench.action.files.save" }, -- Save file
  { "v", "<localleader>,", "workbench.action.files.save" }, -- Save file
  { "n", "<leader>ec", "workbench.files.action.collapseExplorerFolders" }, -- Collapse folders
  { "n", "<leader><leader>", "workbench.action.quickOpen" }, -- Quick open
  -- Text editing
  { "n", "<leader>wu", "editor.action.transformToUppercase" }, -- Word to UPPERCASE
  { "n", "<leader>wl", "editor.action.transformToLowercase" }, -- Word to lowercase
  -- Multi cursor
  { "n", "<leader>ma", "editor.action.selectAllMatches" }, -- Select all matches
  { "n", "<leader>mh", "editor.action.selectHighlights" }, -- Select all matches
  -- Emmet
  { "n", "<leader>mw", "editor.emmet.action.wrapWithAbbreviation" }, -- Wrap with emmet
  { "n", "<leader>mk", "editor.emmet.action.updateTag" }, -- Update tag
  { "n", "<leader>mm", "editor.emmet.action.matchTag" }, -- Match tag
  -- Smart selection
  { "n", "<leader>an", "editor.action.addSelectionToNextFindMatch" }, -- Add next match
  -- Problems & diagnostics
  { "n", "<leader>pr", "workbench.actions.view.problems" }, -- Problems panel
  -- Change case
  { "n", "<leader>wt", "editor.action.transformToTitlecase" }, -- Title Case
  { "n", "<leader>ws", "editor.action.transformToSnakecase" }, -- snake_case
  { "n", "<leader>wc", "editor.action.transformToCamelcase" }, -- camelCase
  { "n", "<leader>wp", "editor.action.transformToPascalcase" }, -- PascalCase
  { "n", "<leader>wk", "editor.action.transformToKebabcase" }, -- kebab-case
  -- Code folding
  { "n", "zc", "editor.fold" }, -- Fold
  { "n", "zo", "editor.unfold" }, -- Unfold
  { "n", "zM", "editor.foldAll" }, -- Fold all
  { "n", "zR", "editor.unfoldAll" }, -- Unfold all
  -- Tab navigation
  { "n", "<leader>1", "workbench.action.openEditorAtIndex1" }, -- Go to tab 1
  { "n", "<leader>2", "workbench.action.openEditorAtIndex2" }, -- Go to tab 2
  { "n", "<leader>3", "workbench.action.openEditorAtIndex3" }, -- Go to tab 3
  { "n", "gn", "workbench.action.nextEditor" }, -- Next editor
  { "n", "gp", "workbench.action.previousEditor" }, -- Previous editor
  -- Terminal navigation
  { "n", "<leader>tt", "workbench.action.terminal.toggleTerminal" }, -- Toggle
  { "n", "<leader>tn", "workbench.action.terminal.new" }, -- New terminal
  { "n", "<leader>tf", "workbench.action.terminal.focus" }, -- Focus terminal
  { "n", "<leader>tk", "workbench.action.terminal.kill" }, -- Kill terminal
  { "n", "<leader>tl", "workbench.action.terminal.clear" }, -- Clear terminal
  { "n", "<leader>ta", "workbench.action.terminal.rename" }, -- Rename terminal
  { "n", "<leader>ts", "workbench.action.terminal.split" }, -- Split terminal
  { "n", "<leader>ht", "workbench.action.togglePanel" }, -- Toggle terminal
  -- Smart word navigation & windows
  { "n", "w", "cursorWordPartRight" }, -- Word part right
  { "n", "b", "cursorWordPartLeft" }, -- Word part left
  { "v", "w", "cursorWordPartRightSelect" }, -- Select word part right
  { "v", "b", "cursorWordPartLeftSelect" }, -- Select word part left
  { "n", "<leader>ww", "workbench.action.joinTwoGroups" }, -- Join groups
  { "n", "<leader>wa", "workbench.action.evenEditorWidths" }, -- Even widths
  { "n", "<leader>wg", "workbench.action.closeGroup" }, -- Close group
  -- Code navigation & definitions
  { "n", "<leader>gd", "editor.action.revealDefinition" }, -- Go to definition
  { "n", "<leader>gy", "editor.action.goToTypeDefinition" }, -- Go to type def
  { "n", "<leader>gi", "editor.action.goToImplementation" }, -- Go to implementation
  { "n", "<leader>gr", "editor.action.goToReferences" }, -- Go to references
  { "n", "<leader>gs", "workbench.action.gotoSymbol" }, -- Go to symbol
  { "n", "<leader>gl", "workbench.action.gotoLine" }, -- Go to line
  { "n", "<leader>jf", "workbench.action.navigateForward" }, -- Navigate forward
  { "n", "<leader>jb", "workbench.action.navigateBack" }, -- Navigate back
  { "n", "<leader>je", "workbench.action.navigateToLastEditLocation" }, -- Jump to last edit
  -- File management
  { "n", "<leader>fd", "fileutils.removeFile" }, -- Delete file
  { "n", "<leader>rf", "fileutils.renameFile" }, -- Rename file
  { "n", "<leader>df", "fileutils.duplicateFile" }, -- Duplicate file
  { "n", "<leader>mf", "fileutils.moveFile" }, -- Move file
  -- Quick search & peek actions
  { "n", "<leader>ss", "workbench.action.showAllSymbols" }, -- Show all symbols
  { "n", "<leader>sa", "workbench.action.showCommands" }, -- Show commands
  { "n", "<leader>so", "workbench.action.quickOpen" }, -- Quick open
  { "n", "<leader>se", "workbench.action.quickOpenSelectNext" }, -- Quick open next
  { "n", "<leader>sq", "workbench.action.quickOpenSelectPrevious" }, -- Quick open previous
  { "n", "<leader>sf", "workbench.action.navigateForwardInEditLocations" }, -- Navigate forward
  { "n", "<leader>sb", "workbench.action.navigateBackInEditLocations" }, -- Navigate back
  { "n", "<leader>vd", "editor.action.peekDefinition" }, -- Peek definition
  { "n", "<leader>vi", "editor.action.peekImplementation" }, -- Peek implementation
  { "n", "<leader>vt", "editor.action.peekTypeDefinition" }, -- Peek type definition
  { "n", "<leader>vh", "editor.action.showHover" }, -- Show hover
  { "n", "<leader>vr", "references-view.findReferences" }, -- Find references
  { "n", "<leader>sr", "editor.action.referenceSearch.trigger" }, -- Reference search
  -- Find, replace & refactoring
  { "n", "<leader>ff", "actions.find" }, -- Find
  { "n", "<leader>fr", "editor.action.startFindReplaceAction" }, -- Find & replace
  { "n", "<leader>fg", "workbench.action.findInFiles" }, -- Find in files
  { "n", "<leader>rg", "workbench.action.replaceInFiles" }, -- Replace in files
  { "n", "<leader>re", "editor.action.rename" }, -- Rename
  { "n", "<leader>rF", "editor.action.refactor" }, -- Refactor
  { "n", "<leader>qf", "editor.action.quickFix" }, -- Quick fix
  { "n", "<leader>af", "editor.action.autoFix" }, -- Auto fix
  { "n", "<leader>sg", "editor.action.triggerSuggest" }, -- Suggestions
  { "n", "<leader>rq", "rest-client.request" }, -- REST client request
  -- Line editing & code maintenance
  { "n", "<leader>lu", "editor.action.copyLinesUpAction" }, -- Copy lines up
  { "n", "<leader>ld", "editor.action.copyLinesDownAction" }, -- Copy lines down
  { "n", "<leader>mu", "editor.action.moveLinesUpAction" }, -- Move lines up
  { "n", "<leader>md", "editor.action.moveLinesDownAction" }, -- Move lines down
  { "n", "<leader>fm", "editor.action.formatDocument" }, -- Format document
  { "n", "<leader>oi", "editor.action.organizeImports" }, -- Organize imports
  { "n", "<leader>en", "editor.action.marker.next" }, -- Next error
  { "n", "<leader>ep", "editor.action.marker.prev" }, -- Previous error
  -- File & workspace management
  { "n", "<leader>cp", "copyFilePath" }, -- Copy file path
  { "n", "<leader>cr", "copyRelativeFilePath" }, -- Copy relative path
  { "n", "<leader>rl", "workbench.action.openRecent" }, -- Recent files
  { "n", "<leader>nF", "workbench.action.files.newUntitledFile" }, -- New file
  { "n", "<leader>cf", "workbench.action.closeActiveEditor" }, -- Close file
  { "n", "<leader>fa", "workbench.action.closeAllEditors" }, -- Close all files
  { "n", "<leader>of", "workbench.action.files.openFile" }, -- Open file
  { "n", "<leader>rw", "workbench.action.reloadWindow" }, -- Reload window
  { "n", "<leader>os", "workbench.action.openSettingsJson" }, -- Open settings
  { "n", "<leader>th", "workbench.action.toggleSidebarVisibility" }, -- Toggle sidebar
}
