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

(define-public nix-next
  (let ((commit "a93916b1905cd7b968e92cd94a3e4a595bff2e0f")
        (revision "0"))
    (package
      (inherit nix)
      (name "nix-next")
      (version (git-version "2.3.10" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/NixOS/nix")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0jhh9z7qass94glq37zrqpr5z0v7y1v9l6hfrp5d5bw4hkc0bkb1"))))
      (arguments
       (substitute-keyword-arguments (package-arguments nix)
         ((#:phases orig)
          `(modify-phases ,orig
             (add-before 'configure 'patch-nlohmann-json-header
               (lambda _
                 (substitute* (find-files "src" "\\.(cc|hh)$")
                   (("#include <nlohmann/json_fwd\\.hpp>")
                    "#include <nlohmann/json.hpp>"))))))
         ((#:tests? _orig #f)
          #f)                           ;Borken test
         ((#:configure-flags orig ''())
          ;; TODO: Package rust-mdbooks and enable doc generation
          `(cons "--disable-doc-gen" ,orig))))
      (native-inputs
       `(("autoconf" ,autoconf)
         ("autoconf-archive" ,autoconf-archive)
         ("automake" ,automake)
         ("libtool" ,libtool)
         ("jq" ,jq)
         ("googletest" ,googletest)
         ("bison" ,bison)
         ("flex" ,flex)
         ("gcc" ,gcc-9)                 ;non-trivial designated initializers
         ,@(package-native-inputs nix)))
      (inputs
       `(("zlib" ,zlib)
         ("nlohmann-json" ,json-modern-cxx)
         ("lowdown" ,lowdown)
         ("libarchive" ,libarchive)
         ,@(package-inputs nix))))))
