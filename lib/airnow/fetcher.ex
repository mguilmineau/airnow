# AirNow.Fetcher is inspired and reworked from ExMangaDownloadr
defmodule AirNow.Fetcher do

  @user_agent Application.get_env(:airnow, :user_agent)
  @http_timeout 60_000
  @max_retries 8

	def fetch( url ) do
		case retryable_http_get( url ) do 
			%HTTPoison.Response{ body: body, headers: headers, status_code: 200 } ->
				{ :ok, body |> gunzip( headers ) }
		end
	end

  defp retryable_http_get( url, retries \\ @max_retries )
	
  defp retryable_http_get( url, 0 ), do: raise "Failed to fetch from #{url} after #{@max_retries} retries."
 
	defp retryable_http_get( url, retries ) when retries > 0 do
    try do
      response = HTTPoison.get!( url, http_headers(), http_options() )
      case response do
				# fatal HTTP error from server
        %HTTPoison.Response{ body: _, headers: _, status_code: status } when status > 499 ->
          raise %HTTPoison.Error{ reason: "req_timedout" }
				# follow HTTP redirect
        %HTTPoison.Response{ body: _, headers: headers, status_code: status} when status > 300 and status < 400 ->
          retryable_http_get( List.keyfind( headers, "Location", 0 ) |> elem(1), retries )
				# regular response
        %HTTPoison.Response{ body: _, headers: _, status_code: _ } ->
          response
				# timeout or other local library error
        %HTTPoison.Error{} ->
            :timer.sleep( sleep_time( retries ) )
            retryable_http_get( url, retries - 1 )
      end
    rescue
      _ in HTTPoison.Error ->
				# wait exponentially longer at each retry attempt
	      :timer.sleep( sleep_time( retries ) )
	      retryable_http_get( url, retries - 1 )
    end
  end

	defp sleep_time( retries ) do
		1 + :math.pow( 2, @max_retries - retries )
	end
	
	defp http_headers do
    [ { "User-Agent",				@user_agent },
			{ "Accept-encoding",	"gzip" },
			{ "Connection",				"keep-alive" } ]
  end

	defp http_options do
    [ timeout: @http_timeout ]
  end

	defp gunzip( body, headers ) do
		if Enum.member?( headers, { "Content-Encoding", "gzip" } ) do
			:zlib.gunzip(body)
		else
			body
		end
	end

end