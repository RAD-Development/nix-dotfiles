;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Alice Huston"
      user-mail-address "aliceghuston@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 18)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans" :size 20)
      doom-big-font (font-spec :family "FiraCode Nerd Font Mono" :size 30))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dark+)

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Resolves BSPWM/Emacs issue where BSPWM won't tile Emacs to the appropriate
;; size on opening unless this is set

(setq frame-resize-pixelwise t)

;; CCLS config stuff
;;(after! ccls
;;  (setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
;;  (set-lsp-priority! 'ccls 2))

;; clangd config
;; (setq lsp-clients-clangd-args '("-j=3"
;; 				"--background-index"
;; 				"--clang-tidy"
;; 				"--completion-style=detailed"
;; 				"--header-insertion=never"
;; 				"--header-insertion-decorators=0"))
;; (after! lsp-clangd (set-lsp-priority! 'clangd 2))

;; Prevents large # of files from loading in
;; (setq lsp-file-watch-threshold 300)

;; set rust analyzer to default
;; (after! lsp-rust
;;   (setq rustic-lsp-server 'rust-analyzer))
;; (setq grip-preview-use-webkit t)

;; set up doxygen generation
;; (use-package! gendoxy
;;   :hook (cc-mode))

;; Disable automatic minibuffer popups for snippets and functions
;; (setq lsp-signature-auto-activate 'nil)

;; local configuration for TeX modes
;; (defun my-latex-mode-setup ()
;;   (setq-local company-backends
;;               (append '((company-math-symbols-latex company-latex-commands))
;;                       company-backends)))

;; (add-hook 'tex-mode-hook 'my-latex-mode-setup)

;; set erlang formatter
;; (set-formatter! 'erlfmt  "rebar3 fmt" :modes '(erlang-mode))

;; Recommended config for company-tabnine
;;(after! company
;;  (setq +lsp-company-backends '(company-tabnine :separate company-capf company-yasnippet))
;;  (setq company-show-quick-access t)
;;  (setq company-idle-delay 0)
;;)

;; enable wakatime globally
   (global-wakatime-mode)

;; get tab working?
;;(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)

;; TODO Figure out what this one does
;; (setq org-agenda-todo-list-sublevels 'nil)

;; Promela mode configs
;; (require 'promela-mode)
;; (add-to-list 'auto-mode-alist '("\\.pml\\'" . promela-mode))

;; Use package tree-sitter
;; (use-package! tree-sitter
;;   :config
;;   (require 'tree-sitter-langs)
;;   (global-tree-sitter-mode)
;;   (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

