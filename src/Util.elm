module Util exposing (..)

both f (a,b) = (f a, f b)
curry f (a,b) = f a b
noCmd a = (a, Cmd.none)