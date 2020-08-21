defmodule GeoConvert do
  use Coord

  def latlng_to_utm(latlng) do
    {out, 0} =
      System.cmd("GeoConvert", [
        # output UTM
        "-u",
        "--input-string",
        latlng_to_binary(latlng)
      ])

    %{"zone" => zone, "hemi" => hemi, "e" => e, "n" => n} =
      Regex.named_captures(
        ~r/^
      (?<zone>\d{1,2})
      (?<hemi>[ns]?)\s
      (?<e>\d+)\s
      (?<n>\d+)\s
      /x,
        out
      )

    zone = String.to_integer(zone)

    hemi =
      case hemi do
        "n" -> :n
        "s" -> :s
        "" -> raise ArgumentError, "Does not support UPS (polar coordinates)"
      end

    e = String.to_integer(e)
    n = String.to_integer(n)

    %UTM{zone: zone, hemi: hemi, e: e, n: n, datum: Datum.wgs84()}
  end

  # By default elixir would output floats in scientific notation, which GeoConvert misparses
  defp latlng_to_binary(%LatLng{lat: lat, lng: lng}),
    do: "#{float_to_binary(lat)} #{float_to_binary(lng)}"

  defp float_to_binary(float),
    do: :erlang.float_to_binary(float, [:compact, {:decimals, 20}])
end
