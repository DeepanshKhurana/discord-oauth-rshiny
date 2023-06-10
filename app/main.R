box::use(
  shiny[...],
  shiny.router[router_ui, router_server, route, change_page],
  yaml[read_yaml],
  utils[browseURL]
)

box::use(
  app/view/mod_process_oauth
)

options(shiny.port = 8080)

# Reading constants

constants <- read_yaml("constants.yml")
discord <- constants$app$discord

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    router_ui(
      route("/",
            div(
              tags$a(href = discord$login_url,
                "Login with Discord",
                icon("discord"))
              )
            ),
      route(
        "process",
        mod_process_oauth$ui(ns("process_login"))
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

    router_server("/")

    # Set Reactive Values

    state <- reactiveValues()
    state$code <- NULL

    # Loading Server

    observe({
      state$code <- reactiveValuesToList(session$clientData)$url_search
    })

    observeEvent(state$code, {
      if (isTruthy(state$code)) {
        state$code <- gsub("\\?code=", replacement = "", state$code)
        mod_process_oauth$server("process_login",
                                 discord_constants = discord,
                                 discord_result_code = state$code)
        change_page("process")
      }
    })

  })
}
