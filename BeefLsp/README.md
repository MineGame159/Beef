# Beef LSP
Language server implementation for Beef.  
Status: Alpha

## Implemented Features
 - Initialization
 - Shutdown
 - Diagnostics
 - Folding ranges
 - Completions
 - Document symbols
 - Signature help
 - Hover
 - Go to definition
 - Find references
 - Workspace symbols
 - Renaming
 - Semantic Tokens
 - Formatting

## Implemented transports
 - Stdio
 - Tcp

## Using
 - From [latest release](https://github.com/MineGame159/Beef/releases) download the `.exe` and `.vsci` files
 - Put the .exe file somewhere on your path
 - In VS Code under the extensions tab click on the 3 dots and click on `Install from VSIX...` and select the `.vsix`
 - Open a Beef workspace folder and it should work
 
 ## Linux
 On linux the Lsp executeable is best left where it gets compiled to, as it needs a relative project structure around it.  
 There are 2 solutions to still make it work:
 - Add the entire IDE/dist directory to the path
 - Leave a script that calls the Lsp executeable with all input parameters in the path and name it the same as the executeable  
 `/home/User/Beef/IDE/dist/BeefLsp "$@"`

## FAQ
 - **How to edit project / workspace settings?**  
 Open the command palette and run either `Beef: Open Workspace Settings` or `Beef: Open Project Settings`

 - **How to change the active configuration?**  
 Either click on the `Beef Lsp: <configuration>` status bar item in bottom left of VS Code or using the command palette run `Beef: Change Configuration`

 - **How to build / run the project?**  
 The extension provides 2 custom task types `beef-build` and `beef-run` both with different properties. You can look at an example `.vscode/tasks.json` file [here](https://github.com/MineGame159/Beef/blob/lsp/BeefLsp/beef-vscode/example_tasks.json).
