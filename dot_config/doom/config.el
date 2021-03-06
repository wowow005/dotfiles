;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; =============
;; ==== 1 基本设置
;; =============

;; ====
;; ==== 1.1 个人信息
;; ====
(setq user-full-name "Mushi"
      user-mail-address "goodhlper005@gmail.com")

;; ====
;; ==== 1.2 更佳的默认设置
;; ====

;; 1.2.1 简单设置
(setq-default
 delete-by-moving-to-trash t
 window-combination-resize t
 x-stretch-cursor t)
(setq undo-limit 80000000
      evil-want-fine-undo t
      auto-save-default t
      truncate-string-ellipsis "..."
      password-cache-expiry nil
      scroll-margin 2)
(display-time-mode 1)
;; (unless (string-match-p "^Power N/A" (battery))
;;   (display-battery-mode 1))
(global-subword-mode 1)

;; 1.2.2 默认打开的界面尺寸
(add-to-list 'default-frame-alist '(height . 40))
(add-to-list 'default-frame-alist '(width . 90))

;; 1.2.3 使用自定义文件.custom.el
(setq-default custom-file (expand-file-name ".custom.el" doom-private-dir))
(when (file-exists-p custom-file)
  (load custom-file))

;; 1.2.4 窗口
(setq evil-vsplit-window-right t
      evil-split-window-below t)
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))
(map! :map evil-window-map
      "SPC" #'rotate-layout
      ;; Navigation
      "<left>"     #'evil-window-left
      "<down>"     #'evil-window-down
      "<up>"       #'evil-window-up
      "<right>"    #'evil-window-right
      ;; Swapping windows
      "C-<left>"       #'+evil/window-move-left
      "C-<down>"       #'+evil/window-move-down
      "C-<up>"         #'+evil/window-move-up
      "C-<right>"      #'+evil/window-move-right)

;; 1.2.5 默认的缓冲区
;; (setq-default major-mode 'org-mode)

;; ====
;; ==== 1.3 Doom 的配置
;; ====
;; 1.3.1 模块
;; 见 init.el 文件

;; 1.3.2 视觉设置
;; 1.3.2.1 字体设置
(setq doom-font (font-spec :family "Sarasa Mono SC Nerd" :size 16)
      doom-big-font (font-spec :family "Sarasa Mono SC Nerd" :size 26)
      doom-variable-pitch-font (font-spec :family "Overpass" :size 16)
      doom-unicode-font (font-spec :family "JuliaMono")
      doom-serif-font (font-spec :family "IBM Plex Mono" :weight 'light))

;; 中文额外设置
;; Set font for chinese characters
;; Font should be twice the width of asci chars so that org tables align
;; This will break if run in terminal mode, so use conditional to only run for GUI.
;; (if (display-graphic-p)
;;     (dolist (charset '(kana han cjk-misc bopomofo))
;;       (set-fontset-font (frame-parameter nil 'font)
;;                         charset (font-spec :family "Hiragino Sans GB" :size 16))))
(let ((font-chinese "PingFang SC"))
  (add-hook! emacs-startup :append
   (set-fontset-font t 'cjk-misc font-chinese nil 'prepend)
   (set-fontset-font t 'han font-chinese nil 'prepend)
   ;; (set-fontset-font t ?中 font-chinese nil 'prepend)
   ;; (set-fontset-font t ?言 font-chinese nil 'prepend)
   ))

;; 1.3.2.2 主题和底栏设置
(setq doom-theme 'modus-vivendi)
;; (setq doom-theme 'doom-vibrant)
(remove-hook 'window-setup-hook #'doom-init-theme-h)
(add-hook 'after-init-hook #'doom-init-theme-h 'append)
(delq! t custom-theme-load-path)
;; 将底栏中红色字体换成橙色
(custom-set-faces!
  '(doom-modeline-buffer-modified :foreground "orange"))
;; 去除底栏中对 LF 和 UTF-8 的显示
(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
                                 '(coding-category-undecided coding-category-utf-8))
                           (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
                t)))
(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

;; 1.3.2.3 杂项设置
;; 行号设置
(setq display-line-numbers-type 't)
;; 更好的默认界面名字
(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboad-name "► Doom")
;; 缩进设置
(setq-default  tab-width 2) ;; 表示一个 tab 4个字符宽
(setq-default indent-tabs-mode nil) ;; nil 表示将 tab 替换成空格
;; beacon 包, 可以在跳转行时闪烁行
(beacon-mode 1)


;; 1.3.3 一些有用的宏

;; 1.3.4 允许 babel 进行命令行操作 - 没搞懂
;; (setq org-confirm-babel-evaluate nil)
;; (defun doom-shut-up-a (orig-fn &rest args)
;;   (quiet! (apply orig-fn args)))
;; (advice-add 'org-babel-execute-src-block :around #'doom-shut-up-a)


;; 1.3.5 Elisp REPL


;; 1.3.6 异步配置混乱 - 我对 literate 还不熟悉

;; 1.3.7 主面板快速操作 - 对我来说不必要, 而且不稳定
;; (defun +doom-dashboard-setup-modified-keymap ()
;;   (setq +doom-dashboard-mode-map (make-sparse-keymap))
;;   (map! :map +doom-dashboard-mode-map
;;         :desc "Find file" :ne "f" #'find-file
;;         :desc "Recent files" :ne "r" #'consult-recent-file
;;         :desc "Config dir" :ne "C" #'doom/open-private-config
;;         :desc "Open config.org" :ne "c" (cmd! (find-file (expand-file-name "config.org" doom-private-dir)))
;;         :desc "Open dotfile" :ne "." (cmd! (doom-project-find-file "~/.config/"))
;;         :desc "Notes (roam)" :ne "n" #'org-roam-node-find
;;         :desc "Switch buffer" :ne "b" #'+vertico/switch-workspace-buffer
;;         :desc "Switch buffers (all)" :ne "B" #'consult-buffer
;;         :desc "IBuffer" :ne "i" #'ibuffer
;;         :desc "Previous buffer" :ne "p" #'previous-buffer
;;         :desc "Set theme" :ne "t" #'consult-theme
;;         :desc "Quit" :ne "Q" #'save-buffers-kill-terminal
;;         :desc "Show keybindings" :ne "h" (cmd! (which-key-show-keymap '+doom-dashboard-mode-map))))
;; (add-transient-hook! #'+doom-dashboard-mode (+doom-dashboard-setup-modified-keymap))
;; (add-transient-hook! #'+doom-dashboard-mode :append (+doom-dashboard-setup-modified-keymap))
;; (add-hook! 'doom-init-ui-hook :append (+doom-dashboard-setup-modified-keymap))
;; (map! :leader :desc "Dashboard" "d" #'+doom-dashboard/open)

;; ====
;; ==== 1.4 其他设置
;; ====

;; 1.4.1 编辑互动

;; 1.4.1.1 鼠标按键 - C-o 和 C-i 足够了
;; (map! :n [mouse-8] #'better-jumper-jump-backward
;;       :n [mouse-9] #'better-jumper-jump-forward)

;; 1.4.2 窗口标题
(setq frame-title-format
      '(""
        (:eval
         (if (s-contains-p org-roam-directory (or buffer-file-name ""))
             (replace-regexp-in-string
              ".*/[0-9]*-?" "☰ "
              (subst-char-in-string ?_ ?  buffer-file-name))
           "%b"))
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name))))))

;; $1.4.3 屏幕标志
;; 实现很复杂

;; $1.4.4 系统守护进程

;; $1.4.5 对 emacs 客户端进行包装

;; $1.4.6 提示运行安装脚本

;; 1.4.7 文学编程支持
(setq org-confirm-babel-evaluate nil
      org-src-fontify-natively t
      org-src-tab-acts-natively t)

;; (org-babel-do-load-languages
;;  'org-babel-load-languages
;;  '((sh         . t)
;;    (js         . t)
;;    (emacs-lisp . t)
;;    (perl       . t)
;;    (scala      . t)
;;    (clojure    . t)
;;    (python     . t)
;;    (ruby       . t)
;;    (dot        . t)
;;    (css        . t)
;;    (plantuml   . t)
;;    (C          . t)
;;    (cpp        . t)
;;    (sql        . t)))


;; ========================
;; ==== 2 PACKAGES 安装包设置
;; ========================

;; ====
;; ==== 2.2 便利的一些包
;; ====

;; 2.2.1 Avy

;; 2.2.2 旋转窗口布局 SPC w SPC
;; packag.el

;; 2.2.3 Emacs Everwhere
;; (use-package! emacs-everywhere
;;   :if (daemonp)
;;   :config
;;   (require 'spell-fu)
;;   (setq emacs-everywhere-major-mode-function #'org-mode
;;         emacs-everywhere-frame-name-format "Edit ∷ %s — %s")
;;   (defadvice! emacs-everywhere-raise-frame ()
;;     :after #'emacs-everywhere-set-frame-name
;;     (setq emacs-everywhere-frame-name (format emacs-everywhere-frame-name-format
;;                                 (emacs-everywhere-app-class emacs-everywhere-current-app)
;;                                 (truncate-string-to-width
;;                                  (emacs-everywhere-app-title emacs-everywhere-current-app)
;;                                  45 nil nil "…")))
;;     ;; need to wait till frame refresh happen before really set
;;     (run-with-timer 0.1 nil #'emacs-everywhere-raise-frame-1))
;;   (defun emacs-everywhere-raise-frame-1 ()
;;     (call-process "wmctrl" nil nil nil "-a" emacs-everywhere-frame-name)))

;; 2.2.4 Which-key
(setq which-key-idle-delay 0.5)
;; 删除过多的 evil 显示
(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))
   ))

;; 2.2.5 Editorconfig
(setq lsp-enable-indentation nil)
(setq editorconfig-mode 1)

;; ====
;; ==== 2.3 工具
;; ====

;; 2.3.0 Vterm 让 Emacs 中的终端更好用
(setq-default explicit-shell-file-name "/bin/zsh")
(setq-default shell-file-name "/bin/zsh")
(use-package! vterm
  :config
  (setq vterm-shell "zsh"))

;; 2.3.1 Abbrev
(add-hook 'doom-first-buffer-hook
          (defun +abbrev-file-name ()
            (setq-default abbrev-mode t)
            (setq abbrev-file-name (expand-file-name "abbrev.el" doom-private-dir))))

;; 2.3.2 $非常大的文件
;; (use-package! vlf-setup
;;   :defer-incrementally vlf-tune vlf-base vlf-write vlf-search vlf-occur vlf-follow vlf-ediff vlf)

;; 2.3.3 Eros
;; From the :tools eval module
(setq eros-eval-result-prefix "⟹ ") ; default =>

;; 2.3.4 Evil
;; 总是打开全局替换
;; 当切换输入模式时不要移动块光标
(after! evil
  (setq evil-ex-substitute-global t
        evil-move-cursor-back nil
        evil-kill-on-visual-paste nil))

;; $2.3.5 Consult
;; From :completion vertico
;; (after! consult
;;   (set-face-attribute 'consult-file nil :inherit 'consult-buffer)
;;   (setf (plist-get (alist-get 'perl consult-async-split-styles-alist) :initial) ";"))

;; 2.3.6 Magit
;; From :tools magit
;; 2.3.6.1 提交信息模板
;; (defvar +magit-project-commit-templates-alist nil
;;   "Alist of toplevel dirs and template strings/functions.")
;; (after! magit
;;   (defun +magit-fill-in-commit-template ()
;;     "Insert template from `+magit-fill-in-commit-template' if applicable."
;;     (when-let ((template (and (save-excursion (goto-char (point-min)) (string-match-p "\\`\\s-*$" (thing-at-point 'line)))
;;                               (cdr (assoc (file-name-base (directory-file-name (magit-toplevel)))
;;                                           +magit-project-commit-templates-alist)))))
;;       (goto-char (point-min))
;;       (insert (if (stringp template) template (funcall template)))
;;       (goto-char (point-min))
;;       (end-of-line)))
;;   (add-hook 'git-commit-setup-hook #'+magit-fill-in-commit-template 90))
;; 为 Org 提交更改的提交信息格式
;; (after! magit
;;   (defun +org-commit-message-template ()
;;     "Create a skeleton for an Org commit message based on the staged diff."
;;     (let (change-data last-file file-changes temp-point)
;;       (with-temp-buffer
;;         (apply #'call-process magit-git-executable
;;                nil t nil
;;                (append
;;                 magit-git-global-arguments
;;                 (list "diff" "--cached")))
;;         (goto-char (point-min))
;;         (while (re-search-forward "^@@\\|^\\+\\+\\+ b/" nil t)
;;           (if (looking-back "^\\+\\+\\+ b/" (line-beginning-position))
;;               (progn
;;                 (push (list last-file file-changes) change-data)
;;                 (setq last-file (buffer-substring-no-properties (point) (line-end-position))
;;                       file-changes nil))
;;             (setq temp-point (line-beginning-position))
;;             (re-search-forward "^\\+\\|^-" nil t)
;;             (end-of-line)
;;             (cond
;;              ((string-match-p "\\.el$" last-file)
;;               (when (re-search-backward "^\\(?:[+-]? *\\|@@[ +-\\d,]+@@ \\)(\\(?:cl-\\)?\\(?:defun\\|defvar\\|defmacro\\|defcustom\\)" temp-point t)
;;                 (re-search-forward "\\(?:cl-\\)?\\(?:defun\\|defvar\\|defmacro\\|defcustom\\) " nil t)
;;                 (add-to-list 'file-changes (buffer-substring-no-properties (point) (forward-symbol 1)))))
;;              ((string-match-p "\\.org$" last-file)
;;               (when (re-search-backward "^[+-]\\*+ \\|^@@[ +-\\d,]+@@ \\*+ " temp-point t)
;;                 (re-search-forward "@@ \\*+ " nil t)
;;                 (add-to-list 'file-changes (buffer-substring-no-properties (point) (line-end-position)))))))))
;;       (push (list last-file file-changes) change-data)
;;       (setq change-data (delete '(nil nil) change-data))
;;       (concat
;;        (if (= 1 (length change-data))
;;            (replace-regexp-in-string "^.*/\\|.[a-z]+$" "" (caar change-data))
;;          "?")
;;        ": \n\n"
;;        (mapconcat
;;         (lambda (file-changes)
;;           (if (cadr file-changes)
;;               (format "* %s (%s): "
;;                       (car file-changes)
;;                       (mapconcat #'identity (cadr file-changes) ", "))
;;             (format "* %s: " (car file-changes))))
;;         change-data
;;         "\n\n"))))
;;   (add-to-list '+magit-project-commit-templates-alist (cons "org-mode" #'+org-commit-message-template)))

;; $2.3.7 Magit delta
;; delta 这个插件暂时有问题

;; $2.3.8 Smerge
;; 没用过
(defun smerge-repeatedly ()
  "Perform smerge actions again and again"
  (interactive)
  (smerge-mode 1)
  (smerge-transient))
(after! transient
  (transient-define-prefix smerge-transient ()
    [["Move"
      ("n" "next" (lambda () (interactive) (ignore-errors (smerge-next)) (smerge-repeatedly)))
      ("p" "previous" (lambda () (interactive) (ignore-errors (smerge-prev)) (smerge-repeatedly)))]
     ["Keep"
      ("b" "base" (lambda () (interactive) (ignore-errors (smerge-keep-base)) (smerge-repeatedly)))
      ("u" "upper" (lambda () (interactive) (ignore-errors (smerge-keep-upper)) (smerge-repeatedly)))
      ("l" "lower" (lambda () (interactive) (ignore-errors (smerge-keep-lower)) (smerge-repeatedly)))
      ("a" "all" (lambda () (interactive) (ignore-errors (smerge-keep-all)) (smerge-repeatedly)))
      ("RET" "current" (lambda () (interactive) (ignore-errors (smerge-keep-current)) (smerge-repeatedly)))]
     ["Diff"
      ("<" "upper/base" (lambda () (interactive) (ignore-errors (smerge-diff-base-upper)) (smerge-repeatedly)))
      ("=" "upper/lower" (lambda () (interactive) (ignore-errors (smerge-diff-upper-lower)) (smerge-repeatedly)))
      (">" "base/lower" (lambda () (interactive) (ignore-errors (smerge-diff-base-lower)) (smerge-repeatedly)))
      ("R" "refine" (lambda () (interactive) (ignore-errors (smerge-refine)) (smerge-repeatedly)))
      ("E" "ediff" (lambda () (interactive) (ignore-errors (smerge-ediff)) (smerge-repeatedly)))]
     ["Other"
      ("c" "combine" (lambda () (interactive) (ignore-errors (smerge-combine-with-next)) (smerge-repeatedly)))
      ("r" "resolve" (lambda () (interactive) (ignore-errors (smerge-resolve)) (smerge-repeatedly)))
      ("k" "kill current" (lambda () (interactive) (ignore-errors (smerge-kill-current)) (smerge-repeatedly)))
      ("q" "quit" (lambda () (interactive) (smerge-auto-leave)))]]))

;; 2.3.9 Company 补全工具
;; From :completion company
(after! company
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 2)
  (setq company-show-quick-access t))
(setq-default history-length 1000)
(setq-default prescient-history-length 1000)
;; 2.3.9.1 纯文本补全
(set-company-backend!
  '(text-mode
    markdown-mode
    gfm-mode)
  '(:seperate
    company-ispell
    company-files
    company-yasnippet))
;; 2.3.9.2 ESS
;; (set-company-backend! 'ess-r-mode '(company-R-args company-R-objects company-dabbrev-code :separate))

;; 2.3.10 Projectile 禁止一些文件进入项目清单
;; From :core packages
(setq projectile-ignored-projects '("~/" "/tmp" "~/.emacs.d/.local/straight/repos/"))
(defun projectile-ignored-project-function (filepath)
 "Return t if FILEPATH is within any of `projectile-ignored-projects'"
 (or (mapcar (lambda (p) (s-starts-with-p p filepath)) projectile-ignored-projects)))

;; $2.3.11 Ispell 拼写和字典的设置
;; 暂时放下

;; 2.3.12$ Tramp 远程访问的设置
;; 2.3.12.1 远程访问时对于命令提示符的识别
;; (after! tramp
;;   (setenv "SHELL" "/bin/bash")
;;   (setq tramp-shell-prompt-pattern "\\(?:^\\|
;; \\)[^]#$%>\n]*#?[]#$%>] *\\(\\[[0-9;]*[a-zA-Z] *\\)*")) ;; default + 
;; 2.3.12.2 解决一些远程访问中的问题
;; Zsh
;;
;; 解决 Guix 包管理器的路径问题
;; (after! tramp
;;   (appendq! tramp-remote-path
;;             '("~/.guix-profile/bin" "~/.guix-profile/sbin"
;;               "/run/current-system/profile/bin"
;;               "/run/current-system/profile/sbin")))

;; 2.3.13 ass 自动展开 snippets
(use-package! aas
  :commands ass-mode)

;; 2.3.14 Screenshot 截图
;; (use-package! screenshot
;;   :defer t
;;   :config (setq screenshot-upload-fn "0x0 %s 2>/dev/null"))

;; 2.3.15 $Etrace
;; 没有研究
;; (use-package! etrace
;;   :after elp)

;; 2.3.16 YASnippet
;; From :edtior snippets
(use-package! yasnippet
  :init
  (setq yas-triggers-in-field t)
  (setq yas-snippet-dirs '("~/.config/doom/snippets"))
  )
;; (setq yas-triggers-in-field t)
;; (add-to-list 'load-path
;;              "~/path-to-yasnippet")
;; (setq yas-snippet-dirs '("~/.config/doom/snippets"))
;; (require 'yasnippet)
;; (yas-global-mode 1)
(use-package! doom-snippets
  :load-path "~/.config/doom/snippets"
  :after yasnippet)

;; 2.3.17 String inflection 大小写转换工具
;; (use-package! string-inflection
;;   :commands (string-inflection-all-cycle
;;              string-inflection-toggle
;;              string-inflection-camelcase
;;              string-inflection-lower-camelcase
;;              string-inflection-kebab-case
;;              string-inflection-underscore
;;              string-inflection-capital-underscore
;;              string-inflection-upcase)
;;   :init
;;   (map! :leader :prefix ("c~" . "naming convention")
;;         :desc "cycle" "~" #'string-inflection-all-cycle
;;         :desc "toggle" "t" #'string-inflection-toggle
;;         :desc "CamelCase" "c" #'string-inflection-camelcase
;;         :desc "downCase" "d" #'string-inflection-lower-camelcase
;;         :desc "kebab-case" "k" #'string-inflection-kebab-case
;;         :desc "under_score" "_" #'string-inflection-underscore
;;         :desc "Upper_Score" "u" #'string-inflection-capital-underscore
;;         :desc "UP_CASE" "U" #'string-inflection-upcase)
;;   (after! evil
;;     (evil-define-operator evil-operator-string-inflection (beg end _type)
;;       "Define a new evil operator that cycles symbol casing."
;;       :move-point nil
;;       (interactive "<R>")
;;       (string-inflection-all-cycle)
;;       (setq evil-repeat-info '([?g ?~])))
;;     (define-key evil-normal-state-map (kbd "g~") 'evil-operator-string-inflection)))

;; 2.3.18 Smart parentheses
;; (sp-local-pair
;;  '(org-mode)
;;  "<<" ">>"
;;  :actions '(insert))

;; 2.3.19 Benchmark-init
(use-package benchmark-init
  :ensure t
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))
;; ====
;; ==== 2.4 Visuals 视觉效果
;; ====

;; 2.4.1 Info colours
(use-package! info-colors
  :commands (info-colors-fontify-node))
(add-hook 'Info-selection-hook 'info-colors-fontify-node)

;; 2.4.2 Modus themes 我用的一款主题

;; 2.4.3 Theme magic 终端的主题
;; (use-package! theme-magic
;;   :commands theme-magic-from-emacs
;;   :config
;;   (defadvice! theme-magic--auto-extract-16-doom-colors ()
;;     :override #'theme-magic--auto-extract-16-colors
;;     (list
;;      (face-attribute 'default :background)
;;      (doom-color 'error)
;;      (doom-color 'success)
;;      (doom-color 'type)
;;      (doom-color 'keywords)
;;      (doom-color 'constants)
;;      (doom-color 'functions)
;;      (face-attribute 'default :foreground)
;;      (face-attribute 'shadow :foreground)
;;      (doom-blend 'base8 'error 0.1)
;;      (doom-blend 'base8 'success 0.1)
;;      (doom-blend 'base8 'type 0.1)
;;      (doom-blend 'base8 'keywords 0.1)
;;      (doom-blend 'base8 'constants 0.1)
;;      (doom-blend 'base8 'functions 0.1)
;;      (face-attribute 'default :foreground))))

;; 2.4.4 Emojify
;; From :ui emoji
;; 用 twitter 表情替换默认的表情
(setq emojify-emoji-set "twemoji-v2")
;; 用表情替换一些在 Org 中遇到的字符
(defvar emojify-disabled-emojis
  '(;; Org
    "◼" "☑" "☸" "⚙" "⏩" "⏪" "⬆" "⬇" "❓"
    ;; Terminal powerline
    ;; "✔"
    ;; Box drawing
    "▶" "◀"
    ;; I just want to see this as text
    "©" "™")
  "Characters that should never be affected by `emojify-mode'.")
(defadvice! emojify-delete-from-data ()
  "Ensure `emojify-disabled-emojis' don't appear in `emojify-emojis'."
  :after #'emojify-set-emoji-data
  (dolist (emoji emojify-disabled-emojis)
    (remhash emoji emojify-emojis)))
;; 创建一种次要模式, 它能将你输入的 ascii/gh 表情转换成 Unicode 格式
(defun emojify--replace-text-with-emoji (orig-fn emoji text buffer start end &optional target)
  "Modify `emojify--propertize-text-for-emoji' to replace ascii/github emoticons with unicode emojis, on the fly."
  (if (or (not emoticon-to-emoji) (= 1 (length text)))
      (funcall orig-fn emoji text buffer start end target)
    (delete-region start end)
    (insert (ht-get emoji "unicode"))))
(define-minor-mode emoticon-to-emoji
  "Write ascii/gh emojis, and have them converted to unicode live."
  :global nil
  :init-value nil
  (if emoticon-to-emoji
      (progn
        (setq-local emojify-emoji-styles '(ascii github unicode))
        (advice-add 'emojify--propertize-text-for-emoji :around #'emojify--replace-text-with-emoji)
        (unless emojify-mode
          (emojify-turn-on-emojify-mode)))
    (setq-local emojify-emoji-styles (default-value 'emojify-emoji-styles))
    (advice-remove 'emojify--propertize-text-for-emoji #'emojify--replace-text-with-emoji)))
;; 在电子邮件和 IRC 中也添加这种次要模式
;; (add-hook! '(mu4e-compose-mode org-msg-edit-mode circe-channel-mode) (emoticon-to-emoji 1))

;; 2.4.5 Doom 的底栏
;; From :ui modeline
;; 对于 PDF 模式底栏的一些调整
;; (after! doom-modeline
;;   (doom-modeline-def-segment buffer-name
;;     "Display the current buffer's name, without any other information."
;;     (concat
;;      (doom-modeline-spc)
;;      (doom-modeline--buffer-name)))
;;   (doom-modeline-def-segment pdf-icon
;;     "PDF icon from all-the-icons."
;;     (concat
;;      (doom-modeline-spc)
;;      (doom-modeline-icon 'octicon "file-pdf" nil nil
;;                          :face (if (doom-modeline--active)
;;                                    'all-the-icons-red
;;                                  'mode-line-inactive)
;;                          :v-adjust 0.02)))
;;   (defun doom-modeline-update-pdf-pages ()
;;     "Update PDF pages."
;;     (setq doom-modeline--pdf-pages
;;           (let ((current-page-str (number-to-string (eval `(pdf-view-current-page))))
;;                 (total-page-str (number-to-string (pdf-cache-number-of-pages))))
;;             (concat
;;              (propertize
;;               (concat (make-string (- (length total-page-str) (length current-page-str)) ? )
;;                       " P" current-page-str)
;;               'face 'mode-line)
;;              (propertize (concat "/" total-page-str) 'face 'doom-modeline-buffer-minor-mode)))))
;;   (doom-modeline-def-segment pdf-pages
;;     "Display PDF pages."
;;     (if (doom-modeline--active) doom-modeline--pdf-pages
;;       (propertize doom-modeline--pdf-pages 'face 'mode-line-inactive)))
;;   (doom-modeline-def-modeline 'pdf
;;     '(bar window-number pdf-pages pdf-icon buffer-name)
;;     '(misc-info matches major-mode process vcs)))

;; 2.4.6 Keycast 按键显示工具
;; (use-package! keycast
;;   :commands keycast-mode
;;   :config
;;   (define-minor-mode keycast-mode
;;     "Show current command and its key binding in the mode line."
;;     :global t
;;     (if keycast-mode
;;         (progn
;;           (add-hook 'pre-command-hook 'keycast--update t)
;;           (add-to-list 'global-mode-string '("" mode-line-keycast " ")))
;;       (remove-hook 'pre-command-hook 'keycast--update)
;;       (setq global-mode-string (remove '("" mode-line-keycast " ") global-mode-string))))
;;   (custom-set-faces!
;;     '(keycast-command :inherit doom-modeline-debug
;;                       :height 0.9)
;;     '(keycast-key :inherit custom-modified
;;                   :height 1.1
;;                   :weight bold)))

;; 2.4.7 Screencast

;; 2.4.8 Mixed pitch
;; From :ui zen
;; (defvar mixed-pitch-modes '(org-mode LaTeX-mode markdown-mode gfm-mode Info-mode)
;;   "Modes that `mixed-pitch-mode' should be enabled in, but only after UI initialisation.")
;; (defun init-mixed-pitch-h ()
;;   "Hook `mixed-pitch-mode' into each mode in `mixed-pitch-modes'.
;; Also immediately enables `mixed-pitch-modes' if currently in one of the modes."
;;   (when (memq major-mode mixed-pitch-modes)
;;     (mixed-pitch-mode 1))
;;   (dolist (hook mixed-pitch-modes)
;;     (add-hook (intern (concat (symbol-name hook) "-hook")) #'mixed-pitch-mode)))
;; (add-hook 'doom-init-ui-hook #'init-mixed-pitch-h)
;; (autoload #'mixed-pitch-serif-mode "mixed-pitch"
;;   "Change the default face of the current buffer to a serifed variable pitch, while keeping some faces fixed pitch." t)
;; (after! mixed-pitch
;;   (defface variable-pitch-serif
;;     '((t (:family "serif")))
;;     "A variable-pitch face with serifs."
;;     :group 'basic-faces)
;;   (setq mixed-pitch-set-height t)
;;   (setq variable-pitch-serif-font (font-spec :family "Alegreya" :size 27))
;;   (set-face-attribute 'variable-pitch-serif nil :font variable-pitch-serif-font)
;;   (defun mixed-pitch-serif-mode (&optional arg)
;;     "Change the default face of the current buffer to a serifed variable pitch, while keeping some faces fixed pitch."
;;     (interactive)
;;     (let ((mixed-pitch-face 'variable-pitch-serif))
;;       (mixed-pitch-mode (or arg 'toggle)))))
;; (set-char-table-range composition-function-table ?f '(["\\(?:ff?[fijlt]\\)" 0 font-shape-gstring]))
;; (set-char-table-range composition-function-table ?T '(["\\(?:Th\\)" 0 font-shape-gstring]))

;; 2.4.9 Marginalia
;; From :completion vertico
;; (after! marginalia
;;   (setq marginalia-censor-variables nil)
;;   (defadvice! +marginalia--anotate-local-file-colorful (cand)
;;     "Just a more colourful version of `marginalia--anotate-local-file'."
;;     :override #'marginalia--annotate-local-file
;;     (when-let (attrs (file-attributes (substitute-in-file-name
;;                                        (marginalia--full-candidate cand))
;;                                       'integer))
;;       (marginalia--fields
;;        ((marginalia--file-owner attrs)
;;         :width 12 :face 'marginalia-file-owner)
;;        ((marginalia--file-modes attrs))
;;        ((+marginalia-file-size-colorful (file-attribute-size attrs))
;;         :width 7)
;;        ((+marginalia--time-colorful (file-attribute-modification-time attrs))
;;         :width 12))))
;;   (defun +marginalia--time-colorful (time)
;;     (let* ((seconds (float-time (time-subtract (current-time) time)))
;;            (color (doom-blend
;;                    (face-attribute 'marginalia-date :foreground nil t)
;;                    (face-attribute 'marginalia-documentation :foreground nil t)
;;                    (/ 1.0 (log (+ 3 (/ (+ 1 seconds) 345600.0)))))))
;;       ;; 1 - log(3 + 1/(days + 1)) % grey
;;       (propertize (marginalia--time time) 'face (list :foreground color))))
;;   (defun +marginalia-file-size-colorful (size)
;;     (let* ((size-index (/ (log10 (+ 1 size)) 7.0))
;;            (color (if (< size-index 10000000) ; 10m
;;                       (doom-blend 'orange 'green size-index)
;;                     (doom-blend 'red 'orange (- size-index 1)))))
;;       (propertize (file-size-human-readable size) 'face (list :foreground color)))))

;; 2.4.10 Centaur Tabs
;; From :ui tabs
(use-package! centaur-tabs
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 22
        centaur-tabs-set-icons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-set-bar 'under
        x-underline-at-descent-line t)
  (centaur-tabs-headline-match)
  (centaur-tabs-mode t)
  (setq uniquify-separator "/")
  (setq uniquify-buffer-name-style 'forward)
  (map! :leader
        :desc "Centaur-tabs-forward" "[" #'centaur-tabs-forward)
  (map! :leader
        :desc "Centaur-tabs-backward" "]" #'centaur-tabs-backward)
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  (term-mode . centaur-tabs-local-mode)
  (calendar-mode . centaur-tabs-local-mode)
  (org-agenda-mode . centaur-tabs-local-mode)
  (helpful-mode . centaur-tabs-local-mode)
  :bind
  ("C-c t s" . centaur-tabs-counsel-switch-group)
  ("C-c t p" . centaur-tabs-group-by-projectile-project)
  ("C-c t g" . centaur-tabs-group-buffer-groups)
  ;; :map evil-normal-state-map
  ;; ("SPC-[" . centaur-tabs-backward)
  ;; ("SPC-]" . centaur-tabs-forward)
  ;; ("g t" . centaur-tabs-forward)
  ;; ("g T" . centaur-tabs-backward)
  )


;; 2.4.11 All the icons
;; From :core packages
(after! all-the-icons
  (setcdr (assoc "m" all-the-icons-extension-icon-alist)
          (cdr (assoc "matlab" all-the-icons-extension-icon-alist))))

;; 2.4.12 Page-break 处理翻页符
(use-package! page-break-lines
  :commands page-break-lines-mode
  :init
  (autoload 'turn-on-page-break-lines-mode "page-break-lines")
  :config
  (setq page-break-lines-max-width fill-column)
  (map! :prefix "g"
        :desc "Prev page break" :nv "[" #'backward-page
        :desc "Next page break" :nv "]" #'forward-page))

;; 2.4.13 Writeroom
;; From :ui zen
;; (setq +zen-text-scale 0.7)
;; (defvar +zen-serif-p t
;;   "Whether to use a serifed font with `mixed-pitch-mode'.")
;; (after! writeroom-mode
;;   (defvar-local +zen--original-org-indent-mode-p nil)
;;   (defvar-local +zen--original-mixed-pitch-mode-p nil)
;;   (defvar-local +zen--original-org-pretty-table-mode-p nil)
;;   (defun +zen-enable-mixed-pitch-mode-h ()
;;     "Enable `mixed-pitch-mode' when in `+zen-mixed-pitch-modes'."
;;     (when (apply #'derived-mode-p +zen-mixed-pitch-modes)
;;       (if writeroom-mode
;;           (progn
;;             (setq +zen--original-mixed-pitch-mode-p mixed-pitch-mode)
;;             (funcall (if +zen-serif-p #'mixed-pitch-serif-mode #'mixed-pitch-mode) 1))
;;         (funcall #'mixed-pitch-mode (if +zen--original-mixed-pitch-mode-p 1 -1)))))
;;   (pushnew! writeroom--local-variables
;;             'display-line-numbers
;;             'visual-fill-column-width
;;             'org-adapt-indentation
;;             'org-superstar-headline-bullets-list
;;             'org-superstar-remove-leading-stars)
;;   (add-hook 'writeroom-mode-enable-hook
;;             (defun +zen-prose-org-h ()
;;               "Reformat the current Org buffer appearance for prose."
;;               (when (eq major-mode 'org-mode)
;;                 (setq display-line-numbers nil
;;                       visual-fill-column-width 60
;;                       org-adapt-indentation nil)
;;                 (when (featurep 'org-superstar)
;;                   (setq-local org-superstar-headline-bullets-list '("🙘" "🙙" "🙚" "🙛")
;;                               ;; org-superstar-headline-bullets-list '("🙐" "🙑" "🙒" "🙓" "🙔" "🙕" "🙖" "🙗")
;;                               org-superstar-remove-leading-stars t)
;;                   (org-superstar-restart))
;;                 (setq
;;                  +zen--original-org-indent-mode-p org-indent-mode
;;                  +zen--original-org-pretty-table-mode-p (bound-and-true-p org-pretty-table-mode))
;;                 (org-indent-mode -1)
;;                 (org-pretty-table-mode 1))))
;;   (add-hook 'writeroom-mode-disable-hook
;;             (defun +zen-nonprose-org-h ()
;;               "Reverse the effect of `+zen-prose-org'."
;;               (when (eq major-mode 'org-mode)
;;                 (when (featurep 'org-superstar)
;;                   (org-superstar-restart))
;;                 (when +zen--original-org-indent-mode-p (org-indent-mode 1))
;;                 ;; (unless +zen--original-org-pretty-table-mode-p (org-pretty-table-mode -1))
;;                 ))))

;; 2.4.14 Treemacs 一个文件侧边栏工具
;; 我不需要改动

;; ====
;; ==== 2.5 Frivolities 一些娱乐的安装包
;; ====

;; 2.5.1 xkcd 一个漫画包
;; 我不需要

;; 2.5.2 Selectric 打字时发声
;; 没人喜欢听老打字机的噪声...
;; (use-package! selectric-mode
;;   :commands selectric-mode)

;; 2.5.3 Wttrin

;; 2.5.4 Spray 闪现文字工具
;; (use-package! spray
;;   :commands spray-mode
;;   :config
;;   (setq spray-wpm 600
;;         spray-height 800)
;;   (defun spray-mode-hide-cursor ()
;;     "Hide or unhide the cursor as is appropriate."
;;     (if spray-mode
;;         (setq-local spray--last-evil-cursor-state evil-normal-state-cursor
;;                     evil-normal-state-cursor '(nil))
;;       (setq-local evil-normal-state-cursor spray--last-evil-cursor-state)))
;;   (add-hook 'spray-mode-hook #'spray-mode-hide-cursor)
;;   (map! :map spray-mode-map
;;         "<return>" #'spray-start/stop
;;         "f" #'spray-faster
;;         "s" #'spray-slower
;;         "t" #'spray-time
;;         "<right>" #'spray-forward-word
;;         "h" #'spray-forward-word
;;         "<left>" #'spray-backward-word
;;         "l" #'spray-backward-word
;;         "q" #'spray-quit))

;; 2.5.5 Elcord 在 discord 中展示使用 emacs 状态
(use-package! elcord
  :commands elcord-mode
  :config
  (setq elcord-use-major-mode-as-main-icon t))

;; 2.5.6 Emms Emacs 多媒体系统
;; (use-package! emms
;;   :defer t
;;   :commands (emms)
;;   :custom
;;   (emms-source-file-default-directory "~/MEGA/Music")
;;   (emms-lyrics-dir "~/MEGA/Music/lyrics")
;;   (emms-lyrics-display-on-minibuffer t)
;;   (emms-lyrics-display-on-modeline nil)
;;   (emms-player-list '(emms-player-mpv))
;;   ;; covers
;;   (emms-browser-covers #'emms-browser-cache-thumbnail-async)
;;   (emms-browser-thumbnail-small-size 64)
;;   (emms-browser-thumbnail-medium-size 128)
;;   :config
;;   (require 'emms-setup)
;;   (emms-all)
;;   (emms-history-load)
;;   (emms-mode-line-disable)
;;   )

;; ====
;; ==== 2.6 File types 文件类型
;; ====


;; =============
;; ==== 3 应用程序
;; =============

;; ====
;; ==== 3.1 看电子书
;; ====
;; 我不觉得这是个好主意 ...

;; ====
;; ==== 3.2 Emacs 中的计算器
;; ====

;; 3.2.1 初始化
;; 弧度制和精确值
(setq calc-angle-mode 'rad  ; radians are rad
      calc-symbolic-mode t) ; keeps expressions like \sqrt{2} irrational for as long as possible

;; 3.2.2 计算 Tex 公式 CalcTeX
;; (use-package! calctex
;;   :commands calctex-mode
;;   :init
;;   (add-hook 'calc-mode-hook #'calctex-mode)
;;   :config
;;   (setq calctex-additional-latex-packages "
;; \\usepackage[usenames]{xcolor}
;; \\usepackage{soul}
;; \\usepackage{adjustbox}
;; \\usepackage{amsmath}
;; \\usepackage{amssymb}
;; \\usepackage{siunitx}
;; \\usepackage{cancel}
;; \\usepackage{mathtools}
;; \\usepackage{mathalpha}
;; \\usepackage{xparse}
;; \\usepackage{arevmath}"
;;         calctex-additional-latex-macros
;;         (concat calctex-additional-latex-macros
;;                 "\n\\let\\evalto\\Rightarrow"))
;;   (defadvice! no-messaging-a (orig-fn &rest args)
;;     :around #'calctex-default-dispatching-render-process
;;     (let ((inhibit-message t) message-log-max)
;;       (apply orig-fn args)))
;;   ;; Fix hardcoded dvichop path (whyyyyyyy)
;;   (let ((vendor-folder (concat (file-truename doom-local-dir)
;;                                "straight/"
;;                                (format "build-%s" emacs-version)
;;                                "/calctex/vendor/")))
;;     (setq calctex-dvichop-sty (concat vendor-folder "texd/dvichop")
;;           calctex-dvichop-bin (concat vendor-folder "texd/dvichop")))
;;   (unless (file-exists-p calctex-dvichop-bin)
;;     (message "CalcTeX: Building dvichop binary")
;;     (let ((default-directory (file-name-directory calctex-dvichop-bin)))
;;       (call-process "make" nil nil nil))))

;; $3.2.3 嵌入计算器 embedded calc
;; (map! :map calc-mode-map
;;       :after calc
;;       :localleader
;;       :desc "Embedded calc (toggle)" "e" #'calc-embedded)
;; (map! :map org-mode-map
;;       :after org
;;       :localleader
;;       :desc "Embedded calc (toggle)" "E" #'calc-embedded)
;; (map! :map latex-mode-map
;;       :after latex
;;       :localleader
;;       :desc "Embedded calc (toggle)" "e" #'calc-embedded)

;; (defvar calc-embedded-trail-window nil)
;; (defvar calc-embedded-calculator-window nil)
;; (defadvice! calc-embedded-with-side-pannel (&rest _)
;;   :after #'calc-do-embedded
;;   (when calc-embedded-trail-window
;;     (ignore-errors
;;       (delete-window calc-embedded-trail-window))
;;     (setq calc-embedded-trail-window nil))
;;   (when calc-embedded-calculator-window
;;     (ignore-errors
;;       (delete-window calc-embedded-calculator-window))
;;     (setq calc-embedded-calculator-window nil))
;;   (when (and calc-embedded-info
;;              (> (* (window-width) (window-height)) 1200))
;;     (let ((main-window (selected-window))
;;           (vertical-p (> (window-width) 80)))
;;       (select-window
;;        (setq calc-embedded-trail-window
;;              (if vertical-p
;;                  (split-window-horizontally (- (max 30 (/ (window-width) 3))))
;;                (split-window-vertically (- (max 8 (/ (window-height) 4)))))))
;;       (switch-to-buffer "*Calc Trail*")
;;       (select-window
;;        (setq calc-embedded-calculator-window
;;              (if vertical-p
;;                  (split-window-vertically -6)
;;                (split-window-horizontally (- (/ (window-width) 2))))))
;;       (switch-to-buffer "*Calculator*")
;;       (select-window main-window))))

;; ====
;; ==== $3.3 IRC
;; ====


;; ====
;; ==== 3.4 新闻订阅 RSS
;; ====

;; ====
;; ==== 3.5 字典
;; ====

;; ====
;; ==== 3.6 电子邮件
;; ====


;; =============
;; ==== 4 语言配置
;; =============

;; ====
;; ==== 4.1 基本配置
;; ====

;; 4.1.1 文件模板
(set-file-template! "\\.tex$" :trigger "__" :mode 'latex-mode)
(set-file-template! "\\.org$" :trigger "__" :mode 'org-mode)
(set-file-template! "/LICEN[CS]E$" :trigger '+file-templates/insert-license)

;; ====
;; ==== 4.2 纯文本文件
;; ====
;; 支持对 ANSI 文本的颜色显示
;; (after! text-mode
;;   (add-hook! 'text-mode-hook
;;              ;; Apply ANSI color codes
;;              (with-silent-modifications
;;                (ansi-color-apply-on-region (point-min) (point-max) t))))

;; ====
;; ==== 4.3 Org
;; ====


;; 4.3.1 系统配置
;; $4.3.1.1 Mime Types
;; $4.3.1.2 Git Diffs

;; 4.3.2 安装包

;; $4.3.2.1 Org 本身

;; 4.3.2.2 视觉效果
;; 4.3.2.2.1 表格
(use-package! org-pretty-table
  :commands (org-pretty-table-mode global-org-pretty-table-mode))
;; 4.3.2.2.2 Emphasis markers 标记可见
(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  (run-at-time nil nil #'org-appear--set-elements))
;; 4.3.2.2.3 标题结构
(use-package! org-ol-tree
  :commands org-ol-tree)
(map! :map org-mode-map
      :after org
      :localleader
      :desc "Outline" "O" #'org-ol-tree)

;; 4.3.2.3 额外功能
;; 4.3.2.3.1 Org 引用
;; 4.3.2.3.2 Julia 支持
;; (use-package! ob-julia
;;   :commands org-babel-execute:julia
;;   :config
;;   (setq org-babel-julia-command-arguments
;;         `("--sysimage"
;;           ,(when-let ((img "~/.local/lib/julia.so")
;;                       (exists? (file-exists-p img)))
;;              (expand-file-name img))
;;           "--threads"
;;           ,(number-to-string (- (doom-system-cpus) 2))
;;           "--banner=no")))
;; 4.3.2.3.3 HTTP 请求
;; (use-package! ob-http
;;   :commands org-babel-execute:http)
;; 4.3.2.3.4 Transclusion
;; (use-package! org-transclusion
;;   :commands org-transclusion-mode
;;   :init
;;   (map! :after org :map org-mode-map
;;         "<f12>" #'org-transclusion-mode))
;; 4.3.2.3.5 Heading graph
;; 4.3.2.3.6 Cooking recipes
;; (use-package! org-chef
;;   :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))
;; 4.3.2.3.7 Importing with Pandoc
(use-package! org-pandoc-import :after org)
;; 4.3.2.3.8 文件比较
;; (use-package! orgdiff
;;   :defer t
;;   :config
;;   (defun +orgdiff-nicer-change-colours ()
;;     (goto-char (point-min))
;;     ;; Set red/blue based on whether chameleon is being used
;;     (if (search-forward "%% make document follow Emacs theme" nil t)
;;         (setq red  (substring (doom-blend 'red 'fg 0.8) 1)
;;               blue (substring (doom-blend 'blue 'teal 0.6) 1))
;;       (setq red  "c82829"
;;             blue "00618a"))
;;     (when (and (search-forward "%DIF PREAMBLE EXTENSION ADDED BY LATEXDIFF" nil t)
;;                (search-forward "\\RequirePackage{color}" nil t))
;;       (when (re-search-forward "definecolor{red}{rgb}{1,0,0}" (cdr (bounds-of-thing-at-point 'line)) t)
;;         (replace-match (format "definecolor{red}{HTML}{%s}" red)))
;;       (when (re-search-forward "definecolor{blue}{rgb}{0,0,1}" (cdr (bounds-of-thing-at-point 'line)) t)
;;         (replace-match (format "definecolor{blue}{HTML}{%s}" blue)))))
;;   (add-to-list 'orgdiff-latexdiff-postprocess-hooks #'+orgdiff-nicer-change-colours))
;; 4.3.2.3.9 $Org music

;; 4.2.3.10 org-fragtog 插件可以让我们自动调用函数生成预览
(add-hook! 'org-mode-hook 'org-fragtog-mode)
(use-package! org-fragtog
  :after org
  :hook
  (org-mode . org-fragtog-mode))

;; 4.2.3.11 Super Agenda
;; (use-package! org-super-agenda
;;   :commands org-super-agenda-mode)

;; 4.2.3.12 Capture
;; (use-package! doct
;;   :commands doct)

;; 4.2.3.13 Org-download
;; (use-package! org-download
;;   :hook (dired-mode . org-download-enable)
;;   :config
;;   (setq org-download-method 'directory)
;;   (setq org-download-image-dir "./img"))
;; (setq org-use-sub-superscripts '{}
;;       org-export-with-sub-superscripts '{})
;; (require 'org-download)
;; (setq-default org-download-method 'directory)
;; (setq-default org-download-image-dir "./img")
;; ;; Drag-and-drop to `dired`
;; (add-hook! 'dired-mode-hook 'org-download-enable)

;; org-hugo
(use-package! ox-hugo
  :after ox)

;; org-roam
(use-package! org-roam
  :init
  (setq org-roam-v2-ack t)
  (setq org-roam-dailies-directory "journal/")
  :custom
  (org-roam-directory "~/MEGA/RoamNotes")
  (org-roam-completion-everywhere t)
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%I:%M %p>: %?"
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
  :map org-roam-dailies-map
  ("Y" . org-roam-dailies-capture-yesterday)
  ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies)
  (org-roam-db-autosync-mode))

;; 4.3.3 行为

;; 4.3.3.1 调整默认值
;; 4.3.3.2 额外功能
(after! org
  (setq org-directory "~/MEGA/org"                      ; let's put files here
        org-use-property-inheritance t              ; it's convenient to have properties inherited
        org-log-done 'time                          ; having the time a item is done sounds convenient
        org-list-allow-alphabetical t               ; have a. A. a) A) list bullets
        ;; org-export-in-background t                  ; run export processes in external emacs process
        org-catch-invisible-edits 'smart            ; try not to accidently do weird stuff in invisible regions
        org-export-with-sub-superscripts '{})       ; don't treat lone _ / ^ as sub/superscripts, require _{} / ^{}
  ;; 把 :coments header-argument 设置成默认
  (setq org-babel-default-header-args
        '((:session . "none")
          (:results . "replace")
          (:exports . "code")
          (:cache . "no")
          (:noweb . "no")
          (:hlines . "no")
          (:tangle . "no")
          (:comments . "link")))
  ;; 移除 "visual-line-mode" 和 "auto-fill-mode"
  (remove-hook 'text-mode-hook #'visual-line-mode)
  (add-hook 'text-mode-hook #'auto-fill-mode)
  ;; 绑定一些键位
  (map! :map evil-org-mode-map
        :after evil-org
        :n "g <up>" #'org-backward-heading-same-level
        :n "g <down>" #'org-forward-heading-same-level
        :n "g <left>" #'org-up-element
        :n "g <right>" #'org-down-element)
  ;; 4.3.3.2.2 零宽度字节的利用
  (map! :map org-mode-map
        :nie "M-SPC M-SPC" (cmd! (insert "\u200B")))
  (defun +org-export-remove-zero-width-space (text _backend _info)
    "Remove zero width spaces from TEXT."
    (unless (org-export-derived-backend-p 'org)
      (replace-regexp-in-string "\u200B" "" text)))
  (after! ox
    (add-to-list 'org-export-filter-final-output-functions #'+org-export-remove-zero-width-space t))
  ;; 4.3.3.2.3 变换列表标号
  (setq org-list-demote-modify-bullet '(("+" . "-") ("-" . "+") ("*" . "+") ("1." . "a.")))
  ;; 4.3.3.2.4 Citation
  ;; (after! oc
  ;;   (defun org-ref-to-org-cite ()
  ;;     "Attempt to convert org-ref citations to org-cite syntax."
  ;;     (interactive)
  ;;     (let* ((cite-conversions '(("cite" . "//b") ("Cite" . "//bc")
  ;;                                ("nocite" . "/n")
  ;;                                ("citep" . "") ("citep*" . "//f")
  ;;                                ("parencite" . "") ("Parencite" . "//c")
  ;;                                ("citeauthor" . "/a/f") ("citeauthor*" . "/a")
  ;;                                ("citeyear" . "/na/b")
  ;;                                ("Citep" . "//c") ("Citealp" . "//bc")
  ;;                                ("Citeauthor" . "/a/cf") ("Citeauthor*" . "/a/c")
  ;;                                ("autocite" . "") ("Autocite" . "//c")
  ;;                                ("notecite" . "/l/b") ("Notecite" . "/l/bc")
  ;;                                ("pnotecite" . "/l") ("Pnotecite" . "/l/bc")))
  ;;            (cite-regexp (rx (regexp (regexp-opt (mapcar #'car cite-conversions) t))
  ;;                             ":" (group (+ (not (any "\n       ,.)]}")))))))
  ;;       (save-excursion
  ;;         (goto-char (point-min))
  ;;         (while (re-search-forward cite-regexp nil t)
  ;;           (message (format "[cite%s:@%s]"
  ;;                                  (cdr (assoc (match-string 1) cite-conversions))
  ;;                                  (match-string 2)))
  ;;           (replace-match (format "[cite%s:@%s]"
  ;;                                  (cdr (assoc (match-string 1) cite-conversions))
  ;;                                  (match-string 2))))))))

  ;; 4.3.3.2.5 cdlatex


  ;; 4.3.3.3 Super Agenda

  ;; ;; 4.3.3.4 Capture
                                        )

;; 4.3.3.2 额外功能

;; 4.3.3.2.1 创建 Org buffer 变的更简单
(evil-define-command evil-buffer-org-new (count file)
  "Creates a new ORG buffer replacing the current window, optionally
   editing a certain FILE"
  :repeat nil
  (interactive "P<f>")
  (if file
      (evil-edit file)
    (let ((buffer (generate-new-buffer "*new org*")))
      (set-window-buffer nil buffer)
      (with-current-buffer buffer
        (org-mode)))))
(map! :leader
      (:prefix "b"
       :desc "New empty ORG buffer" "o" #'evil-buffer-org-new))
;; 4.3.3.2.4 Citation

;; 4.3.3.2.5 cdlatex


;; org-src
;; (setq org-src-preserve-indentation t)

;; (define-key global-map "\C-cc" 'org-capture)

;; (setq org-capture-templates
;;       '(("t" "Todo" entry (file+headline "~/MEGA/org/task.org" "Tasks")
;;          "* TODO %?\n %i\n %a")
;;         ("j" "Journal" entry (file+datetree "~/MEGA/org/journal.org")
;;          "* %?\nEntered on %U\n %i\n %a")))

;; ;; org-elp
;; (require 'org-elp)
;; (setq org-elp-split-fraction 0.2)
;; (setq org-elp-buffer-name "*Equation Live*")
;; (setq org-elp-idle-time 0.5)


;; ====
;; ==== 4.4 LaTex
;; ====

;; Latex 导出模板设置
(with-eval-after-load 'ox-latex
 ;; http://orgmode.org/worg/org-faq.html#using-xelatex-for-pdf-export
 ;; latexmk runs pdflatex/xelatex (whatever is specified) multiple times
 ;; automatically to resolve the cross-references.
(setq org-latex-pdf-process '("latexmk -xelatex -quiet -shell-escape -f %f"))
 ;; 图片默认宽度
 ;; (setq org-image-actual-width '(300))
 (add-to-list 'org-latex-classes
               '("elegantbook"
                 "\\documentclass[lang=cn]{elegantbook}
                 [NO-DEFAULT-PACKAGES]
                 [PACKAGES]
                 [EXTRA]"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
(add-to-list 'org-latex-classes
        '("elegantpaper"
                "\\documentclass[lang=cn]{elegantpaper}
                [NO-DEFAULT-PACKAGES]
                [PACKAGES]
                [EXTRA]"
                ("\\section{%s}" . "\\section*{%s}")
                ("\\subsection{%s}" . "\\subsection*{%s}")
                ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                ("\\paragraph{%s}" . "\\paragraph*{%s}")
                ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
(setq org-latex-listings 'minted)
(add-to-list 'org-latex-packages-alist '("" "minted")))

;; Org 导出配置
;; org preview 设置
;; (add-to-list 'org-preview-latex-process-alist '(xdvsvgm :progams ("xelatex" "dvisvgm")
;;                                                         :discription "xdv > svg"
;;                                                         :message "you need install the programs :xelatex and dvisvgm."
;;                                                         :image-input-type "svg"
;;                                                         :image-size-adjust (1.5 . 1.5)
;;                                                         :latex-compiler ("xelatex -interaction nonstopmode -no-pdf -output-directory %o %f")
;;                                                         :image-converter ("dvisvgm %f -n -b min -c %S -o %O")))
;; (setq org-preview-latex-default-process 'xdvsvgm)


;; ====
;; ==== 4.5 Python
;; ====
(after! lsp-python-ms
  (set-lsp-priority! 'mspyls 1))
