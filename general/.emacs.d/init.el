;; -----------------------------------------------------------------------------
;; pre-requisite
;; -----------------------------------------------------------------------------

(require 'package)

;; The archives that package-list-packages and package-install will use.
;; The default only includes elpa.gnu.org, but a lot of my installed packages
;; come from MELPA.
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa-stb" . "https://stable.melpa.org/packages/")
        ("melpa" . "https://melpa.org/packages/"))
      tls-checktrust t
      tls-program '("gnutls-cli --x509cafile %t -p %p %h")
      gnutls-verify-error t)

;; If there are multiple versions of a file, prefer the newer one. The default
;; is to use the first one found.
(setq load-prefer-newer t)

;; Load packages. It's necessary to call this early.
(package-initialize)

(setq use-package-always-ensure nil
      use-package-verbose t
      use-package-minimum-reported-time 0.01)


;;; Now you can list available packages by running `M-x list-packages`.
;;; Mark packages you want to install by pressing `i` and later press `x`
;;; to install all marked packages (the necessary dependencies will be
;;; installed automatically).

;;; Now, load [use-package](https://github.com/jwiegley/use-package/)
;;; package or propose automatic installation if it is not yet
;;; installed.

(unless (require 'use-package nil t)
  (if (not (yes-or-no-p (concat "Refresh packages, install use-package and"
				" other packages used by init file? ")))
      (error "you need to install use-package first")
    (package-refresh-contents)
    (package-install 'use-package)
    (require 'use-package)
    (setq use-package-always-ensure t)))

;;; After loading `use-package` we can use it to configure other
;;; packages.

(require 'bind-key)  ; Required for :bind in use-package

;; -----------------------------------------------------------------------------
;; configs for programming language
;; -----------------------------------------------------------------------------

(use-package company
  :demand t
  :defer 2
  :config
  (progn
    (setq company-minimum-prefix-length 2
          company-idle-delay 0.1)

    ;; Bind here rather than in ":bind" to avoid complaints about
    ;; company-mode-map not existing.
    (bind-key "C-n" 'company-select-next company-active-map)
    (bind-key "C-p" 'company-select-previous company-active-map))

  :hook (after-init . global-company-mode))

(use-package lsp-mode
  :config
  (defun lee/lsp-setup()
    (setq lsp-idle-delay 0.5
          lsp-enable-symbol-highlighting nil
          lsp-enable-snippet nil  ;; Not supported by company capf, which is the recommended company backend
          lsp-pyls-plugins-flake8-enabled t)
    (lsp-register-custom-settings
     '(("pyls.plugins.pyls_mypy.enabled" t t)
       ("pyls.plugins.pyls_mypy.live_mode" nil t)
       ("pyls.plugins.pyls_black.enabled" t t)
       ("pyls.plugins.pyls_isort.enabled" t t)

       ;; Disable these as they're duplicated by flake8
       ("pyls.plugins.pycodestyle.enabled" nil t)
       ("pyls.plugins.mccabe.enabled" nil t)
       ("pyls.plugins.pyflakes.enabled" nil t))))
  :hook
  ((python-mode . lsp)
   (c-mode . lsp)
   (cpp-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration)
   (lsp-before-initialize . lee/lsp-setup)))

(use-package lsp-ui
  :config
  (defun lee/lsp-ui-setup ()
    (setq lsp-ui-sideline-show-hover nil
          lsp-ui-sideline-enable nil
          lsp-ui-sideline-delay 0.5
          lsp-ui-sideline-ignore-duplicate t
          lsp-ui-flycheck-live-reporting nil
          lsp-ui-doc-delay 5
          lsp-eldoc-enable-hover t
          lsp-signature-doc-lines 2
          lsp-signature-auto-activate t
          lsp-ui-doc-position 'bottom
          lsp-ui-doc-alignment 'frame
          lsp-ui-doc-header nil
          lsp-ui-doc-include-signature t
          lsp-ui-doc-use-childframe nil))
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  :commands lsp-ui-mode
  :hook ((lsp-before-initialize . lee/lsp-ui-setup)))

;; client for c/c++ language server
(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls) (lsp))))

(use-package pyvenv
  :demand t
  :config
  (setq pyvenv-workon "emacs")  ; Default venv
  (pyvenv-tracking-mode 1))  ; Automatically use pyvenv-workon via dir-locals

;; -----------------------------------------------------------------------------
