

#' Estimate Score Distribution
#'
#' Estimates the score distribution to compute the standard error
#' associated with the linking error. This function requires PIAAC data.
#'
#' @param piaac_data The PIAAC dataset. It must contain plausible values and the Weight0 variable.
#' @param by A categorical variable used to estimate different score distributions.
#' @param pvs_names A character vector specifying the names of the plausible value columns.
#' @param weights The Weight0 variable from the PIAAC dataset.
#'
#' @import kde1d
#' @import data.table
#'
#' @author Manuel Reif
#'
#' @export
#'
estimate_score_distr <- function(piaac_data,
                                 by = "GENDER_rec",
                                 pvs_names,
                                 weights = "SPFWT0"){

  density_list = lapply(pvs_names, function(pvx){
    score_kernels = piaac_data[, .(fn = .(kde1d(get(pvx),
                                                weights = get(weights)))),
                               by = by]
  })

  attr(density_list, "by") = by
  attr(density_list, "pvs_names") = pvs_names

  return(density_list)

}



#' Estimate Density Values
#'
#' This function estimates the density values of the score distribution,
#' by using the empirical distribution fitted by means of `estimate_score_distr`.
#'
#' @param x_values We want the density to specific x_values. In PIAAC this are
#' the proficiency scores.
#' @param density_list This is the result of `estimate_score_distr`.
#'
#' @author Manuel Reif
#'
#' @export
estimate_score_dens_value <- function(x_values,
                                      density_list){

  by = attr(density_list, "by")
  durch = seq_along(density_list)

  dens_value_list = lapply(durch, function(du) {
    xth_density = density_list[[du]]
    dens_values = xth_density[, .(density = dkde1d(x = x_values, obj = fn[[1]]),
                                  x_values = x_values,
                                  durch = du), by = by]
    return(dens_values)
  })

  dens_value_dt <- data.table::rbindlist(dens_value_list)

  dens_value_dt_agg = dens_value_dt[, .(mean_dens =  mean(density)),
                                    by = c(by, "x_values")]

  attr(dens_value_dt_agg, "by") = by

  return(dens_value_dt_agg)
}


# HELPER!
diff_character <- function(x){

  x_lagged = vector(mode = "character", length = length(x) - 1)

  for(i in 2:length(x)){
    x_lagged[i-1] = paste(x[i-1], "-", x[i])
  }
  return(x_lagged)
}



#' Estimate the Linking Error
#'
#' Take the density values and the linking error (one value for each dimension)
#' and estimate the level dependent linking error which is the basis for the
#' latter estmation of the "linking error considering" Standard Error!
#'
#' @param estimated_dens Result of: `estimate_score_dens_value`.
#' @param linking_error One Number.
#'
#' @author Manuel Reif
#'
estimate_LE <- function(estimated_dens, linking_error, levlab){

  by = attr(estimated_dens, "by")

  dens_diffs = estimated_dens[, .(dens_diff = diff(mean_dens),
                                  cat_diff = diff_character(x_values),
                                  names = levlab), by = by]
  dens_diffs[, LE := linking_error * abs(dens_diff)]
  return(dens_diffs)
}


# HELPER
create_by_variables = function(dataset1, dataset2){

  d1 = dataset1 %>% data.table
  d2 = dataset2 %>% data.table

  cn1 = colnames(d1)
  v1  = lapply(cn1, function(cn_akt){
    d1[,get(cn_akt)] %>% unique
  })


  cn2 = colnames(d2)
  v2 = lapply(cn2, function(cn_akt){
    d2[,get(cn_akt)] %>% unique
  })


  by_x = c()
  by_y = c()
  vec_numb = 1

  for(i in seq_along(cn1)){
    for(a in seq_along(cn2)){
      if(identical(v1[[i]] %>% sort, v2[[a]] %>% sort)){
        by_x[vec_numb] = cn1[i]
        by_y[vec_numb] = cn2[a]
        vec_numb = vec_numb + 1
      }
    }
  }

  res = list(by_x = by_x, by_y = by_y)
  return(res)
}



#' Compare Levels between cycles
#'
#'  Compare Levels between cycles
#'
#' @param by A categorical variable used to estimate different score distributions.
#' @param svydat_cycle1 svydat_cycle1
#' @param svydat_cycle2 svydat_cycle2
#' @param data4score Data to estimate the Score Distirbution. Data from Cylcle 2
#' is recommanded.
#' @param weights Weight0 to weight the Score Distribution.
#' @param pvs_names A character vector specifying the names of the plausible value columns.
#' @param CATDEF Argument from `svyPVlevel`
#' @param levlab Labels of Levels
#' @param LE_global Linking Error for Literacy or Numercy depending on the pvs_names
#'
#'
#' @author Manuel Reif
#'
#' @export
#'
compare_cycle_levels = function(by,
                                svydat_cycle1,
                                svydat_cycle2,
                                data4score,
                                weights,
                                pvs_names,
                                CATDEF,
                                levlab,
                                LE_global){

  cat("estimating cycle 1\n")
  res1 <- svyPVlevel(by = by,
                     svydat = svydat_cycle1,
                     pvs = pvs_names,
                     CATDEF = CATDEF,
                     levlab = levlab)

  cat("estimating cycle 2\n")
  res2 <- svyPVlevel(by = by,
                     svydat = svydat_cycle2,
                     pvs = pvs_names,
                     CATDEF = CATDEF,
                     levlab = levlab)

  cat("estimating LE and merging\n")

  grouping_variables = all.vars(by[[2]]) %>% as.character()

  res1dt = res1 %>% data.table
  res2dt = res2 %>% data.table

  score_distr = estimate_score_distr(piaac_data = data4score,
                                     by = grouping_variables,
                                     pvs_names = pvs_names, weights = weights)

  dens_point_est = estimate_score_dens_value(x_values = CATDEF,
                                             density_list = score_distr)


  linking_error <- estimate_LE(estimated_dens = dens_point_est,
                               linking_error = LE_global,
                               levlab = levlab)


  by_var1 = create_by_variables(res1, res2)
  by_var2 = create_by_variables(res2, linking_error)

  ON1 = setNames(by_var1$by_x, by_var1$by_y)
  ON2 = setNames(by_var2$by_y, by_var2$by_x)
  ### big merging party

  res1dt[res2dt, Proportion_c2 := i.Proportion, on = ON1]
  res1dt[res2dt, Proportion.SE_c2 := i.Proportion.SE, on = ON1]

  res1dt[linking_error, LE := i.LE, on = ON2]

  res1dt[, Prop_diff := Proportion - Proportion_c2]
  res1dt[, ges_SE := sqrt(Proportion.SE^2 + Proportion.SE_c2^2 + LE^2)]

  res1dt
}



