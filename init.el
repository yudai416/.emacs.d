; elispのパスを通す
(setq load-path (cons "~/.emacs.d/elisp" load-path))
;(setq load-path (cons "~/.emacs.d/dict" load-path))

; オートインストールの設定
;(when (require 'auto-install nil t)
;  (setq auto-install-directory "~/.emacs.d/elisp/")
;  (auto-install-update-emacswiki-package-name t)
;  (auto-install-compatibility-setup))

; ターミナルエミュレータのシェルをbashに設定
(when (require 'multi-term nil t)
  (setq multi-term-directory "~/.emacs.d/elisp/")
  (setq multi-term-program "/bin/bash"))

; undo-treeの設定
;(when (require 'undo-tree nil t)
;  (setq undo-tree-directory "~/.emacs.d/elisp/"))
(when (require 'undo-tree nil t)
 (global-undo-tree-mode))

; 括弧強調
(show-paren-mode t)

; カーソルの位置が何行目か
(line-number-mode t)

; カーソルの位置が何文字目か
(column-number-mode t)

; 行番号表示
(global-linum-mode)
; (setq linum-format "%4d")

; 常時デバッグ
(setq debug-on-error t)

; スタートアップメッセージ非表示
(setq inhibit-startup-message t)

; スクロールバーを消す
(toggle-scroll-bar nil)

; メニューバーを消す
(menu-bar-mode nil)

; バッテリー残量
(display-battery-mode t)

; 文字サイズ指定
(set-face-font 'default "-*-*-*-*-*-*-14-*")

; 初期フレームの設定
;(setq initial-frame-alist 
;      (append
;       '((width  . 143) ; フレーム幅(文字数)
;	 (height . 37)  ; フレーム高さ(文字数)
	 ;(top    . 0)   ; 表示位置
;	 (left   . 0)   ; 表示位置
;	 )
;       initial-frame-alist))

; スクリーンの最大化
(set-frame-parameter nil 'fullscreen 'maximized)

; フルスクリーン
;(set-frame-parameter nil 'fullscreen 'fullboth)

; 起動時にバッファを2分割、左側にbashを表示
(defun split-window-and-run-term()
  (setq w (selected-window))
  (setq w2 (split-window w nil t))
  (select-window w)
  ; (multi-term)
  (eshell)
  (select-window w))
(add-hook 'after-init-hook (lambda()(split-window-and-run-term)))

; 自動略語補完
(require 'auto-complete-config)
(ac-config-default)

; C-c C-c でregionをコメントアウト
(global-set-key (kbd "C-c C-c") 'comment-region)

; C-c C-v でregionをコメントアウト解除
(global-set-key (kbd "C-c C-v") 'uncomment-region)

; C-x , でファイル内探索
(global-set-key (kbd "C-x ,") 'occur)

; C-x / で指定行への移動
(global-set-key (kbd "C-x /") 'goto-line)

; C-x : でkill-summary
(require 'kill-summary)
(global-set-key (kbd "C-x :") 'kill-summary)

; C-x c でkininarimasu
(require 'chitanda)
(global-set-key (kbd "C-x c") 'kininarimasu)

; C-c 0 でerutaso1
(global-set-key (kbd "C-c 0") 'erutaso0)

; C-c 1 でerutaso1
(global-set-key (kbd "C-c 1") 'erutaso1)

; C-c 2 でerutaso2
(global-set-key (kbd "C-c 2") 'erutaso2)

; C-x ; でanything
(require 'anything)
(require 'anything-config)
(require 'anything-match-plugin)
(global-set-key (kbd "C-x ;") 'anything)

; C-x \ でreplace-regexp
(global-set-key (kbd "C-x \\") 'replace-regexp)

; C-x C-\ でreplace-string
(global-set-key (kbd "C-x C-\\") 'replace-string)

; C-x p でfix-this-buffer
(require 'fix-buffer)
(global-set-key (kbd "C-x p") 'fix-this-buffer)

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
  (let* ((temp-file  (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "gcc" (list "-Wall" "-W" "-pedantic" "-fsyntax-only" 
		      local-file))))
(push '("\\.c$" flymake-c-init) flymake-allowed-file-name-masks)
(add-hook 'c-mode-hook 
	  '(lambda () (if (string-match "\\.c$" buffer-file-name)
			  (flymake-mode t))))
; D言語
; .dを.javaと関連付け
(setq auto-mode-alist (cons '("\\.d$" . java-mode) 
			    auto-mode-alist))
(setq interpreter-mode-alist(append '(("java" . java-mode)) 
				    interpreter-mode-alist))
(setq java-deep-indent-paren-style nil)

; processing
; .pdeを.javaと関連付け
(setq auto-mode-alist (cons '("\\.pde$" . java-mode) 
			    auto-mode-alist))
(setq interpreter-mode-alist(append '(("java" . java-mode)) 
				    interpreter-mode-alist))
(setq java-deep-indent-paren-style nil)

; Python
(add-hook 'find-file-hook 'flymake-find-file-hook)
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
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

;; ;;php-mode
;; (load-library "php-mode")
;; (require 'php-mode)

;;web-mode
(require 'web-mode)
;;; 適用する拡張子
(add-to-list 'auto-mode-alist '("\\.phtml$"     . web-mode))
(add-to-list 'auto-mode-alist '("\\.php$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x$"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode))
;;; インデント数
(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-html-offset   2)
  (setq web-mode-css-offset    2)
  (setq web-mode-script-offset 2)
  (setq web-mode-php-offset    2)
  (setq web-mode-java-offset   2)
  (setq web-mode-asp-offset    2))
(add-hook 'web-mode-hook 'web-mode-hook)
;;; 色の設定
(set-face-attribute 'web-mode-html-tag-face nil :foreground "#0000FF")
(set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#CC9922")
