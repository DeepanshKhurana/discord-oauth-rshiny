box::use(
  shiny[...],
  httr[...],
  glue[...]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  textOutput(ns("user_details"))
}

#' @export
server <- function(id, discord_constants, discord_result_code) {
  moduleServer(id, function(input, output, session) {

    output$user_details <- renderPrint({

      params <- list(
        code = discord_result_code,
        client_id = discord_constants$client_id,
        client_secret = discord_constants$client_secret,
        grant_type = discord_constants$grant_type,
        redirect_uri = discord_constants$redirect_uri,
        scope = discord_constants$scope
      )

      config <- config(ssl_verifypeer = 0, ssl_verifyhost = 0)

      login_response <- POST(
        url = discord_constants$api_url,
        body = params,
        encode = "form",
        config = config
      )

      access_token <- content(login_response)$access_token

      if (isTruthy(access_token)) {

        user_response <- GET(
          url = discord_constants$users_url,
          config = config,
          add_headers("Content-Type" = "application/x-www-form-urlencoded",
                      "Accept" = "application/json",
                      "Authorization" = glue("Bearer {access_token}"))
        )

        content(user_response)

      } else {

        "Login failed..."
      }

      })

  })
}
