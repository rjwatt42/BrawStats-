#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

debug<-FALSE
debugExitOnly<-FALSE
debugMainOnly<-TRUE
debugMem<-FALSE 
debugShiny<-FALSE

debugNow<-Sys.time()
debugNowLocation<<-"Start"
debugStart<-Sys.time()
if(debugMem)  memUse<-sum(gc()[,2])

debugPrint<-function(s) {
  if (debugMainOnly && substr(s,1,1)==" ") return()
  elapsedStart<-Sys.time()-debugStart
  
  z<-regexpr("[ ]*[a-zA-Z0-9]*",s)
  caller<-regmatches(s,z)
  
  if (grepl("exit",s)==1) {
    use<-which(debugNowLocation==caller)
    use<-use[length(use)]
    elapsedLocal<-as.numeric(difftime(Sys.time(),debugNow[use],units="secs"))
    str<-paste(format(elapsedStart),s," (",format(elapsedLocal),") ")
    if(debugMem)  str<-paste(str,"  ",format(sum(gc()[,2])-memUse[use]))
    print(str)
  } else {
    if (!debugExitOnly || s=="Opens")
      print(paste(format(elapsedStart),s))
    debugNow<<-c(debugNow,Sys.time())
    debugNowLocation<<-c(debugNowLocation,caller)
    if(debugMem)  memUse<<-c(memUse,sum(gc()[,2]))
  }
}


#because numericInput with "0." returns NA
checkNumber<-function(a,b=a,c=0) {
  if (!isempty(a)) {
    if (is.na(a) || is.null(a)) {a<-c}
  }
  a
}

if (debug) debugPrint("Opens")

source("joinPlots.R")
source("plotStatistic.R")
source("plotES.R")
source("plotReport.R")

source("drawVariable.R")
source("drawPopulation.R")
source("drawPrediction.R")

source("drawSample.R")
source("drawDescription.R")
source("drawInference.R")
source("drawMeta.R")
source("drawExplore.R")
source("drawPossible.R")

source("sampleMake.R")
source("sampleAnalyse.R")
source("sampleLikelihood.R")
source("samplePower.R")
source("sampleRead.R")
source("sampleCheck.R")
source("f_johnson_M.R")
source("f_johnson_z2y.R")
source("f_johnson_pdf.R")
source("sampleShortCut.R")

source("possibleAnalyse.R")

source("graphSample.R")
source("graphDescription.R")
source("graphInference.R")

source("reportSample.R")
source("reportDescription.R")
source("reportInference.R")
source("reportExpected.R")
source("reportMetaAnalysis.R")
source("reportExplore.R")
source("reportPossible.R")

source("runMetaAnalysis.R")
source("runExplore.R")
source("runPossible.R")
source("runBatchFiles.R")

source("wsRead.R")
source("typeCombinations.R")

source("drawInspect.R")
source("isSignificant.R")

source("varUtilities.R")
source("getLogisticR.R")

graphicSource="Main"

####################################

shinyServer(function(input, output, session) {
  if (debug) debugPrint("Start")
  # source("runDebug.R")
  
  observeEvent(input$dimension, {
  if (debugShiny)  print("dimension")
  window_height <- input$dimension[1]
  window_width <- input$dimension[2]
  # 
  # print(c(window_width,window_height))
  }
  )
  
####################################
# BASIC SET UP that cannot be done inside ui.R  
  shinyjs::hideElement(id= "EvidenceHypothesisApply")
  shinyjs::hideElement(id= "Using")
  shinyjs::hideElement(id="EvidenceExpectedStop")
  updateSelectInput(session, "IVchoice", choices = variables$name, selected = variables$name[1])
  updateSelectInput(session, "IV2choice", choices = c("none",variables$name), selected = "none")
  updateSelectInput(session, "DVchoice", choices = variables$name, selected = variables$name[3])
  
  if (!is_local) {
  hideElement("extraRep1")
  hideElement("extraRep2")
  hideElement("extraRep3")
  }
  
####################################
  if (debug) debugPrint("ServerKeys")
  
  source("extras.R")
  source("serverKeys.R",local=TRUE)
  
  observeEvent(input$LoadExtras, {
    if (debugShiny)  print("extras")
    loadExtras(session,input,input$LoadExtras)
               })
  
  observeEvent(input$shortHandGain, {
    if (debugShiny)  print("shorthandgain")
    shortHandGain<<-input$shortHandGain
  }
  )
  observeEvent(input$shortHand, {
    if (debugShiny)  print("shorthand")
    shortHand<<-input$shortHand
  }
  )
  
  observeEvent(c(input$LargeGraphs,input$WhiteGraphs), {
    if (debugShiny)  print("whitegraphs")
    currentGraph<-input$Graphs
    currentReport<-input$Reports
    
    if (input$WhiteGraphs) {
      maincolours<<-maincoloursBW
      graphcolours<<-graphcoloursBW
      updateThemes()
      # mainTheme<<-theme(panel.background = element_rect(fill=graphcolours$graphBack, colour="black"),
      #                   panel.grid.major = element_line(linetype="blank"),panel.grid.minor = element_line(linetype="blank"),
      #                   plot.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC))
      # plotBlankTheme<<-theme(panel.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC),
      #                        panel.grid.major = element_line(linetype="blank"),panel.grid.minor = element_line(linetype="blank"),
      #                        plot.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC),
      #                        axis.title=element_text(size=16,face="bold")
      # )
    } else {
      maincolours<<-maincoloursBL
      graphcolours<<-graphcoloursBL
      updateThemes()
      # mainTheme<<-theme(panel.background = element_rect(fill=graphcolours$graphBack, colour="black"),
      #                   panel.grid.major = element_line(linetype="blank"),panel.grid.minor = element_line(linetype="blank"),
      #                   plot.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC))
      # plotBlankTheme<<-theme(panel.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC),
      #                        panel.grid.major = element_line(linetype="blank"),panel.grid.minor = element_line(linetype="blank"),
      #                        plot.background = element_rect(fill=graphcolours$graphC, colour=graphcolours$graphC),
      #                        axis.title=element_text(size=16,face="bold")
      # )
    }
    
    if (input$LargeGraphs) {
      plotTheme<<-mainTheme+LGplotTheme
      labelSize<<-6*fontScale
      char3D<<-2
      
      output$mainColumns <- renderUI({
        tagList(
          column(width=12,
                 style = paste("margin-left: 4px;padding-left: 0px;margin-right: -10px;padding-right: -10px;"),
                 MainGraphs1(),
                 MainReports1()
          )
        )
      }
      )
      hideElement("HypothesisPopulation")
    } else {
      plotTheme<<-mainTheme+SMplotTheme
      diagramTheme<<-mainTheme+SMplotTheme+theme(plot.margin=margin(0.15,0.8,0,0.25,"cm"))
      labelSize<<-4*fontScale
      char3D<<-1.3
      
      output$mainColumns <- renderUI({
        tagList(
          column(width=4, id="HypothesisPopulation",
                 style = paste("margin-left: 4px;padding-left: 0px;margin-right: -10px;padding-right: -10px;"),
                 HypothesisDiagram(),
                 PopulationDiagram()
          ),
          column(width=8,
                 style = paste("margin-left: 4px;padding-left: 0px;margin-right: -10px;padding-right: -10px;"),
                 MainGraphs(),
                 MainReports()
          )
        )
      }
      )
      showElement("HypothesisPopulation")
    }
    updateTabsetPanel(session, "Graphs",selected = currentGraph)
    updateTabsetPanel(session, "Reports",selected = currentReport)
  })
  
  observeEvent(input$RZ,{
    if (debugShiny)  print("rz")
    oldpar1<-input$EvidenceExpected_par1
    oldpar2<-input$EvidenceExpected_par2
    RZ<<-input$RZ
    switch (RZ,
            "r"={
              names(inferTypeChoicesExtra$Basic)[1]<<-"r"
              names(inferTypeChoicesExtra$World)[1]<<-"rp"
              names(inferTypeChoicesExtra$World)[4]<<-"ra"
              names(inferTypeChoicesExtra$Replication)[1]<<-"r1"
              oldpar1<-gsub("z","r",oldpar1)
              oldpar2<-gsub("z","r",oldpar2)
            },
            "z"={
              names(inferTypeChoicesExtra$Basic)[1]<<-"z"
              names(inferTypeChoicesExtra$World)[1]<<-"zp"
              names(inferTypeChoicesExtra$World)[4]<<-"za"
              names(inferTypeChoicesExtra$Replication)[1]<<-"z1"
              oldpar1<-gsub("r","z",oldpar1)
              oldpar2<-gsub("r","z",oldpar2)
            })
    updateSelectInput(session,"EvidenceExpected_par1",choices=inferTypeChoicesExtra)
    updateSelectInput(session,"EvidenceExpected_par2",choices=inferTypeChoicesExtra)
  })
  
  observeEvent(input$EvidenceExpected_type,{
    if (debugShiny)  print("EvidenceExpected_type")
    if (input$EvidenceExpected_type=="Basic") {
      updateSelectInput(session,"EvidenceExpected_par1",selected=RZ)
      updateSelectInput(session,"EvidenceExpected_par2",selected="p")
    }
  })
  
  
  if (is_local) {
    updateCheckboxInput(session,"LoadExtras",value=TRUE)
  }
  
  
####################################
# other housekeeping
  if (debug) debugPrint("Housekeeping")
  observeEvent(input$allScatter,{
    if (debugShiny) print("Housekeeping")
    allScatter<<-input$allScatter
  }
  )

  observeEvent(input$Explore_VtypeH, {
    if (debugShiny) print("Explore_VtypeH")
    if (input$Explore_VtypeH=="levels") {
        updateSelectInput(session,"Explore_typeH",selected="DV")
      }
  }
  )
  
  observeEvent(input$sN, {
    if (debugShiny) print("sN")
    
    before<-paste0("<div style='",localStyle,"'>")
    after<-"</div>"
    n<-input$sN
    if (!is.null(n) && !is.na(n)) {
      if (n<1 && n>0) {
        html("sNLabel",paste0(before,"Sample Power:",after))
      } else {
        html("sNLabel",paste0(before,"Sample Size:",after))
      }
    }
  }
  )
  
  observeEvent(input$Hypothesis,{
    if (debugShiny) print("Hypothesis")
    if (input$Hypothesis=="World") {
      updateTabsetPanel(session,"HypothesisDiagram",selected = "World")
      updateTabsetPanel(session,"Theory",selected="Prediction")
    }
  })
  
  observeEvent(input$Evidence,{
    if (debugShiny) print("Evidence")
    if (input$Evidence=="Expected") {
      updateTabsetPanel(session,"Graphs",selected = "Expected")
    }
    if (input$Evidence=="MetaAnalysis") {
      updateTabsetPanel(session,"Graphs",selected = "MetaAnalysis")
    }
  })
  
  observeEvent(input$world_distr, {
    if (debugShiny) print("world_distr")
    if (input$world_distr!="Single" && input$world_distr_k==0) {
      updateNumericInput(session,"world_distr_k",value=0.2)
    }
    if (is.element(input$world_distr,c("Single","Double","Uniform"))) {
      updateSelectInput(session,"world_distr_rz",choices=c("r","z"),selected=RZ)
    } else {
      updateSelectInput(session,"world_distr_rz",choices=c("z"),selected="z")
    }
  }
  )
  
  observeEvent(input$STMethod, {
    if (debugShiny) print("STMethod")
    STMethod<<-input$STMethod
    switch (STMethod,
            "NHST"={
              updateNumericInput(session,"alpha",value=alphaSig)
              shinyjs::hideElement("evidencePrior")
              shinyjs::hideElement("STPrior")
              shinyjs::hideElement("evidenceLLR1")
              shinyjs::hideElement("evidenceLLR2")
              shinyjs::hideElement("llr1")
              shinyjs::hideElement("llr2")
            },
            "sLLR"={
              shinyjs::hideElement("evidencePrior")
              shinyjs::hideElement("STPrior")
              shinyjs::showElement("evidenceLLR1")
              shinyjs::showElement("evidenceLLR2")
              shinyjs::showElement("llr1")
              shinyjs::showElement("llr2")
              },
            "dLLR"={
              shinyjs::showElement("evidencePrior")
              shinyjs::showElement("STPrior")
              shinyjs::hideElement("evidenceLLR1")
              shinyjs::hideElement("evidenceLLR2")
              shinyjs::hideElement("llr1")
              shinyjs::hideElement("llr2")
            }
    )
  })
  observeEvent(input$alpha, {
    if (debugShiny) print("alpha")
    alphaSig<<-input$alpha
    alphaLLR<<-0.5*qnorm(1-alphaSig/2)^2
  })
  
  observeEvent(input$evidenceInteractionOnly,{
    if (debugShiny) print("evidenceInteractionOnly")
    showInteractionOnly<<-input$evidenceInteractionOnly
  })
  
  observeEvent(input$pScale,{
    if (debugShiny) print("pScale")
    pPlotScale<<-input$pScale
  })
  
  observeEvent(input$wScale,{
    if (debugShiny) print("wScale")
    wPlotScale<<-input$wScale
  })
  
  observeEvent(input$nScale,{
    if (debugShiny) print("nScale")
    nPlotScale<<-input$nScale
  })
  
  observeEvent(input$EvidenceExpected_type,{
    if (debugShiny) print("EvidenceExpected_type")
    if (input$EvidenceExpected_type=="NHSTErrors") {
      shinyjs::hideElement("EvidenceExpected_par1")
      shinyjs::hideElement("EvidenceExpected_par2")
    } else {
      shinyjs::showElement("EvidenceExpected_par1")
      shinyjs::showElement("EvidenceExpected_par2")
    }
  })
  
####################################
# generic warning dialogue
  
  hmm<-function (cause, top="Careful now!") {
    showModal(
      modalDialog(style = paste("background: ",subpanelcolours$hypothesisC,";",
                                "modal {background-color: ",subpanelcolours$hypothesisC,";}"),
                  title=top,
                  size="s",
                  cause,
                  
                  footer = tagList( 
                    actionButton("MVproceed", "OK")
                  )
      )
    )
  }
  
  observeEvent(input$MVproceed, {
    if (debugShiny) print("MVproceed")
    removeModal()
  })
  
####################################
# QUICK HYPOTHESES
  
  if (debug) debugPrint("QuickHypotheses")
  
  observeEvent(input$Hypchoice,{
    if (debugShiny) print("Hypchoice")
    result<-getTypecombination(input$Hypchoice)
    validSample<<-FALSE
    
    setIVanyway(result$IV)
    setIV2anyway(result$IV2)
    setDVanyway(result$DV)
    
    updateSelectInput(session,"sIV1Use",selected=result$IV$deploy)
    updateSelectInput(session,"sIV2Use",selected=result$IV2$deploy)

    # 3 variable hypotheses look after themselves
    #
    if (!is.null(IV2)) {
      editVar$data<<-editVar$data+1
    }    
    
  })
  
  observeEvent(input$Effectchoice,{
    if (debugShiny) print("Effectchoice")
    switch (input$Effectchoice,
            "e0"={
              updateNumericInput(session,"rIV",value=0)    
              updateNumericInput(session,"rIV2",value=0)    
              updateNumericInput(session,"rIVIV2",value=0)    
              updateNumericInput(session,"rIVIV2DV",value=0)    
            },
            "e1"={
              updateNumericInput(session,"rIV",value=0.3)    
              updateNumericInput(session,"rIV2",value=-0.3)    
              updateNumericInput(session,"rIVIV2",value=0.0)    
              updateNumericInput(session,"rIVIV2DV",value=0.5)    
            },
            "e2"={
              updateNumericInput(session,"rIV",value=0.2)    
              updateNumericInput(session,"rIV2",value=0.4)    
              updateNumericInput(session,"rIVIV2",value=-0.8)    
              updateNumericInput(session,"rIVIV2DV",value=0.0)    
            }
    )
    
  })
  
source("sourceUpdateData.R",local=TRUE)
  
####################################
# VARIABLES  
  if (debug) debugPrint("Variables")

    # make basic variables    
  IV<-variables[1,]
  IV2<-variables[2,]
  DV<-variables[3,]
  MV<-IV

  source("sourceInspectVariables.R",local=TRUE)
  source("sourceVariables.R",local=TRUE)
  
  source("sourceUpdateVariables.R",local=TRUE)
  source("sourceUpdateSystem.R",local=TRUE)
  
  source("sourceSystemDiagrams.R",local=TRUE)
  
  source("sourceSingle.R",local=TRUE)
  source("sourceMetaAnalysis.R",local=TRUE)
  source("sourceExpected.R",local=TRUE)
  
  source("sourceExplore.R",local=TRUE)
  
  source("sourcePossible.R",local=TRUE)
  source("sourceFiles.R",local=TRUE)
  # end of everything        
  
  if (debug) debugPrint("Opens - exit")
})

