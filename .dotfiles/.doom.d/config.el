;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ;;
;; ██░▄▄▀██░▄▄▄░██░▀██░██░▄▄▄█▄░▄██░▄▄░█████░▄▄▄██░████ ;;
;; ██░█████░███░██░█░█░██░▄▄███░███░█▀▀█▀▀██░▄▄▄██░████ ;;
;; ██░▀▀▄██░▀▀▀░██░██▄░██░████▀░▀██░▀▀▄█▄▄██░▀▀▀██░▀▀░█ ;;
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ========= ID =========

(setq user-full-name "Pedro Mendes"
      user-mail-address "phrmendes@tuta.io")

;; ========= FONT =========

(setq doom-font (font-spec :family "SauceCodePro Nerd Font" :size 15)
     doom-variable-pitch-font (font-spec :family "SauceCodePro Nerd Font" :size 17))

(setq doom-theme 'doom-gruvbox)

;; ========= LINE NUMBERS =========

(setq display-line-numbers-type 'relative)
(remove-hook! 'text-mode-hook #'display-line-numbers-mode)

;; ========= DEFAULT PDF READER =========

(use-package! openwith
  :init (add-hook 'after-init-hook 'openwith-mode)
  :config
  (setq openwith-associations '(("\\.pdf\\'" "zathura" (file)))))

;; ========= TANGLE CONFIG FILES =========

(global-set-key [f6] 'org-babel-tangle)

;; ========= COMPANY MODE =========

(use-package! company
  :after lsp-mode
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package! company-box
  :hook (company-mode . company-box-mode))

(setq company-global-modes '(not org-mode))

;; ========= HELM =========

(after! helm
  (require 'helm-easymenu)
  (add-hook! 'helm-find-files-after-init-hook
    (map! :map helm-find-files-map
          "<DEL>" #'helm-find-files-up-one-level)))

;; ========= ESHELL =========

(use-package! esh-autosuggest
  :hook (eshell-mode . esh-autosuggest-mode))

;; ========= ORG MODE =========

(after! org
  (setq org-directory "~/pCloudDrive/notes/"
        org-agenda-files
        '("~/pCloudDrive/notes/todo.org"
          "~/pCloudDrive/notes/dates.org")
        org-cite-csl-styles-dir "~/Zotero/styles"
        org-ellipsis " ▼ "
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)"))
        org-src-fontify-natively t
        org-display-inline-images t))

;; Org superstar ---

(setq org-superstar-headline-bullets-list '("⁖" "◉" "○" "✸" "✿"))

;; Center Org buffers ---

(defun phrm/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package! visual-fill-column
  :hook (org-mode . phrm/org-mode-visual-fill))

;; Zotero connection ---

(use-package! zotxt
  :hook (org-mode . org-zotxt-mode))

;; Slides ---

(defun phrm/presentation-setup ()
  ;; hide the mode line
  (hide-mode-line-mode 1)
  ;; display images inline
  (org-display-inline-images)
  ;; hide tabs
  (centaur-tabs-mode 0)
  ;; scale the text
  (setq text-scale-mode-amount 2)
  (text-scale-mode 1))

(defun phrm/presentation-end ()
  ;; show the mode line again
  (hide-mode-line-mode 0)
  ;; descale the text
  (text-scale-mode 0)
  ;; show tabs
  (centaur-tabs-mode 1))

(use-package! org-tree-slide
  :hook ((org-tree-slide-play . phrm/presentation-setup)
         (org-tree-slide-stop . phrm/presentation-end))
  :custom
  (org-tree-slide-slide-in-effect t)
  (org-tree-slide-activate-message "Presentation started!")
  (org-tree-slide-deactivate-message "Presentation finished!")
  (org-tree-slide-header t)
  (org-tree-slide-breadcrumbs " > ")
  (org-image-actual-width nil))

;; Org-Babel ---

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)
      (R . t)
      (go . t)))
  (push '("conf-unix" . conf-unix) org-src-lang-modes))

;; Org templates ---

(with-eval-after-load 'org
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("rl" . "src R"))
  (add-to-list 'org-structure-template-alist '("nx" . "src nix"))
  (add-to-list 'org-structure-template-alist '("hs" . "src haskell"))
  (add-to-list 'org-structure-template-alist '("go" . "src go")))

;; ========= DEFT =========

(after! deft
  (setq deft-extensions '("txt" "org" "md")
        deft-directory "~/pCloudDrive/notes/"
        deft-recursive t))

;; ========= PROJECTILE =========

(setq projectile-project-search-path '("~/Projects"))

;; ========= DIRENV =========

(envrc-global-mode)

;; ========= SPELLCHECK =========

(after! guess-language
  (set-input-method "TeX")
  (setq guess-language-langcodes
        '((en . ("en_US" "English" "🇺🇸" "English"))
          (pt . ("pt_BR" "Portuguese" "🇧🇷" "Brazilian Portuguese")))
        guess-language-languages '(en pt)
        guess-language-min-paragraph-length 35
        guess-language-langcodes
        '((en . ("en_US" "English" "🇺🇸" "English"))
          (pt . ("pt_BR" "Portuguese" "🇧🇷" "Brazilian Portuguese")))))

(add-hook 'text-mode-hook 'guess-language-mode)
(remove-hook 'yaml-mode-hook #'prog-mode)
(remove-hook 'json-mode-hook #'prog-mode)
(global-set-key [f5] 'guess-language)

;; ========= EVIL SNIPE =========

(evil-snipe-mode +1)
(evil-snipe-override-mode +1)
(setq evil-snipe-scope 'buffer)

;; ========= ESS-R =========

(after! ess-mode
  (setq ess-style 'RStudio
        ;; don't wait when evaluating
        ess-eval-visibly-p 'nowait
        ;; scroll buffer to bottom
        comint-scroll-to-bottom-on-output t))

(global-set-key [f1] 'ess-eval-line)
(global-set-key [f2] 'ess-eval-region)
(global-set-key [f3] 'ess-eval-region-and-go)
(global-set-key [f4] 'ess-eval-line-and-step)

;; Pipe snippet ---

(defun gkh-r-add-pipe ()
  (interactive)
  (end-of-line)
  (unless (looking-back "|>" nil)
    (just-one-space 1)
    (insert "|>"))
  (newline-and-indent))

;; Quarto ---

(require 'quarto-mode)
(add-hook 'poly-gfm+r-mode 'quarto-mode #'company-mode)
(add-to-list 'auto-mode-alist '("\\.[q]md\\'" . poly-gfm+r-mode))
(add-to-list 'company-backends 'company-bibtex)
(after! poly-gfm+r-mode
  (setq markdown-code-block-braces t))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
