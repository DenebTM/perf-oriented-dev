---
title: "Exercise 04"
subtitle: "VU Performance-oriented Computing, Summer Semester 2024"
author: Calvin Hoy
date: 2024-04-13
geometry: margin=2.5cm
papersize: a4
header-includes:
    # figure placement
    # https://stackoverflow.com/a/58840456
    - \usepackage{float}
      \let\origfigure\figure
      \let\endorigfigure\endfigure
      \renewenvironment{figure}[1][2] {
          \expandafter\origfigure\expandafter[H]
      } {
          \endorigfigure
      } 
    # multiple columns
    # https://stackoverflow.com/a/41005796
    - \usepackage{multicol}
    - \let\Begin\begin
    - \let\End\end
comment:
    PDF created using pandoc
    `pandoc --pdf-engine tectonic --filter pandoc-crossref`
---

# (A) Basic Optimization Levels

The flags that are enabled/changed with `-O3` over `-O2` are the following:

```
-fgcse-after-reload
-fipa-cp-clone
-floop-interchange
-floop-unroll-and-jam
-fpeel-loops
-fpredictive-commoning
-fsplit-loops
-fsplit-paths
-ftree-loop-distribution
-ftree-partial-pre
-funroll-completely-grow-size
-funswitch-loops
-fvect-cost-model=dynamic       # O2: =very-cheap
-fversion-loops-for-strides
```



# (B) Individual Compiler Optimizations
