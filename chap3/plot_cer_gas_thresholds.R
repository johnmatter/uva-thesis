# Masses in GeV
mElec <- 0.000510998
mPi   <- 0.13957
mKaon <- 0.493677
mProt <- 0.938272

# Index of refraction at 101.325 kPa, 0 deg C, for wavelength of 589.3 nm
# https://refractiveindex.info
nAero  <- 1.03
nC4F8O <- 1.00137 # https://userweb.jlab.org/~hcf/shmsnim/shmsNIM.pdf
nCO2   <- 1.000449
nNe    <- 1.000067
nN2    <- 1.00031
nAr    <- 1.000281
nH2    <- 1.000132
nHe    <- 1.000036

nOneAtm<-c(nAr, nCO2, nNe, nHe, nC4F8O)
nLabels<-c("Ar","CO2","Ne","He", "C4F8O")

# TODO: Save the indices of refraction as a CSV. It'll be easier to ggplot
# them with labels if they're loaded as a dataframe.

# What about at operating pressure?
# n-1 is proportional to number density, and therefore pressure
nMinus1 <- nOneAtm-1
nMinus1AtPressure <- nMinus1*1
nAtPressure <- nMinus1AtPressure+1

n <- c(nAtPressure)
cherenkovThresh <- 1-1/n

gasdf <- data.frame(yint=cherenkovThresh,
                    grp=as.factor(nLabels))

# Momentum
pStep <- 0.01
pMin  <- pStep
pMax  <- 9
p <- seq(pMin,pMax,pStep)
p <- c(0, p)

numSteps <- length(p)

# Beta
betaElec <- p/sqrt(p^2+mElec^2)
betaPi   <- p/sqrt(p^2+mPi^2)
betaKaon <- p/sqrt(p^2+mKaon^2)
betaProt <- p/sqrt(p^2+mProt^2)
beta     <- c(betaElec, betaPi, betaKaon, betaProt)

# PID
pid <- c(rep("electron", numSteps),
         rep("pion", numSteps),
         rep("kaon", numSteps),
         rep("proton", numSteps)
        )

# Data frame for ggplot
plotMe <- data.frame("pid"=pid, "p"=p, "beta"=beta)

pCer <- ggplot(plotMe,
               aes(
                   x=p,
                   y=1-beta,
                   color=pid
                   )
               ) +
        geom_line() +

        scale_x_continuous(breaks = seq(0,pMax,1)) +
        scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                      labels = trans_format("log10", math_format(10^.x))) +
        annotation_logticks(sides = "lr") +

        scale_color_manual(values=rep("black",4), guide=FALSE) +
        scale_linetype_manual(values=c(2,3,4,5,6),limits=rev(c("He","Ne","Ar","CO2","C4F8O"))) +

        ylab(TeX('$1-\\beta$')) +
        xlab('p [GeV]') +

        annotate("text", x=2,   y=7e-8, label= TeX('$e^{-}$') ) +
        annotate("text", x=2.2, y=3.5e-3, label= TeX('$\\pi$')) +
        annotate("text", x=1.8, y=1.7e-2, label= TeX('$K$')) +
        annotate("text", x=2,   y=2e-1, label= TeX('$p$')) +

        geom_hline(data = gasdf,
                   mapping = aes(yintercept = yint, linetype = grp)) +
        guides(linetype=guide_legend(title="Gas")) +

        theme_bw()

ggsave("cer_gas_thresholds.pdf", pCer, width=7, height=3.5)
