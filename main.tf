terraform {
  required_providers {
    spotify = {
      version = "~> 0.1.5"
      source  = "conradludgate/spotify"
    }
  }
}

variable "spotify_api_key" {
  type = string
}

provider "spotify" {
  api_key = var.spotify_api_key
}

resource "spotify_playlist" "playlist" {
  name        = "Hot IaC Summer"
  description = "This playlist was created by Terraform"
  public      = true

  tracks = local.tracks
}

# individual tracks that slap
data "spotify_track" "lost_in_thought" {
  url = "https://open.spotify.com/track/0BSJ1iQEmGibLCPMHGtdo7?si=850b1224967f4ced"
}

# albums
data "spotify_search_track" "saw" {
  artists = ["Aphex Twin"]
  album = "Selected Ambient Works 85-92"
}

data "spotify_search_track" "boc" {
  artists = ["Boards of Canada"]
  album = "The Campfire Headphase"
}


# randomise our selection
resource "random_shuffle" "random_electronic" {
  input = [
    for i, v in 
    concat(
      data.spotify_search_track.saw.tracks,
      data.spotify_search_track.boc.tracks
    )
    : v.id
  ]
  result_count = 10
}

locals {
  tracks = concat(
    random_shuffle.random_electronic.result,
    [data.spotify_track.lost_in_thought.id]
  )
}

output "all_tracks" {
  value = local.tracks
}
