(provide 'cocoa)

(defun make-vector ()
  [[(class "NSMutableArray") alloc:] init:])
  
(defun vectorp (obj)
    (= [obj isKindOfClass: (class "NSMutableArray")] 1))
    
(defun aref (arr index)
   [arr objectAtIndex: index])
   
(defun setref (arr index val)
    [arr insertObject: val atIndex: index]
    arr)

(defun current-directory ()
    [[(class "NSFileManager") defaultManager:] currentDirectoryPath:])

(defun append-strings (str1 str2)
    [str1 stringByAppendingString: str2])
    
   