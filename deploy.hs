#! /usr/bin/env stack
-- stack --resolver lts-11.8 script --no-nix-pure

{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}

import Turtle hiding (text)
import NeatInterpolation (text)

-- The path of the NixOS build that we're deploying.
newtype NixOS = NixOS Text

-- The address of the server to which we're deploying.
newtype Server = Server Text

main :: IO ()
main = sh $ do
  server <- getServer   -- Read the server address from a file
  path <- build         -- Build NixOS for our server
  upload server path    -- Upload the build to the server
  activate server path  -- Start running the new version

getServer :: Shell Server
getServer = do
  line <- single (input "server-address.txt")
  return (Server (lineToText line))

build :: Shell NixOS
build =
  do
    line <- single (inproc command args empty)
    return (NixOS (lineToText line))
  where
    command = "nix-build"
    args = ["server.nix", "--no-out-link"]

upload :: Server -> NixOS -> Shell ()
upload (Server server) (NixOS path) =
  procs command args empty
  where
    command = "nix-copy-closure"
    args = ["--to", "--use-substitutes", server, path]

activate :: Server -> NixOS -> Shell ()
activate (Server server) (NixOS path) =
  procs command args empty
  where
    command = "ssh"
    args = [server, remoteCommand]
    remoteCommand = [text|
        sudo nix-env --profile $profile --set $path
        sudo $profile/bin/switch-to-configuration switch
      |]
    profile = "/nix/var/nix/profiles/system"
