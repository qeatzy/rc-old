; example from https://nathantypanski.com/blog/2014-08-03-a-vim-like-emacs-config.html
; (server-start)    ; put this line to ~/.emacs.d/init.el
; (load-file "~/notes/swo/rc/init.el")   ; https://www.emacswiki.org/emacs/LoadingLispFiles
; (setq default-directory "~/") ; set default directory
; use 'setq' or 'add-to-list'? melpa, melpa-stable, org, gnu
;                         ("marmalade" . "http://marmalade-repo.org/packages/")
;                          ("melpa-stable" . "http://melpa-stable.milkbox.net/packages/")))
; (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
; (add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
                         (" org" . "http://orgmode.org/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))
(require 'package)
(package-initialize)

; "ido-mode,    https://www.emacswiki.org/emacs/InteractivelyDoThings
(require 'ido)
(setq ido-enable-flex-matching t)   ; https://www.masteringemacs.org/article/introduction-to-ido-mode
(setq ido-everywhere t)
(ido-mode t)
(setq ido-file-extensions-order '(".org" ".py" ".emacs" ".xml" ".el" ".ini" ".cfg" ".cnf"))   ; https://www.masteringemacs.org/article/introduction-to-ido-mode

; "helm, "ctrlp, "fzf
(require 'helm)
(helm-mode 1)
(global-set-key (kbd "M-x") 'helm-M-x)  ; https://juanjoalvarez.net/es/detail/2014/sep/19/vim-emacsevil-chaotic-migration-guide/
; "ag, "ack,
; https://github.com/syohex/emacs-helm-ag
; https://github.com/Wilfred/ag.el

; "apropos, see " info " help
(setq apropos-sort-by-scores t)

; "org-mode
(require 'org)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

; "line
(global-relative-line-numbers-mode t)
(defun relative-abs-line-numbers-format (offset)    ; https://emacs.stackexchange.com/a/21446/9279
  "The default formatting function.
  Return the absolute value of OFFSET, converted to string."
  (if (= 0 offset)
    (number-to-string (line-number-at-pos))
    (number-to-string (abs offset))))
(setq relative-line-numbers-format 'relative-abs-line-numbers-format)

; "buffer, see " file
(global-set-key "\C-x\C-b" 'buffer-menu)    ; rebind from 'list-buffers' to 'buffer-menu'
(defun revert-buffer-confirm-if-modified ()
  "Revert buffer, confirm if file has been modified. see also variable revert-without-query."
  (interactive)
  (revert-buffer t (not (buffer-modified-p)) t))

; "file, see " buffer

; "slime, "lisp, "elisp
(require 'elisp-slime-nav)
(defun my-lisp-hook ()
  (elisp-slime-nav-mode)
  (turn-on-eldoc-mode)
  )
(add-hook 'emacs-lisp-mode-hook 'my-lisp-hook)

; "key, "kb(key binding), see " unbind
(global-set-key (kbd "M-o") 'other-window)
(define-key input-decode-map (kbd "C-i") (kbd "H-i"))   ; C-i and TAB  http://stackoverflow.com/a/11319885/3625404
(global-set-key (kbd "H-i") nil)     ; (global-set-key (kbd "H-i") 'whatever-you-want)

; "unbind, see "kb(key binding) " key
(global-unset-key "\C-xf")  ; 'C-x f' bound to set-fill-column

; "dired
(require 'dired-x)

(defun pseudo-delete-whole-line ()
  "delete whole line upto line begining, if at begining, delete newline."
  (interactive)
  (if (= (current-column) 0)
      (delete-backward-char 1)
    (kill-whole-line)))

; "evil
(require 'evil)
(evil-mode 1)
; TODO emacs how to unmap key in evil mode
; (define-key evil-normal-state-map (kbd "gt") 'persp-next)
(define-key evil-normal-state-map (kbd "gt") 'mode-line-other-buffer)
(define-key evil-normal-state-map (kbd ";") 'evil-ex)
(define-key evil-normal-state-map (kbd "H-i") 'evil-jump-forward)   ; "H-i" for "C-i", see " key
; (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
(define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
(define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
(define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
(define-key evil-normal-state-map (kbd "zh") 'evil-scroll-line-to-top)
; (define-key evil-insert-state-map (kbd "C-h") 'backward-delete-char-untabify)
(define-key evil-insert-state-map (kbd "C-u") 'pseudo-delete-whole-line)
; TODO 'C-u', at line begin, go previous line. (current-column)
; (define-key evil-insert-state-map (kbd "jk") 'evil-normal-state)
(evil-define-key 'normal emacs-lisp-mode-map (kbd "K")
  'elisp-slime-nav-describe-elisp-thing-at-point)

; "sync, see " backup
; "backup and auto-save files, see " sync
(setq make-backup-files nil)    ; no backup files. https://juanjoalvarez.net/es/detail/2014/sep/19/vim-emacsevil-chaotic-migration-guide/
(setq temporary-file-directory "~/.etmp/") ; override default "/tmp/". -- If placing your temp files in /tmp (in Linux) you will not be able to recover a crashed session if your computer also crashes.
(setq backup-directory-alist
      `(".*" . temporary-file-directory))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

; "motion, see " surround
(setq evil-move-cursor-back nil)    ; Don't move back the cursor one position when exiting insert mode.  https://juanjoalvarez.net/es/detail/2014/sep/19/vim-emacsevil-chaotic-migration-guide/

; "surround, see " motion " match
; evil-surround   https://github.com/timcharper/evil-surround
(require 'evil-surround)
(global-evil-surround-mode 1)

; "match, see " motion " surround
(show-paren-mode 1)  ; https://www.gnu.org/software/emacs/manual/html_node/efaq/Matching-parentheses.html
(setq show-paren-delay 0)   ; no delay,  https://www.emacswiki.org/emacs/ShowParenMode

; There is another package that also helps when learning to use a specific mode, it’s called “Discover My Major” (discover-my-major in Melpa). Invoking the command with the same name will show all the functions enabled by the current major mode. It’s great to discover what every mode can do.  https://juanjoalvarez.net/es/detail/2014/sep/19/vim-emacsevil-chaotic-migration-guide/
; https://github.com/steckerhalter/discover-my-major

; "ibuffer
(eval-after-load 'ibuffer
  '(progn
     (evil-set-initial-state 'ibuffer-mode 'normal)
     (evil-define-key 'normal ibuffer-mode-map
       (kbd "m") 'ibuffer-mark-forward
       (kbd "t") 'ibuffer-toggle-marks
       (kbd "u") 'ibuffer-unmark-forward
       (kbd "=") 'ibuffer-diff-with-file
       (kbd "J") 'ibuffer-jump-to-buffer
       (kbd "j") 'evil-next-line
       (kbd "k") 'evil-previous-line
       (kbd "l") 'ibuffer-visit-buffer
       (kbd "M-g") 'ibuffer-jump-to-buffer
       (kbd "M-s a C-s") 'ibuffer-do-isearch
       (kbd "M-s a M-C-s") 'ibuffer-do-isearch-regexp
       ;; ...
       )
     )
   )

; "color, "theme 
(color-theme-approximate-on)

; "info(info mode)
(eval-after-load 'info
  '(progn
     (define-key Info-mode-map (kbd "H-i") 'Info-history-forward)
     ))

; "menu
(menu-bar-mode nil) ; http://www.cnblogs.com/doveyid/archive/2011/09/06/2169126.html
(fset 'yes-or-no-p 'y-or-n-p)
(tool-bar-mode -1)
; (toggle-scroll-bar -1)


; "python, see " elpy
(require 'python)
; (when (executable-find "ipython") ; 
; (setq python-shell-interpreter "ipython")
; (setq python-shell-interpreter "jupyter notebook")
; (setq python-shell-interpreter "jupyter qtconsole")
; (setq python-shell-interpreter "ipython-qtconsole")
(setq python-shell-interpreter "jupyter")
; (setq python-shell-interpreter-args "notebook")
(setq python-shell-interpreter-args "qtconsole")
  ; (setq python-shell-interpreter-args "--pylab")    ; http://www.flannaghan.com/2013/08/29/ipython-emacs
  ; )
; (setq python-shell-completion-native-enable nil)
(setq python-shell-completion-native nil)
(setq python-shell-prompt-detect-failure-warning nil)
; "elpy, see " python    https://github.com/jorgenschaefer/elpy
(elpy-enable)
(elpy-use-ipython)

; ; "status-bar or modeline
;    ;; change mode-line color by evil state
; (lexical-let ((default-color (cons (face-background 'mode-line)
;                                    (face-foreground 'mode-line))))
;   (add-hook 'post-command-hook
;     (lambda ()
;       (let ((color (cond ((minibufferp) default-color)
;                          ((evil-insert-state-p) '("#e80000" . "#ffffff"))
;                          ((evil-emacs-state-p)  '("#444488" . "#ffffff"))
;                          ((buffer-modified-p)   '("#006fa0" . "#ffffff"))
;                          (t default-color))))
;         (set-face-background 'mode-line (car color))
;         (set-face-foreground 'mode-line (cdr color))))))


; "kill, see " clip

; "clip, see " kill
(require 'xclip)    ; M-x install xclip
(xclip-mode t)
; (setq save-interprogram-paste-before-kill t)    ; http://pragmaticemacs.com/emacs/add-the-system-clipboard-to-the-emacs-kill-ring/


