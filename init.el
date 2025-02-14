; Package cl is deprecatedの抑制
(setq byte-compile-warnings '(cl-functions))

; elispのパスを通す
(add-to-list 'load-path "~/.emacs.d/elisp")

; オートインストールの設定
;(when (require 'auto-install nil t)
;  (setq auto-install-directory "~/.emacs.d/elisp/")
;  (auto-install-update-emacswiki-package-name t)
;  (auto-install-compatibility-setup))

; undo-treeの設定
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))

;;; package.el
(require 'package)
;; MELPA
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; MELPA-stable
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t) ;;
;; (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t) ;; elpaを追加
(package-initialize)

;; company
(when (require 'company nil t)
  (global-company-mode))

;; popwin
;; (when (require 'popwin nil t)
;;   (setq display-buffer-alist 'popwin:display-buffer))

; 括弧強調
(show-paren-mode t)

; カーソルの位置が何行目か
(line-number-mode t)

; カーソルの位置が何文字目か
(column-number-mode t)

; 行番号表示
(global-display-line-numbers-mode)
;; (global-linum-mode t)
; (setq linum-format "%4d")

; 常時デバッグ
;; (setq debug-on-error t)

; スタートアップメッセージ非表示
(setq inhibit-startup-message t)

; スクロールバーを消す
(toggle-scroll-bar nil)

; メニューバーを消す
(menu-bar-mode 0)

;; ツールバーの設定
(setq tool-bar-style 'image)
;; (tool-bar-mode 0)

; バッテリー残量
(display-battery-mode t)

;; ; 文字サイズ指定
;; (set-face-font 'default "-*-*-*-*-*-*-14-*")

; スクリーンの最大化
(set-frame-parameter nil 'fullscreen 'maximized)

; C-c C-c でregionをコメントアウト
(global-set-key (kbd "C-c C-c") 'comment-region)

; C-c C-v でregionをコメントアウト解除
(global-set-key (kbd "C-c C-v") 'uncomment-region)

; C-x , でファイル内探索
(global-set-key (kbd "C-x ,") 'occur)

; C-x / で指定行への移動
(global-set-key (kbd "C-x /") 'goto-line)

; C-x : でkill-summary
(when (require 'kill-summary nil t)
  (global-set-key (kbd "C-x :") 'kill-summary))

; C-x c でkininarimasu
(when (require 'chitanda nil t)
  (global-set-key (kbd "C-x c") 'kininarimasu))

; C-c 0 でerutaso1
(global-set-key (kbd "C-c 0") 'erutaso0)

; C-c 1 でerutaso1
(global-set-key (kbd "C-c 1") 'erutaso1)

; C-c 2 でerutaso2
(global-set-key (kbd "C-c 2") 'erutaso2)

; C-x ; でanything
(when (require 'anything nil t)
  (when (require 'anything-config nil t)
    (when (require 'anything-match-plugin nil t)
      (global-set-key (kbd "C-x ;") 'anything))))

; C-x \ でreplace-regexp
(global-set-key (kbd "C-x \\") 'replace-regexp)

; C-x C-\ でreplace-string
(global-set-key (kbd "C-x C-\\") 'replace-string)

; C-x p でfix-this-buffer
(when (require 'fix-buffer nil t)
  (global-set-key (kbd "C-x p") 'fix-this-buffer))

; w3mのインクルード
(add-to-list 'load-path "~/.emacs.d/elisp/w3m/")
(when (require 'w3m-load nil t))

; 選択中のリージョンの色の設定
(set-face-background 'region "LightSteelBlue1")

;; =====================================================
;;
;; root権限でファイルを開く設定
;;
;; =====================================================

; sudo とか ssh とか ubuntu用
(require 'tramp)

(defun th-rename-tramp-buffer ()
  (when (file-remote-p (buffer-file-name))
    (rename-buffer
     (format "%s:%s"
             (file-remote-p (buffer-file-name) 'method)
             (buffer-name)))))

(add-hook 'find-file-hook
          'th-rename-tramp-buffer)

(defadvice find-file (around th-find-file activate)
  "Open FILENAME using tramp's sudo method if it's read-only."
  (if (and (not (file-writable-p (ad-get-arg 0)))
           (y-or-n-p (concat "File "
                             (ad-get-arg 0)
                             " is read-only. Open it as root? ")))
      (th-find-file-sudo (ad-get-arg 0))
    ad-do-it))

(defun th-find-file-sudo (file)
  "Opens FILE with root privileges."
  (interactive "F")
  (set-buffer (find-file (concat "/sudo::" file))))

;; =====================================================
;;
;; Languages mode(各言語モード)
;;
;; =====================================================

;; GUIの警告は表示しない
;(setq flymake-gui-warnings-enabled nil)

; C言語のflymakeの設定
(require 'flymake)
(defun flymake-c-init ()
  (let* ((temp-file  (flymake-proc-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "gcc" (list "-Wall" "-W" "-pedantic" "-fsyntax-only" 
		      local-file))))
(push '("\\.c$" flymake-c-init) flymake-proc-allowed-file-name-masks)
(add-hook 'c-mode-hook 
	  '(lambda () (if (string-match "\\.c$" buffer-file-name)
			  (flymake-mode t))))
; D言語
; .dを.javaと関連付け
;; (setq auto-mode-alist (cons '("\\.d$" . java-mode) 
;; 			    auto-mode-alist))
;; (setq interpreter-mode-alist(append '(("java" . java-mode)) 
;; 				    interpreter-mode-alist))
;; (setq java-deep-indent-paren-style nil)

;; d-mode
(add-to-list 'load-path "~/.emacs.d/d-mode")
(autoload 'd-mode "d-mode" "Major mode for editing D code." t)
(setq auto-mode-alist (cons '("\\.d$" . d-mode) auto-mode-alist))

; processing
; .pdeを.javaと関連付け
(setq auto-mode-alist (cons '("\\.pde$" . java-mode) 
			    auto-mode-alist))
(setq interpreter-mode-alist(append '(("java" . java-mode)) 
				    interpreter-mode-alist))
(setq-default java-deep-indent-paren-style nil)

; Python
(add-hook 'find-file-hook 'flymake-find-file-hook)
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-proc-init-create-temp-buffer-copy
		       'flymake-create-temp-inplace))
	   (local-file (file-relative-name
			temp-file
			(file-name-directory buffer-file-name))))
      (list "/usr/local/bin/pychecker"  (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
	       '("\\.py\\'" flymake-pyflakes-init)))
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;;; haskell-mode
(autoload 'haskell-mode "haskell-mode" nil t)
(autoload 'haskell-cabal "haskell-cabal" nil t)

(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.lhs$" . literate-haskell-mode))
(add-to-list 'auto-mode-alist '("\\.cabal$" . haskell-cabal-mode))

;; ghc-mod
(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)

;;web-mode
(when (require 'web-mode nil t)
  ;;; 適用する拡張子
  (add-to-list 'auto-mode-alist '("\\.phtml$"     . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php$"       . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsp$"       . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x$"   . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb$"       . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode)))

;;; インデント数
(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq-default web-mode-markup-indent-offset 2)
  (setq-default web-mode-css-indent-offset 2)
  (setq-default web-mode-code-indent-offset 2))
(add-hook 'web-mode-hook 'web-mode-hook)
(setq-default js-indent-level 2)

;;; 色の設定
(set-face-attribute 'web-mode-html-tag-face nil :foreground "#0000FF")
(set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#CC9922")

;; .json5をjavascript-modeに対応付け
(add-to-list 'auto-mode-alist '("\\.json5\\'" . javascript-mode))

;; yaml-modeの設定
(when (require 'yaml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  (require 'yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

;; rust-modeの設定
(when (require 'rust-mode nil t)
  (add-hook 'rust-mode-hook (lambda () (setq indent-tabs-mode nil)))
  (setq-default rust-format-on-save t)
  (add-hook 'rust-mode-hook (lambda () (prettify-symbols-mode))))
