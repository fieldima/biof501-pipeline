#Plotting the FUBAR data

library(jsonlite)
library(here)
library(tidyverse)

snake_data <- function (data_path, out_path) {
  fubar <- fromJSON(data_path)
  dat <- as.data.frame(fubar$MLE$content) %>% select(-c(X0.7, X0.8))
  header <- fubar$MLE$headers[,1]
  colnames(dat) <- header
  codon_vector <- c(1:length(dat$alpha))
  
  sel <- dat %>% mutate(selection = if_else(`Prob[alpha<beta]` >= 0.9, "Positive selection", if_else(`Prob[alpha>beta]` >= 0.9, "Stabilizing selection", "Neutral selection")),
                        codon = codon_vector) %>%
    select(codon, alpha, beta, selection)
  
  plot <- sel %>% ggplot(aes(x = codon, y = alpha, fill = selection)) + geom_col(width = 10) +
    geom_col(aes(y = -beta), width = 10) + theme_bw() + geom_text(
      data = subset(sel, selection == "Positive selection"), 
      aes(label = codon), 
      nudge_y = -10,
      angle = 45
    ) +
    ggtitle("Synonymous and Non-synonymous Substitution Rate Per Codon", subtitle = "With Labeled Positively Selected Sites") +
    ylab("Substitution Rate") + xlab("Codon")
  ggsave(out_path, plot = plot, width = 20, height = 10, units = "cm")
}

snake_data(snakemake@input[[1]], snakemake@output[[1]])