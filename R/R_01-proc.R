#Tarea 3 -----------------------------------------------------------------------

#Josefa Espinoza - Camilo Riquelme - Isidora Toledo

#Cargar Paquetes

pacman::p_load(haven, tidyverse, srvyr, survey)

#Cargar Datos

data=read_sav("input/data/ELSOC_W04_v2.01.sav")

#Exploracion inicial de datos a seleccionar

frq(data$c20) #44 ¿Cuál es el movimiento social que ud. más valora?
frq(data$c22) #45 y 53 Frecuencia de participacion en movimientos sociales del entrevistado
frq(data$c41_01) #53 Grado de rabia: Actuales niveles de desigualdad en Chile
frq(data$c41_02) #53 Grado de rabia: El costo de la vida en Chile
frq(data$c16) #58 ¿Cuál de los siguientes partidos políticos representa mejor sus intereses, creencias y valores?
frq(data$c18_04) #74 Grado de acuerdo: Mas que derechos necesitamos un gobierno firme
frq(data$c18_05) #74 Grado de acuerdo: Pais necesita un mandatario fuerte
frq(data$c18_06) #74 Grado de acuerdo: Obediencia y respeto importantes que aprendan los ninnios
frq(data$c18_07) #74 Grado de acuerdo: Obediencia y disciplina son claves para buena vida
frq(data$c23) #Frecuencia de participacion en movimientos sociales familiar del entrevistado
frq(data$c24) #Frecuencia de participacion en movimientos sociales amigo del entrevistado

#Procesamiento -----------------------------------------------------------------

data_proc = data%>%
  select(idencuesta, muestra, m0_sexo, m0_edad , region, estrato, m29_rev, ponderador01, fact_exp01, 
         c20, c22, c23, c24, c41_01, c41_02, c16, c18_04, c18_05, c18_06, c18_07)%>%
  mutate(c20 = case_when(c20==1~"Estudiantil", c20==2~"Laboral", c20==3~"Ambiental", 
                         c20==4~"Indigena", c20==5~"Diversidad Sexual", c20==6~"Provida o Antiaborto", 
                         c20==7~"Antidelincuencia", c20==8~"Feminista", c20==9~"Pensiones",
                         c20==10~"Mov Social de Octubre (18/O)", c20==11~"Otro", c20==12~"Ninguno",
                         TRUE~NA_character_),
         c22_45 = case_when(c22>=3 & c22<=5~"A veces, Frecuentemente o Muy frecuentemente", 
                            c22>=1 & c22<=2~"Nunca/Casi Nunca",
                            TRUE~NA_character_),# variable codificada para la página 45
         c22_53 = case_when(c22>=4 & c22<=5~"Frecuentemente o Muy frecuentemente",
                            c22==3~"A veces", c22>=1 & c22<=2~"Nunca/Casi Nunca",
                            TRUE~NA_character_), #variable codificada para la pagina 53
         c23 = case_when(c23>=3 & c23<=5~"A veces, Frecuentemente o Muy frecuentemente", 
                         c23>=1 & c23<=2~"Nunca/Casi Nunca",
                         TRUE~NA_character_),
         c24 = case_when(c24>=3 & c24<=5~"A veces, Frecuentemente o Muy frecuentemente", 
                         c24>=1 & c24<=2~"Nunca/Casi Nunca",
                          TRUE~NA_character_),
         c41_01 = case_when(c41_01==1~"Nada", c41_01>=2 & c41_01<=3~"Poca o Algo",
                            c41_01>=4 & c41_01<=5~"Bastante o Mucha",
                            TRUE~NA_character_),
         c41_02 = case_when(c41_02==1~"Nada", c41_02>=2 & c41_02<=3~"Poca o Algo",
                            c41_02>=4 & c41_02<=5~"Bastante o Mucha",
                            TRUE~NA_character_),
         c16 = case_when(c16>=1 & c16<=2~"PC + PH", c16>=3 & c16<=4~"PRO + RD", c16==14~"Otro",
                         c16==15~"Ninguno", c16==5~"RN + UDI + EVO", c16>=10 & c16<=11~"RN + UDI + EVO",
                         c16==6~"PPD + PDC + PS + PR", c16==8~"PPD + PDC + PS + PR",
                         c16>=12 & c16<=13~"PPD + PDC + PS + PR",
                         TRUE~NA_character_),
         c18_04 = case_when(c18_04>=4 & c18_04<=5~"De acuerdo o Totalmente de acuerdo",
                            c18_04>=1 & c18_04<=3~"Totalmente en desacuerdo/En desacuerdo/Ni de acuerdo ni en desacuerdo",
                            TRUE~NA_character_),
         c18_05 = case_when(c18_05>=4 & c18_05<=5~"De acuerdo o Totalmente de acuerdo",
                            c18_05>=1 & c18_05<=3~"Totalmente en desacuerdo/En desacuerdo/Ni de acuerdo ni en desacuerdo",
                            TRUE~NA_character_),
         c18_06 = case_when(c18_06>=4 & c18_06<=5~"De acuerdo o Totalmente de acuerdo",
                            c18_06>=1 & c18_06<=3~"Totalmente en desacuerdo/En desacuerdo/Ni de acuerdo ni en desacuerdo",
                            TRUE~NA_character_),
         c18_07 = case_when(c18_07>=4 & c18_07<=5~"De acuerdo o Totalmente de acuerdo",
                            c18_07>=1 & c18_07<=3~"Totalmente en desacuerdo/En desacuerdo/Ni de acuerdo ni en desacuerdo",
                            TRUE~NA_character_))
#Creacion objeto encuesta

data_proc = data_proc%>%
  group_by(estrato)%>%
  mutate(stratn = sum(fact_exp01))%>%
  ungroup()

obj_enc = data_proc%>%
  as_survey_design(ids = 1,
                    strata = estrato,
                    fpc = stratn,
                    weights = ponderador01)

#Guardar Datos -----------------------------------------------------------------

saveRDS(data_proc, file = "output/data/data_proc.rds")
