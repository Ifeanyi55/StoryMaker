library(shiny)
library(shinyalert)
library(shinythemes)
library(shinycssloaders)
library(reticulate)

options(
  spinner.color = "#eaee09",
  spinner.color.background = "#ffffff",
  spinner.size = 2
)

# Import Gradio client
gr_client <- import("gradio_client")

ui <- fluidPage(
  includeScript("main.js"),
  includeCSS("styles.css"),

  # tags$head(tags$meta(name = "viewport",
  #                    content = "width=device-width, initial-scale=1.0")),
  
  tags$head(tags$style("
    body {
      justify-content: center;
      overflow:hidden;
      align-items: center;
      transform: scale(0.93); /* Scale down to 95% to zoom out*/
      transform-origin: top center; /* Keep the scaling centered horizontally */
    }
  ")),
  
  theme = shinytheme("darkly"),
  title = "Story Maker",
  
  sidebarLayout(
    sidebarPanel = "",
    
    mainPanel(
      align = "center",
      width = 12,
      h2(strong("Story Maker"), style = "color:#eaee09;"),

     tags$a(href = "https://www.github.com/Ifeanyi55",
          target = "_blank",
          style = "text-decoration:none;margin-top:-90px;margin-right:240px;",
          actionButton("github",
          strong("GitHub"),
          icon = icon("github",lib = "font-awesome"),
          style = "margin-top:-90px;margin-right:240px;")),

      actionButton("hint", 
                  strong("Hint"), 
                  icon = icon("lightbulb"),
                  style = "margin-left:-1500px;margin-top:-90px;"),
      
      fileInput(
        "image_upload",
        accept = c("image/jpeg", "image/png"),
        label = NULL,
        buttonLabel = strong("Select Image",style = "color:#eaee09;"),
        placeholder = "JPEG and PNG"
      ),
      
      fluidRow(
        column(
          6,
          div(
            imageOutput(outputId = "image"),
            style = "border-style:solid;
                     border-radius:15px;
                     border-color:#eaee09;
                     border-width:13px;
                     width:100%;
                     height:100%;"
          )
        ),
        
        column(
          6,
          div(
            id = "text-holder",
            withSpinner(textOutput("text"), type = 2),
            style = "position:absolute;
                     border-style:solid;
                     border-radius:15px;
                     border-color:#eaee09;
                     border-width:13px;
                     width:47%;
                     font-size:18px;
                     overflow:auto;
                     padding:10px;
                     text-align:justify;
                     position:fixed;
                     height:64%;"
          )
        )
      ),
      
      br(),
      
      actionButton("create", strong("Create Story"), icon = icon("book"))
      
    )
  )
)

server <- function(input, output, session) {

  file_upload_1 <- reactive({
    inFile <- input$image_upload
    if (is.null(inFile)) return(NULL)
    
    img <- magick::image_read(path = inFile$datapath)
    img_resized <- magick::image_scale(img, "627.5x400")
    temp_file <- tempfile(fileext = ".png")
    magick::image_write(img, path = temp_file)
    
    list(
      src = temp_file,
      contentType = "image/png",
      alt = "Uploaded Image",
      width = 627.5,
      height = 400
    )
  })

  # Read uploaded image with Gradio's handle_file() function  
  file_upload_2 <- reactive({
    inFile <- input$image_upload
    if (is.null(inFile)) return(NULL)
    
    img <- gr_client$handle_file(inFile$datapath)
    return(img)
  })
  

  output$image <- renderImage({
    req(file_upload_1())
    file_upload_1()
  }, deleteFile = TRUE)
  
  client <- reactive({
    gr_client$Client(
      src = "Ifeanyi/Image-To-Story",
      hf_token = "your Hugging Face token",
      verbose = FALSE
    )
  })
  
  run_prediction <- eventReactive(input$create, {
    req(file_upload_2())
    client()$predict(
      api_name = "/predict",
      image = file_upload_2()
    )
  }) 
  
  output$text <- renderText({
    tryCatch(
      {
        run_prediction()
      },
      error = function(error){
        message(NULL)
      }
    )
  })

  observeEvent(input$hint,{

    shinyalert(
      title = "Hint",
      text = "Upload an image and use AI to create a short story from that image.\n
              Overwrite an image by simply uploading a new one.",
      closeOnEsc = T,
      confirmButtonCol = "#eaee09",
      closeOnClickOutside = T,
      confirmButtonText = "Got it!",
      className = "modal",
      timer = 10000,
      imageUrl = "https://cdn.pixabay.com/photo/2016/04/09/16/09/light-bulb-1318337_1280.png"
  )
  })

  
}



# Run the application 
shinyApp(ui = ui, server = server)
