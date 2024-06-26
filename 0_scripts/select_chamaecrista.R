### load libraries
if(!require("tidyverse")) install.packages("tidyverse"); library("tidyverse")
if(!require("ggplot2")) install.packages("ggplot2"); library("ggplot2")
if(!require("phangorn")) install.packages("phangorn"); library("phangorn")
if(!require("ape")) install.packages("ape"); library("ape")
if(!require("seqinr")) install.packages("seqinr"); library("seqinr")

### input diretory
dir_input = "2_cassieae/sequences_rogueless/"
file_names = list.files(dir_input)

### loading data
fasta_list = list()
for(i in 1:length(file_names) ){
  fasta_list[[i]] = read.phyDat(paste0(dir_input, file_names[i]),
                                format = "fasta",
                                type = "DNA"
  )
  names(fasta_list)[i] = str_remove(string = file_names[i], 
                                    pattern = ".fasta")
}

################################# FIND COMMON SPECIES ###########################

### getting species per locus
all_names = c()
for(i in 1:length(fasta_list)){
  some_names = names(fasta_list[[i]])
  all_names = c(all_names, some_names)
}
### into one dataframe
all_names = unique(all_names)

### get names per locus
names_loci =  all_names
for(i in 1:length(fasta_list)){
  boll_names = all_names %in% names(fasta_list[[i]])
  names_loci = cbind(names_loci, boll_names)
}
colnames(names_loci) = c("species", names(fasta_list))

### transform to tibble
names_loci = as_tibble(names_loci)
### get species with all loci sequenced 
common_names = names_loci %>% 
  filter_at(vars(-species), all_vars(. == TRUE) ) %>% 
  select(species) %>% 
  pull()

### get species with loci in nucleus and plastid
sampled_names = names_loci %>% 
  filter( !grepl("C_", species)) %>% 
  filter((ETS == TRUE |ITS == TRUE) & (matK == TRUE | trnDT == TRUE | trnLF == TRUE)) %>% 
  select(species) %>% 
  pull()

### chamaecrista names
c_names = names_loci %>% 
  filter( grepl("C_", species)) %>% 
  select(species) %>% 
  pull()

### keep names
keep_names = c(c_names, sampled_names)

### keeping only cassieae
my_fasta_list = fasta_list
for(i in 1:length(fasta_list)){
  my_fasta_list[[i]] = fasta_list[[i]][names(fasta_list[[i]]) %in% keep_names]
  names(fasta_list)[i] = names(fasta_list)[i]
}

### exporting sequences from ingroup
dir_out = "2_chamaecrista/sequences_rogueless/"
for(i in 1:length(my_fasta_list)){
  fasta_name = paste0(names(my_fasta_list)[i], ".fasta")
  write.phyDat(x = my_fasta_list[[i]], 
               file = paste0(dir_out,fasta_name), 
               format = "fasta", 
               colsep = "", 
               nbcol =100
  )
}
