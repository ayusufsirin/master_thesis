\NeedsTeXFormat{LaTeX2e}[1996/12/01]
\ProvidesClass{Thesis}[2007/02/22 v1.0 LaTeX document class]

\def\baseclass{book}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\baseclass}}
\def\@checkoptions#1#2{
    \edef\@curroptions{\@ptionlist{\@currname.\@currext}}
    \@tfor\@this:=#2\do{
        \@expandtwoargs\in@{,\@this,}{,\@curroptions,}
        \ifin@ \@tempswatrue \@break@tfor \fi}
    \let\@this\@empty
    \if@tempswa \else \PassOptionsToClass{#1}{\baseclass}\fi
}
\@checkoptions{11pt}{{10pt}{11pt}{12pt}}
\PassOptionsToClass{a4paper}{\baseclass}
\ProcessOptions\relax
\LoadClass{\baseclass}
\newcommand\bhrule{\typeout{------------------------------------------------------------------------------}}

\newcommand\Declaration[1]{%

    \setstretch{1.5}
    \btypeout{Ethics}
    %\addtotoc{Ethics}
    \thispagestyle{plain}
    %\null\vfil
    %\vskip 60\p@
    \begin{center}{\fontsize{14}{16.8} \bfseries ETİK}\end{center}
    %\vskip 60\p@
    {\normalsize #1}
    \vfil\vfil\null
    %\cleardoublepage

}

\newcommand\btypeout[1]{\bhrule\typeout{\space #1}\bhrule}
\def\today{\ifcase
               \month\or
               January\or February\or March\or April\or May\or June\or
               July\or August\or September\or October\or November\or December
\fi
    \space \number\year}
\usepackage{setspace}
\onehalfspacing
\setlength{\parindent}{0pt}
\setlength{\parskip}{2.0ex plus0.5ex minus0.2ex}
\usepackage{vmargin}

\RequirePackage[utf8]{inputenc}
\setmarginsrb  { 3cm}  % left margin
{ 2.5cm}  % top margin
{ 2.5cm}  % right margin
{ 2.5cm}  % bottom margin
{  20pt}  % head height
{0.25in}  % head sep
{   9pt}  % foot height
{ 0.3in}  % foot sep
%----------------------------------------------------------------------------------------

\raggedbottom
\setlength{\topskip}{1\topskip \@plus 5\p@}
\doublehyphendemerits=10000       % No consecutive line hyphens.
\brokenpenalty=10000              % No broken words across columns/pages.
\widowpenalty=9999                % Almost no widows at bottom of page.
\clubpenalty=9999                 % Almost no orphans at top of page.
\interfootnotelinepenalty=9999    % Almost never break footnotes.
\usepackage{fancyhdr}
%\lhead[\rm\thepage]{\fancyplain{}{\sl{\rightmark}}}
%\rhead[\fancyplain{}{\sl{\leftmark}}]{\rm\thepage}
%\chead{}\lfoot{}\rfoot{}\cfoot{}
\pagestyle{fancy}

\fancyhf{} % clear all header and footer fields
\fancyfoot[C]{\footnotesize\thepage}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}


%\renewcommand{\chaptermark}[1]{\btypeout{\thesection\space #1}\markboth{\@chapapp\ \thesection\ #1}{\@chapapp\ \thesection\ #1}}
%\renewcommand{\sectionmark}[1]{\btypeout{\thesection\space #1}}
%\renewcommand{\sectionmark}[1]{\thesection{\arabic{section}.}}
\usepackage{titlesec}

\titleformat*{\section}{\centering\normalfont\Large\bfseries}
\titlespacing*{\section} {0pt}{2.5ex plus 1ex minus .2ex}{1.3ex plus .2ex}
\titlespacing*{\subsection} {0pt}{2ex plus 1ex minus .2ex}{0.5ex plus .2ex}

\renewcommand{\sectionmark}[1]{}
\renewcommand{\subsectionmark}[1]{}
\renewcommand{\subsubsectionmark}[1]{}
\renewcommand{\paragraphmark}[1]{}
\usepackage{chngcntr}

\renewcommand{\thechapter}{\arabic{chapter}}
\renewcommand{\thesection}{\thechapter.\arabic{section}.}
\renewcommand{\thesubsection}{\thesection\arabic{subsection}.}
\renewcommand{\thesubsubsection}{\thesubsection\arabic{subsubsection}.}
\renewcommand{\theparagraph}{\thesubsubsection\arabic{paragraph}.}

\counterwithin{figure}{chapter}
\counterwithin{table}{chapter}

\renewcommand{\thefigure}{\thechapter.\arabic{figure}}
\renewcommand{\thetable}{\thechapter.\arabic{table}}

%\usepackage{secdot}
%\renewcommand{\theequation}{\arabic{equation}.}
\renewcommand{\theequation}{\arabic{equation}}
%\renewcommand{\theappendix}{\theappendix\arabic{appendix}.}
%\renewcommand{\thechapter}{\arabic{appendix}.}
%\usepackage{chngcntr}
\counterwithout{equation}{section}
%\counterwithin{figure}{section}
%\counterwithin{table}{section}
\def\cleardoublepage{\clearpage\if@twoside \ifodd
                                               \c@page\else
                                               \hbox{}
                                               \thispagestyle{empty}
                                               \newpage
                                               \if@twocolumn\hbox{}\newpage
\fi\fi\fi}
\usepackage{amsmath,amsfonts,amssymb,amscd,amsthm,xspace}
\theoremstyle{plain}
\newtheorem{example}{Example}[chapter]
\newtheorem{theorem}{Theorem}[chapter]
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{axiom}[theorem]{Axiom}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}
\usepackage[justification=RaggedRight,format=hang,small,labelsep=space, width=\textwidth]{caption}
\setlength{\captionmargin}{20pt}
\newcommand{\fref}[1]{Figure~\ref{#1}}
\newcommand{\tref}[1]{Table~\ref{#1}}
\newcommand{\eref}[1]{Equation~\ref{#1}}
\newcommand{\cref}[1]{Chapter~\ref{#1}}
\newcommand{\sref}[1]{Section~\ref{#1}}
\newcommand{\aref}[1]{Appendix~\ref{#1}}
\renewcommand{\topfraction}{0.85}
\renewcommand{\bottomfraction}{.85}
\renewcommand{\textfraction}{0.1}
\renewcommand{\dbltopfraction}{.85}
\renewcommand{\floatpagefraction}{0.75}
\renewcommand{\dblfloatpagefraction}{.75}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}
\usepackage{graphicx}
\usepackage{epstopdf}
%\usepackage[scriptsize]{subfigure}
\usepackage{booktabs}
\usepackage{rotating}
\usepackage{listings}
\usepackage{lstpatch}
\usepackage{slashbox}

\usepackage{epigraph}%%added by urt
%\setlength{\epigraphwidth}{0.8\textwidth} % Adjust the width of the epigraph
%\renewcommand{\epigraphsize}{\normalsize} % Set the size of the epigraph text
\let\originalepigraph\epigraph
\renewcommand\epigraph[2]{\originalepigraph{\textit{#1}}{\textsc{#2}}}
%\usepackage{amsmath}
%\usepackage{amssymb}
\DeclareMathOperator*{\bigast}{\ast}
\usepackage{lipsum}
\usepackage{pgfplotstable} % For importing tables from CSV
\usepackage{subcaption}
\usepackage{mathrsfs}
\usepackage{comment}
\usepackage{appendix}

\renewcommand{\rmdefault}{phv} % Arial
\renewcommand{\sfdefault}{phv} % Arial

\lstset{captionpos=b,
    frame=tb,
    basicstyle=\scriptsize\ttfamily,
    showstringspaces=false,
    keepspaces=true}
\lstdefinestyle{matlab} {
    language=Matlab,
    keywordstyle=\color{blue},
    commentstyle=\color[rgb]{0.13,0.55,0.13}\em,
    stringstyle=\color[rgb]{0.7,0,0} }
\usepackage[pdfpagemode={UseOutlines},bookmarks=true,bookmarksopen=true,
    bookmarksopenlevel=0,bookmarksnumbered=true,hypertexnames=false,
    colorlinks,linkcolor={black},citecolor={black},urlcolor={black},
    pdfstartview={FitV},unicode,breaklinks=true]{hyperref}
\pdfstringdefDisableCommands{%
    \let\\\space
}

{
%\vfil\vfil\vfil\null
%\cleardoublepage
}

\usepackage{titletoc}

\usepackage{tocloft}

\renewcommand{\chapterautorefname}{Kısım}
\renewcommand{\chaptername}{Kısım}
\renewcommand{\appendixname}{Ek}
\renewcommand{\bibname}{KAYNAKÇA}
\renewcommand{\cftbeforechapskip}{0\baselineskip}        % allow spacing after each chapter/section entry
\renewcommand{\contentsname}{İÇİNDEKİLER}
\renewcommand{\cfttoctitlefont}{\hfill\large\bfseries}
\renewcommand{\cftaftertoctitle}{\hfill}
\renewcommand{\cftbeforetoctitleskip}{-0.5in} % title vertical location
\renewcommand{\cfttoctitlefont}{\hfill\large\bf}
\renewcommand{\cftaftertoctitleskip}{1\baselineskip}%
\renewcommand{\cftchapfont}{\bfseries}
\renewcommand{\cftchappagefont}{\normalfont}
\renewcommand{\cftchapleader}{\cftdotfill{\cftchapdotsep}}
%\renewcommand\cftchapafterpnum{\vskip1.5pt}
%\renewcommand\cftsecafterpnum{\vskip1.5pt}
%\renewcommand\cftsecindent{\setlength{}{1pt}}
%\renewcommand*{\l@section}{\@dottedtocline{1}{0em}{1.2em}}
%\renewcommand*{\l@subsection}{\@dottedtocline{1}{1.2em}{2em}}
%\renewcommand*{\l@subsubsection}{\@dottedtocline{1}{2.2em}{3em}}
%\renewcommand*{\l@paragraph}{\@dottedtocline{1}{3.7em}{3.5em}}
%\renewcommand{\cftchapdotsep}{1}
\renewcommand{\cftsecdotsep}{1}
%\renewcommand{\@pnumwidth}{1em} \renewcommand{\@tocrmarg}{4em}
\renewcommand{\@dotsep}{1}
\renewcommand{\cftsecfont}{\normalfont}
\renewcommand\cftsecfont{\normalfont}
\renewcommand\cftsecpagefont{\normalfont}
\renewcommand{\cftsecleader}{\cftdotfill{\cftsecdotsep}}
\renewcommand\cftsecdotsep{\cftdot}
\renewcommand\cftsubsecdotsep{\cftdot}
\renewcommand{\cftchappagefont}{\normalfont}

\cftsetindents{section}{0in}{0.5in}

\addtocontents{toc}{~\hfill\underline{\textbf{Sayfa}}\par}
\addtocontents{lof}{~\hfill\underline{\textbf{Sayfa}}\par}
\addtocontents{lot}{~\hfill\underline{\textbf{Sayfa}}\par}

% depth for numbering and TOC
\addtocounter{secnumdepth}{2}
\setcounter{tocdepth}{6}

% use a unique counter name to avoid clashes with tocloft
\newcounter{titledummy}
\newcommand\addtotoc[1]{%
  \refstepcounter{titledummy}%
  \addcontentsline{toc}{section}{#1}%
}

% List of Figures configuration
\renewcommand{\listfigurename}{ŞEKİLLER}
\renewcommand{\figurename}{Şekil}
\renewcommand{\cftloftitlefont}{\hfill\large\bfseries}
\renewcommand{\cftafterloftitle}{\hfill}
\renewcommand{\cftbeforeloftitleskip}{-0.5in}
\renewcommand{\cftloftitlefont}{\hfill\large\bf}
\renewcommand{\cftdotsep}{1}
\renewcommand{\@dotsep}{1}

% List of Tables configuration
\renewcommand{\listtablename}{TABLOLAR}
\renewcommand{\tablename}{Tablo}
\renewcommand{\cftlottitlefont}{\hfill\large\bfseries}
\renewcommand{\cftafterlottitleskip}{1.0\baselineskip}
\renewcommand{\cftafterlottitle}{\hfill}
\renewcommand{\cftbeforelottitleskip}{-0.25in}
\renewcommand{\cftlottitlefont}{\hfill\large\bf}
\renewcommand{\@dotsep}{1}

\renewcommand{\cftfigpresnum}{\figurename\enspace}
%\renewcommand{\cftfigaftersnum}{.}
\newlength{\mylen}
\settowidth{\mylen}{\cftfigpresnum\cftfigaftersnum}
\addtolength{\cftfignumwidth}{\mylen}

\renewcommand{\cfttabpresnum}{\tablename\enspace}
%\renewcommand{\cftfigaftersnum}{.}
%\newlength{\mylen}
\settowidth{\mylen}{\cfttabpresnum\cfttabaftersnum}
\addtolength{\cfttabnumwidth}{\mylen}

%\renewcommand\listoffigures{%
%  \btypeout{List of Figures}%
%  \begin{spacing}{1}{%
%    \setlength{\parskip}{1pt}%
%    \if@twocolumn
%      \@restonecoltrue\onecolumn
%    \else
%      \@restonecolfalse
%    \fi
%    \section*{\large\listfigurename
%      \@mkboth{\MakeUppercase\listfigurename}
%              {\MakeUppercase\listfigurename}}%
%    \@starttoc{lof}%
%    \if@restonecol\twocolumn\fi
%    \cleardoublepage
%  }\end{spacing}%
%}
%
%\renewcommand\listoftables{%
%  \btypeout{List of Tables}%
%  \begin{spacing}{1}{%
%    \setlength{\parskip}{1pt}%
%    \if@twocolumn
%      \@restonecoltrue\onecolumn
%    \else
%      \@restonecolfalse
%    \fi
%    \section*{\large\listtablename
%      \@mkboth{\MakeUppercase\listtablename}
%              {\MakeUppercase\listtablename}}%
%    \@starttoc{lot}%
%    \if@restonecol\twocolumn\fi
%    \cleardoublepage
%  }\end{spacing}%
%}

\newcommand\listsymbolname{\large{\centerline{KISALTMALAR}}}
\usepackage{longtable}
\newcommand\listofsymbols[2]{
    \btypeout{\listsymbolname}
    \addtotoc{KISALTMALAR}

    \section*{\listsymbolname
    \@mkboth{
        \MakeUppercase\listsymbolname}{\MakeUppercase\listsymbolname}}
    \begin{longtable}[c]{#1}#2\end{longtable}\par
    \cleardoublepage
}

\newcommand\acknowledgements[1]{
    \btypeout{TEŞEKKÜR}
    \addtotoc{TEŞEKKÜR}
    \thispagestyle{plain}
    \fancyfoot[C]{\footnotesize \thepage}
    \begin{center}{\fontsize(14){16.8}\bf{TEŞEKKÜR} \par}\end{center}
    {\normalsize #1}
    \vfil\vfil\null
    \clearpage
}
%\usepackage[utf8]{inputenc}
%\usepackage[english]{babel}
%\usepackage[T1]{fontenc}
%
%\usepackage{xcolor}
%\definecolor{maroon}{cmyk}{0, 0.87, 0.68, 0.32}
%\definecolor{halfgray}{gray}{0.55}
%\definecolor{ipython_frame}{RGB}{207, 207, 207}
%\definecolor{ipython_bg}{RGB}{247, 247, 247}
%\definecolor{ipython_red}{RGB}{186, 33, 33}
%\definecolor{ipython_green}{RGB}{0, 128, 0}
%\definecolor{ipython_cyan}{RGB}{64, 128, 128}
%\definecolor{ipython_purple}{RGB}{170, 34, 255}
%
%\lstset{
%    breaklines=true,
%    %
%    extendedchars=true,
%    literate=
%    {á}{{\'a}}1 {é}{{\'e}}1 {í}{{\'i}}1 {ó}{{\'o}}1 {ú}{{\'u}}1
%    {Á}{{\'A}}1 {É}{{\'E}}1 {Í}{{\'I}}1 {Ó}{{\'O}}1 {Ú}{{\'U}}1
%    {à}{{\`a}}1 {è}{{\`e}}1 {ì}{{\`i}}1 {ò}{{\`o}}1 {ù}{{\`u}}1
%    {À}{{\`A}}1 {È}{{\'E}}1 {Ì}{{\`I}}1 {Ò}{{\`O}}1 {Ù}{{\`U}}1
%    {ä}{{\"a}}1 {ë}{{\"e}}1 {ï}{{\"i}}1 {ö}{{\"o}}1 {ü}{{\"u}}1
%    {Ä}{{\"A}}1 {Ë}{{\"E}}1 {Ï}{{\"I}}1 {Ö}{{\"O}}1 {Ü}{{\"U}}1
%    {â}{{\^a}}1 {ê}{{\^e}}1 {î}{{\^i}}1 {ô}{{\^o}}1 {û}{{\^u}}1
%    {Â}{{\^A}}1 {Ê}{{\^E}}1 {Î}{{\^I}}1 {Ô}{{\^O}}1 {Û}{{\^U}}1
%    {œ}{{\oe}}1 {Œ}{{\OE}}1 {æ}{{\ae}}1 {Æ}{{\AE}}1 {ß}{{\ss}}1
%    {ç}{{\c c}}1 {Ç}{{\c C}}1 {ø}{{\o}}1 {å}{{\r a}}1 {Å}{{\r A}}1
%    {€}{{\EUR}}1 {£}{{\pounds}}1
%}
%
%%%
%%% Python definition (c) 1998 Michael Weber
%%% Additional definitions (2013) Alexis Dimitriadis
%%% modified by me (should not have empty lines)
%%%
%\lstdefinelanguage{iPython}{
%    morekeywords={access,and,break,class,continue,def,del,elif,else,except,exec,finally,for,from,global,if,import,in,is,lambda,not,or,pass,print,raise,return,try,while},%
%    %
%    % Built-ins
%    morekeywords=[2]{abs,all,any,basestring,bin,bool,bytearray,callable,chr,classmethod,cmp,compile,complex,delattr,dict,dir,divmod,enumerate,eval,execfile,file,filter,float,format,frozenset,getattr,globals,hasattr,hash,help,hex,id,input,int,isinstance,issubclass,iter,len,list,locals,long,map,max,memoryview,min,next,object,oct,open,ord,pow,property,range,raw_input,reduce,reload,repr,reversed,round,set,setattr,slice,sorted,staticmethod,str,sum,super,tuple,type,unichr,unicode,vars,xrange,zip,apply,buffer,coerce,intern},%
%    %
%    sensitive=true,%
%    morecomment=[l]\#,%
%    morestring=[b]',%
%    morestring=[b]",%
%    %
%    morestring=[s]{'''}{'''},% used for documentation text (mulitiline strings)
%    morestring=[s]{"""}{"""},% added by Philipp Matthias Hahn
%    %
%    morestring=[s]{r'}{'},% `raw' strings
%    morestring=[s]{r"}{"},%
%    morestring=[s]{r'''}{'''},%
%    morestring=[s]{r"""}{"""},%
%    morestring=[s]{u'}{'},% unicode strings
%    morestring=[s]{u"}{"},%
%    morestring=[s]{u'''}{'''},%
%    morestring=[s]{u"""}{"""},%
%    %
%    % {replace}{replacement}{lenght of replace}
%    % *{-}{-}{1} will not replace in comments and so on
%    literate=
%    {á}{{\'a}}1 {é}{{\'e}}1 {í}{{\'i}}1 {ó}{{\'o}}1 {ú}{{\'u}}1
%    {Á}{{\'A}}1 {É}{{\'E}}1 {Í}{{\'I}}1 {Ó}{{\'O}}1 {Ú}{{\'U}}1
%    {à}{{\`a}}1 {è}{{\`e}}1 {ì}{{\`i}}1 {ò}{{\`o}}1 {ù}{{\`u}}1
%    {À}{{\`A}}1 {È}{{\'E}}1 {Ì}{{\`I}}1 {Ò}{{\`O}}1 {Ù}{{\`U}}1
%    {ä}{{\"a}}1 {ë}{{\"e}}1 {ï}{{\"i}}1 {ö}{{\"o}}1 {ü}{{\"u}}1
%    {Ä}{{\"A}}1 {Ë}{{\"E}}1 {Ï}{{\"I}}1 {Ö}{{\"O}}1 {Ü}{{\"U}}1
%    {â}{{\^a}}1 {ê}{{\^e}}1 {î}{{\^i}}1 {ô}{{\^o}}1 {û}{{\^u}}1
%    {Â}{{\^A}}1 {Ê}{{\^E}}1 {Î}{{\^I}}1 {Ô}{{\^O}}1 {Û}{{\^U}}1
%    {œ}{{\oe}}1 {Œ}{{\OE}}1 {æ}{{\ae}}1 {Æ}{{\AE}}1 {ß}{{\ss}}1
%    {ç}{{\c c}}1 {Ç}{{\c C}}1 {ø}{{\o}}1 {å}{{\r a}}1 {Å}{{\r A}}1
%    {€}{{\EUR}}1 {£}{{\pounds}}1
%    %
%    {^}{{{\color{ipython_purple}\^{}}}}1
%    {=}{{{\color{ipython_purple}=}}}1
%    %
%    {+}{{{\color{ipython_purple}+}}}1
%    {*}{{{\color{ipython_purple}$^\ast$}}}1
%    {/}{{{\color{ipython_purple}/}}}1
%    %
%    {+=}{{{+=}}}1
%    {-=}{{{-=}}}1
%    {*=}{{{$^\ast$=}}}1
%    {/=}{{{/=}}}1,
%    literate=
%    *{-}{{{\color{ipython_purple}-}}}1
%     {?}{{{\color{ipython_purple}?}}}1,
%    %
%    identifierstyle=\color{black}\ttfamily,
%    commentstyle=\color{ipython_cyan}\ttfamily,
%    stringstyle=\color{ipython_red}\ttfamily,
%    keepspaces=true,
%    showspaces=false,
%    showstringspaces=false,
%    %
%    rulecolor=\color{ipython_frame},
%    frame=single,
%    frameround={t}{t}{t}{t},
%    framexleftmargin=6mm,
%    numbers=left,
%    numberstyle=\tiny\color{halfgray},
%    %
%    %
%    backgroundcolor=\color{ipython_bg},
%    %   extendedchars=true,
%    basicstyle=\scriptsize,
%    keywordstyle=\color{ipython_green}\ttfamily,
%}
%
%\usepackage{color}
%
%\definecolor{dkgreen}{rgb}{0,0.6,0}
%\definecolor{gray}{rgb}{0.5,0.5,0.5}
%\definecolor{mauve}{rgb}{0.58,0,0.82}
%\definecolor{gray}{rgb}{0.4,0.4,0.4}
%\definecolor{darkblue}{rgb}{0.0,0.0,0.6}
%\definecolor{lightblue}{rgb}{0.0,0.0,0.9}
%\definecolor{cyan}{rgb}{0.0,0.6,0.6}
%\definecolor{darkred}{rgb}{0.6,0.0,0.0}
%
%
%\lstset{
%  basicstyle=\ttfamily\footnotesize,
%  columns=fullflexible,
%  showstringspaces=false,
%  numbers=left,                   % where to put the line-numbers
%  numberstyle=\tiny\color{gray},  % the style that is used for the line-numbers
%  stepnumber=1,
%  numbersep=5pt,                  % how far the line-numbers are from the code
%  backgroundcolor=\color{white},      % choose the background color. You must add \usepackage{color}
%  showspaces=false,               % show spaces adding particular underscores
%  showstringspaces=false,         % underline spaces within strings
%  showtabs=false,                 % show tabs within strings adding particular underscores
%  frame=none,                   % adds a frame around the code
%  rulecolor=\color{black},        % if not set, the frame-color may be changed on line-breaks within not-black text (e.g. commens (green here))
%  tabsize=1,                      % sets default tabsize to 2 spaces
%  captionpos=b,                   % sets the caption-position to bottom
%  breaklines=true,                % sets automatic line breaking
%  breakatwhitespace=false,        % sets if automatic breaks should only happen at whitespace
%  title=\lstname,                   % show the filename of files included with \lstinputlisting;
%                                  % also try caption instead of title
%  commentstyle=\color{gray}\upshape
%}
%
%
%\lstdefinelanguage{XML}
%{
%  morestring=[s][\color{mauve}]{"}{"},
%  morestring=[s][\color{black}]{>}{<},
%  morecomment=[s]{<?}{?>},
%  morecomment=[s][\color{dkgreen}]{<!--}{-->},
%  stringstyle=\color{black},
%  identifierstyle=\color{lightblue},
%  keywordstyle=\color{red},
%  morekeywords={xmlns,xsi,noNamespaceSchemaLocation,type,id,x,y,source,target,version,tool,transRef,roleRef,objective,eventually}% list your attributes here
%}