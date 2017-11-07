#' Title Generador de soluciones de problemas de programacion lineal con simplex en tablas de formato .xlsx
#'
#' @param lp Objeto tipo lpExtPtr proveniente del paquete lpSolveAPI y que debe estar resuelto con la funcion solve antes de ser introducido
#' @param wb Donde se coloca un objeto Workbook de XLConnect
#'
#' @return Rellena un archivo .xlsx, previamente creado con loadWorkbook, con la resolucion de un problema de Simplex.
#' @export
#'
#' @examples
#' print("Introduciremos ejemplos posteriormente, disculpa las molestias.")
tablaSimplex <- function(lp, wb){
  XLConnect::createSheet(wb, "Sheet1")

  iteracion <- 1

  texteitor(lp, wb, iteracion)

  nombres_regiones <- XLConnect::getDefinedNames(wb)[!stringr::str_detect(XLConnect::getDefinedNames(wb), "base")]

  indices <- 1:4
  inicio <- 3

  #Espacio para determinar el color de la celda del pivote
  estilocelda <- XLConnect::createCellStyle(wb, "estilocelda")
  XLConnect::setFillBackgroundColor(estilocelda, color = XLC$"COLOR.LIGHT_GREEN")
  XLConnect::setFillForegroundColor(estilocelda, color = XLC$"COLOR.LIGHT_GREEN")
  XLConnect::setFillPattern(estilocelda, fill = XLC$"FILL.SOLID_FOREGROUND")

  while(iteracion <= 4){
    costes <- XLConnect::readNamedRegion(wb, stringr::str_c("costes_redux", iteracion), header = FALSE)
    m_restr <- XLConnect::readNamedRegion(wb, stringr::str_c("restricciones", iteracion), header = FALSE)
    celda_restr <- coord_celdas(wb, stringr::str_c("restricciones", iteracion))
    rhs_num <- XLConnect::readNamedRegion(wb, stringr::str_c("rhs", iteracion), header = FALSE)
    pivote <- pivot_calc(m_restr, celda_restr, costes, rhs_num)
    base_vars <- XLConnect::readWorksheet(wb, "Sheet1", startRow = inicio + 1, endRow = inicio + nrow(lp), startCol = 1, endCol = 1, header = FALSE)
    if(!is.null(pivote)){
      #Coloreamos la celda del pivote
      XLConnect::setCellStyle(wb, sheet = "Sheet1", row = inicio + pivote$Fila, col = 2 + pivote$Columna, cellstyle = estilocelda)
      iteracion <- iteracion + 1
      texteitor(lp, wb, iteracion)
      for(x in indices){
        nombres_regiones <- XLConnect::getDefinedNames(wb)[!str_detect(getDefinedNames(wb), "base")]
        celda <- coord_celdas(wb, nombres_regiones[x])
        formula <- formula_celdas(celda, pivote)
        coord <- XLConnect::getReferenceCoordinatesForName(wb, nombres_regiones[x + 4])
        times <- nrow(as.matrix(formula))
        XLConnect::setCellFormula(wb, sheet = "Sheet1", row = coord[1,1]:coord[2,1], col = sort(rep(coord[1,2]:coord[2,2], times)), formula = formula)
        }

      } else {
        return("Algoritmo finalizado.")
      }
    #¿Sección para actualizar la columna cB y las variables de la base?
    var_base <- XLConnect::readWorksheet(wb, "Sheet1", startRow = 1, endRow = 1, startCol = 3, endCol = 3 + ncol(lp), simplify = T, header = FALSE)
    #Dibujamos la columna de las variables de la base de la tabla anterior
    XLConnect::writeWorksheet(wb, base_vars, "Sheet1", startRow = inicio + nrow(lp) + 5, startCol = 1, header = FALSE)
    #Metemos la var de entrada en la columna izquierda
    XLConnect::writeWorksheet(wb, var_base[pivote$Columna], "Sheet1", startRow =  inicio + nrow(lp) + 4 + pivote$Fila, startCol = 1, header = FALSE)
    #Actualizamos la columna cB con los coeficientes de la base de la iteracion anterior
    rhs_new <- XLConnect::readNamedRegion(wb, paste0("base_coefs", iteracion - 1), header = FALSE)
    XLConnect::writeNamedRegion(wb, data = rhs_new, name = paste0("base_coefs", iteracion), header = FALSE)
    #Actualizamos la columna cB con el coeficiente de la variable que ha entrado
    XLConnect::writeWorksheet(wb, get.mat(lp, 0, pivote$Columna), "Sheet1", startRow = inicio + nrow(lp) + 4 + pivote$Fila, startCol = 2, header = FALSE)
    indices <- indices  + 4
    inicio <- inicio + nrow(lp) + 4
  }

}
