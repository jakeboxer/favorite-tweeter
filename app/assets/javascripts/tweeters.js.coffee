$ ->
  $statsContainer = $(".js-calculating")

  if $statsContainer.length > 0
    waitAndPollTweeterStats($statsContainer.attr("data-screen-name"), $statsContainer)

waitAndPollTweeterStats = (tweeter, $container) ->
  window.setTimeout((-> pollTweeterStats(tweeter, $container)), 2000)

pollTweeterStats = (tweeter, $container) ->
  $.ajax("/tweeters/#{tweeter}/stats", dataType: "html").done (data, textStatus, jqXHR) ->
    if jqXHR.status is 202
      # 202 means "Accepted but not ready for processing", so poll again soon.
      waitAndPollTweeterStats(tweeter, $container)
    else
      # It's 200, so replace container contents with data.
      $container.html(data)

