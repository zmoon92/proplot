#!/bin/bash
#------------------------------------------------------------------------------#
# ***Notes on getting ttf files on Mac****
# /System/Library/Font *OR* /Library/Fonts
# Might be a .dfont, but need .ttf files for matplotlib; use fondu to break down.
# Sometimes fondu created .bdf files, not .ttf; use https://github.com/Tblue/mkttf
# Requires FontForge and PoTrace
# Install new fonts with: "brew cask install font-<name-of-font>" after using
# "brew tap caskroom/fonts" to initialize; these will appear in ~/Library/Fonts.
#------------------------------------------------------------------------------#
# This function sets up any .ttf fonts contained in the <fonts> directory to
# be detected by matplotlib.
# Normally matplotlib just includes a couple open-source .ttf files,
# but this way we can carry many more options across different systems.
# See: https://olgabotvinnik.com/blog/2012-11-15-how-to-set-helvetica-as-the-default-sans-serif-font-in/
#------------------------------------------------------------------------------#
# First add the fonts
# For abspath function see: https://stackoverflow.com/a/21188136/4970632
function abspath() { # abspath that works on mac, Linux, or anything with bash
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}
dir=$(abspath ${0%/*}) # this script's directory
base=$dir/../panplot/fonts
mpldir=$(python -c "import matplotlib; print(matplotlib.matplotlib_fname())")
mfontdir=${mpldir%matplotlibrc}/fonts/ttf
echo $mfontdir
echo "Transfering .ttf to $mfontdir..."
for font in $base/*.ttf; do
  if [ ! -r "$mfontdir/${font##*/}" ]; then
    echo "Adding font \"${font##*/}\"..."
    cp "$font" "$mfontdir/"
  fi
done

# Then delete the cache; echo each one
# For get_cachedir see: https://stackoverflow.com/a/24196416/4970632
shopt -s nullglob # keep empty if does not exist
cachedir=$(python -c "import matplotlib; print(matplotlib.get_cachedir())")
rm $cachedir/font* 2>/dev/null
caches=($cachedir/*.cache) # may be more than one
for cache in ${caches[@]}; do # might be more than one
  if [ ! -d "$cache" ]; then # may be a tex.cache folder
    echo "Deleting cache \"$cache\"..."
    rm "$cache"
  fi
done