(define-module (ciregnu packages nix)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)

  #:use-module (guix build-system gnu)

  #:use-module (gnu packages autotools)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages web))

(define-public lowdown
  (package
    (name "lowdown")
    (version "0.7.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://kristaps.bsd.lv/lowdown/snapshots/lowdown-"
                           version ".tar.gz"))
       (sha256
        (base32 "17w7qhyvgg61n5pyqcn99w5a86r7qfqwh2xgqn5zfjady28zg9bw"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f                      ;No test
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (invoke "./configure"
                       (string-append "PREFIX=" out)
                       (string-append "MANDIR=" out "/share/man"))))))))
    (native-inputs
     `(("which" ,which)))
    (home-page "https://kristaps.bsd.lv/lowdown")
    (synopsis "Simple Markdown translator")
    (description "Lowdown is a Markdown translator producing HTML5,
roff documents in the ms and man formats, LaTeX, gemini, and terminal output.")
    (license license:isc)))
