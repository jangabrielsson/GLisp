# GLisp
Lisp in Objective-C

Tail recursive, throw-catch, macros, back-quote macro, reader in lisp, REPL, ...

```lisp
;;; Standard lisp functions

(setq *trace-level* 1)          ;;; Not used yet
(setq *log-level* 2)            ;;; Not used yet
(setq *trace-tailcall* nil)     ;;; Logs "successful" tail calls
(setq *trace-macroexpand* nil)  ;;; Logs macro expands
(setq *trace-closure* nil)      ;;; Logs creations of closures...
(setq *libraries* nil)          ;;; require/provide...
(setq *library-path* "")        ;;; if different than current app dir...

(funset 'list (lambda l l))

(funset 'defun (nlambda (name params . body)
     (list 'funset (list 'quote name)
            (cons 'lambda (cons params body)))))

(funset 'defmacro (nlambda (name params . body)
     (list 'funset (list 'quote name)
            (cons 'nlambda (cons params body)))))
            
(defmacro progn body (list (cons 'lambda (cons '() body))))

(defun map(f l)
   (if l (cons (f (car l)) (map f (cdr l))) nil))

(defmacro first(x) (list 'car x))
(defmacro rest(x) (list 'cdr x))
(defmacro second (x) (list 'first (list 'rest x)))
(defmacro defparameter(var val) (list 'setq var val))
(defmacro defconstant(var val) (list 'setq var val))
(defmacro defvar(var val) (list 'setq var val))
(defmacro defconst(var val) (list 'setq var val))
(defun cadr(x) (car (cdr x)))
(defun cddr(x) (cdr (cdr x)))

(defmacro null(x) (list 'eq x nil))
(defmacro not(x) (list 'if x nil t))
;(defmacro and(x y) (list 'if x y nil))
;(defmacro or(x y) (list 'if x x y)) 

(defun symbolp (sym) (or (atom sym) (stringp sym) (keywordp sym)))

(defmacro + (x y) (list 'add x y))
(defmacro - (x y) (list 'sub x y))
(defmacro * (x y) (list 'mul x y))
(defmacro / (x y) (list 'div x y))
(defmacro = (x y) (list 'eq x y))

(defun < (x y) (lessp x y))
(defun > (x y) (not (or (eq x y) (lessp x y))))

(defun *progbody* (body) (if (null body) nil (if (cdr body) (cons 'progn body) (first body))))

(defmacro when (test . body)
    (list 'if test (*progbody* body)))

(defmacro unless (condition . body)
  (list 'if (list 'not condition) (cons 'progn body)))

(defun equal(x y)
   (if (eq x y) t
       (if (and (consp x) (consp y))
           (and (equal (car x)(car y))
           		(equal (cdr x)(cdr y))))))

(defun length (l) 
   (if (null l) 0
       (+ 1 (length (rest l)))))
       
(defun append-helper (list rest)
   (if (eq list nil)
       (if (null rest) rest (if (null (cdr rest)) (car rest) (append-helper (car rest) (cdr rest))))
       (cons (car list) (append-helper (cdr list) rest))))
       
(defun append list  
     (if (eq list nil) nil (append-helper (car list) (cdr list))))

(defun reverse(x) 
   (if (consp x)
      (append (reverse (cdr x))(list (car x)))
      x))

(defun memq (a l)
   (if (eq l nil) nil
       (if (eq a (car l)) l
           (memq a (cdr l)))))
 
(defun getprop (symbol property) 
   (*find-prop-list* property (*getprop* symbol)))

(defun *find-prop-list* (property list) 
    (if (null list) nil
        (if (eq property (car list)) (car (cdr list))
            (*find-prop-list* property (cdr (cdr list))))))
            
(defun putprop (symbol property value) 
   (*setprop* symbol (*put-prop-list* (*getprop* symbol) property value))
   value)

(defun *put-prop-list* (list property value) 
    (if (null list) (list property value)
        (if (eq property (car list)) (cons property (cons value (cdr (cdr list))))
            (cons (car list) (cons (car (cdr list)) (*put-prop-list* (cdr (cdr list)) property value))))))

;;; (let ((a b)(c d)) (foo a b))
;;; ((lambda (a b) (foo a b)) b d)

(defun *list-helper* (l)
    (if (null l) l
       (if (null (rest l)) (first l)
           (cons (first l) (*list-helper* (rest l))))))

(defun list* l (*list-helper* l))

;;; (let ((a b)(c d)) (+ a b)) ->
;;; ((lambda (a c) (+ a b)) b d)
                                           
(defmacro let (vars . body)
    (list* (list* 'lambda (map (function 'car) vars) body) (map (function '(fn (x)(car (cdr x)))) vars)))

;;; (let* ((a b)(c d)) (foo a b))
;;; ((lambda (a c) (setq a b) (setq c d) (foo a b)) nil nil)

(defmacro let* (vars . body)
    (list* (list* 'lambda (map (function 'car) vars) 
                  (append (map (function '(fn (x) (list 'setq (car x) (car (cdr x))))) vars) body))
           (map (function '(fn (x) nil)) vars)))
    
;;; (cond(test1 res1)(test2 res2)...) -> (if test1 res1 (if (test2 res2 ...)))
(defmacro cond body
   (let* ((fc (function '(fn (bl)
                  (if (eq bl nil) nil
                         (list 'if (car (car bl)) (cons 'progn (cdr (car bl)))
                                  (fc (cdr bl))))))))
       (fc body)))

;(do ((x 1 (+ x 1)) (y 2 (+ y 3))) ((> x 2) y) (print x))
;(catch tag (let* ((return #'(fn p (throw tag (if p (car p) p))))
;                  (f #'(fn(x y) (if (> x 2) (throw tag y)) (print x) (f (+ x 1) (+ y 3)))))
;              (f 1 2)))

(defmacro do (inits test . body)  ;; Redefined later
    (let ((tag (gensym))
          (uf (gensym))
          (steps (map (function '(fn (x) (car (cdr (cdr x))))) inits))
          (vars (map (function '(fn (x) (car x))) inits))
          (initvs (map (function '(fn (x) (car (cdr x)))) inits)))
       (list 'catch (list 'quote tag) 
           (list 'let* (list
                          (list 'return (list 'function (list 'quote (list 'fn 'p (list 'throw (list 'quote tag) '(if p (car p) p))))))
                          (list uf (list 'function (list 'quote (list* 'fn vars (cons (list 'if (car test) (list 'return (car (cdr test))))
                                                                                       (append body (list (cons uf steps))))))))
                       ) 
                 (cons uf initvs)))))
   
;; Setup for backquote...	
(defun assq (x y)
	(cond ((null y) nil)
		((eq x (car (car y))) (car y))
		(t (assq x (cdr y))) ))
		
(defun nth (i l)
   (if (eq l nil) nil
       (if (eq i 0) (car l)
           (nth (- i 1) (cdr l)))))
      
(defun last (l)
    (if (null l) l
        (if (null (cdr l)) l
            (last (cdr l)))))
            
(defun nconc l
    (if (null l) l
        (if (null (car l)) (nconc (cdr l))
            (if (null (cdr l)) (car l)
                (if (null (cdr (cdr l))) (progn (rplacd (last (car l)) (car (cdr l))) (car l))
                    (nconc (nconc (car l) (car (cdr l))) (cdr (cdr l))))))))
                                           
(defun vectorp (expr) nil)

(defmacro error (format . msgs)
    (list '*error* (cons 'strformat (cons format msgs))))       

(defun provide (lib)
	(if (memq lib *libraries*) nil
	    (setq *libraries* (cons lib *libraries*))))

(defun loadfile (filePath)
    (send *lisp* loadFile: filePath))
	
(defun require (lib)
	(if (memq lib *libraries*) nil
		(loadfile (strformat "%@%@" *library-path* lib))))

(require "defun.lsp")

;;;;;;;;;;;;;;;;;;;; Now we can use Defun with keywords ;;;;;;;;;;;;;;;;;;;; 

(defun print (object &optional (stream *stdout*) (qf nil))
    (send stream print: object qf: (if qf 1 0)))
    
(defun flush (&optional (stream *stdout*))
    (send stream flush:))
    
;;; Setup for read macros
(defun intern (string)
    (send *lisp* intern: (send (send (class "Atom") alloc:) initWithName: string)))

(defun readToken (stream)
    (send stream nextToken:))
    
(defun pushBackToken (stream symbol)
    (send stream pushBackToken: symbol))
    
(defun read (&optional (stream *stdin*))
    (send stream read:))
    
(defun *bracket-read-macro* (stream)
   (let* ((sym (readToken stream))
          (readRest (function '(fn (stream)
                (let ((sym (readToken stream)))
                    (cond ((eq sym *aRBra*) nil)
                          ((eq sym nil) (throw nil "Read error: Empty []"))
                          (t (pushBackToken stream sym)
                               (cons (read stream) (readRest stream)))))))))
      (if (eq sym *aRBra*) (throw nil "Read error: malformed [...]"))
      (pushBackToken stream sym)
      (cons 'send (cons (read stream) (readRest stream)))))

(defvar *read-macro-table* (send (send (class "NSMutableDictionary") alloc:) init:))

(defun set-macro-character (symbol fun)
    (send *read-macro-table* setObject: fun forKey: (send symbol description:)))

(set-macro-character *aFun* (lambda (stream) (list 'function (read stream))))

;;;;;;;;;;;;;;;;;;;; Now we can use #'fun ;;;;;;;;;;;;;;;;;;;;

(set-macro-character *aLBra* #'*bracket-read-macro*)

;;;;;;;;;;;;;;;;;;;; Now we can use brackets ;;;;;;;;;;;;;;;;;;;;
(defun make-symbol (sym) (intern sym))
(require "backquote.lsp")

;;;;;;;;;;;;;;;;;;;; Now we can use backquotes ;;;;;;;;;;;;;;;;;;;;

(require "cocoa.lsp")

;(defmacro or(x y) (let ((s (gensym))) `(let ((,s ,x)) (if ,s ,s ,y))))
(defmacro first(x)`(car ,x))
(defmacro rest(x)`(cdr ,x))
(defmacro second(x)`(car (cdr ,x)))
(defmacro third(x)`(car (cdr (cdr ,x))))
(defmacro caar(x)`(car (car ,x)))
(defmacro cadr(x)`(car (cdr ,x)))
(defmacro cdar(x)`(cdr (car ,x)))
(defmacro cddr(x)`(cdr (cdr ,x)))
(defmacro cdddr(x) `(cdr (cdr (cdr ,x))))
(defmacro cadar(x)`(car (cdr (car ,x))))

(defmacro funcall(f &rest args) `(apply ,f (list ,@args)))

(defmacro dolist(params &rest body)
	(let ((ll (gensym)))
	`(let ((,ll ,(second params)))
	   (while ,ll
	    (setq ,(first params) (first ,ll))
	    (setq ,ll (rest ,ll))
	    ,@body))))

(defmacro dotimes(params &rest body)
	(let ((var (first params))(ll (gensym)))
	`(let ((,ll ,(second params)))
	   (setq ,var 0)
	   (while (< ,var ,ll)
	    (setq ,var (+ ,var 1))
	    ,@body))))

(defmacro setf (var value)
	`(setq ,var ,value))
	
(defmacro incf (var &optional (value 1))
	`(setq ,var (+ ,var ,value)))
	
(defmacro decf (var &optional (value 1))
	`(setq ,var (- ,var ,value)))
	
(defun mapcar(f l)
  (let* ((fun (fn (l)
		  (if l
		      (cons (f (car l)) (fun (cdr l)))))))
	(fun l)))
   
(defun foldl(f e l)
  (let* ((fun #'(fn (l)
		  (if l
		      (f (car l) (fun(cdr l)))
		    e))))
	(fun l)))
       
(defun plus (&rest lst) (foldl #'+ 0 lst))

(defmacro loop (&rest body)
    (let ((tag (gensym)))
        `(let ((return #'(fn val (throw ',tag (if val (car val) val)))))
            (catch ',tag (while t ,@body)))))

(defmacro do (inits test &rest body)
    (let ((tag (gensym))
          (uf (gensym))
          (steps (map #'(fn (x) (car (cdr (cdr x)))) inits))
          (vars (map #'(fn (x) (car x)) inits))
          (initvs (map #'(fn (x) (car (cdr x))) inits)))
       `(catch ',tag 
           (let* ((return #'(fn (p) (throw ',tag (if p (car p) p))))
                  (,uf #'(fn ,vars (if ,(car test) (return ,(car (cdr test)))) ,@body (,uf ,@steps))))
              (,uf ,@initvs)))))


;;; (case expr (val1 res1) (val2 res2) ...) -> (let ((test expr)) (cond ((eq test val1) res1) ...
(defmacro case (&rest body)
   (let ((test (gensym)))
      `(let ((,test ,(car body))) 
           (cond ,@(map #'(fn(c) `((eq ,test ,(car c)) ,@(cdr c))) (cdr body))))))

(defun get-date () 
    (send (class "NSDate") date:))

(defun date-diff (old-date)
    (send (get-date) timeIntervalSinceDate: old-date))
    
(defmacro time (expr)
  (let ((tt (gensym)) (res (gensym)))
    `(progn (setq ,tt (get-date) ,res ,expr ,tt (date-diff ,tt)) (format t "%s milliseconds\n" (* ,tt 1000)) ,res)))
    
(defun format (stream format &rest args)
	(print (apply #'strformat (cons format args))))

(defvar * nil)
(defvar ** nil)
(defvar *** nil)

(defun toploop()
	(print "GLisp>")
	(flush)
	(setq expr (read *stdin*))
	(setq res (catch 'nil (eval expr)))
	(when (not (memq expr '(* ** ***)))
		(setq *** **)
		(setq ** *)
		(setq * res))
    (print res *stdout* t)
    (print "\n")
	(toploop)
)

;;;(toploop) ;;; Ok, let's start...
