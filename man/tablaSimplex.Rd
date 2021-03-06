% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tablaSimplexfuncion.R
\name{tablaSimplex}
\alias{tablaSimplex}
\title{Resolución de un problema simplex en formato tabla .xlsx}
\usage{
tablaSimplex(lp, wb, max_iteracion = 100)
}
\arguments{
\item{lp}{Objeto tipo \code{lpExtPtr} proveniente del paquete
\code{lpSolveAPI} y que debe estar resuelto con la funcion solve antes de
ser introducido}

\item{wb}{Donde se coloca un objeto Workbook de XLConnect}
}
\value{
Rellena un archivo .xlsx, previamente creado con loadWorkbook, con la
 resolucion de un problema de Simplex.
}
\description{
Genera cada una de las tablas hasta la solución óptima de un problema Simplex
y lo exporta en un archifo de formato .xlsx
}
\details{
Esta función requiere de dos objetos: Uno lpExtPtr que esté resuelto
 con la funcion \link[lpSolveAPI]{solve}, y otro de tipo workbook, ambos
 provenientes de los paquetes lpSolveAPI y XLConnect

 Nótese que el problema de programación lineal introducido debe estar
 necesariamente en forma estándar, porque de momento no contiene un argumento
 que permita elegir la base inicial con la que comenzar la tabla de Simplex.
 En el apartado ejemplos se resuelve un problema sencillo en forma estándar
 con variables de holgura y soluciones enteras.

 Finalmente, el .xlsx devuelto contendrá una fila de Ms para el supuesto de
 que se utilice el método de la M grande. La función detecta de forma
 automática cuales de las variables son artificiales, comparando los
 coeficientes de las variables de la base inicial que sean mayores que cero,
 con aquellos coeficientes de las variables iniciales mayores que cero
 (suponiendo que las variables artificiales tengan un coeficiente
 significativamente grande).
}
\examples{
#Cargamos un problema de programaciÃ³n lineal y lo resolvemos
library(lpSolveAPI)
library(XLConnect)

problem_79_es <- make.lp(3,5)
set.objfn(problem_79_es, c(-2,-5, 0, 0, 0))
set.rhs(problem_79_es, c(7,3,5))
set.constr.type(problem_79_es, c(rep("=", 3)))
set.row(problem_79_es,1, c(-6, -2, 1, 0, 0))
set.row(problem_79_es,2, c(-8, -4, 0, 1, 0))
set.row(problem_79_es,3, c(1, 4, 0, 0, 1))

solve(problem_79_es)

#Procedemos a generar el objeto workbook y a utilizar la funciÃ³n. Como resultado,
#deberÃ­a aparecer un objeto .xlsx en la carpeta del directorio de trabajo con el nombre
#indicado (en este caso, "Miproblema79.xlsx").

problem79 <- loadWorkbook("Miproblema79.xlsx", create = TRUE)
tablaSimplex(problem_79_es, wb = problem79)
saveWorkbook(problem79)
}
