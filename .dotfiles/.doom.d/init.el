;;; init.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ;;
;;  █▄░▄██░▀██░█▄░▄█▄▄░▄▄█████░▄▄▄██░████ ;;
;;  ██░███░█░█░██░████░███▀▀██░▄▄▄██░████ ;;
;;  █▀░▀██░██▄░█▀░▀███░███▄▄██░▀▀▀██░▀▀░█ ;;
;;  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(doom! :completion
       (company +childframe) ; the ultimate code completion backend
       (helm +fuzzy +icons)  ; the search engine of the future

       :ui
       doom                ; what makes DOOM look the way it does
       doom-dashboard      ; a nifty splash screen for Emacs
       doom-quit           ; DOOM quit-message prompts when you quit Emacs
       emoji               ; 🙂
       hl-todo             ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       indent-guides       ; highlighted indent columns
       ligatures           ; ligatures and symbols to make your code pretty again
       minimap             ; show a map of the code on the side
       modeline            ; snazzy, Atom-inspired modeline, plus API
       nav-flash           ; blink cursor line after big motions
       neotree             ; a project drawer, like NERDTree for vim
       ophints             ; highlight the region an operation acts on
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       tabs                ; a tab bar for Emacs
       treemacs            ; a project drawer, like neotree but cooler
       (vc-gutter +pretty) ; vcs diff in the fringe
       vi-tilde-fringe     ; fringe tildes to mark beyond EOB
       window-select       ; visually switch windows
       workspaces          ; tab emulation, persistence & separate workspaces
       zen                 ; distraction-free coding or writing
       deft                ; major mode for managing notes written in plain text formats

       :editor
       (evil +everywhere) ; come to the dark side, we have cookies
       file-templates     ; auto-snippets for empty files
       fold               ; (nigh) universal code folding
       (format +onsave)   ; automated prettiness
       multiple-cursors   ; editing in many places at once
       ;;rotate-text      ; cycle region at point between text candidates
       snippets           ; my elves. They type so I don't have to
       ;;word-wrap        ; soft wrapping with language-aware indent

       :emacs
       dired     ; making dired pretty [functional]
       electric  ; smarter, keyword-based electric-indent
       ;;ibuffer ; interactive buffer management
       undo      ; persistent, smarter undo for your inevitable mistakes
       vc        ; version-control and Emacs, sitting in a tree

       :term
       eshell

       :checkers
       (syntax +childframe) ; tasing you for every semicolon you forget
       (spell +flyspell)    ; tasing you for misspelling mispelling
       ;;grammar            ; tasing grammar mistake every you make

       :tools
       ansible         ; DevOps automation tool
       biblio          ; writes a PhD for you (citation needed)
       (debugger +lsp) ; FIXME stepping through code, to help you add bugs
       (docker +lsp)   ; container management tool
       ;;editorconfig  ; let someone else argue about tabs vs spaces
       ein             ; tame Jupyter notebooks with emacs
       (eval +overlay) ; run code, run (also, repls)
       lookup          ; navigate your code and its documentation
       (lsp +peek)     ; M-x vscode
       (magit +forge)  ; a git porcelain for Emacs
       pdf             ; pdf enhancements
       terraform       ; infrastructure as code
       tree-sitter     ; syntax and parsing, sitting in a tree...
       ;;upload        ; map local to remote projects via ssh/ftp
       direnv          ; save (or destroy) the environment at your leisure
       (eval +overlay) ; run code, run (also, repls)

       :lang
       emacs-lisp
       nix
       (ess +stan)
       (go +lsp)
       (haskell +lsp)
       (json +lsp)
       (julia +lsp)
       (latex +lsp +fold +cdlatex)
       markdown
       (org +dragndrop +jupyter +pandoc +pretty +present +noter +roam2)
       (python +lsp +conda +pyright +poetry)
       (sh +lsp +fish)
       (yaml +lsp)
       (lua +lsp)

       :config
       ;;literate
       (default +bindings +smartparens))
