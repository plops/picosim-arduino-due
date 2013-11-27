;; find a rigid transform between the different images on the cameras
;; the transform is defined by a rotation angle phi and a translation [tx ty]

;; coordinates of edges of the field mask on the two cameras (left and then right image)
(defparameter *points2* 
  '( 
    ((70 158) (923 169) (57 411) (1031 268))	 ;; top left
    ((874 158) (1719 169) (851 416) (1828 293))	 ;; top right
    ((878 1556) (1723 1565) (854 1819) (1777 1697)) ;; bottom right
    ((64 1569) (914 1576) (40 1804) (965 1652))     ;; bottom left
    ))

(transform 70 158 '(-0.0011044846334446 849.2004203009124 8.979760304753475)
	   )

(defparameter *points* 
  '(
    ((70 158) (923 169))	 ;; top left
    ((874 158) (1719 169))	 ;; top right
    ((878 1556) (1723 1565)) ;; bottom right
    ((64 1569) (914 1576))     ;; bottom left
    )) 

(destructuring-bind (tl tr br bl) *points*
  (list (first tl) (second tl)))

;; shift between images of top camera 
(with-output-to-string (s)
  (loop for ((x1 y1) (x2 y2)) in *points* do
       (format s "( cos(p)*~a+q*sin(p)*~a)+tx-~a," x1 y1 x2)
       (format s "(-sin(p)*~a+q*cos(p)*~a)+ty-~a," x1 y1 y2)))
;; q:1
;; [[- 0.0011044846334446, 849.2004203009124, 8.979760304753475], 
;;                                                           7.38624793612216, 1]

(defun transform (x1 y1 trafo)
  (destructuring-bind (phi tx ty) trafo
    (let ((c (cos phi))
	  (s (sin phi))
	  (q 1))
     (list
      (+ (* c x1) (* q s y1) tx)
      (+ (* (- s) x1) (* q c y1) ty)))))

;; shift between left image of first camera and left image of second camera
(with-open-file (o "rigid-c1l-c2l.max" :direction :output :if-exists :supersede :if-does-not-exist :create)
 (let ((p (with-output-to-string (s)
	    (loop for ((x1 y1) b (x2 y2) g) in *points2* do
		 (format s "( cos(p)*~a+q*sin(p)*~a)+tx-~a," x1 y1 x2)
		 (format s "(-sin(p)*~a+q*cos(p)*~a)+ty-~a," x1 y1 y2)))))
   (format o "load(minpack)$
q:1;
g(p,tx,ty):=[~a]$
minpack_lsquares(g(p,tx,ty), [p,tx,ty], [-3.1,1200,-20]);" (subseq p 0 (1- (length p))))))

;; q:1
;; [[- 0.00835498860452068, - 13.796248043062, 248.3406937646649], 
;;                                                           18.71577318028841, 1]

 
;; shift between left image of first camera and right image of second camera
(with-open-file (o "rigid-c1l-c2r.max" :direction :output :if-exists :supersede :if-does-not-exist :create)
 (let ((p (with-output-to-string (s)
	    (loop for ((x1 y1) b g (x2 y2)) in *points2* do
		 (format s "( cos(p)*~a+q*sin(p)*~a)+tx-~a," x1 y1 x2)
		 (format s "(-sin(p)*~a+q*cos(p)*~a)+ty-~a," x1 y1 y2)))))
   (format o "load(minpack)$
q:1;
g(p,tx,ty):=[~a]$
minpack_lsquares(g(p,tx,ty), [p,tx,ty], [-3.1,1200,-20]);" (subseq p 0 (1- (length p))))))

;; q:1
;; [[- 0.0438329391108518, 966.8980925783296, 97.41566493091041], 
;;                                                          20.53464701279592, 1]

;; (* 180 (/ pi) -0.0438329391108518) 2.5 degree

;; above functions generate maxima code that looks like this:
;; load(minpack)$
;; q:-1;
;; g(s,p,tx,ty):=[s*( cos(p)*<cx>+q*sin(p)*<cy>)+tx-<dx>,
;; s*(-sin(p)*<cx>+q*cos(p)*<cy>)+ty-<dy>, ... ]$
;; minpack_lsquares(g(s,p,tx,ty), [s,p,tx,ty], [0.88,-3.1,1200,-20]);
