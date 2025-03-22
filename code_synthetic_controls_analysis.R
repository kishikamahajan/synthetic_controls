# Loading the dataset
data("basque")
basque %>% dplyr::glimpse()

# Generating the control
synthetic_control_model <- basque %>%
  
  synthetic_control(outcome = gdpcap,
                  unit = regionname,
                  time = year,
                  i_unit = "Basque Country (Pais Vasco)",
                  i_time = 1970,
                  generate_placebos = T) %>%
  
  generate_predictor(time_window = 1964:1969,
                   invest = mean(invest , na.rm = T),
                   working_age_pop_ill = mean(school.illit , na.rm = T),
                   working_age_pop_prim = mean(school.prim , na.rm = T),
                   working_age_pop_high = mean(school.high , na.rm = T),
                   working_age_pop_post_high = mean(school.post.high , na.rm = T)) %>%
  
  generate_predictor(time_window = 1961:1969,
                   agriculture = mean(sec.agriculture , na.rm = T),
                   energy = mean(sec.energy , na.rm = T),
                   industry = mean(sec.industry , na.rm = T),
                   construction = mean(sec.construction , na.rm = T),
                   services_venta = mean(sec.services.venta , na.rm = T),
                   services_nonventa = mean(sec.services.nonventa , na.rm = T)) %>%  
  
  generate_predictor(time_window = 1960:1969,
                   gdpcap = mean(gdpcap , na.rm = T)) %>%  
  
  generate_predictor(time_window = 1969,
                   popdens = mean(popdens , na.rm = T)) %>%  
  
  generate_weights(optimization_window = 1955:1974) %>%
  
  generate_control()
  
# Plotting the trends
synthetic_control_model %>%
  plot_trends()
  
Observation: As can be seen from the above plot, the pre-trends i.e., before the intervention closely match to each other. There is extremely minimal variation but overall, the trends pretty much mirror each other. 

As for the trends post the intervention, we see trends diverging between the treated and the donor pool. The trend which is higher post the intervention is actually from the synthetic group. This is what would've been expected. The effect of the terrorism activity would've been a lower GDP in the region which is what we observe from the graph as well by the dramatic fall after large scale terrorism activity took place in the Basque region. 
  
# Plotting the differences
synthetic_control_model %>%
  plot_differences()
  
This plot shows the difference between the treated and the synthetic groups and we can essentially check whether the gap is significantly different from 0 pre and post treatment. 

No, the pre-treatment difference is not exactly zero. The gap varies between -0.25 and almost 0.05. However, these pre-treatment differences shouldn't raise much concern as the magnitude of these differences post the treatment is significantly higher which even cross -1 around 1989 and -1 in 1990. 

# Plotting unit and predictor weights
synthetic_control_model %>%
  plot_weights()
  
Observations:
1. As can be seen from the above plots, maximum unit weights are assigned to Cataluna and Madrid (Comunidad De). 
2. As for the predictor weights, the majority of the weights have been assigned to "popdens" and "agriculture". Futher, industry, gdpcap, and working age population with more than high school education, among others have been assigned the next set of high weights. 

# Plotting the gaps in per capita GDP for the Basque region and its synthetic version as well as the gaps for other placebo synthetic controls 

synthetic_control_model %>%
  plot_placebos()

As can be observed from the above plot, before the treatment, the difference in Basque county and the control units is significantly close to 0 which indicates good pre-treatment fit for both treated and control units. However, post the treatment, the difference in Basque Country diverges significantly from 0, more importantly this divergence is way more than any of the control units in that, the negative trend is persistent and systematic particularly post 1975. The control units have relatively smaller differences post the treatment and none show the consistent, large negative deviation seen in the Basque Country. 

# Plotting the ratio of the pre vs post intervention period mean squared prediction errors for Basque and all other units

synthetic_control_model %>%
  plot_mspe_ratio()

Yes, the result is consistent with what would've been expected. This is because we would expect the post MSPE to pre MSPE ratio to be the highest in the treated group, i.e., we would expect to the most post-treatment effects in the group that was treated. In other words, this proves the point that the negative effects of terrorism in the Basque Country were in fact extreme enough compared to the donor pools' and that this effect observed in Basque Country was unlikely to have occurred by chance. 
We would've expected the regions in the donor pool to have smaller ratios i.e., the effects should not differ by much in the post treatment period as compared to the pre treatment period. 
  
# Plotting a significance table which shows p-values for the treatment effect of the treated unit and all other donor units

synthetic_control_model %>%
  grab_significance()

As can be seen Basque Country has been given the first rank and when we look at the p-value on Basque, it is approximately 0.056. This is technically above the 5% significance level. Hence, going purely by this table, the treatment effect of the treated unit is not significant. 
However, it should be noted that the total number of regions is only 18 and this affects the minimum possible p-value (1/18 ≈ 0.056). For the treatment effect to be "significant" by the 5% level, we need atleast 20 entries as 1/20 = 0.05. Hence, had there been 2 more regions in the donor pool, we could've probably concluded that the effect is "significant". 

However, it must be noted that the MSP ratio for Basque country is significantly larger than the next highest (81 vs 9). Hence, the p-value which is a little above the significance level shouldn't be the sole reason for discarding the otherwise significant treatment effect. 
