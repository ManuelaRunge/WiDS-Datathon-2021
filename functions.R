# Title     : Women in data Science Datathon 2021
# Objective : Classification Problem, predict diabetes yes/no
# Team      : <team_name>
# Related rscripts: data_processing.R, target_prediction.R, functions.R
# Created on: 2/18/2021
###----------------------------------------

f_cols_by_cat <- function(codebook=""){
  if(codebook==""){
    codebook <- fread(file.path(data_dir, "DataDictionaryWiDS2021.csv"))
    colnames(codebook) <- gsub(" ", "_", tolower(colnames(codebook)))
  }
  ### Group variables by category
  #table(codebook$category)
  category_labels = gsub(" ", "", unique(tolower(codebook$category)))
  cols_cat = list()
  for (i in c(1:length(category_labels))) {
    category <- unique(codebook$category)[i]
    category_label = category_labels[i]
    cols_cat[[category_label]] <- codebook$variable_name[codebook$category == category]
  }
  return(cols_cat)
}


f_get_cols_strint <- function (dat){
  ### Group variables by type
cols_binary=c()
cols_numeric=c()
cols_character=c()
cols_intstr = list()
for (col in colnames(dat)) {
  if(is.numeric(dat[[col]]) & length(unique(dat[[col]])) ==2 )  cols_binary <- c(cols_binary, col)
  if(is.numeric(dat[[col]])) cols_numeric <- c(cols_numeric, col)
  if(is.character(dat[[col]])) cols_character <- c(cols_character, col)

}
cols_intstr[['binary']] <- cols_binary
cols_intstr[['numeric']] <- cols_numeric
cols_intstr[['character']] <- cols_character
return(cols_intstr)
}

p_hist_by_target <- function(dat=train_df,
                             selected_cols=cols_intstr$numeric[1:10],
                             target_var = 'diabetes_mellitus',
                             plotname="phist",
                             SAVE=FALSE){
 # title = names(cols)[i]
    phist <- dat %>%
      select_at(c(selected_cols, target_var)) %>%
      pivot_longer(cols = -target_var) %>%
      rename('target_var' = target_var) %>%
      ggplot(aes(x = value, fill = as.factor(target_var), group=target_var)) +
      geom_histogram() +
      facet_wrap(~name, scales = "free")+
      labs(x="Value", y="Count", fill=target_var) +
      theme(legend.position = "top")+
      scale_fill_manual(values=c("deepskyblue3","orange"))
    if(SAVE){
      if(!dir.exists(file.path("fig")))dir.create(file.path("fig"))
      ggsave(paste0(plotname,'.png'),phist, path=file.path("fig"), device = "png")
    }
return(phist)
}

p_bar_by_target <- function(dat=train_df,
                             selected_cols=cols_intstr$character,
                             target_var = 'diabetes_mellitus',
                             plotname="pbar",
                             SAVE=FALSE){
    l = length(selected_cols)
    selected_cols <- train_df  %>% select_at(selected_cols) %>% select_if(is.character) %>% colnames()
    print(paste0("Removed ",l - length(selected_cols)," non character variables"))
    pbar <- train_df %>%
      select_at(c(selected_cols, target_var)) %>%
      pivot_longer(cols = -target_var) %>%
      rename('target_var' = target_var) %>%
      ggplot() +
      geom_bar(aes(x = value, group = target_var, fill = as.factor(target_var))) +
      facet_wrap(~name, scales = "free") +
      labs(x="Value", y="Count", fill=target_var) +
      coord_flip() +
      theme(legend.position = "top")+
      scale_fill_manual(values=c("deepskyblue3","orange"))
    if(SAVE){
      if(!dir.exists(file.path("fig")))dir.create(file.path("fig"))
      ggsave(paste0(plotname,'.png'),pbar, path=file.path("fig"), device = "png")
    }
return(pbar)
}
