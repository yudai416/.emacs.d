(defun fix-this-buffer ()
  (interactive)
  (set-window-dedicated-p (selected-window) 1)
  (message "This buffer has been fixed on this window!")
)

(defun unfix-this-buffer ()
  (interactive)
  (set-window-dedicated-p (selected-window) nil)
  (message "This buffer has been released from this window.!")
)

(provide 'fix-buffer)
