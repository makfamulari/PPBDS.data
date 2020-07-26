#' @title Tutorial submission functions
#'
#' @description
#' The following function has modified from Colin
#' Rundel's learnrhash package, available at
#' https://github.com/rundel/learnrhash. Many thanks to Professor Rundel, who
#' has developed a fantastic tool for courses that teach R and use the learnr
#' package.
#'
#' This note is also modified from Professor Rundel's description: Note that when
#' including these functions in a learnr Rmd document it is necessary that the
#' server function, `submission_server()`, be included in an R chunk where
#' `context="server"`. Conversely, any of the ui functions, `*_ui()`, must *not*
#' be included in an R chunk with a `context`.
#'
#' @rdname submission_functions
#' @export
submission_server <- function() {
  p = parent.frame()
  check_server_context(p)

  # Evaluate in parent frame to get input, output, and session
  local({
    encoded_txt = shiny::eventReactive(
      input$hash_generate,
      {
        objs = learnr:::get_all_state_objects(session)
        objs = learnr:::submissions_from_state_objects(objs)

        learnrhash::encode_obj(objs)
      }
    )

    output$downloadData <- downloadHandler(
      filename = "tutorial_responses.rds",
      responses <- encoded_txt(),
      content = function(file) {
        write_rds(responses, file)
      }
    )

  }, envir = p)
}

check_server_context <- function(.envir) {
  if (!is_server_context(.envir)) {
    calling_func = deparse(sys.calls()[[sys.nframe()-1]])

    err = paste0(
      "Function `", calling_func,"`",
      " must be called from an Rmd chunk where `context = \"server\"`"
    )

    stop(err, call. = FALSE)
  }
}

is_server_context <- function(.envir) {
  # We are in the server context if there are the follow:
  # * input - input reactive values
  # * output - shiny output
  # * session - shiny session
  #
  # Check context by examining the class of each of these.
  # If any is missing then it will be a NULL which will fail.

  inherits(.envir$input,   "reactivevalues") &
    inherits(.envir$output,  "shinyoutput")    &
    inherits(.envir$session, "ShinySession")
}

#' @rdname submission_functions
#' @export
submission_ui <- shiny::div(
  "When you have completed this tutorial, follow these steps:",
  shiny::tags$br(),
  shiny::tags$ol(
    shiny::tags$li("Click Generate Hash. Nothing will pop up, but this will create an .rds file of your hashed responses."),
    shiny::tags$li("Click the small unlabelled button next to Generate Hash to download the .rds file. A window will pop up asking you where to place the downloaded file."),
    shiny::tags$li("Upload this file to the appropriate Canvas assignment.")),
  shiny::fluidPage(
    shiny::mainPanel(
      shiny::div(id = "form",
                 shiny::actionButton("hash_generate", "Generate Hash"),
                 shiny::downloadButton(outputId = "downloadData", label = "Download"))
    )
  )
)

utils::globalVariables(c("input", "session", "downloadHandler", "write_rds"))