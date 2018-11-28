defmodule AirNow.Downloader do
	use GenServer

	@ets_sha :sha256
	@sha256_current :sha256_current
	@sha256_forecast :sha256_forecast
	@sha_keys [@sha256_current, @sha256_forecast]

	#
	# Client API
	#

	@doc "Start a Downloader process"
  def start_link( state ), do: GenServer.start_link( __MODULE__, state, name: __MODULE__ )

	@doc "Execute a Downloader process"
	def download_images( data, zip, directory ), do: GenServer.call( __MODULE__,
		{ :download_images, data: data, zip: zip, directory: directory }, 60_000 )

	#
  # Server Callbacks
	#

	def init( state ) do
		:ets.new( @ets_sha, [:named_table, :public] )
		:ets.insert( @ets_sha, { @sha256_current, nil } )
		:ets.insert( @ets_sha, { @sha256_forecast, nil } )
		{ :ok, state }
	end

	@doc false
	# synchronous calls	
  def handle_call( { :download_images, data: data, zip: zip, directory: directory }, _from, state ) do
		data = process( data, zip, directory )
    { :reply, data, state }
  end
	
	#
	# Private
	#
	
	defp process( data, zip, directory ) do
		ltd = local_date_time()
		download_image( data[:current_img], directory, "current_#{zip}_#{ltd}", @sha256_current )
		download_image( data[:forecast_img], directory, "forecast_#{zip}_#{ltd}", @sha256_forecast )
		Map.merge( data, %{
			ltd: ltd
			} )
	end
	
	defp download_image( from_url, _to_directory, _to_filename, _sha_key ) when from_url == nil, do: nil
	
	defp download_image( from_url, to_directory, to_filename, sha_key ) do
		try do
			{ :ok, body } = AirNow.Fetcher.fetch( from_url )
			# https://www.djm.org.uk/posts/cryptographic-hash-functions-elixir-generating-hex-digests-md5-sha1-sha2/
			sha256 = :crypto.hash( :sha256, body ) |> Base.encode16()
			# do not save file if sha256 is same as previous
			unless is_same_image?( sha_key, sha256 ) do
				File.write!( "#{to_directory}/#{to_filename}.jpg", body )
				:ets.insert( @ets_sha, { sha_key, sha256 } )
			end
		rescue
			e in CaseClauseError -> IO.puts "Downloader Error: #{inspect e}"
		end
	end
	
	defp local_date_time do
		{ { y, mo, d }, { h, mi, _s } } = :calendar.local_time
		"#{y}-#{pad(mo)}-#{pad(d)} #{pad(h)}.#{pad(mi)}"
	end
	
	# used for date and time formatting
	defp pad( data, total_digits \\ 2 ) do
		data |> Integer.to_string |> String.pad_leading( total_digits, "0" )
	end

	defp is_same_image?( sha_key, sha256 ) when sha_key in @sha_keys do
		{ _sha_key, previous_sha256 } = :ets.lookup( @ets_sha, sha_key ) |> List.first
		previous_sha256 == sha256
	end
	
	defp is_same_image?( sha_key, _sha256 ), do: raise "Unsupported SHA Key #{sha_key}"
	
end
