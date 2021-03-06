# source - https://jacksonlab.agronomy.wisc.edu/2016/05/23/15-level-colorblind-friendly-palette/
colorblind_palette <- c("#000000","#004949","#009292","#ff6db6","#ffb6db",
                        "#490092","#006ddb","#b66dff","#6db6ff","#b6dbff",
                        "#920000","#924900","#db6d00","#24ff24","#ffff6d")

d <- read.csv("cutstudy.csv")

constFit <- lm(d$absorption~1)
absorptionEstimate <- summary(constFit)$coefficients[1]
absorptionError <- summary(constFit)$coefficients[2]

p <- d %>% mutate(cut = fct_reorder(cut, desc(factor_order))) %>%
     ggplot(aes(color=cut,
                   order=factor_order,
                   x=0,
                   y=absorption,
                   ymin=absorption-uncertainty,
                   ymax=absorption+uncertainty)) +
     geom_pointrange(position=position_dodge(width=0.5))+
     annotate("text", x=-0.157, y=absorptionEstimate*1.015,
              label=TeX(sprintf(r'($\\bar{A}_{exp}$ = %0.2f $\\pm$ %0.2f)', absorptionEstimate, absorptionError))) +
     geom_hline(aes(yintercept=absorptionEstimate), colour="black") +
     annotate("rect", xmin = -Inf, xmax = Inf, ymin = absorptionEstimate-absorptionError, ymax = absorptionEstimate+absorptionError, fill = "black", alpha = .2, color = NA) +
     theme_bw()+
     theme(axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
     scale_color_manual(values=rev(head(color_blind_palette,n=11))) +
     ylab("Absorption [%]")

absorptionOriginal <- d[d$cut=="Original cuts",]$absorption
absorptionOriginalUncertainty <- d[d$cut=="Original cuts",]$uncertainty

# Percent difference
d <- d %>% mutate(percentDifference = 100*(absorption-absorptionOriginal)/absorptionOriginal)
# d <- d %>% mutate(percentDifferenceUncertainty = 100*sqrt( (absorption^2 * absorptionOriginalUncertainty^2)/absorptionOriginal^4 + uncertainty^2/absorptionOriginal^2))
d <- d %>% mutate(percentDifferenceUncertainty = abs(percentDifference * sqrt( (uncertainty^2+absorptionOriginalUncertainty^2)/(absorption-absorptionOriginal)^2 + (absorptionOriginalUncertainty/absorptionOriginal)^2 )))
# d <- d %>% mutate(percentDifferenceUncertainty = percentDifference*sqrt(uncertainty^2+absorptionOriginalUncertainty^2)*sqrt(1/(absorption-absorptionOriginal)^2 + 1/(absorption+absorptionOriginal)^2))

pPctDiff <- d %>% mutate(cut = fct_reorder(cut, desc(factor_order))) %>%
     ggplot(aes(color=cut,
                order=factor_order,
                x=0,
                y=percentDifference,
                ymin=percentDifference-percentDifferenceUncertainty,
                ymax=percentDifference+percentDifferenceUncertainty)) +
     geom_pointrange(position=position_dodge(width=0.5))+
     theme_bw()+
     theme(axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
     scale_color_manual(values=rev(head(color_blind_palette,n=11))) +
     ylab("Percent difference [%]")

# Absolute difference
d <- d %>% mutate(absoluteDifference = absorption-absorptionOriginal)
d <- d %>% mutate(absoluteDifferenceUncertainty = sqrt(uncertainty^2+absorptionOriginalUncertainty^2))

pAbsDiff <- d %>% mutate(cut = fct_reorder(cut, desc(factor_order))) %>%
     ggplot(aes(color=cut,
                order=factor_order,
                x=0,
                y=absoluteDifference,
                ymin=absoluteDifference-absoluteDifferenceUncertainty,
                ymax=absoluteDifference+absoluteDifferenceUncertainty)) +
     geom_pointrange(position=position_dodge(width=0.5))+
     theme_bw()+
     theme(axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
     scale_color_manual(values=rev(head(color_blind_palette,n=11))) +
     ylab("Absolute difference [%]")

ggsave("proton_absorption_cut_study.pdf", p, width=7, height=3)
ggsave("proton_absorption_cut_study_percent_difference.pdf", pPctDiff, width=7, height=3)
ggsave("proton_absorption_cut_study_absolute_difference.pdf", pAbsDiff, width=7, height=3)
