
;;; (defun foo (a &optional (b 6) c &rest r) (list a b c r))

;;;(lambda (a . tail) ((lambda (b c r) (list a b c r)) (if tail (poplist tail) 6) (if tail (poplist tail) nil) tail))

;;;(lambda (a . tail) (let ((b (if tail (poplist tail) 6))(c (if tail (poplist tail) nil)) (r tail)) (list a b c r))

;(if tail (pop tail) def)

(provide 'defun)

(defun *make-body* (opts rst body tail)
    (let ((lets (map (function '(fn(v) (if (atom v) (list v (list 'if tail (list 'poplist tail) nil))
                                    (list (car v) (list 'if tail (list 'poplist tail) (car (cdr v))))))) opts)))
       (if (not (eq rst nil)) (setq lets (append lets (list (list rst tail)))))
       (list* 'let lets body)))

(defun *parse-params* (params vars opts rest what)
   (if (null params) (list vars opts rest)
      (let ((p (first params)))
         (cond ((eq p &optional) 
                (if (eq what 'start) (*parse-params* (rest params) vars opts rest 'opts) nil)) ;;; opts
               ((eq p &rest)
                 (if (and (eq (length params) 2) (atom (second params)))
                     (list vars opts (second params))
                     nil))
               ((eq what 'opts) (*parse-params* (rest params) vars (append opts (list p)) rest what))
               (t (*parse-params* (rest params) (append vars (list p)) opts rest what))))))

(defun *transform-lambda* (lmbd)
   (let* ((lambda (car lmbd))
          (params (car (cdr lmbd)))
          (body (cdr (cdr lmbd)))
          (psl (*parse-params* params nil nil nil 'start)) ;;; ( var-list opt-list rest-var)
          (tail (gensym))
          (mpar (first psl))
          (opar (second psl))
          (rst (second(rest psl))))
     (if (null opar) (list* lambda (append mpar rst) body)
         (list lambda (append mpar tail) (*make-body* opar rst body tail)))))
         
(defmacro defun (name params . body)
   (let ((lmbd (*transform-lambda* (list* 'lambda params body))))
        (if (and (> (length body) 1) (stringp (first body)))
            (putprop name '*documentation* (first body)))
        (list 'funset (list 'quote name) lmbd)))
    
(defmacro defmacro (name params . body)
   (let ((lmbd (*transform-lambda* (list* 'nlambda params body))))
        (if (and (> (length body) 1) (stringp (first body)))
            (putprop name '*documentation* (first body)))
        (list 'funset (list 'quote name) lmbd)))
    
(defmacro describe (name) `(getprop `,name '*documentation*))



